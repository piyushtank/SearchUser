//
//  StorageManager.swift
//  SearchUser
//

import Foundation
import UIKit

protocol StorageManagerInterface {
    func saveUsers(_ users: [User], for term: String)
    func saveAvatar(_ image: UIImage, for id: Int)
    var users: [String: SearchUserResult] { get }
    var termsAndUserIds: [String: [String]] { get }
}

/**
 * Persisatant storage manager to support offline mode.
 * The storage manager stores following :
 * 1. { "Users" : [{ "id" : <int>, "display_name":  <String>, username: <String> }, ..] }
 * 2. { "Avatars":  [{"id" : "Data (image)"}, ..] }
 * 3. {"Searches: { <string> : [id1, id2...]} }
 */
class StorageManager: StorageManagerInterface {
    
    private static let usersKey = "Users"
    private static let avatarsKey = "Avatars"
    private static let searchesKey = "Searches"
    
    func saveUsers(_ users: [User], for term: String) {
        var theUsers = UserDefaults.standard.object(forKey: StorageManager.usersKey) as? [String:Data] ?? [String:Data]()
        var theSearches = UserDefaults.standard.object(forKey: StorageManager.searchesKey) as? [String:[String]] ?? [String:[String]]()

        var ids = [String]()
        for user in users {
            if let data = try? JSONEncoder().encode(user) {
                theUsers["\(user.id)"] = data
                ids.append("\(user.id)")
            }
        }
        
        theSearches[term] = ids
        UserDefaults.standard.setValue(theUsers, forKey: StorageManager.usersKey)
        UserDefaults.standard.setValue(theSearches, forKey: StorageManager.searchesKey)
    }
    
    func saveAvatar(_ image: UIImage, for id: Int) {
        var theAvatars = UserDefaults.standard.object(forKey: StorageManager.avatarsKey) as? [String:Data] ?? [String:Data]()
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            theAvatars["\(id)"] = data
        }
        UserDefaults.standard.setValue(theAvatars, forKey: StorageManager.avatarsKey)
    }
    
    var users: [String:SearchUserResult] {
        var results = [String:SearchUserResult]()
        let theUsers = UserDefaults.standard.object(forKey: StorageManager.usersKey) as? [String:Data]
        let theAvatars = UserDefaults.standard.object(forKey: StorageManager.avatarsKey) as? [String:Data]
        
        guard let theUsers = theUsers, let theAvatars = theAvatars else { return results }
        
        for (id, value) in theUsers {
            
            if let user = try? JSONDecoder().decode(User.self, from: value),
               let imageData = theAvatars[id] {
                
                if let image = UIImage(data: imageData) {
                    results[id] =  SearchUserResult(user: user, image: image)
                }
            }
        }

        return results
    }
    
    var termsAndUserIds: [String:[String]] {
        return UserDefaults.standard.object(forKey: StorageManager.searchesKey) as? [String:[String]] ?? [String:[String]]()
    }

    
}
