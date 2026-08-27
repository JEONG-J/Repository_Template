#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tools/openapi/generate_endpoint_scaffold.sh \
    --spec <openapi.json> \
    --feature <FeatureName> \
    --path </api/path> \
    --method <get|post|put|patch|delete>

Example:
  tools/openapi/generate_endpoint_scaffold.sh \
    --spec ./openapi.json \
    --feature Home \
    --path /api/v1/notices/recent \
    --method get
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

SPEC=""
FEATURE=""
API_PATH=""
METHOD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spec)
      SPEC="${2:-}"
      shift 2
      ;;
    --feature)
      FEATURE="${2:-}"
      shift 2
      ;;
    --path)
      API_PATH="${2:-}"
      shift 2
      ;;
    --method)
      METHOD="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$SPEC" || -z "$FEATURE" || -z "$API_PATH" || -z "$METHOD" ]]; then
  usage
  exit 1
fi

if [[ ! -f "$SPEC" ]]; then
  echo "Error: OpenAPI spec file not found: $SPEC" >&2
  exit 1
fi

METHOD="$(echo "$METHOD" | tr '[:upper:]' '[:lower:]')"
case "$METHOD" in
  get|post|put|patch|delete) ;;
  *)
    echo "Error: Unsupported method '$METHOD'" >&2
    exit 1
    ;;
esac

require_cmd jq
require_cmd sed

ROOT_DIR="$(git rev-parse --show-toplevel)"
OUT_DIR="$ROOT_DIR/AppName/AppName/Features/$FEATURE/Data/Generated"
TEMPLATE_DIR="$ROOT_DIR/tools/openapi/templates"
mkdir -p "$OUT_DIR"

esc_path=$(printf '%s' "$API_PATH" | sed 's~/~\\/~g')
op=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"] // empty" "$SPEC")
if [[ -z "$op" ]]; then
  echo "Error: Endpoint not found in spec: $METHOD $API_PATH" >&2
  exit 1
fi

operation_id=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"].operationId // empty" "$SPEC")
summary=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"].summary // empty" "$SPEC")
request_ref=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"].requestBody.content[\"application/json\"].schema[\"\$ref\"] // empty" "$SPEC")
response_ref=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"].responses[\"200\"].content[\"application/json\"].schema[\"\$ref\"] // empty" "$SPEC")
tags=$(jq -r ".paths[\"$API_PATH\"][\"$METHOD\"].tags // [] | join(\", \")" "$SPEC")

if [[ -z "$operation_id" ]]; then
  raw="${METHOD}_${API_PATH}"
  operation_id="$(echo "$raw" | sed 's#[{}]##g; s#[^a-zA-Z0-9]# #g' | awk '{for(i=1;i<=NF;i++){if(i==1){printf tolower(substr($i,1,1)) substr($i,2)}else{printf toupper(substr($i,1,1)) tolower(substr($i,2))}}}')"
fi

operation_pascal="$(echo "$operation_id" | sed 's/[^a-zA-Z0-9]/ /g' | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) tolower(substr($i,2));}')"
if [[ -z "$operation_pascal" ]]; then
  echo "Error: failed to compute operation name from '$operation_id'" >&2
  exit 1
fi

request_name="${operation_pascal}RequestDTO"
response_name="${operation_pascal}ResponseDTO"
case_name="$(echo "$operation_id" | sed 's/[^a-zA-Z0-9]//g')"
if [[ -z "$case_name" ]]; then
  case_name="$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')Endpoint"
fi

safe_feature="$(echo "$FEATURE" | sed 's/[^a-zA-Z0-9]//g')"
api_enum="${safe_feature}GeneratedAPI"
repo_protocol="${safe_feature}GeneratedRepositoryProtocol"
repo_impl="${safe_feature}GeneratedRepository"
usecase_protocol="${operation_pascal}UseCaseProtocol"
usecase_impl="${operation_pascal}UseCase"

meta_file="$OUT_DIR/${operation_pascal}.generated.meta.md"
api_file="$OUT_DIR/${operation_pascal}API.generated.swift"
dto_file="$OUT_DIR/${operation_pascal}DTO.generated.swift"
repo_file="$OUT_DIR/${operation_pascal}Repository.generated.swift"
usecase_file="$OUT_DIR/${operation_pascal}UseCase.generated.swift"
test_file="$OUT_DIR/${operation_pascal}UseCaseTests.generated.swift"

cp "$TEMPLATE_DIR/endpoint.meta.template.md" "$meta_file"
cp "$TEMPLATE_DIR/api.template.swift" "$api_file"
cp "$TEMPLATE_DIR/dto.template.swift" "$dto_file"
cp "$TEMPLATE_DIR/repository.template.swift" "$repo_file"
cp "$TEMPLATE_DIR/usecase.template.swift" "$usecase_file"
cp "$TEMPLATE_DIR/usecase_test.template.swift" "$test_file"

escape_replacement() {
  printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

replace() {
  local target="$1"
  sed -i '' \
    -e "s|__FEATURE__|$(escape_replacement "$FEATURE")|g" \
    -e "s|__API_PATH__|$(escape_replacement "$API_PATH")|g" \
    -e "s|__HTTP_METHOD__|$(escape_replacement "$METHOD")|g" \
    -e "s|__SUMMARY__|$(escape_replacement "$summary")|g" \
    -e "s|__TAGS__|$(escape_replacement "$tags")|g" \
    -e "s|__OPERATION_ID__|$(escape_replacement "$operation_id")|g" \
    -e "s|__OPERATION_PASCAL__|$(escape_replacement "$operation_pascal")|g" \
    -e "s|__CASE_NAME__|$(escape_replacement "$case_name")|g" \
    -e "s|__REQUEST_DTO__|$(escape_replacement "$request_name")|g" \
    -e "s|__RESPONSE_DTO__|$(escape_replacement "$response_name")|g" \
    -e "s|__REQUEST_REF__|$(escape_replacement "$request_ref")|g" \
    -e "s|__RESPONSE_REF__|$(escape_replacement "$response_ref")|g" \
    -e "s|__API_ENUM__|$(escape_replacement "$api_enum")|g" \
    -e "s|__REPO_PROTOCOL__|$(escape_replacement "$repo_protocol")|g" \
    -e "s|__REPO_IMPL__|$(escape_replacement "$repo_impl")|g" \
    -e "s|__USECASE_PROTOCOL__|$(escape_replacement "$usecase_protocol")|g" \
    -e "s|__USECASE_IMPL__|$(escape_replacement "$usecase_impl")|g" \
    "$target"
}

replace "$meta_file"
replace "$api_file"
replace "$dto_file"
replace "$repo_file"
replace "$usecase_file"
replace "$test_file"

cat <<EOF
Generated files:
- $meta_file
- $api_file
- $dto_file
- $repo_file
- $usecase_file
- $test_file

Next:
1) Fill DTO fields from schema refs.
2) Wire repository/usecase in DIContainer.
3) Replace generated placeholders and move files to final folders if needed.
EOF
