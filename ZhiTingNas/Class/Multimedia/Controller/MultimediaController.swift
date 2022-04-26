//
//  MultimediaController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/11/16.
//

import UIKit
import AVKit
import SwiftUI
import Kingfisher
import WebKit
import IJKMediaFramework
import QuickLook

enum MultimediaType {
    case video(title: String, url: URL)
    case music(title: String, url: URL)
    case picture(titleSet: [String], picSet: [String], index: Int, isFromLocation: Bool)
    case document(title: String, url: URL)
    
    var _rawValue: String {
        switch self {
        case .video:
            return "video"
        case .music:
            return "music"
        case .picture:
            return "picture"
        case .document:
            return "document"
        }
    }

   
}

class MultimediaController: BaseViewController {
    
    var name = ""
    var currentType: MultimediaType
    var currentUrl : URL
    var startPoint_X = 0.0
    
    
    // MARK: - Music属性
    
    var musicPlayer: IJKFFMoviePlayerController?
    var curTime: TimeInterval?
    var isDragged = Bool()
    
    lazy var musicImageView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.music_bg)
    }
    
    lazy var musicLogoImageView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.music_gb_logo)
    }

    var musicPlayBtn = Button().then {
        $0.setImage(.assets(.music_playBtn), for: .normal)
        $0.setImage(.assets(.music_stopBtn), for: .selected)
        $0.addTarget(self, action: #selector(pauseButtonSelected(sender:)), for: .touchUpInside)
    }//音乐播放按钮
    
    
    // MARK: - document属性
    var webView: WKWebView!
    var previewController: QLPreviewController!
    
    // MARK: - Picture属性

    //存储图片数组
    var images: [String]!

    //存储图片名称数组
    var imageNames: [String]!
    
    //默认显示的图片索引
    var index: Int!

    //用来放置各个图片单元
    var collectionView: UICollectionView!

    //collectionView的布局
    var collectionViewLayout: UICollectionViewFlowLayout!

    //页控制器（小圆点）
    var pageControl : UIPageControl!
    

    // MARK: - Video属性
    var placeIamge: UIImage?
    var player : AVPlayer!
    var palyerItem : AVPlayerItem!
    
    var playerView : VideoPlayerView!
    
    //顶部控件
    var navigationView = UIView().then{
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    var backBtn = Button().then {
        $0.setImage(.assets(.backBtn_white), for: .normal)
        $0.isEnhanceClick = true
        $0.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
    }//播放按钮
    var titleLabel = UILabel().then {
        $0.font = .font(size: 18.ztScaleValue, type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .left
    }
    
    var controlView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    var currentTimeLabel = UILabel().then {
        $0.font = .font(size: 11.ztScaleValue, type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .left
        $0.text = "00:00:00"
    }//时间label

    
    var allTimeLabel = UILabel().then {
        $0.font = .font(size: 11.ztScaleValue, type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .left
        $0.text = "00:00:00"
    }//时间label
    
    lazy var slider = UISlider().then {
        $0.setThumbImage(.assets(.thumbImage_blue), for: .normal)
//        $0.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
    }
    
    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch currentType {
        case .video:
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.isAllOrientation = true
            }
        case .music:
            break
        case .picture:
            break
        case .document:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.orientation != .portrait {
            //强制归正：
            let oriention = UIInterfaceOrientation.portrait // 设置屏幕为竖屏
            UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch currentType {
        case .video:
            view.backgroundColor = .black
            //修改信号栏颜色
            setNeedsStatusBarAppearanceUpdate()
            setupVideo()

        case .music:
            view.backgroundColor = .white
            setupMusicUI()
            setupMusicPlayer()
        case .picture:
            view.backgroundColor = .black
            //修改信号栏颜色
            setNeedsStatusBarAppearanceUpdate()
            setupPictureUI()
        case .document( _, let url):
            view.backgroundColor = .white
            if url.absoluteString.contains("file://") {
                setupDocument()
            }else{
                setupWebView()
            }
        }
    }
    
    init(type: MultimediaType) {
        self.currentType = type
        switch type {
        case .video(let title, let url):
            self.titleLabel.text = title
            self.currentUrl = url
        case .music(let title, let url):
            self.titleLabel.text = title
            self.currentUrl = url
        case .picture(let titleSet,let picSet,let index, _):
            self.imageNames = titleSet
            self.images = picSet
            self.index = index
            self.currentUrl = URL(string: picSet.first!)!
        case .document(let title, let url):
            self.titleLabel.text = title
            self.currentUrl = url
        }
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        switch currentType {
        case .video:
            break
        case .picture:
            view.addSubview(navigationView)
            navigationView.addSubview(backBtn)
            navigationView.addSubview(titleLabel)
            break
        case .document:
            navigationView.backgroundColor = .custom(.white_ffffff)
            backBtn.setImage(.assets(.navigation_back), for: .normal)
            titleLabel.textColor = .custom(.black_3f4663)
            view.addSubview(navigationView)
            navigationView.addSubview(backBtn)
            navigationView.addSubview(titleLabel)
            break
        case .music:
            navigationView.backgroundColor = .custom(.white_ffffff)
            backBtn.setImage(.assets(.navigation_back), for: .normal)
            titleLabel.textColor = .custom(.black_3f4663)
            view.addSubview(navigationView)
            navigationView.addSubview(backBtn)
            navigationView.addSubview(titleLabel)
            break
        }
        
    }
    
    override func setupSubscriptions() {

        if currentType._rawValue != "video" {
            navigationView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview()
                $0.height.equalTo(Screen.k_nav_height+Screen.statusBarHeight)
            }

            backBtn.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(15.5))
                $0.width.equalTo(8.ztScaleValue)
                $0.height.equalTo(14.ztScaleValue)
            }

            titleLabel.snp.makeConstraints {
                $0.centerY.equalTo(backBtn)
                $0.left.equalTo(backBtn.snp.right).offset(12.ztScaleValue)
                $0.right.equalToSuperview()
            }
        }
        
        //添加侧滑返回手势
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlerightPanGesture(sender:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
                switch currentType {
                case .video:
                    return .lightContent

                case .picture:
                    return .lightContent

                case .document:
                    return .darkContent

                case .music:
                    return .darkContent

                }

    }
    
    override func viewWillLayoutSubviews() {
        switch currentType {
        case .video:
            playerView.frame = self.view.bounds
            
        case .music:
            break
        case .picture:
            break
        case .document:
            break
        }
    }
    
    deinit {
        print("multimediaController Deinit")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isAllOrientation = false
        }
        
        if currentType._rawValue == "video" {
            self.playerView.player?.shutdown()
        }
        
        if currentType._rawValue == "music" {
            self.musicPlayer?.shutdown()
            self.musicPlayer = nil
        }
        
    }

    
    // MARK: - picture Init（）
    private func setupPictureUI(){
        
        self.view.backgroundColor = .black
        //collectionView尺寸样式设置
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        //横向滚动
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
        //collectionView初始化
        collectionView = UICollectionView(frame: CGRect(x: 0, y: Screen.k_nav_height, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height),
                                          collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        //不自动调整内边距，确保全屏
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        
        //将视图滚动到默认图片上
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)

        //设置页控制器
        pageControl = UIPageControl()
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        pageControl.numberOfPages = images.count
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = index
        self.titleLabel.text = imageNames[index]
        view.addSubview(self.pageControl)
    }

    
    // MARK: - WebView Init()
    private func setupDocument(){
        previewController = QLPreviewController()
        previewController.delegate = self
        previewController.dataSource = self
        previewController.view.frame = CGRect(x: 0, y: Screen.k_nav_height, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
        self.addChild(previewController)
        self.view.addSubview(previewController.view)
       
    }
    
    private func setupWebView() {
        
        webView = WKWebView(frame: .zero)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        //添加进度条
//        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Screen.k_nav_height)
            make.left.right.bottom.equalToSuperview()
        }
        var request = URLRequest(url: currentUrl)
        request.setValue(AreaManager.shared.currentArea.scope_token, forHTTPHeaderField: "scope-token")
        webView.load(request)
    }

    
    // MARK: - Music Init （）
    private func setupMusicUI(){
        view.addSubview(musicImageView)
        musicImageView.addSubview(musicLogoImageView)
        currentTimeLabel.textColor = .custom(.blue_427aed)
        view.addSubview(currentTimeLabel)
        view.addSubview(slider)
        allTimeLabel.textColor = .custom(.gray_a2a7ae)
        view.addSubview(allTimeLabel)
        view.addSubview(musicPlayBtn)
        
        musicImageView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(75.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(200.ztScaleValue)
        }
        musicLogoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-2.ztScaleValue)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(22.ztScaleValue)
        }
        
        currentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(musicImageView.snp.bottom).offset(75.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.lessThanOrEqualTo(100)
        }
        allTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(currentTimeLabel)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.width.lessThanOrEqualTo(100)
        }
        slider.snp.makeConstraints {
            $0.centerY.equalTo(currentTimeLabel)
            $0.left.equalTo(currentTimeLabel.snp.right).offset(6.5.ztScaleValue)
            $0.right.equalTo(allTimeLabel.snp.left).offset(-6.5.ztScaleValue)
            $0.height.equalTo(50.ztScaleValue)
        }
        
        musicPlayBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(slider.snp.bottom).offset(50.ztScaleValue)
            $0.width.height.equalTo(70.ztScaleValue)
        }

    }
    
    private func setupMusicPlayer(){
        let options = IJKFFOptions.byDefault()
        options?.setFormatOptionValue("scope-token:\(AreaManager.shared.currentArea.scope_token)", forKey: "headers")
        
        musicPlayer = IJKFFMoviePlayerController.init(contentURL:currentUrl, with: options)
        musicPlayer?.scalingMode = IJKMPMovieScalingMode.aspectFit
        musicPlayer?.shouldAutoplay = false
        musicPlayer?.prepareToPlay()
        musicPlayer?.play()
        refreshMusicControl()
        
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchCancel), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUpInside), for: .touchUpInside)
        
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTapGesture(sender:))))
    }
    
    @objc func refreshMusicControl() {
        guard let delegatePlayer = musicPlayer else { return }

        let duration = delegatePlayer.duration
        let intDuration = duration + 0.5
        if intDuration > 0 {
            slider.maximumValue = Float(duration)
            allTimeLabel.text = String(format: "%02d:%02d", Int(intDuration/60),Int(Int(intDuration)%60))
        }else {
            slider.maximumValue = 1
            allTimeLabel.text = "--:--"
        }
        var position: TimeInterval
        if isDragged {
            position = TimeInterval(slider.value)
        }else {
            position = delegatePlayer.currentPlaybackTime
        }
        let intPosition = position + 0.5
        if intPosition > 0 {
            slider.value = Float(position)
        }else {
            slider.value = 0
        }
        currentTimeLabel.text = String(format: "%02d:%02d", Int(position/60),Int(Int(position)%60))
        let isPlaying = delegatePlayer.isPlaying()
        musicPlayBtn.isSelected = isPlaying
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshMusicControl), object: nil)
        self.perform(#selector(refreshMusicControl), with: nil, afterDelay: 0.4)
    }

    
    // MARK: - video Init（）
    private func setupVideo(){
        switch currentType {
        case .video(let title, let url):
            playerView = VideoPlayerView.init(frame: self.view.bounds, strUrl: url.absoluteString,headers: "scope-token:\(AreaManager.shared.currentArea.scope_token)")
            self.view.addSubview(playerView)
            playerView.mediaControl?.backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
            playerView.mediaControl?.titleLabel.textColor = .custom(.white_ffffff)
            playerView.mediaControl?.titleLabel.text = title
        default:
            break
        }
 
    }
                
    
}

