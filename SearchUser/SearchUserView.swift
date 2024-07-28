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
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                        
                        Text(user.username)
                            .font(Font.headline.weight(.light))
                            .lineLimit(1)
                    }
                    .background(.white)
                    .padding(.trailing, 16)
                    .listRowInsets(EdgeInsets())
                    .frame(height: 44)
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return 16
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(.white)
        }
        .navigationTitle("Search User")
    }
}
