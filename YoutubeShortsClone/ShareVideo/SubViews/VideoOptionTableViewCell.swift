//
//  VideoOptionTableViewCell.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/24.
//

import SnapKit
import UIKit

enum VideoOptionType: CaseIterable {
    case open, location, viewers, remix, comment
    var logoImage: UIImage {
        switch self {
        case .open:
            return UIImage(systemName: "globe.americas")!
        case .location:
            return UIImage(systemName: "mappin.and.ellipse")!
        case .viewers:
            return UIImage(systemName: "person.2")!
        case .remix:
            return UIImage(systemName: "play.rectangle")!
        case .comment:
            return UIImage(systemName: "ellipsis.bubble")!
        }
    }
    var title: String {
        switch self {
        case .open:
            return "공개"
        case .location:
            return "위치"
        case .viewers:
            return "시청자층 선택"
        case .remix:
            return "동영상 및 오디오 리믹스 허용"
        case .comment:
            return "부적절할 수 있는 댓글은 검토를 위해 보류"
        }
    }
    var subTitle: String {
        switch self {
        case .open:
            return "공개 상태"
        case .location:
            return ""
        case .viewers:
            return ""
        case .remix:
            return "Shorts 리믹스"
        case .comment:
            return "댓글"
        }
    }
}

final class VideoOptionTableViewCell: UITableViewCell {
    
    static let identifier = "VideoOptionTableViewCell"
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [subTitleLabel, titleLabel])
        stackView.spacing = 8.0
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var disclosureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .white
        return imageView
    }()
    
    
    func update(_ videoOptionType: VideoOptionType) {
        setupView()
        logoImage.image = videoOptionType.logoImage
        titleLabel.text = videoOptionType.title
        subTitleLabel.text = videoOptionType.subTitle
    }
    
}

extension VideoOptionTableViewCell {
    
    func setupView() {
        backgroundColor = .black
        [ logoImage, disclosureImage, vStack].forEach {
            addSubview($0)
        }
            
        logoImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.height.equalTo(30.0)
        }
        
        disclosureImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16.0)
            $0.width.equalTo(10.0)
            $0.height.equalTo(16.0)
        }
        
        vStack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(logoImage.snp.trailing).inset(-16.0)
            $0.trailing.equalTo(disclosureImage.snp.leading).inset(-16.0)
        }
    }
}
