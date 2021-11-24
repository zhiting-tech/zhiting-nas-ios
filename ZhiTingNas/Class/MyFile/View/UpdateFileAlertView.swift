//
//  UpdateFileAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/26.
//

import UIKit

class UpdateFileAlertView: UIView {

    var selectCallback: ((_ index: Int) -> ())?
    private var functionDatas = [ButtonModel]()


    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
    }
    
    //funtionCollectionView
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.itemSize = CGSize(width: ZTScaleValue(80), height:  ZTScaleValue(80))
        //行列间距
        $0.minimumLineSpacing = ZTScaleValue(14.5)
        $0.minimumInteritemSpacing = (Screen.screenWidth - (ZTScaleValue(80) * 3)) / 4
        //设置内边距
        $0.sectionInset = UIEdgeInsets(top: ZTScaleValue(0), left: (Screen.screenWidth - (ZTScaleValue(80) * 3)) / 4, bottom: ZTScaleValue(0), right: (Screen.screenWidth - (ZTScaleValue(80) * 3)) / 4)
    }

    lazy var funtionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.isScrollEnabled = false
        $0.register(ShareFileCell.self, forCellWithReuseIdentifier: ShareFileCell.reusableIdentifier)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.titleLabel.text = title
        self.selectCallback = callback
        let names = ["视频","图片","其他文件"]
        let imgs = [UIImage.assets(.update_video),
                    UIImage.assets(.update_picture),
                    UIImage.assets(.update_file)]
        for i in 0 ..< names.count {
            let model = ButtonModel()
            model.img = imgs[i] ?? UIImage()
            model.name = names[i]
            functionDatas.append(model)
        }
        funtionCollectionView.reloadData()
    }

    
    
    private func setupViews() {
        clipsToBounds = true
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(funtionCollectionView)
    }
    
    private func setupConstraints(){
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-ZTScaleValue(10))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(150))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(19))
            $0.left.right.equalToSuperview()
        }
        
        funtionCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(10)).priority(.high)
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.containerView.snp.updateConstraints {
                $0.height.equalTo(ZTScaleValue(150))
            }
            self.layoutIfNeeded()
        }


    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            self.layoutIfNeeded()
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }

    private func dismissWithCallback(idx: Int) {
        self.endEditing(true)
//        weak var weakSelf = self
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
//        }, completion: { isFinished in
//            if isFinished {
//                weakSelf?.selectCallback?(idx)
//                super.removeFromSuperview()
//            }
//        })
        selectCallback?(idx)
        super.removeFromSuperview()
    }

}

extension UpdateFileAlertView: UICollectionViewDelegate, UICollectionViewDataSource {
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return functionDatas.count
    }
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareFileCell.reusableIdentifier, for: indexPath) as! ShareFileCell
        cell.iconView.image = functionDatas[indexPath.item].img
        cell.fileNameLabel.text = functionDatas[indexPath.item].name
        cell.iconView.snp.updateConstraints {
            $0.width.height.equalTo(ZTScaleValue(30))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissWithCallback(idx: indexPath.item)
    }
}

