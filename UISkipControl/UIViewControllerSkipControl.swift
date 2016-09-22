//
//  UIViewControllerSkipControl.swift
//  studySwift
//
//  Created by AKsoftware on 16/2/29.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

// MARK: - UIViewController 扩展，主要提供多种present dismiss方法

/*
    扩展UIViewController，替换系统方法，用来增加Window控制
 */

extension UIViewController {
    
    //初始化，执行替换
    static var isExchange:Int? = 0;
    open override class func initialize() {
        if isExchange == 0 {
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "presentViewController:animated:completion:", currentMethodName: "skipControlPresentViewController:animated:completion:")
            UISkipControlHelper.exchangeMethod(className: self, originMethodName: "dismissViewControllerAnimated:completion:", currentMethodName: "skipControlDismissViewControllerAnimated:completion:")
            isExchange = 1
        }
    }
    
    // 替换原来的presentViewContoller方法后的方法
    public func skipControlPresentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? ) {
        self.presentViewController(viewControllerToPresent, animated: flag, allowQueued: false, completion: completion);
    }

    /// 执行present VC 操作，主要增加了是否加入队列参数
    ///
    /// - parameter viewControllerToPresent: 被切换的VC
    /// - parameter flag:                    是否为动画切换
    /// - parameter allowQueued:             是否能加入队列
    /// - parameter completion:              切换完成后的糊掉
    public func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool, allowQueued: Bool, completion: (() -> Void)?) {
        UISkipControlManager.shareInstance.skipViewController(self, skippedController: viewControllerToPresent, skipType:UISkipControlSkipType.UISkipControlSkipTypePresent, isAllowQueued: allowQueued, isAnimated:flag, completionBlock: completion)
    }
    
    
    /// 替换dismiss 函数
    public func skipControlDismissViewControllerAnimated(_ flag:Bool, completion: (() -> Void)?) {
        self.dismissViewControllerAnimated(flag, allowQueued: false, completion: completion)
    }

    /// 执行dismiss VC 操作，主要增加了是否加入队列参数
    ///
    /// - parameter flag:                    是否为动画切换
    /// - parameter allowQueued:             是否能加入队列
    /// - parameter completion:              切换完成后的糊掉
    public func dismissViewControllerAnimated(_ flag:Bool, allowQueued:Bool, completion: (() -> Void)?) {
        UISkipControlManager.shareInstance.skipViewController(self, skippedController: nil, skipType:UISkipControlSkipType.UISkipControlSkipTypeDismiss, isAllowQueued: allowQueued, isAnimated:flag, completionBlock: completion)
    }

    
}
