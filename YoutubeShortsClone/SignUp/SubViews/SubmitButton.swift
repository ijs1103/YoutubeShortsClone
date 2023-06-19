//
//  SubmitButton.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/15.
//

import UIKit

enum SubmitButtonType {
    case login, logout, signup
    var buttonTitle: String {
        switch self {
        case .login:
            return "로그인"
        case .logout:
            return "로그아웃"
        case .signup:
            return "가입"
        }
    }
    var buttonBgColor: UIColor {
        switch self {
        case .login, .logout:
            return .black
        case .signup:
            return .systemPurple
        }
    }
}

protocol SubmitButtonDelegate: AnyObject {
    func didTappedSubmitButton(type: SubmitButtonType)
}

final class SubmitButton: UIButton {
    weak var delegate: SubmitButtonDelegate?
    
    let type: SubmitButtonType
    
    init(type: SubmitButtonType, isEnabled: Bool = false) {
        self.type = type
        super.init(frame: .zero)
        self.setTitle(type.buttonTitle, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = type.buttonBgColor
        self.toggleEnabled(isEnabled: isEnabled)
        self.addTarget(self, action: #selector(didTappedSubmitButton), for: .touchUpInside)
        self.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.layer.cornerRadius = 8.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggleEnabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.alpha = isEnabled ? 1.0 : 0.3
    }

    @objc func didTappedSubmitButton() {
        delegate?.didTappedSubmitButton(type: type)
    }
}
