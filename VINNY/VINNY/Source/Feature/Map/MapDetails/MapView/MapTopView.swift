//
//  MapTopView.swift
//  VINNY
//
//  Created by 홍지우 on 7/15/25.
//

import SwiftUI

struct MapTopView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text("지도")
                    .font(.suit(.bold, size: 24))
                    .foregroundStyle(Color.contentBase)
                
                Spacer()
                
                Button(action: {
                   
                }) {
                    Image("notifications")
                        .resizable()
                        .frame(width: 24, height: 24)
                }            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            HStack(spacing: 8) {
                Image("magnifier")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("빈티지샵, 게시글 검색하기")
                    .font(.suit(.regular, size: 16))
                    .foregroundStyle(Color.contentAssistive)
                
                Spacer()
                
                Image("close")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.backFillRegular)
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.bottom, 8)
        }
        .background(
            Color.backFillStatic
                .clipShape(RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight]))
        )
    }
    
    struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

}

extension Notification.Name {
    static let moveMapToCurrentLocation = Notification.Name("moveMapToCurrentLocation")
    static let setMapTrackingEnabled = Notification.Name("setMapTrackingEnabled")
    static let deselectMarkerAndRefresh = Notification.Name("deselectMarkerAndRefresh")
}

#Preview {
    MapTopView()
}
