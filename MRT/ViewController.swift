//
//  ViewController.swift
//  MRT
//
//  Created by evan3rd on 2015/5/13.
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("routineSyncDepartureTime"), userInfo: nil, repeats: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - private
  func routineSyncDepartureTime() {
    DepartureManager.sharedInstance.syncMRTDepartureTime(completionBlock: { () -> Void in
      println("==========")
      for var i = 0; i < DepartureManager.sharedInstance.stations.count; ++i {
        var st = DepartureManager.sharedInstance.stations[i]
        println("\(st.cname) \(st.code)")
        
        for p:Platform in st.redLine {
          println("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
        }
        
        for p:Platform in st.orangeLine {
          println("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
        }
        println("==========")
      }
    }, errorBlock: nil)
  }
}

