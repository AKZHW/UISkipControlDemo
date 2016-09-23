
# UISkipControlDemo
  UISkipControl 提供了管理当前页面跳转的整个流程，保证每一个Window上每时每刻只有一个跳转动画在执行，解决了同时 push pop 或者present造成crash
  的bug,
##使用方法
###1.正常的push
  
        let vc = UIViewController()
        self.navigationController?.pushViewController(vc, animated: true);
        let vc1 = UIViewController()
        self.navigationController?.pushViewController(vc1, animated: true); //会失败，因为同时进行两个push

  解决同事push的crash问题
  
###2.增加跳转队列，将将要跳转的操作加入到队列，当Window可以执行跳转时进行跳转
  
        let vc = UIViewController()
        self.navigationController?.pushViewController(vc, animated: true);
        let vc1 = UIViewController()
        self.navigationController?.pushViewController(vc, animated: true, allowQueued: true, completionBlock: nil) //成功，因为加入到队列了
  
  同时还能解决点击界面不同按钮误操作push两个VC的bug
  
