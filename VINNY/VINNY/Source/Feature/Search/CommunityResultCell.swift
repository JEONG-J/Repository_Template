    // 커뮤니티 결과 셀: 유저 정보를 표시하는 셀
    struct CommunityResultCell: View {
        let user: UserResult

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.name)
                        .font(.suit(.semibold, size: 16))
                        .foregroundColor(.white)
                    Text(user.position)
                        .font(.suit(.regular, size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.backFillRegular)
            .cornerRadius(12)
        }
    }
    