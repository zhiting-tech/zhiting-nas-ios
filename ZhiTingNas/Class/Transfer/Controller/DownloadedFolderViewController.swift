//
//  DownloadedFolderViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/24.
//

import UIKit
import IJKMediaFramework

class DownloadedFolderViewController: BaseViewController {
    lazy var documentVC = UIDocumentInteractionController()
    var transitionUtil = FolderTransitionUtil()
    var player: IJKFFMoviePlayerController?

    private lazy var filePathLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.text = "根目录"
        $0.textColor = .custom(.gray_a2a7ae)
    }
    
    private lazy var headerView = FolderDetailHeader(currentFileName: currentPaths.last ?? "").then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    //PathCollectionView
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal//水平方向滚动
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.itemSize = UICollectionViewFlowLayout.automaticSize
        $0.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    lazy var pathCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.isScrollEnabled = true
        $0.register(PathCell.self, forCellWithReuseIdentifier: PathCell.reusableIdentifier)
    }
    
    var currentPath = ""
    
    var currentPaths = [String]() {
        didSet {
            if currentPaths.count == 1 {
                view.addSubview(filePathLabel)
                filePathLabel.snp.makeConstraints {
                    $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(5))
                    $0.left.equalTo(ZTScaleValue(15))
                    $0.right.equalTo(-ZTScaleValue(15))
                    $0.height.equalTo(ZTScaleValue(30))
                }
                filePathLabel.text = currentPaths[0]
            }
            pathCollectionView.reloadData()
        }
    }
    


    
    private lazy var currentDatas = [FileModel]()
    private var seletedFiles = [FileModel]()//选中的文件
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderTableViewCell.reusableIdentifier)
        
    }
    
    private lazy var funtionTabbarView = FunctionTabbarView().then {
        $0.backgroundColor = .custom(.blue_427aed)
    }
    private var funtionTabbarIsShow = false
    
    private var myFileDetailView = FileDetailAlertView(title: "文件详情")
    private var setNameView: SetNameAlertView?


    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // MARK: - funtionTabbarAction
        funtionTabbarView.deleteBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击删除")
            self.seletedFiles.map(\.name).forEach { name in
                if let url = DownloadedDocumentManager.shared.goCacheUrl {
                    let path = self.currentPaths.joined(separator: "/")
                    let fileUrl = url.appendingPathComponent("/\(path)/\(name)")
                    DownloadedDocumentManager.shared.deleteFile(url: fileUrl)

                }
            }
            self.getDiskData()
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        reload()
        pathCollectionView.scrollToItem(at: IndexPath(item: currentPaths.count - 1, section: 0), at: .right, animated: true)
    }
    
    override func setupViews() {
        view.addSubview(headerView)
        headerView.setBtns(btns: [])
        headerView.actionCallback = { [weak self] tag in
            guard let self = self else { return }
            switch tag {
            case 0:
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
        view.addSubview(pathCollectionView)
        view.addSubview(tableView)
        let header = GIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reload))
    
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        
        pathCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(30))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(pathCollectionView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func getDiskData(){
        currentDatas = DownloadedDocumentManager.shared.getFileList(by: currentPath)
        tableView.mj_header?.endRefreshing()
        tableView.reloadData()
    }
    
    @objc private func reload(){
        
        getDiskData()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    

}

extension DownloadedFolderViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPaths.count
    }
    
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.reusableIdentifier, for: indexPath) as! PathCell
        cell.titleLabel.text = currentPaths[indexPath.item]
        if indexPath.item == currentPaths.count - 1 {
            cell.arrowImgview.isHidden = true
        }else{
            cell.arrowImgview.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //点击栏目回到对应文件路径
        if indexPath.item == 0 {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        if indexPath.item == currentPaths.count - 1 {
            return
        }
        
        if (self.navigationController?.viewControllers.count)! >= indexPath.item {
            guard let vc = self.navigationController?.viewControllers[indexPath.item] else { return }
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DownloadedFolderViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.reusableIdentifier, for: indexPath) as! FolderTableViewCell
        cell.selectionStyle = .none
        if let url = DownloadedDocumentManager.shared.goCacheUrl {
            let path = self.currentPaths.joined(separator: "/")
            let fileUrl = url.appendingPathComponent("/\(path)/\(currentDatas[indexPath.row].name)")
            cell.setModel(currentModel: currentDatas[indexPath.row], filePath: fileUrl.absoluteString, type: .download)
        }else{
            cell.setModel(currentModel: currentDatas[indexPath.row], type: .download)
        }
        cell.selectBtn.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击cell
        
        print("点击cell")
        let file = currentDatas[indexPath.row]
        if file.type == 0 {//文件夹
            let vc = DownloadedFolderViewController()
            vc.currentPath = currentPath + "/\(file.name)"
            let paths = currentPaths + [file.name]
            vc.currentPaths = paths
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if let url = DownloadedDocumentManager.shared.goCacheUrl {
            let path = self.currentPaths.joined(separator: "/")
            let fileUrl = url.appendingPathComponent("/\(path)/\(currentDatas[indexPath.row].name)")
            switch ZTCTool.resourceTypeBy(fileName: file.name) {
            case .ppt,.pdf,.txt,.excel,.document,.music,.picture,.video:
                myFileDetailView.setCurrentFileModel(file: file, types: [.preview,.open],filePath: fileUrl.absoluteString)
            default:
                myFileDetailView.setCurrentFileModel(file: file, types: [.open],filePath: fileUrl.absoluteString)
            }
        }else{
            myFileDetailView.setCurrentFileModel(file: file,types: [.open])
        }

        myFileDetailView.selectCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .preview:
                if let url = DownloadedDocumentManager.shared.goCacheUrl {
                    let path = self.currentPaths.joined(separator: "/")
                    let fileUrl = url.appendingPathComponent("/\(path)/\(file.name)").absoluteURL
                    switch ZTCTool.resourceTypeBy(fileName: file.name) {
                    case .video:
                        let playerVC = MultimediaController(type: .video(title: file.name, url: fileUrl))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                    
                    case .music:
                        let playerVC = MultimediaController(type: .music(title: file.name, url: fileUrl))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                        
                    case .picture:
                        //获取图片集，以及当前第几个
                        let picSet = self.currentDatas.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                        let index = picSet.firstIndex(where: {$0.name == file.name}) ?? 0
                        let picStringSet = picSet.map({url.appendingPathComponent("/\(path)/\($0.name)").absoluteURL.absoluteString})
                        let titleSet = picSet.map(\.name)

                        let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                        
                    case .document,.excel,.txt,.pdf,.ppt:
                        let playerVC = MultimediaController(type: .document(title: file.name, url: fileUrl))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                    default:
                        break
                    }
                }

                self.myFileDetailView.removeFromSuperview()

            case .open:
                if let url = DownloadedDocumentManager.shared.goCacheUrl {
                    let path = self.currentPaths.joined(separator: "/")
                    let fileUrl = url.appendingPathComponent("/\(path)/\(file.name)")
                    self.documentVC.url = fileUrl
                    let rect = CGRect(x: self.view.bounds.size.width, y: 40, width: 0, height: 0)
                    self.documentVC.presentOpenInMenu(from: rect, in: self.view, animated: true)

                }

                self.myFileDetailView.removeFromSuperview()
            case .delete:
                if let url = DownloadedDocumentManager.shared.goCacheUrl {
                    let path = self.currentPaths.joined(separator: "/")
                    let fileUrl = url.appendingPathComponent("/\(path)/\(file.name)")
                    DownloadedDocumentManager.shared.deleteFile(url: fileUrl)
                    self.getDiskData()
                }
                self.myFileDetailView.removeFromSuperview()
                
            default:
                break
            }
        }
        
        showFileDetailView()
    }
}

extension DownloadedFolderViewController {
    
    private func showFileDetailView(){
        SceneDelegate.shared.window?.addSubview(myFileDetailView)
    }
    
    private func getThumbnail(url:String) -> UIImage{
        let options = IJKFFOptions.byDefault()
        options?.setFormatOptionValue("scope-token:\(AreaManager.shared.currentArea.scope_token)", forKey: "headers")
        
        guard let videoURL =  URL(string: url) else{
            return UIImage()
        }
        if self.player != nil {
            self.player?.shutdown()
            self.player?.view.removeFromSuperview()
            self.player?.stop()
            self.player = nil
        }
            self.player = IJKFFMoviePlayerController.init(contentURL:videoURL, with: options)
            self.player?.scalingMode = IJKMPMovieScalingMode.aspectFit
            self.player?.shouldAutoplay = false
            self.player?.prepareToPlay()
            self.player?.play()
            self.player?.currentPlaybackTime = TimeInterval(10)
            return self.player?.thumbnailImageAtCurrentTime() ?? UIImage()
    }
}


