//
//  LoginViewController.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/19.
//

import UIKit

class LoginViewController: BaseViewController {

    lazy var logoImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.login_icon)
    }
    
    lazy var loginBtn = Button().then{
        $0.setTitle("智汀家居快速登陆", for: .normal)
        $0.backgroundColor = .custom(.blue_427aed)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.titleLabel?.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if let url = URL(string: "zhiting://operation?action=diskAuth"), UIApplication.shared.canOpenURL(url) {
                print("跳转成功")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showToast("请先安装 \"智汀家庭云\" APP")
                print("跳转失败")
            }
        }
    }
    
    override func setupViews() {
        self.view.addSubview(logoImgView)
        self.view.addSubview(loginBtn)
    }
    
    override func setupConstraints() {
        logoImgView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(ZTScaleValue(150))
            $0.width.height.equalTo(ZTScaleValue(135))
        }
        
        loginBtn.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-ZTScaleValue(100))
            $0.width.equalTo(ZTScaleValue(275))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
    }


}
