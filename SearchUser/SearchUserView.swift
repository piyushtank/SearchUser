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
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .background(.yellow)
                            .foregroundStyle(.tint)
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(10.0)
                        
                        Spacer()
                            .frame(width: 12)
                        
                        Text(user.displayName)
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                        
                        Text(user.username)
                            .font(Font.headline.weight(.light))
                            .lineLimit(1)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Search User")
    }
}
