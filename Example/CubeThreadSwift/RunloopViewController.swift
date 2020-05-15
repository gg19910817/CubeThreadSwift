//
//  RunloopViewController.swift
//  CubeThreadSwift_Example
//
//  Created by gg19910817 on 2020/5/15.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class RunloopViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        runloop()
        addObserver()
    }
    
    /*
     Tips: Runloop
     1. https://www.jianshu.com/p/d260d18dd551
     2. 每个线程最多有一个Runloop对象，用来处理触摸事件、UI刷新事件、定时器事件、Selector事件
     3. 主线程runloop在UIApplicationMain方法中被默认打开，并以Default方式运行。
     4. 子线程的runloop使用懒加载方式，在第一次获取 RunLoop 时创建，销毁则是在线程结束的时候。在获取以后需要手动run，才会运行。
     5. RunLoop 并不保证线程安全。我们只能在当前线程内部操作当前线程的 RunLoop 对象，而不能在当前线程内部去操作其他线程的 RunLoop 对象方法。
     6. RunLoop 会在没有事件源的情况下退出，例如本来只有一个定时器事件源，定时器如果invalidate了，runloop就会退出，线程也释放。
     7. 如果需要切换运行模式（CFRunLoopModeRef），只能退出Loop，再重新指定一个运行模式（CFRunLoopModeRef）进入。
     8. mode包含kCFRunLoopDefaultMode（非UI操作时mode），UITrackingRunLoopMode（UI操作时mode），kCFRunLoopCommonModes（伪模式，其实是一个数组）和（不常用的UIInitializationRunLoopMode，GSEventReceiveRunLoopMode）
     */
    func runloop() {
        let thread = Thread.init(target: self, selector: #selector(run), object: "run")
        thread.name = "runloop"
        thread.start()
        /// 此时可以cancel掉 thread.cancel()。一旦进入run，则无法cancel，只会将其标志为iscanceled。
        
    }
    
    lazy var timer = Timer.init(timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: "timerFire", repeats: true)
    
    @objc func run() {
        let runloop = RunLoop.current /// 创建了此线程的Runloop
        
        
        runloop.add(timer, forMode: .defaultRunLoopMode)
        
        runloop.run() /// 以Default Mode运行，后面的代码不会再执行了。（除非线程自己exit了）
    }
    @objc func timerFire() {
        print(Date())
//        timer.invalidate()
    }
    
    /*
     Tips:
     1. 使用CFRunLoopObserverRef处理Runloop的各个通知。
     */
    func addObserver() {
        
        // 创建观察者
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, CFIndex.zero) { (observer, activity) in
            print(activity)
        }

        // 添加观察者到当前RunLoop中
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode);

        // 释放observer，最后添加完需要释放掉
//        CFRelease(observer)
    }

}
