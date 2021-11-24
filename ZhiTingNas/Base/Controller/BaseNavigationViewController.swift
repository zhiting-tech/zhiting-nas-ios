//
//  BaseNavigationViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !(viewController is MyFileViewController || viewController is ShareFileViewController || viewController is MineViewController) {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count == 1 {
            self.dismiss(animated: animated, completion: nil)
        }
        return super.popViewController(animated: animated)
    }
}

class BaseProNavigationViewController: BaseNavigationViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

