//
//  RecordButtonView.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit
import SnapKit

final class RecordButtonView: UIView {
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor  = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        button.layer.cornerRadius = 34.0
        return button
    }()
    init() {
        super.init(frame: .zero)
        setupViews()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension RecordButtonView {
    private func setupViews() {
        layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 0.5).cgColor
        layer.borderWidth = 6
        layer.cornerRadius = 85/2
        addSubview(button)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(68.0)
        }
    }
}
