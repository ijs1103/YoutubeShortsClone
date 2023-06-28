//
//  UtilButtonView.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/20.
//

import UIKit
import SnapKit

enum UtilButtonType: String, CaseIterable {
    case flip, speed, beauty, filters, timer, flash
    var buttonImage: UIImage {
        switch self {
        case .flip:
            return UIImage(systemName: "arrow.triangle.2.circlepath.camera")!
        case .speed:
            return UIImage(systemName: "speedometer")!
        case .beauty:
            return UIImage(systemName: "lasso.and.sparkles")!
        case .filters:
            return UIImage(systemName: "camera.filters")!
        case .timer:
            return UIImage(systemName: "timer")!
        case .flash:
            return UIImage(named: "flash")!
        }
    }
    var buttonTitle: String {
        return self.rawValue.capitalized
    }
}

protocol UtilButtonViewDelegate: AnyObject {
    func didTapUtilButtonView(type: UtilButtonType)
}

final class UtilButtonView: UIView {
    weak var delegate: UtilButtonViewDelegate?
    
    private let type: UtilButtonType
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.tintColor = .white
        return view
    }()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .white
        return label
    }()
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ imageView, label ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6.0
        return stack
    }()
    init(type: UtilButtonType) {
        self.type = type
        super.init(frame: .zero)
        imageView.image = type.buttonImage
        label.text = type.buttonTitle
        setupViews()
        setupGestureRecognizer()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UtilButtonView {
    private func setupViews() {
        addSubview(vStack)
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(35.0)
        }
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUtilButtonView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func didTapUtilButtonView() {
        delegate?.didTapUtilButtonView(type: type)
    }
}
