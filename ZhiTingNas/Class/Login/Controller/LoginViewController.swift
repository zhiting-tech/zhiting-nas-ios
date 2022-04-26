//
//  LoginViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/19.
//

import UIKit
import AttributedString
import WebKit

class LoginViewController: BaseViewController {
    @UserDefaultBool("IsAgreeUserAgreement")
    var isAgreeUserAgreement: Bool

    lazy var logoImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.logo_white)
    }
    
    lazy var bgView = ImageView().then {
        $0.image = .assets(.login_bg)
        $0.contentMode = .scaleAspectFill
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 12.5
    }

    lazy var phoneTextField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f5f5f5)
        $0.layer.cornerRadius = 10
        $0.font = .font(size: 16, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.placeholder = "请输入手机号"
        $0.keyboardType = .phonePad
        let leftView = phoneZoneView
        leftView.clipsToBounds = true
        $0.leftView = leftView
        $0.leftViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        $0.rightView = rightView
        $0.rightViewMode = .always
        $0.delegate = self
    }
    
    lazy var pwdTextField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f5f5f5)
        $0.layer.cornerRadius = 10
        $0.font = .font(size: 16, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.placeholder = "请输入密码"
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        $0.leftView = leftView
        $0.leftViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 33, height: 15))
        rightView.addSubview(secureButton)
        $0.rightView = rightView
        $0.rightViewMode = .always
        $0.isSecureTextEntry = true
    }
    
    lazy var errTipsLabel1 = UILabel().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.red_fe0000)
    }
    
    lazy var errTipsLabel2 = UILabel().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.red_fe0000)
    }
    
    private lazy var secureButton = Button(frame: CGRect(x: 0, y: 0, width: 18, height: 15)).then {
        $0.setImage(.assets(.view_off), for: .selected)
        $0.setImage(.assets(.view_on), for: .normal)
        $0.isEnhanceClick = true
        $0.isSelected = true
    }

    lazy var loginBtn = Button().then{
        $0.setTitle("登录", for: .normal)
        $0.backgroundColor = .custom(.blue_427aed)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.titleLabel?.textAlignment = .center
    }
    
    lazy var quickLoginBtn = Button().then{
        $0.setTitle("智汀家庭云快速登录", for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.titleLabel?.textAlignment = .center
    }
    
    lazy var agreeBtn = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_whiteBG), for: .selected)
        $0.isSelected = false
        $0.isEnhanceClick = true
        $0.clickCallBack = {
            $0.isSelected = !$0.isSelected
        }
    }
    
    lazy var userAgreementLabel = UILabel().then {
    
        $0.textColor = .custom(.white_ffffff)
        $0.font = .font(size: ZTScaleValue(11))
        $0.textAlignment = .center

        $0.attributed.text = "确认授权或登录即视为同意\("《用户协议》", .font(.systemFont(ofSize: ZTScaleValue(11))), .foreground(.custom(.white_ffffff)), .action(clickUserAreement), .underline(.single, color: nil))与\("《隐私政策》", .font(.systemFont(ofSize: ZTScaleValue(11))), .foreground(.custom(.white_ffffff)), .action(clickPrivacy), .underline(.single, color: nil))"
    }
    
    private var userAgreementAlert: UserAgreementAlertView?

    
    private func clickUserAreement(){
        print("点击《用户协议》")
        let webview = WebViewController(link: "\(cloudUrl)/zt-nas/protocol/user")
        webview.webViewTitle = "《用户协议》"
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    private func clickPrivacy(){
        print("点击《隐私政策》")
        let webview = WebViewController(link: "\(cloudUrl)/zt-nas/protocol/privacy")
        webview.webViewTitle = "《隐私政策》"
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    private lazy var phoneZoneView = PhoneZoneCodeView(frame: CGRect(x: 0, y: 0, width: 75, height: 40)).then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoneZone)))
    }
    
    private lazy var zoneViewAlert = PhoneZoneCodeViewAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 用于触发本地网络权限弹窗
        triggerLocalNetworkPrivacyAlert()
    }
    
    override func setupViews() {
        view.addSubview(bgView)
        view.addSubview(logoImgView)
        view.addSubview(containerView)
        containerView.addSubview(phoneTextField)
        containerView.addSubview(pwdTextField)
        containerView.addSubview(errTipsLabel1)
        containerView.addSubview(errTipsLabel2)
        containerView.addSubview(loginBtn)
        containerView.addSubview(quickLoginBtn)
        view.addSubview(agreeBtn)
        view.addSubview(userAgreementLabel)
        
        zoneViewAlert.selectCallback = { [weak self] zone in
            guard let self = self else { return }
            self.phoneZoneView.label.text = "+\(zone.code)"
        }
        
        zoneViewAlert.dismissCallback = { [weak self] in
            guard let self = self else { return }
            self.phoneZoneView.arrow.image = .assets(.arrow_down_regular)
        }

        loginBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.login()
        }

        secureButton.clickCallBack = { [weak self] button in
            guard let self = self else { return }
            button.isSelected = !button.isSelected
            self.pwdTextField.isSecureTextEntry = button.isSelected
        }
        
        if !isAgreeUserAgreement {
            userAgreementAlert = UserAgreementAlertView.show(target: self, message: "温馨提示", userAgreementCallback: {[weak self] tap in
                guard let self = self else {return}
                switch tap {
                case 0:
                    self.clickUserAreement()
                case 1:
                    self.clickPrivacy()
                default:
                    break
                }
            })
        }
            

                
        quickLoginBtn.clickCallBack = { [weak self] sender in
            guard let self = self else { return }
            
            if !self.agreeBtn.isSelected {
                self.showToast("请先阅读并同意智汀云盘的《用户协议》与《隐私政策》")
                sender.isUserInteractionEnabled = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    sender.isUserInteractionEnabled = true
                }
                return
            }
            
            if let url = URL(string: "zhiting://operation?action=diskAuth"), UIApplication.shared.canOpenURL(url) {
                print("跳转成功")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                
                if let url = URL(string: "https://apps.apple.com/us/app/%E6%99%BA%E6%B1%80%E5%AE%B6%E5%BA%AD%E4%BA%91/id1591550488"), UIApplication.shared.canOpenURL(url) {
                    print("跳转成功")
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImgView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top).offset(-50.ztScaleValue)
            $0.width.equalTo(93.5.ztScaleValue)
            $0.height.equalTo(105.ztScaleValue)
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        phoneTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.equalToSuperview().offset(22.5)
            $0.right.equalToSuperview().offset(-22.5)
            $0.height.equalTo(60)
        }
        
        errTipsLabel1.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(4)
            $0.left.equalTo(phoneTextField.snp.left)
            $0.right.equalTo(phoneTextField.snp.right)
        }
        
        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(22)
            $0.left.equalToSuperview().offset(22.5)
            $0.right.equalToSuperview().offset(-22.5)
            $0.height.equalTo(60)
        }

        errTipsLabel2.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(4)
            $0.left.equalTo(pwdTextField.snp.left)
            $0.right.equalTo(pwdTextField.snp.right)
        }

        loginBtn.snp.makeConstraints{
            $0.top.equalTo(pwdTextField.snp.bottom).offset(54)
            $0.left.equalToSuperview().offset(22.5)
            $0.right.equalToSuperview().offset(-22.5)
            $0.height.equalTo(60)
        }
        
        
        
        quickLoginBtn.snp.makeConstraints{
            $0.top.equalTo(loginBtn.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(22.5)
            $0.right.equalToSuperview().offset(-22.5)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-30)
        }
        
        userAgreementLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(ZTScaleValue(8))
            $0.bottom.equalTo(-ZTScaleValue(25.5))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
        }
        
        agreeBtn.snp.makeConstraints {
            $0.right.equalTo(userAgreementLabel.snp.left).offset(-ZTScaleValue(5))
            $0.width.height.equalTo(ZTScaleValue(14))
            $0.centerY.equalTo(userAgreementLabel)
        }
        
    }
}

