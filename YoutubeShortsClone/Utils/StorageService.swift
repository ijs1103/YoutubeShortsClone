//
//  StorageService.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/17.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ProgressHUD

final class StorageService {
    static func savePhoto(nickname: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        // Firebase Storage에 이미지 저장
        storageProfileRef.putData(data, metadata: metadata) { storageMetaData, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL { url, error in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.displayName = nickname
                        changeRequest.commitChanges { error in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        }
                    }
                    var dictTemp = dict
                    dictTemp["profileImageUrl"] = metaImageUrl
                    // Realtime Database에 저장
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp) {
                        error, ref in
                        if error == nil {
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    }
                }
            }
            
        }
    }
}
