//
//  SignInViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

final class SignInViewController: UIViewController {
        
    private lazy var emailInput = FormInput(formInputType: .email)
    private lazy var passwordInput = FormInput(formInputType: .password)
    private lazy var signinButton  = SubmitButton(type: .login, isEnabled: true)
    
    private lazy var inputStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailInput, passwordInput])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16.0
        
        return stack
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [inputStack, signinButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16.0
        
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupDelegates()
    }
}
extension SignInViewController {
    private func setupNavigation() {
        navigationItem.title = "Sign-in"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupViews() {
        [vStack].forEach {
            view.addSubview($0)
        }
        vStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.equalToSuperview().offset(16.0)
            $0.trailing.equalToSuperview().offset(-16.0)
        }
        inputStack.snp.makeConstraints {
            $0.leading.equalTo(vStack.snp.leading)
            $0.trailing.equalTo(vStack.snp.trailing)
        }
    }
    private func setupDelegates() {
        signinButton.delegate = self
    }

    private func validateInputs() {
        guard let email = emailInput.textField.text, !email.isEmpty, let password = passwordInput.textField.text, !password.isEmpty else {
            ProgressHUD.showError("There is an Empty Field")
            return
        }
    }
    private func signIn(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        ProgressHUD.show("로딩중...")
        Api.User.signIn(email: emailInput.textField.text!, password: passwordInput.textField.text!) {
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMsg in
            onError(errorMsg)
        }
    }

}

extension SignInViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        view.endEditing(true)
        validateInputs()
        signIn {
            let scene = UIApplication.shared.connectedScenes.first
            if let sceneDelegate: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sceneDelegate.configureInitVC()
            }
        } onError: { errorMsg in
            ProgressHUD.showError(errorMsg)
        }
    }
}