extension LoginViewController {
    @objc private func selectPhoneZone() {
        phoneZoneView.arrow.image = .assets(.arrow_up_regular)
        let associatedFrame = containerView.convert(phoneTextField.frame, to: view)
        zoneViewAlert.setAssociateFrame(frame: associatedFrame)
        SceneDelegate.shared.window?.addSubview(zoneViewAlert)
    }
    
    private func login() {
        var flag = true
        
        if phoneTextField.text?.count ?? 0 < 11 {
            errTipsLabel1.text = "请输入正确的手机号码"
            flag = false
        }
        
        if pwdTextField.text == "" {
            errTipsLabel2.text = "请输入密码"
            flag = false
        }
        
        if !flag {
            return
        }

        if !agreeBtn.isSelected {
            showToast("请先阅读并同意智汀云盘的《用户协议》与《隐私政策》")
            loginBtn.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loginBtn.isUserInteractionEnabled = true
            }
            return
        }
        
        guard let phone = phoneTextField.text, let pwd = pwdTextField.text else { return }
        
        showLoading()
        NetworkManager.shared.login(phone: phone, pwd: pwd) { [weak self] response in
            guard let self = self else { return }
            
            NetworkManager.shared.getAreasToken(user_id: response.user_info.user_id, type: "2") { [weak self] areasResponse in
                let list = areasResponse.extension_token_list
                self?.hideLoading()
                let areas: [Area] = list.map { item in
                    let area = Area()
                    area.name = item.area_name
                    area.id = item.area_id
                    area.scope_token = item.token
                    area.sa_id = item.said
                    area.sa_user_id = item.sa_user_id
                    return area
                }
                
                if areas.count > 0 {
                    UserManager.shared.isCloudUser = true
                    let user = User()
                    user.phone = response.user_info.phone
                    user.nickname = response.user_info.nickname
                    user.user_id = response.user_info.user_id
                    UserManager.shared.currentUser = user
                    UserManager.shared.cacheUser(user: user)
                    AreaManager.shared.cacheAreas(areas: areas)

                    //授权成功，重新激活gomobile
                    SceneDelegate.shared.setupWindow()
                } else {
                    let alert = LoginNoAreaAlert()
                    alert.sureCallback = {
                        alert.removeFromSuperview()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
//                let vc = LoginSelectedAreaController()
//                vc.areas = areas
//                vc.complete = { model in
//                    let user = User()
//                    user.nickname = response.user_info.nickname
//                    user.phone = response.user_info.phone
//                    user.user_id = response.user_info.user_id
//                    UserManager.shared.currentUser = user
//                    UserManager.shared.isCloudUser = true
//                    UserManager.shared.cacheUser(user: user)
//
//                    let area = Area()
//                    area.id = model.area_id
//                    area.name = model.area_name
//                    area.scope_token = model.token
//                    area.sa_id = model.said
//                    area.sa_user_id = model.sa_user_id
//
//                    AreaManager.shared.cacheAreas(areas: [area])
//                    AreaManager.shared.currentArea = area
//
//                    //授权成功，重新激活gomobile
//                    SceneDelegate.shared.setupWindow()
//                }
//                self?.navigationController?.pushViewController(vc, animated: true)
            } failureCallback: { [weak self] code, err in
                self?.showToast(err)
            }
            
        } failureCallback: { [weak self] code, err in
            self?.showToast(err)
            self?.hideLoading()
        }

        
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        errTipsLabel1.text = ""
        errTipsLabel2.text = ""
        if let text = textField.text, textField == phoneTextField {
            textField.text = String(text.prefix(11))
        }
        
        
        
    }
}

extension LoginViewController {
    func triggerLocalNetworkPrivacyAlert() {
        let sock4 = socket(AF_INET, SOCK_DGRAM, 0)
        guard sock4 >= 0 else { return }
        defer { close(sock4) }
        let sock6 = socket(AF_INET6, SOCK_DGRAM, 0)
        guard sock6 >= 0 else { return }
        defer { close(sock6) }
        
        let addresses = addressesOfDiscardServiceOnBroadcastCapableInterfaces()
        var message = [UInt8]("!".utf8)
        for address in addresses {
            address.withUnsafeBytes { buf in
                let sa = buf.baseAddress!.assumingMemoryBound(to: sockaddr.self)
                let saLen = socklen_t(buf.count)
                let sock = sa.pointee.sa_family == AF_INET ? sock4 : sock6
                _ = sendto(sock, &message, message.count, MSG_DONTWAIT, sa, saLen)
            }
        }
    }
    /// Returns the addresses of the discard service (port 9) on every
    /// broadcast-capable interface.
    ///
    /// Each array entry is contains either a `sockaddr_in` or `sockaddr_in6`.
    private func addressesOfDiscardServiceOnBroadcastCapableInterfaces() -> [Data] {
        var addrList: UnsafeMutablePointer<ifaddrs>? = nil
        let err = getifaddrs(&addrList)
        guard err == 0, let start = addrList else { return [] }
        defer { freeifaddrs(start) }
        return sequence(first: start, next: { $0.pointee.ifa_next })
            .compactMap { i -> Data? in
                guard
                    (i.pointee.ifa_flags & UInt32(bitPattern: IFF_BROADCAST)) != 0,
                    let sa = i.pointee.ifa_addr
                else { return nil }
                var result = Data(UnsafeRawBufferPointer(start: sa, count: Int(sa.pointee.sa_len)))
                switch CInt(sa.pointee.sa_family) {
                case AF_INET:
                    result.withUnsafeMutableBytes { buf in
                        let sin = buf.baseAddress!.assumingMemoryBound(to: sockaddr_in.self)
                        sin.pointee.sin_port = UInt16(9).bigEndian
                    }
                case AF_INET6:
                    result.withUnsafeMutableBytes { buf in
                        let sin6 = buf.baseAddress!.assumingMemoryBound(to: sockaddr_in6.self)
                        sin6.pointee.sin6_port = UInt16(9).bigEndian
                    }
                default:
                    return nil
                }
                return result
            }
    }

}
