//
//  Ref.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/17.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let REF_USER = "users"
let STORAGE_PROFILE = "profile"
let STORAGE_URL = "gs://tiktoktutorial-e88f2.appspot.com"
let EMAIL = "email"
let UID = "uid"
let NICKNAME = "nickname"
let PROFILE_IMAGE_URL = "profileImageUrl"
let STATUS = "status"

final class Ref {
    // Realtime Database 레퍼런스
    let databaseRoot = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    // Firebase Storage 레퍼런스
    let storageRoot = Storage.storage().reference(forURL: STORAGE_URL)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
}
