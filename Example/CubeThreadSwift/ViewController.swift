//
//  ViewController.swift
//  CubeThreadSwift
//
//  Created by gg19910817 on 05/15/2020.
//  Copyright (c) 2020 gg19910817. All rights reserved.
//

import UIKit
import Foundation

@available(iOS 10.0, *)
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        useNSThread()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     Tips: 多线程问题
     1. iOS下多线程的使用包含NSThread和NSOperation以及GCD
     */
    @available(iOS 10.0, *)
    func useNSThread() {
        /*
         Tips: NSThread
         1. NSThread是封装程度最小最轻量级的，使用更灵活
         2. 但要手动管理线程的生命周期、线程同步和线程加锁等，开销较大
        */
        
        let current = Thread.current
        /*
         当前线程等待，不占用cpu，UI也会阻塞。
         */
        Thread.sleep(forTimeInterval: 3)
        
        /*
         Kill掉当前线程，主线程被kill，导致后续UI不再调用。
         */
//        Thread.exit()
        /*
         此代码由于当前线程被Kill，将不再调用。
         */
        print("999")
        
        
        /// 创建新的线程
        let t1 = Thread.init()
        
        let t2 = Thread.init {
            // 这里是线程运行一次，运行完，线程就退出。
            // 如果没有执行Run方法，thread只是创建完成并没有运行。
            // 每次执行一个CPU时间片
//            while true {
//                print(Thread.current)
//                print(Date())
                /// 开始以后的cancel无法取消任务，只是标记本线程为cancel.exit才能真正退出。
//                Thread.current.cancel()
//            }
        }
        /// 即便这里start，也不是马上运行，依然等到函数出栈才执行。
        t2.start()
        
        let t3 = Thread.init(target: self, selector: #selector(t3Run), object: nil)
        /// 这里越高，占用的cpu时间片就越多，但是不代表其他低线程就不执行了，只是概率变小，间隔变长。
        t3.qualityOfService = .userInteractive
        t3.start()
        /// cancel方法在此处有效，但是在开始执行以后就不行了。
//        t3.cancel()
        
        let new = Thread.init()
        
        print(new)
    }
    @objc func t3Run() {
        
//        while true {
//            print(Thread.current)
//            print(Date())
//            Thread.current.cancel()
//        }
        
        
        ///
        /// 如果添加了Delay，不立刻执行，而是添加了一个定时器Timer到Runloop中
        /// 但是因为子线程如果没有主动去获取Runloop，此时没有创建，所以这里会不执行。
        /// 线程会在函数结尾直接结束
        self.perform(#selector(performAction), with: 1, afterDelay: 0)
        
        /// 下面的会执行
        self.perform(#selector(performAction), with: 2, afterDelay: 0)
        self.perform(#selector(performAction), with: 3, afterDelay: 5)
        
        /*
        Tips: 函数派发
        1. https://www.jianshu.com/p/91bfe3f11eec
        2. 函数的调用是直接调用还是基于消息机制，在swift中有所不同。
        3. swift会对代码进行优化，所以导致一下方法有一些是基于动态派发的。
        4. 区别于ObjectC中消息调用全部取决于runtime
        */
        self.performAction(4) /// 在这里是直接调用函数指针，是最快的，中间没有其他方法入栈。
        self.perform(#selector(performAction), with: 5, with: 2) /// 基于消息机制，中间有消息转发
        self.perform(#selector(performAction), on: .current, with: 6, waitUntilDone: true) ///消息转发次数更多，并有线程判断。
        
        /// 如果没有指定mode，将会被抛弃。
        self.performSelector(onMainThread: #selector(performAction), with: 7, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
        
        /// 此处会创建新的线程执行此任务
        self.performSelector(inBackground: #selector(performAction), with: nil)

    }
    
    @objc func performAction(_ i : Any) {
        print("-----\(i)")
    }
    
    
    func whySync() {
        
    }
    
    

}

