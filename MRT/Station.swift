//
//  Station.swift
//  MRT
//
//  Created by evan3rd on 2015/5/14.
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//

import Foundation

class Station: NSObject {
  var mrtId = ""
  var name = ""
  var cname = ""
  var code = ""
  var redLine: Array<Platform> = Array()
  var orangeLine: Array<Platform> = Array()
}

class Platform: NSObject {
  var destination = ""
  var arrivalTime = ""
  var nextArrivalTime = ""
}