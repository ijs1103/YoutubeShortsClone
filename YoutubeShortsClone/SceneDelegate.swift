//
//  SceneDelegate.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/06.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .black
        configureInitVC()
        window?.makeKeyAndVisible()
    }
    // 로그인 여부에 따라 달라지는 VC
    func configureInitVC() {
        if Auth.auth().currentUser != nil {
            window?.rootViewController = TabBarViewController()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: SignInViewController())
        }
    }
}

