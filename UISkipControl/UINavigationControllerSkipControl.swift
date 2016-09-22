//
//  UINavigationControllerIsAnimated.swift
//  studySwift
//
//  Created by AKsoftware on 16/2/28.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var NavcompletionBlockKey:String = "NavcompletionBlockKey"
private var NavDelegateObjectKey:String = "NavDelegateObjectKey"

// MARK: - 扩展UINavigationController ，主要增加切换控制植入
/*
    对UINavigationController 切换方法进行替换，植入了切换控制
    并且增加了丰富的方法
 */
extension UINavigationController:UINavigationControllerDelegate{
    static var isNavExchange:Int? = 0;

    //完成回调，主要执行切换完成后的操作，由UISkipControlManager赋值
    var completionBlock:(()->Void)? {
        get{
            if objc_getAssociatedObject(self, &NavcompletionBlockKey) != nil {
                let completionBlockObject = objc_getAssociatedObject(self, &NavcompletionBlockKey) as? BlockObject
                return completionBlockObject?.completionBlock
            } else {
                return nil
            }
        }
        set{
            if newValue != nil {
                var completionBlockObject = objc_getAssociatedObject(self, &NavcompletionBlockKey) as? BlockObject
                if completionBlockObject != nil {
                    completionBlockObject?.completionBlock = newValue
                } else {
                    completionBlockObject = BlockObject(block: newValue)
                    objc_setAssociatedObject(self, &NavcompletionBlockKey, completionBlockObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                }
            } else {
                objc_setAssociatedObject(self, &NavcompletionBlockKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    //初始化方法，替换系统的push pop...等方法
    open override class func initialize() {
        if isNavExchange == 0 {
            //UISkipControlManager.shareInstance
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "pushViewController:animated:", currentMethodName: "skipControlPushViewController:animated:")
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "popViewControllerAnimated:", currentMethodName: "skipControlPopViewControllerAnimated:")
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "popToViewController:animated:", currentMethodName: "skipControlPopToViewController:animated:")
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "popToRootViewControllerAnimated:", currentMethodName: "skipControlPopToRootViewControllerAnimated:")
            isNavExchange = 1
        }
    }
    
    /// 替换原来的方法
    public func skipControlPushViewController(_ viewController:UIViewController, animated:Bool) {
        // 由于UINavigationController initWithRootViewController 会调用该方法，并且当时没有显示在Window上，所以特殊处理，此处不加控制，并不会造成crash
        if  self.viewControllers.count == 0 && animated == false {
            self.skipControlPushViewController(viewController, animated: animated)
            return
        }

        UISkipControlManager.shareInstance.skipViewController(self, skippedController: viewController, skipType: UISkipControlSkipType.UISkipControlSkipTypePush, isAllowQueued: false, isAnimated: animated, completionBlock: nil)
    }
    
    /// 执行push VC操作，主要增加了完成回调，是否放入队列操作
    ///
    /// - parameter viewController:  被push的 ViewController
    /// - parameter animated:        是否为动画执行
    /// - parameter allowQueued:     是否语队列执行
    /// - parameter completionBlock: 完成块
    func pushViewController(_ viewController: UIViewController, animated: Bool, allowQueued:Bool, completionBlock:(()->Void)?) {
        UISkipControlManager.shareInstance.skipViewController(self, skippedController: viewController, skipType: UISkipControlSkipType.UISkipControlSkipTypePush, isAllowQueued: allowQueued, isAnimated: animated, completionBlock: completionBlock)
    }

    //用来替换原来的popViewController
    public func skipControlPopViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        return self.popViewControllerAnimated(animated, allowQueued: false, completionBlock: nil)
    }

    /// 执行pop VC操作，主要增加了完成回调，是否放入队列操作
    ///
    /// - parameter animated:        是否为动画执行
    /// - parameter allowQueued:     是否语队列执行
    /// - parameter completionBlock: 完成块
    public func popViewControllerAnimated(_ animated: Bool, allowQueued: Bool, completionBlock:(()->Void)?) -> UIViewController? {
    
        let array = UISkipControlManager.shareInstance.skipViewController(self, skippedController: nil, skipType: UISkipControlSkipType.UISkipControlSkipTypePop, isAllowQueued: false, isAnimated: animated, completionBlock: completionBlock)
        if array != nil && (array?.count)! > 0 && array?[0] is UIViewController {
            return array?[0] as! UIViewController?
        }
        return nil
    }
    
    
    /// 执行popTo VC操作，主要增加了完成回调，是否放入队列操作
    ///
    /// - parameter viewController:  被popTo的 ViewController
    /// - parameter animated:        是否为动画执行
    /// - parameter allowQueued:     是否语队列执行
    /// - parameter completionBlock: 完成块
    public func popToViewController(_ viewController: UIViewController, animated: Bool,allowQueued: Bool, completionBlock:(()->Void)?) -> [UIViewController]? {
        return UISkipControlManager.shareInstance.skipViewController(self, skippedController: viewController, skipType: UISkipControlSkipType.UISkipControlSkipTypePopTo, isAllowQueued: false, isAnimated: animated, completionBlock: completionBlock) as! [UIViewController]?
    }
    
    public func skipControlPopToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return self.popToViewController(viewController, animated: animated, allowQueued: false, completionBlock: nil);
    }
    
    //popTo root
    
    public func skipControlPopToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        return self.popToRootViewControllerAnimated(animated, allowQueued: false, completionBlock: nil)
    }
    
    
    /// 执行popToRoot VC操作，主要增加了完成回调，是否放入队列操作
    ///
    /// - parameter animated:        是否为动画执行
    /// - parameter allowQueued:     是否语队列执行
    /// - parameter completionBlock: 完成块
    public func popToRootViewControllerAnimated(_ animated: Bool, allowQueued: Bool, completionBlock:(()->Void)?) -> [UIViewController]? {
        return UISkipControlManager.shareInstance.skipViewController(self, skippedController: nil, skipType: UISkipControlSkipType.UISkipControlSkipTypePopToRoot, isAllowQueued: false, isAnimated: animated, completionBlock: completionBlock) as! [UIViewController]?
    }
}
