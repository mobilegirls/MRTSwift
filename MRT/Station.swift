//
//  Station.swift
//  MRT
//
//  Created by Inflames on 2015/5/14.
//  Copyright (c) 2015年 Inflames. All rights reserved.
//

import Foundation

class Station: NSObject {
  var mrtId = ""
  var name = ""
  var cname = ""
  var code = ""
  //"descr":"大寮","arrival":"2","next_arrival":"10"
  var redLine: Array<Platform> = Array()
  var orangeLine: Array<Platform> = Array()
}

class Platform: NSObject {
  var destination = ""
  var arrivalTime = ""
  var nextArrivalTime = ""
}