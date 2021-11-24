//
//  EditFolderStorageCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/7/6.
//

import UIKit

class EditFolderStorageCell: UITableViewCell,ReusableView {

    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.myFile_tab)
    }
    
    lazy var nameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    lazy var selectBtn = Button().then{
        $0.setImage(.assets(.fileSelected_normal), for: .normal)
        $0.setImage(.assets(.fileSelected_selected), for: .selected)
    }
    //当前选择的类型(选择存储池或分区)
    var chooeseType = ButtonSeletedType.StoragePool
    
    var currentstoragePoolModel = StoragePoolModel()
    var currentPartitionModel = LogicVolume()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setStoragePoolModel(currentModel: StoragePoolModel) {
        currentstoragePoolModel = currentModel
        
        iconImgView.image = .assets(.icon_storagePool)

        nameLabel.text = currentModel.name
        selectBtn.isSelected = currentModel.isSelected ?? false
        setupViews()
    }
    
    public func setPartitionModel(currentModel: LogicVolume) {
        currentPartitionModel = currentModel
        iconImgView.image = .assets(.icon_storagePoolPartition)
        nameLabel.text = currentModel.name
        selectBtn.isSelected = currentModel.isSelected ?? false
        setupViews()
    }

    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(selectBtn)
        
        iconImgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(14.5))
            $0.width.equalTo(ZTScaleValue(37.5))
            $0.height.equalTo(ZTScaleValue(38))
        }
        
        selectBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(14.5))
            $0.width.equalTo(ZTScaleValue(12))
            $0.height.equalTo(ZTScaleValue(12))
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(17.5))
            $0.right.equalTo(selectBtn.snp.left).offset(-ZTScaleValue(10))
            $0.height.equalTo(ZTScaleValue(15))
        }
    }
    
    override func prepareForReuse() {
        iconImgView.removeFromSuperview()
        nameLabel.removeFromSuperview()
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
