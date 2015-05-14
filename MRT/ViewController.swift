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
    
    let urlPath: String = "http://data.kaohsiung.gov.tw/Opendata/MrtJsonGet.aspx?site=102"
    var url: NSURL = NSURL(string: urlPath)!
    var request: NSURLRequest = NSURLRequest(URL: url)
//    URLConnection.asyncConnection(request, completionBlock: { (data, response) -> Void in
//      let s = NSString(data: data, encoding: NSUTF8StringEncoding)
//      
//      println(s)
//      
//      var str = "Hello, playground"
//      var x = str.substringWithRange(Range<String.Index>(start: str.startIndex, end: str.endIndex))
//      println(x)
//      
//      let ss = s as! String
//      var range = ss.rangeOfString("<!DOCTYPE html>")
//      if ss.rangeOfString("<!DOCTYPE html>") != nil {
//        println("\(range!.startIndex)")
//        let g = ss.substringWithRange(Range<String.Index>(start: ss.startIndex, end: advance(range!.startIndex, -2)))
//        println(g)
//        
//        let data = (g as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//        let json = JSON(data: data!)
//        let name = json["MRT"][0]["descr"]
//        println(name)
//        
//        DepartureManager.sharedInstance.test()
//      }
//      
//    }) { (error) -> Void in
//      //println(error)
//    }
    
    //DepartureManager.sharedInstance.syncStationDefaultData()
    
    var st = Station()
    st.code = "999"
    DepartureManager.sharedInstance.syncDepartureTime(st)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

