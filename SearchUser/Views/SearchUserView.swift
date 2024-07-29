//
//  SearchUserView.swift
//  SearchUser
//

import SwiftUI

struct SearchUserView: View {
    @ObservedObject var searchUserInfo: SearchUserInfo
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search users...", text: $searchUserInfo.searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                List(searchUserInfo.users) { user in
                    HStack {
                        AsyncImage(url: URL(string: user.avatarURL)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 28, height: 28)
                        .cornerRadius(4.0)
                        .padding(.leading, 16)
                        
                        Spacer()
                            .frame(width: 12)
                        
                        Text(user.displayName)
                            .font(.custom("Lato-Bold", size: 16))
                            .foregroundColor(Color(hex: "1D1C1D"))
                            .lineLimit(1)
                        
                        Spacer()
                            .frame(width:8)
                        
                        Text(user.username)
                            .font(.custom("Lato-Regular", size: 16))
                            .foregroundColor(Color(hex: "616061"))
                            .lineLimit(1)
                    }
                    .background(Color(hex: "FFFFFF"))
                    .padding(.trailing, 16)
                    .listRowInsets(EdgeInsets())
                    .frame(height: 44)
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return 16
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(hex: "FFFFFF"))
            }
            .navigationTitle("Search User")
        }
    }
}
