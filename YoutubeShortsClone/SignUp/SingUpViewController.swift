//
//  SingUpViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD

final class SingUpViewController: UIViewController {
    
    var image: UIImage? = nil
    
    private lazy var avatarView = AvatarView()
    private lazy var emailInput = FormInput(formInputType: .email)
    private lazy var passwordInput = FormInput(formInputType: .password)
    private lazy var nicknameInput = FormInput(formInputType: .nickname)
    private lazy var signupButton  = SubmitButton(type: .signup, isEnabled: true)
    
    private lazy var inputStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailInput, passwordInput, nicknameInput])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16.0
        
        return stack
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarView, inputStack, signupButton])
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
extension SingUpViewController {
    private func setupNavigation() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
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
        avatarView.delegate = self
        signupButton.delegate = self
    }
    @objc func presentPicker() {
        var config: PHPickerConfiguration = PHPickerConfiguration()
        config.filter = PHPickerFilter.images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    private func validateInputs() {
        guard let email = emailInput.textField.text, !email.isEmpty, let password = passwordInput.textField.text, !password.isEmpty, let nickname = nicknameInput.textField.text, !nickname.isEmpty else {
            ProgressHUD.showError("There is an Empty Field")
            return
        }
    }
    private func signUp(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        ProgressHUD.show("로딩중...")
        Api.User.signUp(email: emailInput.textField.text!, password: passwordInput.textField.text!, nickname: nicknameInput.textField.text!, image: image) {
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMsg in
            onError(errorMsg)
        }
        
    }
}
extension SingUpViewController: AvatarViewDelegate {
    func didTapAvatarView() {
        presentPicker()
    }
}
extension SingUpViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        validateInputs()
        signUp {
            let scene = UIApplication.shared.connectedScenes.first
            if let sceneDelegate: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sceneDelegate.configureInitVC()
            }
        } onError: { errorMsg in
            ProgressHUD.showError(errorMsg)
        }
    }
}
extension SingUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) {[unowned self] image, error in
                if let selectedImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.avatarView.updateImage(selectedImage)
                        self.image = selectedImage
                    }
                }
            }
        }
        dismiss(animated: true)
    }
}