// MARK: - Player Control
extension MultimediaController {
    
    //播放
    @objc func playAction() {
        musicPlayer?.play()
        refreshMusicControl()
    }
    
    @objc func pauseAction() {
        musicPlayer?.pause()
        refreshMusicControl()
    }

    
    //暂停
    @objc func pauseButtonSelected(sender:UIButton)  {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            self.playAction()
        }else{
            self.pauseAction()
        }
    }
    
    @objc func backBtnAction(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshMusicControl), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Action & Gesture
extension MultimediaController {
    
    @objc func sliderTouchDown() {
        beginDrag()
    }
    
    @objc func sliderTouchCancel() {
        endDrag()
    }
    
    @objc func sliderValueChanged() {
        continueDrag()
    }
    
    @objc func sliderTouchUpInside() {
        musicPlayer?.currentPlaybackTime = TimeInterval(slider.value)
        endDrag()
    }

    func beginDrag() {
        isDragged = true
    }
    
    func endDrag() {
        isDragged = false
    }
    
    func continueDrag() {
        refreshMusicControl()
    }

    
    @objc private func actionTapGesture(sender: UITapGestureRecognizer){
        let touchPonit = sender.location(in: slider)
        let value = Float(slider.maximumValue - slider.minimumValue) * Float(touchPonit.x / slider.frame.size.width) + slider.minimumValue
        slider.setValue(Float(value), animated: true)
        guard let isPreprare = self.musicPlayer?.isPreparedToPlay else {return}
        if isPreprare {
            self.musicPlayer?.currentPlaybackTime = TimeInterval(slider.value)
        }
    }
    
