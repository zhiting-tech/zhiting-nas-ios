//
//  UserShareInfoCell.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/24.
//

import UIKit

class UserShareInfoCell: UITableViewCell,ReusableView {

    lazy var userImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.user_default)
    }
    
    lazy var userNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    lazy var selectBtn = Button().then{
        $0.setImage(.assets(.shareSelected_normal), for: .normal)
        $0.setImage(.assets(.shareSelected_selected), for: .selected)
    }
    
    var currentUserModel = User()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setModel(currentModel: User) {
        currentUserModel = currentModel
        userImgView.setImage(urlString: currentModel.icon_url, placeHolder: .assets(.user_default))
        userNameLabel.text = currentModel.nickname
        selectBtn.isSelected = currentModel.isSelected ?? false
        setupViews()
    }
    
    private func setupViews(){
        contentView.addSubview(userImgView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(selectBtn)
        
        userImgView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(40))
            $0.left.equalTo(ZTScaleValue(15))
        }
                
        selectBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(16))
        }
        
        userNameLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.left.equalTo(userImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
    }
    
    override func prepareForReuse() {
        userImgView.removeFromSuperview()
        userNameLabel.removeFromSuperview()
        selectBtn.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
