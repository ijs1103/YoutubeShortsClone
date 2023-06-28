//
//  VideoUploadViewController.swift
//  YoutubeShortsClone
//
//  Created by 이주상 on 2023/06/19.
//

import UIKit
import AVFoundation

final class VideoUploadViewController: UIViewController {
    
    let photoFileOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputUrl: URL!
    var currentCameraDevice: AVCaptureDevice?
    var thumbnailImage: UIImage?
    var recordedClips: [VideoClips] = []
    var isRecording = false
    var videoDurationOfLastClip = 0
    var recordingTimer: Timer?
    var currentMaxRecordingDuration: Int = 15 {
        didSet {
            timerLabel.text = "\(currentMaxRecordingDuration)s"
        }
    }
    var total_RecordedTime_In_Secs = 0
    var total_RecordedTime_In_Minutes = 0
    lazy var segmentedProgressView = SegmentedProgressView(width: view.frame.width - 17.5)
    
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
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "15"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 20.0
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 2.2
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var soundButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "music.note"), for: .normal)
        button.tintColor = .white
        button.setTitle("사운드 추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.backgroundColor = .black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 18.0
        button.addTarget(self, action: #selector(didTapSoundButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var effectButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "wand.and.stars")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEffectButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var galleryButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "photo")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGalleryButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var discardButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "delete.backward")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.alpha = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDiscardButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "done-2"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        button.alpha = 0
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        button.layer.cornerRadius = 20.0
        return button
    }()

    private lazy var recordButton = RecordButtonView()
    
    private lazy var utilButtonStack: UIStackView = {
        let utilButtons = UtilButtonType.allCases.map {
            UtilButtonView(type: $0)
        }
        utilButtons.forEach {
            $0.delegate = self
        }
        let stack = UIStackView(arrangedSubviews: utilButtons)
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 32.0
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if setupCaptureSession() {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
        setupViews()
        setupDelegates()
        setupZposition()
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
        [closeButton, timerLabel, soundButton, utilButtonStack, recordButton, effectButton, galleryButton, saveButton, discardButton, segmentedProgressView].forEach {
            view.addSubview($0)
        }
        segmentedProgressView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.frame.width - 17.5)
            $0.height.equalTo(6.0)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48.0)
            $0.leading.equalToSuperview().offset(16.0)
            $0.width.height.equalTo(35.0)
        }
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).inset(-32.0)
            $0.leading.equalTo(closeButton.snp.leading)
            $0.width.height.equalTo(40.0)
        }
        soundButton.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.top)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120.0)
            $0.height.equalTo(36.0)
        }
        utilButtonStack.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.top)
            $0.trailing.equalToSuperview().offset(-16.0)
        }
        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-64.0)
            $0.width.height.equalTo(85.0)
        }
        effectButton.snp.makeConstraints {
            $0.centerY.equalTo(recordButton.snp.centerY)
            $0.leading.equalToSuperview().offset(32.0)
            $0.width.height.equalTo(35.0)
        }
        galleryButton.snp.makeConstraints {
            $0.centerY.equalTo(recordButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-32.0)
            $0.width.height.equalTo(35.0)
        }
        discardButton.snp.makeConstraints {
            $0.height.equalTo(35.0)
            $0.width.equalTo(55.0)
        }
        saveButton.snp.makeConstraints {
            $0.centerY.equalTo(recordButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-32.0)
            $0.width.height.equalTo(40.0)
        }
        discardButton.snp.makeConstraints {
            $0.centerY.equalTo(recordButton.snp.centerY)
            $0.trailing.equalTo(saveButton.snp.leading).inset(-8.0)
        }
    }
    private func setupCaptureSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        // setup inputs
        if let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video), let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
            do {
                let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
                let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
                if captureSession.canAddInput(inputVideo) {
                    captureSession.addInput(inputVideo)
                    activeInput = inputVideo
                }
                if captureSession.canAddInput(inputAudio) {
                    captureSession.addInput(inputAudio)
                }
                if captureSession.canAddOutput(movieOutput) {
                    captureSession.addOutput(movieOutput)
                }
            } catch let error {
                print("Cannot setup camera input: ",error.localizedDescription)
                return false
            }
        }
        // setup ouputs
        if captureSession.canAddOutput(photoFileOutput) {
            captureSession.addOutput(photoFileOutput)
        }
        // setup output previews
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return true
    }
    private func setupZposition() {
        [closeButton, timerLabel, soundButton, recordButton, effectButton, galleryButton, utilButtonStack, saveButton, discardButton].forEach {
            $0.layer.zPosition = 1
        }
    }
    private func setupDelegates() {
        recordButton.delegate = self
    }
    @objc private func didTapCloseButton() {
        tabBarController?.selectedIndex = 0
    }
    @objc private func didTapSaveButton() {
        
        let previewVC = PreviewCapturedViewController(recordedClips: recordedClips)
        previewVC.viewWillDeinitRestartVideoSession = { [weak self] in
            guard let self = self else { return }
            if self.setupCaptureSession() {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
        navigationController?.pushViewController(previewVC, animated: true)
    }
    @objc private func didTapDiscardButton() {
        let alertVC = UIAlertController(title: "Discard the last clip?", message: nil, preferredStyle: .alert)
        let discardAction = UIAlertAction(title: "Discard", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.handleDiscardLastRecordedClip()
        }
        let keepAction = UIAlertAction(title: "Keep", style: .cancel) { (_) in
            
        }
        [discardAction, keepAction].forEach {
            alertVC.addAction($0)
        }
        present(alertVC, animated: true)
    }
    private func handleDiscardLastRecordedClip() {
        print("discard")
        outputUrl = nil
        thumbnailImage = nil
        recordedClips.removeLast()
        handleResetAllVisibilityToIdentity()
        handleSetNewOuputUrlAndThumbnailImage()
        segmentedProgressView.handleRemoveLastSegment()
        if recordedClips.isEmpty {
            handleResetTimersAndProgressViewToZero()
        } else {
            handleCalculateDurationLeft()
        }
    }
    private func handleCalculateDurationLeft() {
        let timeToDiscard = videoDurationOfLastClip
        let currentCombineTime = total_RecordedTime_In_Secs
        let newVideoDuration = currentCombineTime - timeToDiscard
        total_RecordedTime_In_Secs = newVideoDuration
        let countDownSec = Int(currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timerLabel.text = "\(countDownSec)"
    }
    private func handleSetNewOuputUrlAndThumbnailImage() {
        outputUrl = recordedClips.last?.videoUrl
        let currentUrl: URL? = outputUrl
        guard let currentUrl = currentUrl, let generatedThumbnailImage = generateThumbnailImage(with: currentUrl) else { return }
        if currentCameraDevice?.position == .front {
            thumbnailImage = didTakePhoto(generatedThumbnailImage, to: .upMirrored)
        } else {
            thumbnailImage = generatedThumbnailImage
        }
    }
    @objc private func didTapSoundButton() {
        
    }
    @objc private func didTapEffectButton() {
        
    }
    @objc private func didTapGalleryButton() {
        
    }
    private func getDeviceFront(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    private func getDeviceBack(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    private func didTapFlip() {
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        let newCameraDevice = (currentInput?.device.position == .back) ? getDeviceFront(position: .front) : getDeviceBack(position: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        if captureSession.inputs.isEmpty {
            captureSession.addInput(newVideoInput!)
            activeInput = newVideoInput
        }
        if let microphone = AVCaptureDevice.default(for: .audio) {
            do {
                let micInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(micInput) {
                    captureSession.addInput(micInput)
                }
            } catch let micInputError {
                print("Audio Input Setting Error : ", micInputError)
            }
        }
        captureSession.commitConfiguration()
    }
    private func didTapSpeed() {
        
    }
    private func didTapBeauty() {
        
    }
    private func didTapFilters() {
        
    }
    private func didTapTimer() {
        
    }
    private func didTapFlash() {
        
    }
    private func tempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    private func startRecording() {
        if movieOutput.isRecording == false {
            guard let connection = movieOutput.connection(with: .video) else { return }
            if connection.isVideoOrientationSupported {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                let device = activeInput.device
                if device.isSmoothAutoFocusSupported {
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                        print("Config Setting Error: ", error)
                    }
                    outputUrl = tempUrl()
                    movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
                    handleAnimateRecordButton()
                }
            }
        }
    }
    private func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            handleAnimateRecordButton()
            stopTimer()
            segmentedProgressView.pauseProgress()
        }
    }
    private func didTapRecordButton() {
        if movieOutput.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    private func handleAnimateRecordButton() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: { [weak self] in
            guard let self = self else { return }
            if !self.isRecording {
                self.recordButton.button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.recordButton.button.layer.cornerRadius = 5
                self.recordButton.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                self.saveButton.alpha = 0
                self.discardButton.alpha = 0
                
                [self.soundButton, self.effectButton, self.galleryButton].forEach {
                    $0.isHidden = true
                }
            } else {
                self.recordButton.button.transform = CGAffineTransform.identity
                self.recordButton.button.layer.cornerRadius = 34.0
                self.recordButton.transform = CGAffineTransform.identity
                self.handleResetAllVisibilityToIdentity()
            }
        }) {[weak self] onComplete in
            guard let self = self else { return }
            self.isRecording = !self.isRecording
        }
    }
    private func handleResetAllVisibilityToIdentity() {
        if recordedClips.isEmpty {
            [self.soundButton, self.effectButton, self.galleryButton].forEach {
                $0.isHidden = false
            }
            saveButton.alpha = 0
            discardButton.alpha = 0
        } else {
            [self.soundButton, self.effectButton, self.galleryButton].forEach {
                $0.isHidden = true
            }
            saveButton.alpha = 1
            discardButton.alpha = 1
        }
    }
}
extension VideoUploadViewController: UtilButtonViewDelegate {
    func didTapUtilButtonView(type: UtilButtonType) {
        switch type {
        case .flip:
            didTapFlip()
        case .speed:
            didTapSpeed()
        case .beauty:
            didTapBeauty()
        case .filters:
            didTapFilters()
        case .timer:
            didTapTimer()
        case .flash:
            didTapFlash()
        }
    }
}
extension VideoUploadViewController: RecordButtonViewDelegate {
    func didTapRecordButtonView() {
        didTapRecordButton()
    }
}
extension VideoUploadViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error recoding movie: \(error?.localizedDescription ?? "")")
        } else {
            let recordedVideoUrl = outputUrl! as URL
            guard let generatedThumbnailImage = generateThumbnailImage(with: recordedVideoUrl) else { return }
            if currentCameraDevice?.position == .front {
                thumbnailImage = didTakePhoto(generatedThumbnailImage, to: .upMirrored)
            } else {
                thumbnailImage = generatedThumbnailImage
            }
        }
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        let newRecordedClip = VideoClips(videoUrl: fileURL, cameraPosition: currentCameraDevice?.position)
        recordedClips.append(newRecordedClip)
        startTimer()
        print("recordedClips : ", recordedClips.count)
    }
    private func didTakePhoto(_ photo: UIImage, to orientation: UIImage.Orientation) -> UIImage {
        let flippedImage = UIImage(cgImage: photo.cgImage!, scale: photo.scale, orientation: orientation)
        return flippedImage
    }
    private func generateThumbnailImage(with videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cmTime = CMTimeMake(value: 1, timescale: 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
}

//MARK: - RECORDING TIMER

extension VideoUploadViewController {
    private func startTimer() {
        videoDurationOfLastClip = 0
        stopTimer()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.timerTick()
        })
    }
    
    private func timerTick() {
        total_RecordedTime_In_Secs += 1
        videoDurationOfLastClip += 1
        let time_limit = currentMaxRecordingDuration * 10
        if total_RecordedTime_In_Secs == time_limit {
            didTapRecordButton()
        }
        let startTime = 0
        let trimmedTime = Int(currentMaxRecordingDuration) - startTime
        let positiveOrZero = max(total_RecordedTime_In_Secs, 0)
        let progress = Float(positiveOrZero) / Float(trimmedTime) / 10
        segmentedProgressView.setProgress(CGFloat(progress))
        let countDownSec = Int(currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timerLabel.text = "\(countDownSec)s"
    }
    private func handleResetTimersAndProgressViewToZero() {
        total_RecordedTime_In_Secs = 0
        total_RecordedTime_In_Minutes = 0
        videoDurationOfLastClip = 0
        stopTimer()
        segmentedProgressView.setProgress(0)
        timerLabel.text = "\(currentMaxRecordingDuration)"
    }
    private func stopTimer() {
        recordingTimer?.invalidate()
    }
}
