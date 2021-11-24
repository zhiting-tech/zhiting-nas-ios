//
//  TabbarController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit

class TabbarController: UITabBarController {
    
    var myFileVC: MyFileViewController?
    var shareFileVC: ShareFileViewController?
    var mineVC: MineViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configTabbar()
        setUpChilds()
    }
    
}

extension TabbarController{
    private func configTabbar() {
        tabBar.backgroundColor = .custom(.white_ffffff)
        tabBar.barTintColor = .custom(.white_ffffff)
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = false
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.05
        tabBar.layer.shadowRadius = 8
        tabBar.layer.shadowOffset = CGSize(width: ZTScaleValue(-0.1), height: ZTScaleValue(-0.1))
    }

    private func setUpChilds(){
        let myFileVC = MyFileViewController()
        set(vc: myFileVC, title: "文件".localizedString, image: .assets(.myFile_tab), selImage: .assets(.myFile_tab_sel))
        myFileVC.tabBarItem.tag = 0
        let myFileNav = BaseNavigationViewController(rootViewController: myFileVC)
        self.myFileVC = myFileVC
        
        let shareFileVC = ShareFileViewController()
        set(vc: shareFileVC, title: "共享文件".localizedString, image: .assets(.shareFile_tab), selImage: .assets(.shareFile_tab_sel))
        shareFileVC.tabBarItem.tag = 1
        let shareFileNav = BaseNavigationViewController(rootViewController: shareFileVC)
        self.shareFileVC = shareFileVC
        
        let mineVC = MineViewController()
        set(vc: mineVC, title: "我的".localizedString, image: .assets(.mine_tab), selImage: .assets(.mine_tab_sel))
        mineVC.tabBarItem.tag = 2
        let mineNav = BaseNavigationViewController(rootViewController: mineVC)
        self.mineVC = mineVC
        
        addChild(myFileNav)
        addChild(shareFileNav)
        addChild(mineNav)
    }
    
    private func set(vc: UIViewController, title: String, image: UIImage?, selImage: UIImage?) {
        vc.title = title

        let titleAttNormal = [NSAttributedString.Key.font: UIFont.font(size: 11),NSAttributedString.Key.foregroundColor: UIColor.custom(.gray_a2a7ae)]
        let titleAttSel = [NSAttributedString.Key.font: UIFont.font(size: 11),NSAttributedString.Key.foregroundColor: UIColor.custom(.blue_427aed)]

        vc.tabBarItem.setTitleTextAttributes(titleAttNormal, for: .normal)
        vc.tabBarItem.setTitleTextAttributes(titleAttSel, for: .selected)
        vc.tabBarItem.image = image?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = selImage?.withRenderingMode(.alwaysOriginal)

    }
}
