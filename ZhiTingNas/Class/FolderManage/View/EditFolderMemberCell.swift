//
//  EditFolderMemberCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/2.
//

import UIKit


class EditFolderMemberCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else { return }
            nicknameLabel.text = member.nickname
            var items = [AuthView.ItemType]()
            if member.read == 1 { items.append(.read) }
            if member.write == 1 { items.append(.write) }
            if member.deleted == 1 { items.append(.delete) }
            authView.setItems(items: items)
        }
    }

    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.user_default)
        $0.layer.cornerRadius = 20.ztScaleValue
    }
    
    private lazy var nicknameLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "User"
    }
    
    lazy var editBtn = Button().then {
        $0.setImage(.assets(.btn_edit), for: .normal)
    }

    lazy var deleteBtn = Button().then {
        $0.setImage(.assets(.btn_delete), for: .normal)
    }

    private lazy var authView = AuthView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(avatar)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(editBtn)
        contentView.addSubview(deleteBtn)
        contentView.addSubview(authView)
        

    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.height.width.equalTo(40.ztScaleValue).priority(.high)
            $0.top.equalToSuperview().offset(10.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-10.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(30.ztScaleValue)
        }
        
        editBtn.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.right.equalTo(deleteBtn.snp.left).offset(-15)
            $0.height.width.equalTo(30.ztScaleValue)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top)
            $0.left.equalTo(avatar.snp.right).offset(10)
            $0.right.equalTo(editBtn.snp.left).offset(-10)
        }
        
        authView.snp.makeConstraints {
            $0.bottom.equalTo(avatar.snp.bottom)
            $0.left.equalTo(avatar.snp.right).offset(10)
            $0.right.equalTo(editBtn.snp.left).offset(-10)
            $0.height.equalTo(16.ztScaleValue)
        }



    }

    
}


extension EditFolderMemberCell {
    class AuthView: UIView {
        enum ItemType {
            case read
            case write
            case delete
        }

        private lazy var readItem = AuthItemView(frame: CGRect(x: 0, y: 0, width: 35.ztScaleValue, height: 16.ztScaleValue)).then { $0.titleLabel.text = "可读" }
        
        private lazy var writeItem = AuthItemView(frame: CGRect(x: 0, y: 0, width: 35.ztScaleValue, height: 16.ztScaleValue)).then { $0.titleLabel.text = "可写" }
        
        private lazy var deleteItem = AuthItemView(frame: CGRect(x: 0, y: 0, width: 35.ztScaleValue, height: 16.ztScaleValue)).then { $0.titleLabel.text = "可删" }

        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setItems(items: [ItemType]) {
            readItem.removeFromSuperview()
            writeItem.removeFromSuperview()
            deleteItem.removeFromSuperview()
            var margin: CGFloat = 0
            items.forEach { item in
                if item == .read {
                    addSubview(readItem)
                    readItem.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.left.equalToSuperview().offset(margin)
                        $0.height.equalTo(16.ztScaleValue)
                        $0.width.equalTo(35.ztScaleValue)
                    }

                } else if item == .write {
                    addSubview(writeItem)
                    writeItem.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.left.equalToSuperview().offset(margin)
                        $0.height.equalTo(16.ztScaleValue)
                        $0.width.equalTo(35.ztScaleValue)
                    }
                } else if item == .delete {
                    addSubview(deleteItem)
                    deleteItem.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.left.equalToSuperview().offset(margin)
                        $0.height.equalTo(16)
                        $0.width.equalTo(35)
                    }
                }
                
                margin += 45.ztScaleValue
            }

        }

    }
    
    class AuthItemView: UIView {
        lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 11.ztScaleValue, type: .medium)
            $0.textColor = .custom(.white_ffffff)
            $0.textAlignment = .center

        }
        
        
        lazy var bgView = ImageView().then {
            $0.image = getGradientImageWithColors(colors: [UIColor(red: 255/255, green: 109/255, blue: 87/255, alpha: 1),  UIColor(red: 255/255, green: 140/255, blue: 123/255, alpha: 1)], imgSize: CGSize(width: 35, height: 16))
        }
            
            
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            layer.cornerRadius = 2.ztScaleValue
            addSubview(bgView)
            addSubview(titleLabel)
            
            bgView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func getGradientImageWithColors(colors:[UIColor],imgSize: CGSize) -> UIImage {
            
            var arRef = [CGColor]()
            colors.forEach { (ref) in
                arRef.append(ref.cgColor)
            }
            UIGraphicsBeginImageContextWithOptions(imgSize, true, 1)
            let context = UIGraphicsGetCurrentContext()
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: arRef as CFArray, locations: nil)!
            context!.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: imgSize.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))

            let outputImage = UIImage.init(cgImage: (UIGraphicsGetImageFromCurrentImageContext()?.cgImage)!)
            UIGraphicsEndImageContext()

            return outputImage
        }
        
    }

}
