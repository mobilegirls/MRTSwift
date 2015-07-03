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
    
    DepartureManager.sharedInstance.syncStationData(completionBlock: { () -> Void in
      DepartureManager.sharedInstance.syncMRTDepartureTime(completionBlock: { () -> Void in
        print("==========")
        for var i = 0; i < DepartureManager.sharedInstance.stations.count; ++i {
          let st = DepartureManager.sharedInstance.stations[i]
          print("\(st.cname) \(st.code)")
          
          for p:Platform in st.redLine {
            print("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
          }
          
          for p:Platform in st.orangeLine {
            print("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
          }
          print("==========")
        }
        }, errorBlock: nil)
      }, errorBlock: nil)
    
    NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: Selector("routineSyncDepartureTime"), userInfo: nil, repeats: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - private
  func routineSyncDepartureTime() {
    DepartureManager.sharedInstance.syncMRTDepartureTime(completionBlock: { () -> Void in
      print("==========")
      for var i = 0; i < DepartureManager.sharedInstance.stations.count; ++i {
        let st = DepartureManager.sharedInstance.stations[i]
        print("\(st.cname) \(st.code)")
        
        for p:Platform in st.redLine {
          print("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
        }
        
        for p:Platform in st.orangeLine {
          print("\(p.destination) \(p.arrivalTime) \(p.nextArrivalTime)")
        }
        print("==========")
      }
    }, errorBlock: nil)
  }
}

