//
//  TabBarItem.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit

enum TabBarItem: CaseIterable {
    case home, shorts, add, subscribe, profile
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .shorts:
            return "Shorts"
        case .add:
            return ""
        case .subscribe:
            return "구독"
        case .profile:
            return "프로필"
        }
    }
    
    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .home:
            return (UIImage(systemName: "house"), UIImage(systemName: "house.fill"))
        case .shorts:
            return (UIImage(systemName: "play.circle"), UIImage(systemName: "play.circle.fill"))
        case .add:
            return (UIImage(systemName: "plus.circle"), UIImage(systemName: "plus.circle.fill"))
        case .subscribe:
            return (UIImage(systemName: "play.rectangle.on.rectangle"), UIImage(systemName: "play.rectangle.on.rectangle.fill"))
        case .profile:
            return (UIImage(systemName: "person"), UIImage(systemName: "person.fill"))
        }
    }

    var viewController: UIViewController {
        return UINavigationController(rootViewController: VideoUploadViewController())
//        switch self {
//        case .home:
//            return UINavigationController(rootViewController: HomeViewController())
//        case .shorts:
//            return UINavigationController(rootViewController: ShortsViewController())
//        case .add:
//            return UINavigationController(rootViewController: AddViewController())
//        case .subscribe:
//            return UINavigationController(rootViewController: SubscribeViewController())
//        case .profile:
//            return UINavigationController(rootViewController: ProfileViewController())
//        }
    }
}
