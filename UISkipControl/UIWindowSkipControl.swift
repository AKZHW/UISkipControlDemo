//
//  UIWindowAnimated.swift
//  studySwift
//
//  Created by AKsoftware on 16/2/27.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var isAnimatedKey:String = "isAnimatedKey"
private var skipAnimationQueueKey:String = "skipAnimationQueueKey"

typealias SkipAnimationBlock = () -> Void

// MARK: - UIWindow 的扩展，给Window 增加isAnimated 动画切换标志， 队列属性
/* 
    切换的原则，每一个Window上同一时间只能进行一个动画，所以增加isAnimated 来标志
    当前是否正在执行切换，用skipAnimationQueue 来组织Window上的切换动
 */
extension UIWindow {
    
    //动画标志状态
    var isAnimated: Bool {
        get{
            if objc_getAssociatedObject(self, &isAnimatedKey) != nil {
                return (objc_getAssociatedObject(self, &isAnimatedKey) as? Bool)!
            }
            return false
        }
        set{
            objc_setAssociatedObject(self, &isAnimatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    //队列
    fileprivate var skipAnimationQueue:[BlockObject]{
        get {
            if objc_getAssociatedObject(self, &skipAnimationQueueKey) != nil {
                return objc_getAssociatedObject(self, &skipAnimationQueueKey) as! [BlockObject]
            } else {
                let queue:[BlockObject] = [BlockObject]()
                self.skipAnimationQueue = queue;
                return queue;
            }
        }
        set {
            objc_setAssociatedObject(self, &skipAnimationQueueKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //队列执行函数
    func performAnimationBlock()
    {
        if self.isAnimated == false {
            if self.skipAnimationQueue.count > 0 {
                let blockObject = self.skipAnimationQueue.first
                if blockObject != nil {
                    blockObject!.performBlock()
                    self.skipAnimationQueue.removeFirst()
                }
            }
        }
    }

    //加入队列
    public func enqueueAnimationBlock(_ block:@escaping ()->()){
        self.skipAnimationQueue.append(BlockObject(block: block))
    }
    
    //辅助函数，通过VC获取Window
    class func windowForViewController(_ viewController :UIViewController?) ->UIWindow? {
        var currentController:UIViewController? = viewController
        while(currentController != nil && currentController?.view.window == nil) {
            currentController = currentController?.presentedViewController
        }
        return currentController?.view.window
    }
}
