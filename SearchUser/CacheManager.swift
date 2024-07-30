//
//  Cache.swift
//  SearchUser
//

import UIKit

protocol CacheManagerInterface {
    mutating func update(_ users: [User], for term: String)
    mutating func update(_ image: UIImage, for id: Int)
    func searchUserResults(for term: String) -> [SearchUserResult]?
}

// The purpose of CacheManager is to implement timeout/refresh cache
struct CacheManager: CacheManagerInterface {
    
    private var cache: Cache = Cache(users: [String : User](),
                                     images: [String : UIImage](),
                                     termsAndUserIds: [String : [String]]())
    
    mutating func update(_ users: [User], for term:String) {
        cache.update(users, for: term)
    }
    
    mutating func update(_ image: UIImage, for id: Int) {
        cache.update(image, for: id)
    }
    
    func searchUserResults(for term: String) -> [SearchUserResult]? {
        return cache.searchUserResults(for: term)
    }
    
    struct Cache {
        var users: [String: User]
        var images: [String: UIImage]
        var termsAndUserIds: [String: [String]]
        
        mutating func update(_ users: [User], for term:String) {
            var ids = [String]()
            for user in users {
                let theId = "\(user.id)"
                ids.append(theId)
                self.users[theId] = user
            }
            termsAndUserIds[term] = ids
        }
        
        mutating func update(_ image: UIImage, for id: Int) {
            let theId = "\(id)"
            images[theId] = image
        }
        
        func searchUserResults(for term: String) -> [SearchUserResult]? {
            guard let ids = termsAndUserIds[term] else { return nil }
            
            var result = [SearchUserResult]()
            for id in ids {
                if let image = self.images[id], let user = self.users[id] {
                    let u = SearchUserResult(user: user, image: image)
                    result.append(u)
                }
            }
            return result.count > 0 ? result : nil
        }
    }
}