    //侧滑返回页面
    @objc private func handlerightPanGesture(sender: UIPanGestureRecognizer){
        
        let location_X = 0.15 * Screen.screenWidth;
        let point = sender.translation(in: sender.view)
        print("pointX\(point.x)")
        
        if sender.state == .began{//开始滑动
            let location = sender.location(in: sender.view)
            startPoint_X = location.x
            print("开始滑动\(startPoint_X)")
        }
        
        if sender.state == .ended{//右滑结束
            
            print("滑动结束\(point.x)")
            if startPoint_X < location_X && point.x > 0 {// 右滑
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshMusicControl), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
}

// MARK: - UIScrollViewDelegate
//extension MultimediaController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return pictureImageView
//    }
//}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MultimediaController: UICollectionViewDelegate, UICollectionViewDataSource {
    
        //collectionView单元格创建
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                            for: indexPath) as! ImagePreviewCell
        switch currentType {
        case .picture( _, _, _,let isFromLocation):
            cell.imageView.setImage(urlString: self.images[indexPath.row] , placeHolder: .assets(.imageSet_Placehoder), isAppendingPercent: !isFromLocation) { img in
                guard let img = img else {return}
                    if img.size.height > Screen.screenHeight - Screen.k_nav_height || img.size.width > Screen.screenWidth {
                        cell.imageView.contentMode = .scaleAspectFit
                    }else{
                        cell.imageView.contentMode = .center
                    }
                }
        default:
            break
        }

        
        return cell
    }
    
    //collectionView单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    //collectionView里某个cell将要显示
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, indexPath: IndexPath) {
          
        if let cell = cell as? ImagePreviewCell{
            //由于单元格是复用的，所以要重置内部元素尺寸
            cell.resetSize()
          }
      }
    
    //collectionView里某个cell显示完毕
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //当前显示的单元格
        let visibleCell = collectionView.visibleCells[0]
        //设置页控制器当前页
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
        self.titleLabel.text = imageNames[collectionView.indexPath(for: visibleCell)!.item]
    }
}

extension MultimediaController: WKNavigationDelegate, WKUIDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }

}

extension MultimediaController: QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // 路径 可以获得基本信息 但是不能打开
        return  currentUrl as QLPreviewItem
    }
}
