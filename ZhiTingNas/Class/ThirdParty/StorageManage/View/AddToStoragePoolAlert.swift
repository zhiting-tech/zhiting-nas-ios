//
//  AddToStoragePoolAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/29.
//

import UIKit

class AddToStoragePoolAlert: UIView {
    var selectCallback: ((_ storagePool: StoragePoolModel) -> ())?

    var storagePools = [StoragePoolModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedIndex = 0

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "添加至".localizedString
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
    
    private lazy var sureBtn = LoadingButton().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.blue_427aed)
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
        collectionView.register(SelectCell.self, forCellWithReuseIdentifier: SelectCell.reusableIdentifier)

        return collectionView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
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
        containerView.addSubview(sureBtn)

        sureBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if self.storagePools.count > 0 {
                self.startBtnLoading()
                self.selectCallback?(self.storagePools[self.selectedIndex])
            }
            
        }
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

        sureBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
        }

        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16.ztScaleValue)
            $0.bottom.equalTo(sureBtn.snp.top).offset(-15.ztScaleValue)
        }
    }
    

    @objc private func close() {
        removeFromSuperview()
    }

    func startBtnLoading() {
        self.sureBtn.buttonState = .waiting
        collectionView.isUserInteractionEnabled = false
    }

    func stopBtnLoading() {
        self.sureBtn.buttonState = .normal
        collectionView.isUserInteractionEnabled = true
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

extension AddToStoragePoolAlert: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storagePools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCell.reusableIdentifier, for: indexPath) as! SelectCell
        cell.isPicked = (selectedIndex == indexPath.row)
        cell.nameLabel.text = storagePools[indexPath.row].name
        cell.sizeLabel.text = "\(storagePools[indexPath.row].use_capacity)GB/\(storagePools[indexPath.row].use_capacity)GB"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
        
    }

    
}



// MARK: - SelectCell
extension AddToStoragePoolAlert {
    class SelectCell: UICollectionViewCell, ReusableView {
        var isPicked = false {
            didSet {
                selectedBtn.image = isPicked ? .assets(.selected_whiteBG) : .assets(.unselected_tick)
                backgroundColor = isPicked ? .custom(.blue_427aed) : .custom(.gray_f2f5fa)
                nameLabel.textColor = isPicked ? .custom(.white_ffffff) : .custom(.black_3f4663)
                sizeLabel.textColor = isPicked ? .custom(.white_ffffff) : .custom(.black_3f4663)
            }
        }


        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.icon_storagePool)
        }
        
        lazy var selectedBtn = ImageView().then {
            $0.image = .assets(.fileSelected_normal)
            $0.contentMode = .scaleAspectFit
        }

        
        lazy var nameLabel = UILabel().then {
            $0.font = .font(size: 16.ztScaleValue, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "存储池".localizedString
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
            contentView.addSubview(selectedBtn)
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
            
            selectedBtn.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.right.equalToSuperview().offset(-10)
                $0.width.height.equalTo(16)
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

