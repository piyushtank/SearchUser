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
                    UserRowView(user: user)
                }
                .listStyle(PlainListStyle())
                .background(Constants.Colors.backgroundColor)
            }
            .navigationTitle("Search User")
        }
    }
}


