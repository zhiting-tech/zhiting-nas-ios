//
//  ImageView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/17.
//

import UIKit
import Kingfisher


class ImageView: UIImageView {

    func setImage(urlString: String, placeHolder: UIImage? = nil, isAppendingPercent: Bool = true, complete:((UIImage?)->())? = nil) {
        contentMode = .scaleAspectFit
        guard let queryStr = isAppendingPercent ? urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) : urlString,
              let url = URL(string: queryStr)
        else {
            image = placeHolder
            return
        }

        var options = [KingfisherOptionsInfoItem]()
        /// retry
        let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(30))

        /// 请求头token
        let requestModifier = AnyModifier {  (request) -> URLRequest? in
            var modifierRequest = request
            modifierRequest.setValue(AreaManager.shared.currentArea.id, forHTTPHeaderField: "Area-ID")
            modifierRequest.setValue(AreaManager.shared.currentArea.scope_token, forHTTPHeaderField: "scope-token")
            return modifierRequest
        }
        
        
        options.append(.cacheOriginalImage)
        options.append(.retryStrategy(retry))
        options.append(.requestModifier(requestModifier))
        
        kf.setImage(with: url, placeholder: placeHolder, options: options) { result in
            switch result {
            case .success(let res):
                complete?(res.image)
            default:
                complete?(nil)
            }
        }

    
    }


}

/// kingfisher 图片加载证书信任
class KFCerAuthenticationChallenge: AuthenticationChallengeResponsible {
    static let shared = KFCerAuthenticationChallenge()
    
    public func downloader(
        _ downloader: ImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }

    public func downloader(
        _ downloader: ImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
}
