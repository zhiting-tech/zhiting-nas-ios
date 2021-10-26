//
//  ImageView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/17.
//

import UIKit
import Kingfisher


class ImageView: UIImageView {

    func setImage(urlString: String, placeHolder: UIImage? = nil) {
        contentMode = .scaleAspectFit
        guard let queryStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
//            modifierRequest.setValue("\(AppDelegate.shared.appDependency.currentAreaManager.currentArea.id)", forHTTPHeaderField: "Area-ID")
            return modifierRequest
        }
        
        
        options.append(.cacheOriginalImage)
        options.append(.retryStrategy(retry))
        options.append(.requestModifier(requestModifier))
        
        kf.setImage(with: url,placeholder: placeHolder, options: options)

    
    }


}
