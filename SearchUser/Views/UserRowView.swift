//
//  UserRowView.swift
//  SearchUser
//

import SwiftUI

struct UserRowView: View {
    
    var user: SearchUserResult
    
    var body: some View {
        HStack {
            AvatarView(user: user)
            Spacer().frame(width: Constants.General.smallSpacerWidth)
            DisplayNameView(name: user.displayName)
            Spacer().frame(width: Constants.General.largeSpacerWidth)
            UserNameView(name: user.userName)
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
    @ObservedObject var user: SearchUserResult
    
    var body: some View {
        Group {
            if let image = user.avatar.uiImage {
                Image(uiImage: image)
                    .resizable()
            } else if user.avatar.isFetching {
                ProgressView()
            } else if let _ = user.avatar.failureReason {
                // draw a default image here
                Image(systemName: "person")
            } else {
                Color.gray
            }
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
