//
//  BaseViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit
@_exported import Then
@_exported import SnapKit
@_exported import MJRefresh
import Combine
import Toast_Swift

class BaseViewController: UIViewController {
    lazy var cancellables = [AnyCancellable]()
    
    var loadingView: LoadingView?
    
    lazy var navBackBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 25, height: 30)
        btn.setImage(.assets(.navigation_back), for: .normal)
        btn.addTarget(self, action: #selector(navPop), for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    public var disableSideSliding = false


    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("\(String(describing: self.classForCoder)) deinit.")
    }
    
    // MARK: - LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.white_ffffff)
        setupViews()
        setupConstraints()
        setupSubscriptions()
        // Do any additional setup after loading the view.
    }
        
    func setupViews() {}
    
    func setupConstraints() {}
    
    func setupSubscriptions() {}

}

// MARK: - Navigation stuff
extension BaseViewController: UIGestureRecognizerDelegate {
    private func setupNavigation() {
        /// navigationbar style
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backgroundColor = .custom(.white_ffffff)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663)]
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        
        /// navigation back gesture
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        ///
        if navigationController?.children.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBackBtn)
        }
                
    }

    @objc func navPop() {
        navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !disableSideSliding
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

extension BaseViewController {
    func showToast(_ toast: String) {
        SceneDelegate.shared.window?.makeToast(toast)
    }
    
    func showLoading(_ backgroundColor: UIColor = .clear) {
        loadingView?.removeFromSuperview()
        loadingView = LoadingView(frame: view.bounds)
        loadingView?.frame.size.height = view.bounds.size.height - Screen.k_nav_height
        loadingView?.backgroundColor = backgroundColor
        if let loadingView = loadingView {
            view.addSubview(loadingView)
            view.bringSubviewToFront(loadingView)
            loadingView.show()
        }
        
    }
    
    func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}
