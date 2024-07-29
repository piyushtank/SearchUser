//
//  UserRowView.swift
//  SearchUser
//

import SwiftUI

struct UserRowView: View {
    
    var user: User
    
    var body: some View {
        HStack {
            AvatarView(urlStr: user.avatarURL)
            Spacer().frame(width: Constants.General.smallSpacerWidth)
            DisplayNameView(name: user.displayName)
            Spacer().frame(width: Constants.General.largeSpacerWidth)
            UserNameView(name: user.username)
        }
        .background(Constants.Colors.backgroundColor)
        .padding(.trailing, Constants.General.padding)
        .listRowInsets(EdgeInsets())
        .frame(height: Constants.General.rowHeight)
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return Constants.General.padding
        }
    }
}

struct AvatarView: View {
    var urlStr: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlStr)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: Constants.General.avatarWidth, height: Constants.General.avatarHeight)
        .cornerRadius(Constants.General.cornerRadius)
        .padding(.leading, Constants.General.padding)
    }
}

struct DisplayNameView: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(Constants.Fonts.latoBold)
            .foregroundColor(Constants.Colors.displayNameColor)
            .lineLimit(1)
    }
}

struct UserNameView: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(Constants.Fonts.latoRegular)
            .foregroundColor(Constants.Colors.userNameColor)
            .lineLimit(1)
    }
}
