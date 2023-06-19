//
//  VideoUploadViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit

final class VideoUploadViewController: UIViewController {
        
    private lazy var closeButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "xmark")
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var recordButton = RecordButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDelegates()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
extension VideoUploadViewController {
    private func setupViews() {
        [closeButton, recordButton].forEach {
            view.addSubview($0)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.equalToSuperview().offset(16.0)
            $0.width.height.equalTo(35.0)
        }
        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-64.0)
            $0.width.height.equalTo(85.0)
        }
    }
    private func setupDelegates() {
        
    }
    @objc private func didTapCloseButton() {
        
    }
}
