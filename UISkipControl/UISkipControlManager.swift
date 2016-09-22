//
//  UISkipControlManager.swift
//  UISkipControl
//
//  Created by AKsoftware on 16/9/21.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import UIKit

/// 常用跳转类型 eg:push pop
enum UISkipControlSkipType : String {
    case UISkipControlSkipTypeNone = "None"
    case UISkipControlSkipTypePush = "Push"
    case UISkipControlSkipTypePop = "Pop"
    case UISkipControlSkipTypePopTo = "PopTo"
    case UISkipControlSkipTypePopToRoot = "PopToRoot"
    case UISkipControlSkipTypePresent = "Present"
    case UISkipControlSkipTypeDismiss = "Dismiss"
}

/// 各种VC跳转管理类，有一个单例来管理
class UISkipControlManager {

    /// 管理跳转的单例
    static let shareInstance = UISkipControlManager()

    init() {
        ///注册navigationController push or pop 完成后的通知 -- UINavigationControllerDidShowViewControllerNotification
        NotificationCenter.default.addObserver(self, selector:#selector(handleNavigationControllerDidSkip(_:)), name: NSNotification.Name(rawValue: "UINavigationControllerDidShowViewControllerNotification"), object: nil)
    }

    /// 执行navigationController切换后的完成块
    ///
    /// - parameter notification: 通知中包括发送通知的navigationController
    @objc public func handleNavigationControllerDidSkip(_ notification:NSNotification) {
        var navigationtroller:UINavigationController?
        if (notification.object != nil && notification.object is UINavigationController ) {
            navigationtroller = notification.object as! UINavigationController?
            if ((navigationtroller?.completionBlock) != nil) {
                navigationtroller?.completionBlock!()
            }
        }
    }

    /// 将UINavigationController 和 UIViewController 切换方式集中起来处理
    ///
    /// - parameter skipingController: 发起跳转的VC
    /// - parameter skippedController: 被跳转的VC 在pop ,popToRoot ，dismiss 时可以为空
    /// - parameter skipType:          跳转类型
    /// - parameter isAllowQueued:     是否允许将本次切换加入到队列中执行，由于加入队列，需要对skippedController强制持有
    /// - parameter isAnimated:        是否为有动画跳转
    /// - parameter completionBlock:   跳转完成回调
    ///
    /// - returns: 返回一个数组，报过了每种切换的结果
    func skipViewController(_ skipingController: UIViewController, skippedController: UIViewController?, skipType:UISkipControlSkipType, isAllowQueued:Bool, isAnimated:Bool, completionBlock:(()->Void)?) -> [AnyObject]? {
        
        /// 合法性检测，VC对应的Window必须存在
        weak var weakWindow = UIWindow.windowForViewController(skipingController)
        if weakWindow == nil {
            return nil
        }

        /// 构造切换完成后的清理工作
        weak var weakSkippingController = skipingController
        weak var weakSkippedController = skippedController
        let freeCompetionBlock = {

            //打印log
            let strongSkippingController = weakSkippingController
            let strongSkippedController = weakSkippedController
            print("DID -- \(strongSkippingController) \(skipType.rawValue) \(strongSkippedController)")
            
            //1. 切换完成后释放VC对应的Window的动画属性
            let strongWindow = weakWindow
            if (strongWindow != nil) {
                strongWindow?.isAnimated = false
            }
            
            //将2和3加入到主线程队列中执行，主要目的在于让系统完成自己的清场任务后执行，否则有问题
            DispatchQueue.main.async {
                //2. 执行自定义的完成切换回调
                if (completionBlock != nil) {
                    completionBlock!()
                }
                
                //3. 执行该VC Window对应的队列
                strongWindow?.performAnimationBlock()
            }
        }
        
        //判断当前Window是否可以执行VC切换
        if weakWindow != nil && weakWindow?.isAnimated == false {
            
            //可以执行切换，先锁定window
            weakWindow?.isAnimated = true;
            
            //log
            print("WILL -- \(skipingController) \(skipType.rawValue) \(skippedController)")
            
            //执行切换
            return self.performSkip(skipingController, skippedController: skippedController, skipType: skipType, isAnimated: isAnimated , completionBlock: freeCompetionBlock)
        } else if (isAllowQueued){
            
            //当前不能执行切换，但在允许加入队列的情况下，构造队列完成操作任务，加入到window队列
            weak var weakSelf = self
            weakWindow?.enqueueAnimationBlock {

                let strongSelf = weakSelf
                let strongSkippingController = weakSkippingController
                //let strongSkippedController = weakSkippedController 取消对 skippedController weak持有，否则push popTo present 无法执行
                if (strongSelf != nil && strongSkippingController != nil) {
                    //执行切换
                    strongSelf?.performSkip(strongSkippingController!, skippedController: skippedController, skipType: skipType, isAnimated: isAnimated, completionBlock: freeCompetionBlock)
                }
            }
            
            //log
            print("QUEUED -- \(skipingController) \(skipType.rawValue) \(skippedController)")
        }
        //log 当前无法进行切换
        print("FAILED -- \(skipingController) \(skipType.rawValue) \(skippedController)")
        return nil
    }
    
    /// 执行实际的切换过程
    ///
    /// - parameter skipingController: 发起切换的VC
    /// - parameter skippedController: 被
    /// - parameter skipType:          被跳转的VC 在pop ,popToRoot ，dismiss 时可以为空
    /// - parameter isAnimated:        是否为动画切换
    /// - parameter completionBlock:   完成块
    ///
    /// - returns: 返回一个数组，报过了每种切换的结果
    func performSkip(_ skipingController: UIViewController, skippedController: UIViewController?, skipType:UISkipControlSkipType, isAnimated:Bool, completionBlock:(()->Void)?) -> [AnyObject]? {
        
        //如果 skipingController 如果为UINavigationController，将完成块绑定到 skipingController
        if skipingController is UINavigationController {
            let navigationController:UINavigationController = skipingController as! UINavigationController
            navigationController.completionBlock = completionBlock
        }

        //根据不同的类型执行不同的切换
        switch skipType {
        //navigationController
        case .UISkipControlSkipTypePush:
            if skipingController is UINavigationController {
                let navigationController:UINavigationController = skipingController as! UINavigationController
                navigationController.skipControlPushViewController(skippedController!, animated:isAnimated)
                return nil
            }
        case .UISkipControlSkipTypePop:
            if skipingController is UINavigationController {
                let navigationController:UINavigationController = skipingController as! UINavigationController
                let popViewController = navigationController.skipControlPopViewControllerAnimated(isAnimated);
                var array:[AnyObject] = []
                if popViewController != nil {
                    array.append(popViewController!);
                    return array
                } else {
                    return nil
                }
            }
        case .UISkipControlSkipTypePopTo:
            if skipingController is UINavigationController {
                let navigationController:UINavigationController = skipingController as! UINavigationController
                return navigationController.skipControlPopToViewController(skippedController!, animated: isAnimated)
            }
        case .UISkipControlSkipTypePopToRoot:
            if skipingController is UINavigationController {
                let navigationController:UINavigationController = skipingController as! UINavigationController
                return navigationController.skipControlPopToRootViewControllerAnimated(isAnimated)
            }

        //Present - dismiss
        case .UISkipControlSkipTypePresent:
            skipingController.skipControlPresentViewController(skippedController!, animated: isAnimated, completion: completionBlock)
            return nil;
        case .UISkipControlSkipTypeDismiss:
            skipingController.skipControlDismissViewControllerAnimated(isAnimated, completion: completionBlock)
            return nil;
        default:
            return nil
        }
        return nil
    }
}
