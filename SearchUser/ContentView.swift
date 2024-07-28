//
//  ContentView.swift
//  SearchUser
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var searchUserInfo: SearchUserInfo
    
    var users = ["user1", "user2", "user3", "user4"]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search users...", text: $searchUserInfo.searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                List(users, id: \.self) { user in
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .background(.yellow)
                            .foregroundStyle(.tint)
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(10.0)
                        
                        Spacer()
                            .frame(width: 12)
                        
                        Text("Display Name")
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                        
                        Text(user)
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

#Preview {
    ContentView()
}
