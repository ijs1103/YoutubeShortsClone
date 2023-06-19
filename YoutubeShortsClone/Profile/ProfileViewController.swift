//
//  ProfileViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/06.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD

final class ProfileViewController: UIViewController {
    
    var image: UIImage? = nil
    
    private lazy var avatarView = AvatarView()
    private lazy var logoutButton  = SubmitButton(type: .logout, isEnabled: true)
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarView, logoutButton])
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
extension ProfileViewController {
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
    }
    private func setupDelegates() {
        avatarView.delegate = self
        logoutButton.delegate = self
    }
    @objc func presentPicker() {
        var config: PHPickerConfiguration = PHPickerConfiguration()
        config.filter = PHPickerFilter.images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    private func logOut() {
        Api.User.logOut()
    }
}
extension ProfileViewController: AvatarViewDelegate {
    func didTapAvatarView() {
        presentPicker()
    }
}
extension ProfileViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        logOut()
    }
}
extension ProfileViewController: PHPickerViewControllerDelegate {
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
