//
//  Button.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/17.
//

import UIKit

//MARK: -定义button相对label的位置
enum RGButtonImagePosition {
        case top          //图片在上，文字在下，垂直居中对齐
        case bottom       //图片在下，文字在上，垂直居中对齐
        case left         //图片在左，文字在右，水平居中对齐
        case right        //图片在右，文字在左，水平居中对齐
}

class Button: UIButton {

    /// if enhance the click scope
    lazy var isEnhanceClick = false
    /// enhance offset
    lazy var enhanceOffset: CGFloat = -20
    
    lazy var redPoint = UILabel().then{
        $0.backgroundColor = .custom(.red_fe0000)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .center
        $0.layer.cornerRadius = ZTScaleValue(5)
        $0.layer.masksToBounds = true
        $0.font = .font(size: ZTScaleValue(8), type: .medium)
    }
    
    /// click callback
    var clickCallBack: ((Button) -> ())? {
        didSet {
            addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func btnClick(_ btn: Button) {
        clickCallBack?(btn)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isEnhanceClick {
            let biggerFrame = self.bounds.inset(by: UIEdgeInsets.init(top: enhanceOffset, left: enhanceOffset, bottom: enhanceOffset, right: enhanceOffset))
            return biggerFrame.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
        
    }
    
    // MARK: - 添加右上角小红点
    public func setUpNumber(value: Int){
//        self.clipsToBounds = false
        redPoint.removeFromSuperview()//防止重叠
        redPoint.text = String(format: "%d", value)
        self.addSubview(redPoint)
        redPoint.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.right)
            $0.top.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(16))
        }
        if value == 0 {
            redPoint.removeFromSuperview()
        }
    }
    
    
    /// - Description 设置Button图片的位置
        /// - Parameters:
        ///   - style: 图片位置
        ///   - spacing: 按钮图片与文字之间的间隔
        func imagePosition(style: RGButtonImagePosition, spacing: CGFloat) {
            //得到imageView和titleLabel的宽高
            let imageWidth = self.imageView?.frame.size.width
            let imageHeight = self.imageView?.frame.size.height
            
            var labelWidth: CGFloat! = 0.0
            var labelHeight: CGFloat! = 0.0
            
            labelWidth = self.titleLabel?.intrinsicContentSize.width
            labelHeight = self.titleLabel?.intrinsicContentSize.height
            
            //初始化imageEdgeInsets和labelEdgeInsets
            var imageEdgeInsets = UIEdgeInsets.zero
            var labelEdgeInsets = UIEdgeInsets.zero
            
            //根据style和space得到imageEdgeInsets和labelEdgeInsets的值
            switch style {
            case .top:
                //上 左 下 右
                imageEdgeInsets = UIEdgeInsets(top: -labelHeight-spacing/2, left: 0, bottom: 0, right: -labelWidth)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-spacing/2, right: 0)
//                guard let imageView = self.imageView ,let titleLabel = self.titleLabel else {
//                    return
//                }
//                imageView.snp.remakeConstraints{
//                    $0.top.equalToSuperview()
//                    $0.centerX.equalToSuperview()
//                    $0.width.height.equalTo(ZTScaleValue(18))
//                }
//                titleLabel.snp.remakeConstraints{
//                    $0.top.equalTo(imageView.snp.bottom).offset(spacing)
//                    $0.centerX.equalToSuperview()
//                    $0.width.lessThanOrEqualTo(ZTScaleValue(18))
//                }
                break;
                
            case .left:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
                break;
                
            case .bottom:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-spacing/2, right: -labelWidth)
                labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2, left: -imageWidth!, bottom: 0, right: 0)
                break;
                
            case .right:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+spacing/2, bottom: 0, right: -labelWidth-spacing/2)
                labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!-spacing/2, bottom: 0, right: imageWidth!+spacing/2)
                break;
                
            }
            
            self.titleEdgeInsets = labelEdgeInsets
            self.imageEdgeInsets = imageEdgeInsets
            
        }

}
