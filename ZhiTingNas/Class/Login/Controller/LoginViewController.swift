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
    
    lazy var agreeBtn = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_blueBG), for: .selected)
        $0.isSelected = false
        $0.clickCallBack = {
            $0.isSelected = !$0.isSelected
        }
    }
    
    lazy var userAgreementLabel = UILabel().then {
    
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(11))
        $0.textAlignment = .center
        
        $0.attributed.text = "确认授权或登录即视为同意\("《用户协议》", .font(.systemFont(ofSize: ZTScaleValue(11))), .foreground(.custom(.blue_2da3f6)), .action(clickUserAreement))与\("《隐私政策》", .font(.systemFont(ofSize: ZTScaleValue(11))), .foreground(.custom(.blue_2da3f6)), .action(clickPrivacy))"
    }
    
    private var userAgreementAlert: UserAgreementAlertView?

    
    private func clickUserAreement(){
        print("点击《用户协议》")
        let webview = WebViewController(link: "https://scgz.zhitingtech.com/zt-nas/protocol/user")
        webview.webViewTitle = "《用户协议》"
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    private func clickPrivacy(){
        print("点击《隐私政策》")
        let webview = WebViewController(link: "https://scgz.zhitingtech.com/zt-nas/protocol/privacy")
        webview.webViewTitle = "《隐私政策》"
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
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
            

                
        loginBtn.clickCallBack = {[weak self] sender in
            guard let self = self else {return}
            
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
        self.view.addSubview(logoImgView)
        self.view.addSubview(loginBtn)
        self.view.addSubview(agreeBtn)
        self.view.addSubview(userAgreementLabel)
    }
    
    override func setupConstraints() {
        logoImgView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(ZTScaleValue(150))
            $0.width.height.equalTo(ZTScaleValue(135))
        }
        
        loginBtn.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-ZTScaleValue(130))
            $0.width.equalTo(ZTScaleValue(275))
            $0.height.equalTo(ZTScaleValue(50))
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
