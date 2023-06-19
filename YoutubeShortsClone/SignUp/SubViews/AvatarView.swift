//
//  AvatarView.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/06.
//

import UIKit
import SnapKit

protocol AvatarViewDelegate: AnyObject {
    func didTapAvatarView()
}

final class AvatarView: UIView {
    weak var delegate: AvatarViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
        setupGesture()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(_ image: UIImage) {
        imageView.image = image
    }
}

extension AvatarView {
    private func setupViews() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.edges.equalToSuperview()
        }
    }
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(didTapAvatarView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func didTapAvatarView() {
        delegate?.didTapAvatarView()
    }
}
