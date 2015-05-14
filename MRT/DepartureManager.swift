//
//  DepartureManager.swift
//  MRT
//
//  Created by Inflames on 2015/5/14.
//  Copyright (c) 2015年 Inflames. All rights reserved.
//

import Foundation

private let _SomeManagerSharedInstance = DepartureManager()

class DepartureManager {
  static let sharedInstance = DepartureManager()
  
  var stations: Array<Station> = Array()
  
  func test() {
    println("text")
  }
  
  func syncStationDefaultData() {
    let urlPath: String = "http://data.kaohsiung.gov.tw/Opendata/DownLoad.aspx?Type=2&CaseNo1=AP&CaseNo2=17&FileType=2&Lang=C&FolderType=O"
    var url: NSURL = NSURL(string: urlPath)!
    var request: NSURLRequest = NSURLRequest(URL: url)
    
    URLConnection.asyncConnection(request, completionBlock: { (data, response) -> Void in
      let s = NSString(data: data, encoding: NSUTF8StringEncoding)
      println(s)

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
      
      println(self.stations[10].cname)
      }) { (error) -> Void in
        println(error)
    }
  }
  
  func syncDepartureTime(station: Station) -> Station {
    let urlPath: String = String(format: "http://data.kaohsiung.gov.tw/Opendata/MrtJsonGet.aspx?site=%@", station.code)
    var url: NSURL = NSURL(string: urlPath)!
    var request: NSURLRequest = NSURLRequest(URL: url)
    URLConnection.asyncConnection(request, completionBlock: { (data, response) -> Void in
      let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
      println(responseString)
      
      var range = responseString.rangeOfString("<!DOCTYPE html>")
      if responseString.rangeOfString("<!DOCTYPE html>") != nil {
        let s = responseString.substringWithRange(Range<String.Index>(start: responseString.startIndex, end: advance(range!.startIndex, -2)))
        println(s)
        
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
            station.redLine.append(p)
          } else if station.code.toInt() < 999 {
            station.orangeLine.append(p)
          } else {
            switch index {
            case "0", "1" :
              station.orangeLine.append(p)
            case "2", "3" :
              station.redLine.append(p)
            default: ()
            }
          }
        }
      }
      
      //println("\(station.redLine.firstDestination) \(station.redLine.firstNextArrivalTime)")
      println("\(station.redLine[0].destination) \(station.redLine[0].arrivalTime)")
      println("\(station.orangeLine[0].destination) \(station.orangeLine[0].arrivalTime)")
      }) { (error) -> Void in
        println(error)
    }
    
    return station
  }
}