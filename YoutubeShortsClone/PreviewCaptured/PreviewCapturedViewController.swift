//
//  PreviewCapturedViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/22.
//

import UIKit
import SnapKit
import AVKit

final class PreviewCapturedViewController: UIViewController {
    var currentPlayingVideoClip: VideoClips
    let recordedClips: [VideoClips]
    var viewWillDeinitRestartVideoSession: (() -> Void)?
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var urlsForVids: [URL] = [] {
        didSet {
            print("outputURLunwrapped: ", urlsForVids)
        }
    }
    var hideStatusBar: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private lazy var closeButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "xmark")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20.0
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleStartPlayingFirstClip()
        hideStatusBar = true
        recordedClips.forEach { clip in
            urlsForVids.append(clip.videoUrl)
        }
        print("\(recordedClips.count)")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        player.play()
        hideStatusBar = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        player.pause()
    }

    init(recordedClips: [VideoClips]) {
        self.currentPlayingVideoClip = recordedClips.first!
        self.recordedClips = recordedClips
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleStartPlayingFirstClip() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let firstClip = self.recordedClips.first else { return }
            self.currentPlayingVideoClip = firstClip
            self.setupPlayerView(with: firstClip)
        }
    }
    
    func setupPlayerView(with videoClip: VideoClips) {
        let player = AVPlayer(url: videoClip.videoUrl)
        let playerLayer = AVPlayerLayer(player: player)
        self.player = player
        self.playerLayer = playerLayer
        playerLayer.frame = imageView.frame
        self.player = player
        self.playerLayer = playerLayer
        imageView.layer.insertSublayer(playerLayer, at: 3)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        handleMirrorPlayer(cameraPosition: videoClip.cameraPosition)
    }
    
    func removePeriodcTimeObserver() {
        player.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
    }
    
    @objc private func avPlayerItemDidPlayToEndTime(notification: Notification) {
        if let currentIndex = recordedClips.firstIndex(of: currentPlayingVideoClip) {
            let nextIndex = currentIndex + 1
            if nextIndex > recordedClips.count - 1 {
                removePeriodcTimeObserver()
                guard let firstClip = recordedClips.first else { return }
                setupPlayerView(with: firstClip)
                currentPlayingVideoClip = firstClip
            } else {
                for (index, clip) in recordedClips.enumerated() {
                    if index == nextIndex {
                        removePeriodcTimeObserver()
                        setupPlayerView(with: clip)
                        currentPlayingVideoClip = clip
                    }
                }
            }
        }
    }
    
    private func handleMirrorPlayer(cameraPosition: AVCaptureDevice.Position) {
        if cameraPosition == .front {
            imageView.transform = CGAffineTransform(scaleX: -1, y: -1)
        } else {
            imageView.transform = .identity
        }
    }
    
    deinit {
        print("PreviewCaptureVideoVc was deinited")
        (viewWillDeinitRestartVideoSession)?()
    }
}
extension PreviewCapturedViewController {
    private func setupViews() {
        [imageView, closeButton, nextButton].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.equalToSuperview().offset(16.0)
            $0.width.height.equalTo(35.0)
        }
        nextButton.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.top)
            $0.trailing.equalToSuperview().offset(-16.0)
            $0.height.equalTo(40.0)
            $0.width.equalTo(60.0)
        }
    }
    @objc private func didTapCloseButton() {
        hideStatusBar = true
        navigationController?.popViewController(animated: true)
    }
    
    private func handleMergeClips() {
        VideoCompositionWriter().mergeMultipleVideo(urls: urlsForVids) { success, outputUrl in
            if success {
                guard let outputUrl = outputUrl else { return }
                DispatchQueue.main.async {
                    let player = AVPlayer(url: outputUrl)
                    let AVPlayerVC = AVPlayerViewController()
                    AVPlayerVC.player = player
                    self.present(AVPlayerVC, animated: true) {
                        AVPlayerVC.player?.play()
                    }
                }
            }
        }
    }
    @objc private func didTapNextButton() {
        handleMergeClips()
        hideStatusBar = false
        let shareVideoVC = ShareVideoViewController(videoUrl: currentPlayingVideoClip.videoUrl)
        shareVideoVC.selectedPhoto = imageView.image
        navigationController?.pushViewController(shareVideoVC, animated: true)
    }
}
