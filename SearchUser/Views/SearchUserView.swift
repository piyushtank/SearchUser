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
                TextField(Constants.Labels.textFieldPlaceHolder, text: $searchUserInfo.searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)  // Disable auto-capitalization
                    .disableAutocorrection(true) // Disable auto-correction
                
                List(searchUserInfo.users) { user in
                    UserRowView(user: user)
                }
                .listStyle(PlainListStyle())
                .background(Constants.Colors.backgroundColor)
            }
            .navigationTitle(Constants.Labels.navigationTitle)
        }
    }
}


