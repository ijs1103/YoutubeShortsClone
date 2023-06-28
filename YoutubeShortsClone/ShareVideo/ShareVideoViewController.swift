//
//  ShareVideoViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/23.
//

import UIKit
import SnapKit
import AVFoundation
import ProgressHUD

final class ShareVideoViewController: UIViewController {
    
    private let placeHolder = "Shorts 동영상 설명 추가"
    private let originalVideoUrl: URL
    var encodedVideoURL: URL?
    var selectedPhoto: UIImage?
    
    private lazy var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapThumbnailImage))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 18.0, weight: .bold)
        return label
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.text = placeHolder
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 8.0, right: 8.0)
        view.font = .systemFont(ofSize: 20.0)
        view.textColor = .lightGray
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    private lazy var remainCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/100"
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textView, remainCountLabel])
        stackView.spacing = 8.0
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var spacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoOptionTableViewCell.self, forCellReuseIdentifier: VideoOptionTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .black
        return tableView
    }()
    
    private lazy var tempSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("임시 보관함에 저장", for: .normal)
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.layer.cornerRadius = 12.0
        button.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        button.addTarget(self, action: #selector(didTapTempSaveButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Shorts 동영상 업로드", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.layer.cornerRadius = 12.0
        button.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        button.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tempSaveButton, uploadButton])
        stackView.spacing = 8.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    init(videoUrl: URL) {
        self.originalVideoUrl = videoUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        if let thumbnailImage = thumbnailImageForFileUrl(originalVideoUrl) {
            self.selectedPhoto = thumbnailImage.imageRotated(by: .pi/2)
            thumbnailImageView.image = thumbnailImage.imageRotated(by: .pi/2)
        }
        VideoCompositionWriter.saveVideoToBeUploadedToServerToTempDirectory(sourceURL: originalVideoUrl) { [weak self] outputURL in
            guard let self = self else { return }
            self.encodedVideoURL = outputURL
            print("encodedVideoURL: ", outputURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ShareVideoViewController {
    private func setupNavigation() {
        navigationItem.title = "세부정보 추가"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    private func setupViews() {
        [thumbnailImageView, vStack, spacingView, tableView, buttonStack].forEach {
            view.addSubview($0)
        }
        thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.equalToSuperview().offset(8.0)
            $0.width.equalTo(80.0)
            $0.height.equalTo(120.0)
        }
        vStack.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).inset(-8.0)
            $0.trailing.equalToSuperview().offset(-8.0)
            $0.height.equalTo(120.0)
        }
        spacingView.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).inset(-16.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.0)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(spacingView.snp.bottom).inset(-16.0)
            $0.leading.equalToSuperview().offset(8.0)
            $0.trailing.equalToSuperview().offset(-8.0)
        }
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).inset(-16.0)
            $0.leading.equalToSuperview().offset(8.0)
            $0.trailing.equalToSuperview().offset(-8.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16.0)
        }
    }
    private func updateCountLabel(charLength: Int) {
        remainCountLabel.text = "\(charLength)/100"
    }
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    @objc private func didTapThumbnailImage() {
        
    }
    @objc private func didTapTempSaveButton() {
        
    }
    @objc private func didTapUploadButton() {
        shareVideo {
            self.dismiss(animated: true) {
                self.tabBarController?.selectedIndex = 0
            }
        } onError: { errorMsg in
            ProgressHUD.showError(errorMsg)
        }
    }
    private func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 7, timescale: 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    private func shareVideo(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMsg: String) -> Void) {
        ProgressHUD.show("로딩중...")
        Api.Post.shareVideo(encodedVideoURL: encodedVideoURL, selectedPhoto: selectedPhoto, textView: textView) {
            ProgressHUD.dismiss()
            onSuccess()
        } onError: { errorMsg in
            onError(errorMsg)
        }
    }
}

extension ShareVideoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolder {
            textView.text = nil
            textView.textColor = .white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeHolder
            textView.textColor = .lightGray
            updateCountLabel(charLength: 0)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)
        let charLength = newString.count
        guard charLength <= 100 else { return false }
        updateCountLabel(charLength: charLength)
        
        return true
    }
}

extension ShareVideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
}

extension ShareVideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoOptionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoOptionTableViewCell.identifier, for: indexPath) as? VideoOptionTableViewCell
        cell?.selectionStyle = .none
        var videoOptionType: VideoOptionType = .open
        switch indexPath.row {
        case 0:
            videoOptionType = .open
        case 1:
            videoOptionType = .location
        case 2:
            videoOptionType = .viewers
        case 3:
            videoOptionType = .remix
        case 4:
            videoOptionType = .comment
        default:
            break
        }
        cell?.update(videoOptionType)

        return cell ?? UITableViewCell()
    }
}
