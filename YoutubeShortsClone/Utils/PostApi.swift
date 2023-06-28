//
//  PostApi.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/27.
//

import Foundation
import ProgressHUD
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

final class PostApi {
    func shareVideo(encodedVideoURL: URL?, selectedPhoto: UIImage?, textView: UITextView, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        let creationDate = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(1)
        if let encodedVideoURLUnwrapped = encodedVideoURL {
            let videoIdString = "\(NSUUID().uuidString).mp4"
            let storageRef = Ref().storageRoot.child("posts").child(videoIdString)
            let metadata = StorageMetadata()
            print("encodedVideoURLUnwrapped : ", encodedVideoURLUnwrapped)
            storageRef.putFile(from: encodedVideoURLUnwrapped, metadata: metadata) { metadata, error in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                print(2)
                storageRef.downloadURL(completion: { [self] videoUrl, error in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    print(3)
                    guard let videoUrlString = videoUrl?.absoluteString else { return }
                    print(4)
                    uploadThumbnailImageToStorage(selectedPhoto: selectedPhoto) { postImageUrl in
                        let values = ["creationDate": creationDate, "imageUrl": postImageUrl, "videoUrl": videoUrlString, "description": textView.text!, "likes": 0, "views": 0, "commentCount": 0, "uid": uid] as [String: Any]
                        let postId = Ref().databaseRoot.child("Posts").childByAutoId()
                        postId.updateChildValues(values, withCompletionBlock: { error, ref in
                            if error != nil {
                                onError(error!.localizedDescription)
                                return
                            }
                            print(5)
                            guard let postKey = postId.key else { return }
                            print(6)
                            Ref().databaseRoot.child("User-Posts").child(uid).updateChildValues([postKey: 1])
                            onSuccess()
                        })
                    }
                })
            }
        }
    }
    func uploadThumbnailImageToStorage(selectedPhoto: UIImage?, completion: @escaping (String) -> ()) {
        if let thumbnailImage = selectedPhoto, let imageData = thumbnailImage.jpegData(compressionQuality: 0.3) {
            let photoIdString = NSUUID().uuidString
            let storageRef = Ref().storageRoot.child("post_images").child(photoIdString)
            storageRef.putData(imageData, completion: { metadata, error in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { imageUrl, error in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    guard let postImageUrl = imageUrl?.absoluteString else { return }
                    completion(postImageUrl)
                })
            })
        }
    }
}
