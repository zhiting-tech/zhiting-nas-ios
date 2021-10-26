//
//  EditFolderCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/1.
//

import UIKit
import Combine

class EditFolderCell: UITableViewCell, ReusableView {
    var validatePublisher = PassthroughSubject<Void, Never>()

    var selectIndexCallback: ((Int) -> ())? {
        didSet {
            selectView.selectIndexCallback = { [weak self] idx in
                self?.selectIndexCallback?(idx)
                self?.validatePublisher.send(())
            }
        }
    }
    
    var tapBtnCallback: (() -> ())?

    enum EditFolderCellType {
        case textField(title: String, placeHolder: String, isSecure: Bool)
        case selectView(title: String, selection1: String, selection2: String)
        case rightButton(title: String, placeHolder: String)
    }

    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "名称"
    }
    
    lazy var textField = UITextField().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.delegate = self
    }
    
    lazy var detailLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "名称"
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBtn)))
    }
    
    lazy var arrowDown = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.arrow_down)
    }

    lazy var selectView = SelectView()
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }


    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tapBtn() {
        tapBtnCallback?()
    }
    
    convenience init(type: EditFolderCellType) {
        self.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: EditFolderCell.reusableIdentifier)
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(line)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18.ztScaleValue)
            $0.left.equalToSuperview().offset(16.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-18.ztScaleValue)
            $0.width.equalTo(65.ztScaleValue)
        }
        
        line.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(titleLabel.snp.right).offset(20.ztScaleValue)
            $0.height.equalTo(0.5)
            $0.right.equalToSuperview()
        }


        switch type {
        case .rightButton(let title, let placeHolder):
            titleLabel.text = title
            contentView.addSubview(detailLabel)
            contentView.addSubview(arrowDown)
            
            detailLabel.text = placeHolder
            
            
            detailLabel.snp.makeConstraints {
                $0.left.equalTo(line.snp.left)
                $0.right.lessThanOrEqualToSuperview().offset(ZTScaleValue(-25.ztScaleValue))
                $0.centerY.equalTo(titleLabel.snp.centerY)
            }

            arrowDown.snp.makeConstraints {
                $0.centerY.equalTo(detailLabel.snp.centerY)
                $0.left.equalTo(detailLabel.snp.right).offset(10)
                $0.height.equalTo(4.ztScaleValue)
                $0.width.equalTo(8.ztScaleValue)
            }

        case .selectView(let title, let selection1, let selection2):
            contentView.addSubview(selectView)
            titleLabel.text = title
            selectView.item1.label.text = selection1
            selectView.item2.label.text = selection2
            
            selectView.snp.makeConstraints {
                $0.left.equalTo(line.snp.left)
                $0.right.equalToSuperview()
                $0.centerY.equalTo(titleLabel.snp.centerY)
                
            }
            
            selectView.selectedIndex = 1

        case .textField(let title, let placeHolder, let isSecure):
            titleLabel.text = title
            textField.placeholder = placeHolder
            textField.isSecureTextEntry = isSecure
            contentView.addSubview(textField)
            
            textField.snp.makeConstraints {
                $0.left.equalTo(line.snp.left)
                $0.right.equalToSuperview().offset(-15.ztScaleValue)
                $0.centerY.equalTo(titleLabel.snp.centerY)
            }

        }

    }
    

}

extension EditFolderCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, text.count > 100 {
            self.textField.text = String(text.prefix(100))
        }
        
        validatePublisher.send(())
        
    }
}

extension EditFolderCell {
    class SelectView: UIView {
        var selectIndexCallback: ((Int) -> ())?

        var selectedIndex = 0 {
            didSet {
                if selectedIndex == 0 {
                    item1.isSelected = true
                    item2.isSelected = false
                } else if selectedIndex == 1 {
                    item1.isSelected = false
                    item2.isSelected = true
                } else {
                    item1.isSelected = false
                    item2.isSelected = false
                }
            }
        }

        lazy var item1 = SelectItemView()
        
        lazy var item2 = SelectItemView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(item1)
            addSubview(item2)

            item1.snp.makeConstraints {
                $0.top.bottom.left.equalToSuperview()
                $0.width.greaterThanOrEqualTo(130.ztScaleValue)
            }
            
            item2.snp.makeConstraints {
                $0.left.equalTo(item1.snp.right)
                $0.top.bottom.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.width.greaterThanOrEqualTo(130.ztScaleValue)
            }
            
            item1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapItem1)))
            item1.isUserInteractionEnabled = true
            item2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapItem2)))
            item2.isUserInteractionEnabled = true
            
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func tapItem1() {
            selectedIndex = 0
            selectIndexCallback?(0)
        }
        
        @objc private func tapItem2() {
            selectedIndex = 1
            selectIndexCallback?(1)
        }


    }
    
    class SelectItemView: UIView {
        var isSelected: Bool? {
            didSet {
                guard let isSelected = isSelected else { return }
                icon.image = isSelected ? .assets(.fileSelected_selected) : .assets(.fileSelected_normal)
                label.textColor = isSelected ? .custom(.black_3f4663) : .custom(.gray_a2a7ae)
            }
        }

        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.fileSelected_normal)
        }
        
        lazy var label = UILabel().then {
            $0.font = .font(size: 14.ztScaleValue, type: .bold)
            $0.textColor = .custom(.gray_a2a7ae)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(icon)
            addSubview(label)
            
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(15.ztScaleValue)
                $0.height.width.equalTo(12.ztScaleValue)
                $0.left.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
            }

            label.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.left.equalTo(icon.snp.right).offset(10)
                $0.right.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
