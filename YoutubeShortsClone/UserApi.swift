//
//  UserApi.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/17.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD

final class UserApi {
    
    func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    func signUp(email: String, password: String, nickname: String, image: UIImage?, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        guard let selectedImage = image, let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            ProgressHUD.showError("Select a profile-image")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                var dict: Dictionary<String, Any> = [ UID: authData.user.uid, EMAIL: authData.user.email, NICKNAME: nickname, PROFILE_IMAGE_URL: "", STATUS: "" ]
                
                let storageProfileRef = Ref().storageSpecificProfile(uid: authData.user.uid)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                StorageService.savePhoto(nickname: nickname, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict) {
                    onSuccess()
                } onError: { errorMsg in
                    onError(errorMsg)
                }
            }
        }
    }
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate: SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sceneDelegate.configureInitVC()
        }
    }
    
}
