//
//  HardDisksInfoAlert.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/30.
//

import UIKit

class HardDisksInfoAlert: UIView {

    var hardDisks = [PhysicalVolume]()
    

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "物理硬盘".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }
    
    private lazy var closeBtn = Button().then {
        $0.isEnhanceClick = true
        $0.setImage(.assets(.close_button), for: .normal)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = false
        
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemWH: CGFloat = (Screen.screenWidth - 75.ztScaleValue) / 2
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
    
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .custom(.white_ffffff)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reusableIdentifier)

        return collectionView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(hardDisks: [PhysicalVolume]) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.hardDisks = hardDisks
        titleLabel.text = "物理硬盘（\(hardDisks.count)个）"
        collectionView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(collectionView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeBtn)

    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(500.ztScaleValue)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20.ztScaleValue)
        }
        
        closeBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.width.equalTo(12.ztScaleValue)
        }

        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
        }
    }
    

    @objc private func close() {
        removeFromSuperview()
    }


    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 1
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension HardDisksInfoAlert: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hardDisks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        
        let hardDrive = hardDisks[indexPath.row]

        cell.nameLabel.text = hardDrive.name
        cell.sizeLabel.text = "\(ZTCTool.convertFileSize(size: hardDrive.capacity))"

        return cell
    }
    
    
}



// MARK: - ItemCell
extension HardDisksInfoAlert {
    class ItemCell: UICollectionViewCell, ReusableView {

        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.icon_hardDrive_purple)
        }
        

        
        lazy var nameLabel = UILabel().then {
            $0.font = .font(size: 16.ztScaleValue, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "硬盘".localizedString
        }
        
        lazy var sizeLabel = UILabel().then {
            $0.font = .font(size: 11.ztScaleValue, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "0GB".localizedString
        }


        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .custom(.gray_f2f5fa)
            clipsToBounds = true
            layer.cornerRadius = 10
            
            
            contentView.addSubview(icon)
            contentView.addSubview(nameLabel)
            contentView.addSubview(sizeLabel)

        }
        
        private func setupConstraints() {
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(19.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.height.equalTo(36.ztScaleValue)
                $0.width.equalTo(33.5.ztScaleValue)
            }
            

            
            nameLabel.snp.makeConstraints {
                $0.top.equalTo(icon.snp.bottom).offset(28.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.right.equalToSuperview().offset(-20.ztScaleValue)
            }
            
            sizeLabel.snp.makeConstraints {
                $0.top.equalTo(nameLabel.snp.bottom).offset(5.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.right.equalToSuperview().offset(-20.ztScaleValue)
                $0.bottom.equalToSuperview().offset(-20.ztScaleValue)
            }
            
        }

        
    }
    
}

