//
//  FolderTransitionUtil.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/9.
//

import UIKit

class FolderTransitionUtil: NSObject {
    enum Operation {
        case present
        case dismiss
    }

    var operationType: Operation?

}

extension FolderTransitionUtil: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operationType = .present
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operationType = .dismiss
        return self
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

}

extension FolderTransitionUtil: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimation(context: transitionContext)
    }
    
    /// 转场动画
    private func transitionAnimation(context: UIViewControllerContextTransitioning) {
        /// 获取容器视图(转场动画发生的地方)
        let containerView = context.containerView
        
        /// 动画执行时间
        let duration = self.transitionDuration(using: context)

        guard
            let fromVC = context.viewController(forKey: .from),
            let fromView = fromVC.view,
            let toVC = context.viewController(forKey: .to),
            let toView = toVC.view,
            let operation = operationType
        else {
            return
        }
        
        var offset = containerView.frame.width
        
        var fromTransform = CGAffineTransform.identity
        var toTransform = CGAffineTransform.identity

        offset = operation == .present ? offset : -offset
        fromTransform = CGAffineTransform(translationX: -offset, y: 0)
        toTransform = CGAffineTransform(translationX: offset, y: 0)
        
        containerView.insertSubview(toView, at: 0)

        toView.transform = toTransform
        UIView.animate(withDuration: duration) {
            fromView.transform = fromTransform
            toView.transform = .identity
        } completion: { finished in
            fromView.transform = .identity
            toView.transform = .identity
            //考虑到转场中途可能取消的情况，转场结束后，恢复视图状态。(通知是否完成转场)
            let wasCancelled = context.transitionWasCancelled
            context.completeTransition(!wasCancelled)

        }


    }

}
