import SwiftUI

struct ProfileSelectedFilter: View {
    @Binding var selectedIndex: Int
    let filters: [String]
    let counts: [Int]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment:.center, spacing: 0) {
                ForEach(filters.indices, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut) {
                            selectedIndex = index
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("\(filters[index])")
                                .font(.suit(selectedIndex == index ? .bold : .regular, size: 16))
                                .foregroundStyle(selectedIndex == index ? Color.contentBase : Color.contentDisabled)

                            Text("\(counts[index])개")
                                .font(.suit(.medium, size: 12))
                                .foregroundStyle(Color("ContentAdditive"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 16)

            // 밑줄
            Rectangle()
                .fill(Color.borderDividerRegular)
                .frame(height: 1)
                .overlay(
                    GeometryReader { geometry in
                        let tabWidth = geometry.size.width / CGFloat(filters.count)
                        Rectangle()
                            .fill(Color("ContentBase"))
                            .frame(width: tabWidth, height: 2)
                            .offset(x: CGFloat(selectedIndex) * tabWidth)
                            .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                    }
                )
        }
    }
}
