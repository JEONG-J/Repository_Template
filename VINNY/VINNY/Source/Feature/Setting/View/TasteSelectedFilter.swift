import SwiftUI

struct TasteSelectionTab: View {
    @Binding var selectedIndex: Int
    let titles: [String]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(titles.indices, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut) {
                            selectedIndex = index
                        }
                    } label: {
                        Text(titles[index])
                            .font(.suit(selectedIndex == index ? .bold : .medium, size: 16))
                            .foregroundStyle(selectedIndex == index ? Color.contentBase : Color.contentDisabled)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 56)
            .padding(.horizontal, 8)

            // 밑줄
            Rectangle()
                .fill(Color.borderDividerRegular)
                .frame(height: 1)
                .overlay(
                    GeometryReader { geometry in
                        let tabWidth = geometry.size.width / CGFloat(titles.count)
                        Rectangle()
                            .fill(Color("ContentBase"))
                            .frame(width: tabWidth, height: 2)
                            .offset(x: CGFloat(selectedIndex) * tabWidth, y: 0)
                    }
                )
        }
    }
}
