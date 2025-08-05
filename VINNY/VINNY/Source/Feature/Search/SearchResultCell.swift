//
//  SearchResultCell.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//

import SwiftUI

// 검색 결과 셀: 샵 정보를 나타내는 셀 구성
// 이 셀은 Shops 모델 데이터를 기반으로 하여 샵 정보를 표시하기 때문에,
// "커뮤니티"와 같은 다른 데이터 타입에는 재사용되지 않을 가능성이 높습니다.
struct SearchResultCell: View {
    let shops: Shops // 외부에서 주입받는 샵 데이터
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // 셀 전체 구성 수직 스택
            VStack(alignment: .leading, spacing: 13) { // 텍스트와 태그 사이 간격 13pt
                
                // 상단 이름 + 주소 + > 아이콘 줄
                HStack(alignment: .center, spacing: 12) {
                    // 프로필 이미지
                    Image("example_profile") // 실제 이미지 에셋명으로 교체
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 12)
                    
                    // 상호명 및 주소
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shops.name) // 상호명
                            .font(.suit(.bold, size: 18)) // 볼드 16pt
                            .foregroundColor(.contentBase) // 기본 텍스트 컬러
                        
                        Text(shops.address) // 주소
                            .font(.suit(.regular, size: 12)) // 일반체 13pt
                            .foregroundColor(.contentAdditive) // 보조 텍스트 컬러
                    }
                    
                    Spacer() // 오른쪽 끝 정렬 유도
                    
                    // 오른쪽 화살표 아이콘 (탭 이동 느낌)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.contentAssistive)
                }
                
                // 하단 태그 리스트 (가변적)
                HStack(spacing: 6) {
                    // 태그가 없으면 기본 태그 3개 출력
                    ForEach(shops.tags.isEmpty ? ["지역", "개쥬얼", "스트릿"] : shops.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.suit(.medium, size: 12)) // 태그 폰트: 중간체 12pt
                            .foregroundColor(.contentAdditive)
                            .padding(.horizontal, 8) // 좌우 패딩
                            .padding(.vertical, 4)   // 상하 패딩
                            .background(Color.backFillStrong) // 배경 색상
                            .clipShape(RoundedRectangle(cornerRadius: 6)) // 태그 pill 형태
                    }
                }
            }
            .padding(.vertical, 16) // 셀 상하 여백

            Divider() // 아래 경계선
                .background(Color.borderDividerRegular)
        }
    }
}
