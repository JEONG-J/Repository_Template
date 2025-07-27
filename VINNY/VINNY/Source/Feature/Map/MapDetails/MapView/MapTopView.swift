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
                
                Image("notifications")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
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
            
            HStack(spacing: 8) {
                Image("star")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.backFillRegular)
                    )
                
                Button(action: {
                    LocationManager.shared.startUpdatingLocation() // 위치 정보 최신화
                    
                    // 현재 위치가 있을면 지도에 전달
                    if let location = LocationManager.shared.currentLocation {
                        NotificationCenter.default.post(name: .moveMapToCurrentLocation, object: location)
                        
                        // 지도 이동 허용 (추적 모드 활성화)
                        NotificationCenter.default.post(name: .setMapTrackingEnabled, object: true)
                    }
                }) {
                    HStack(spacing: 2) {
                        Image("reset")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("현 위치에서 검색")
                            .font(.suit(.medium, size: 14))
                            .foregroundStyle(Color.contentBase)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.backFillRegular)
                    )
                }
                
                Image("icon")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.backFillRegular)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 14)
        }
        .padding(.top, 54)
        .background(Color.backFillStatic)
        .ignoresSafeArea()
    }
}

extension Notification.Name {
    static let moveMapToCurrentLocation = Notification.Name("moveMapToCurrentLocation")
    static let setMapTrackingEnabled = Notification.Name("setMapTrackingEnabled")
}

#Preview {
    MapTopView()
}
