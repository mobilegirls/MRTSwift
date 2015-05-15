//
//  DepartureManager.swift
//  MRT
//
//  Created by evan3rd on 2015/5/14.
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//

import Foundation

private let _SomeManagerSharedInstance = DepartureManager()

class DepartureManager {
  static let sharedInstance = DepartureManager()
  
  var stations: Array<Station> = Array()
  
  var syncIndex = 0
  
  var _completionBlock: (() -> Void)?
  var _errorBlock: ((error: NSError) -> Void)?
  
  func syncStationData(completionBlock completion:(() -> Void)?, errorBlock: ((error: NSError) -> Void)?) {
    let urlPath: String = "http://data.kaohsiung.gov.tw/Opendata/DownLoad.aspx?Type=2&CaseNo1=AP&CaseNo2=17&FileType=2&Lang=C&FolderType=O"
    var url: NSURL = NSURL(string: urlPath)!
    var request: NSURLRequest = NSURLRequest(URL: url)
    
    URLConnection.asyncConnection(request, completionBlock: { (data, response) -> Void in
      //let s = NSString(data: data, encoding: NSUTF8StringEncoding)
      //println(s)

      let json = JSON(data: data)
      
      for (index: String, subJson: JSON) in json {
        let st = Station()

        if let mrtId = subJson["ODMRT_MrtId"].string {
          st.mrtId = mrtId
        }
        
        if let name = subJson["ODMRT_Name"].string {
          st.name = name
        }
        
        if let cname = subJson["ODMRT_CName"].string {
          st.cname = cname
        }
        
        if let code = subJson["ODMRT_Code"].string {
          st.code = code
        }
        
        self.stations.append(st)
      }
      
      if let block = completion {
        block()
      }
      
    }) { (error) -> Void in
      println(error)
      if let block = errorBlock {
        block(error: error)
      }
    }
  }
  
  func syncDepartureTime(station: Station, completionBlock completion:(() -> Void)?, errorBlock: ((error: NSError) -> Void)?) {
    let urlPath: String = String(format: "http://data.kaohsiung.gov.tw/Opendata/MrtJsonGet.aspx?site=%@", station.code)
    var url: NSURL = NSURL(string: urlPath)!
    var request: NSURLRequest = NSURLRequest(URL: url)
    URLConnection.asyncConnection(request, completionBlock: { (data, response) -> Void in
      let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
      //println(responseString)
      
      var range = responseString.rangeOfString("<!DOCTYPE html>")
      if responseString.rangeOfString("<!DOCTYPE html>") != nil {
        let s = responseString.substringWithRange(Range<String.Index>(start: responseString.startIndex, end: advance(range!.startIndex, -2)))
        //println(s)
        
        let d = (s as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let json = JSON(data: d!)
        
        for (index: String, subJson: JSON) in json["MRT"] {
          var p = Platform()
          if let arrival = subJson["arrival"].string {
            p.arrivalTime = arrival
          }
          
          if let nextArrival = subJson["next_arrival"].string {
            p.nextArrivalTime = nextArrival
          }
          
          if let name = subJson["descr"].string {
            p.destination = name
          }
          
          if station.code.toInt() < 200 {
            if station.redLine.count > 1 {
              station.redLine[index.toInt()!] = p
            } else {
              station.redLine.append(p)
            }
          } else if station.code.toInt() < 999 {
            if station.orangeLine.count > 1 {
              station.orangeLine[index.toInt()!] = p
            } else {
              station.orangeLine.append(p)
            }
          } else {
            switch index {
            case "0", "1" :
              if station.orangeLine.count > 1 {
                station.orangeLine[index.toInt()!] = p
              } else {
                station.orangeLine.append(p)
              }
            case "2", "3" :
              if station.redLine.count > 1 {
                station.redLine[index.toInt()! - 2] = p
              } else {
                station.redLine.append(p)
              }
            default: ()
            }
          }
        }
      }
      
      if let block = completion {
        block()
      }
    }) { (error) -> Void in
      println(error)
        
      if let block = errorBlock {
        block(error: error)
      }
    }
  }
  
  func syncMRTDepartureTime(completionBlock completion:(() -> Void)?, errorBlock: ((error: NSError) -> Void)?) {
    if let block = completion {
      _completionBlock = block
    }
    
    if let block = errorBlock {
      _errorBlock = block
    }
    
    syncDepartureTime(stations[syncIndex], completionBlock: { () -> Void in
      ++self.syncIndex
      if self.syncIndex < self.stations.count {
        self.syncMRTDepartureTime(completionBlock: nil, errorBlock: nil)
      } else {
        self.syncIndex = 0
        if let block = self._completionBlock {
          block()
        }
      }
    }) { (error) -> Void in
      println(error)
      if let block = self._errorBlock {
        block(error: error)
      }
    }
  }
}