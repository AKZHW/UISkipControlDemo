//
//  UISkipControlHelper.swift
//  studySwift
//
//  Created by AKsoftware on 16/2/29.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import ObjectiveC

class UISkipControlHelper: NSObject {
     class func exchangeMethod(className:AnyClass, originMethodName:String, currentMethodName:String) {
        let originalPushSelector = Selector(originMethodName)
        let skipControlPushSelector = Selector(currentMethodName)
        
        let originalPushMethod = class_getInstanceMethod(className, originalPushSelector)
        let skipControlPushMethod = class_getInstanceMethod(className, skipControlPushSelector)
        
        let didAddMethod = class_addMethod(className, originalPushSelector, method_getImplementation(skipControlPushMethod), method_getTypeEncoding(skipControlPushMethod))
        if didAddMethod {
            class_replaceMethod(className, skipControlPushSelector, method_getImplementation(originalPushMethod), method_getTypeEncoding(originalPushMethod))
        } else {
            method_exchangeImplementations(originalPushMethod, skipControlPushMethod)
        }
    }
}

class BlockObject {
    /// real block
    var completionBlock:(()->Void)?

    init(block: (()->Void)?) {
        self.completionBlock = block
    }

    func performBlock(){
        if (self.completionBlock != nil) {
            self.completionBlock!();
        }
    }
}
