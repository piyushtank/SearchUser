//
//  User.swift
//  SearchUser
//

import UIKit
import Combine

class SearchUserResult: ObservableObject, Identifiable {
    private(set) var user: User
    
    var displayName: String {
        user.displayName
    }
    
    var userName: String {
        user.displayName
    }
    
    init(user: User) {
        self.user = user
    }
    
    init(user: User, image: UIImage) {
        self.user = user
        self.avatar = .found(image)
    }
    
    @Published var avatar: Avatar = .none
    
    @MainActor
    func fetchAvatarImage(_ storageClosure: (Int, UIImage) -> Void ) async {
        let url = user.avatarURL
        if !url.isEmpty {
            avatar = .fetching(URL(string: url)!)
            do {
                let image = try await fetchUIImage(from: URL(string: url)!)
                if url == user.avatarURL {
                    avatar = .found(image)
                    storageClosure(self.user.id, image)
                }
            } catch {
                avatar = .failed("Couldn't set avatar: \(error.localizedDescription)")
            }
        } else {
            avatar = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Avatar {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
}

struct User: Codable, Identifiable {
    let id: Int
    let displayName: String
    let username: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case username
        case avatarURL = "avatar_url"
    }
}
