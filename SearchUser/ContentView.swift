//
//  ContentView.swift
//  SearchUser
//

import SwiftUI



struct ContentView: View {
    @State private var searchText: String = "search-user"
    
    var users = ["user1", "user2", "user3", "user4"]

    var body: some View {
        VStack {
            TextField("Search users...", text: $searchText)
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
}

#Preview {
    ContentView()
}
