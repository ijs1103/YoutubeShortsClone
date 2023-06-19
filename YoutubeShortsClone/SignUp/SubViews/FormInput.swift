//
//  FormInput.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/15.
//

import UIKit
import SnapKit

enum FormInputType {
    case email, password, nickname
    
    var placeholder: String {
        switch self {
        case .email:
            return "Enter email"
        case .password:
            return "Enter password"
        case .nickname:
            return "Enter nickname"
        }
    }
}

final class FormInput: UIView {
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 2.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8.0, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    init(formInputType: FormInputType) {
        super.init(frame: .zero)
        setupViews()
        setupDelegates()
        textField.placeholder = formInputType.placeholder
    }
    func updateNickname(_ nickname: String) {
        textField.text = nickname
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension FormInput {
    private func setupViews() {
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    private func setupDelegates() {
        textField.delegate = self
    }
    
}

extension FormInput: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.black.cgColor
        return true
    }
}
