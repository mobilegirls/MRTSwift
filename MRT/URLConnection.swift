//
//  URLConnection.swift
//  MRT
//
//  Created by evan3rd on 2015/3/13.
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//

import Foundation

class URLConnection: NSObject, NSURLConnectionDelegate {
  
  var _connection: NSURLConnection?
  var _request: NSURLRequest?
  var _data: NSMutableData?
  var _response: NSURLResponse?
  var _downloadSize: Double?
  
  var _completionBlock: ((data: NSData, response: NSURLResponse) -> Void)?
  var _errorBlock: ((error: NSError) -> Void)?
  var _uploadBlock: ((progress: Float) -> Void)?
  var _downloadBlock: ((progress: Float) -> Void)?
  
  class func asyncConnectionWithURLString(urlString: String?, completionBlock completion:((NSData, NSURLResponse) -> Void), errorBlock: ((error: NSError) -> Void)) {
    var request = NSURLRequest(URL: NSURL(string: urlString!)!)
    URLConnection.asyncConnectionWithRequest(request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: nil, downloadProgressBlock: nil)
  }
  
  class func asyncConnectionWithRequest(request : NSURLRequest?, completion: (data: NSData, response: NSURLResponse) -> Void, errorBlock: (error: NSError) -> Void, uploadProgressBlock: ((progress: Float) -> Void)?, downloadProgressBlock: ((progress: Float) -> Void)?) {
    let connection = URLConnection(request: request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: uploadProgressBlock, downloadProgressBlock: downloadProgressBlock)
    connection.start()
  }
  
  class func asyncConnection(request:NSURLRequest?, completionBlock completion:((NSData, NSURLResponse) -> Void), errorBlock: ((error: NSError) -> Void)) {
    URLConnection.asyncConnectionWithRequest(request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: nil, downloadProgressBlock: nil)
  }
  
  init(request : NSURLRequest?, completion: (data: NSData, response: NSURLResponse) -> Void, errorBlock: (error: NSError) -> Void, uploadProgressBlock: ((progress: Float) -> Void)?, downloadProgressBlock: ((progress: Float) -> Void)?) {
    _request = request
    _completionBlock = completion
    _errorBlock = errorBlock
    _uploadBlock = uploadProgressBlock
    _downloadBlock = downloadProgressBlock
  }
  
  func start() {
    _connection = NSURLConnection(request: _request!, delegate: self)
    _data = NSMutableData()
    _connection?.start()
  }
  
  // MARK: - NSURLConnectionDelegate
  
  func connectionDidFinishLoading(connection: NSURLConnection) {
    if let block = _completionBlock {
      block(data: _data!, response: _response!)
    }
  }
  
  func connection(connection: NSURLConnection, didFailWithError error: NSError) {
    if let block = _errorBlock {
      block(error: error)
    }
  }
  
  func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
    _response = response
    _downloadSize = Double(_response!.expectedContentLength)
  }
  
  func connection(connection: NSURLConnection, didReceiveData data: NSData) {
    _data?.appendData(data)
    
    if _downloadSize != 1 {
      var progress = Float(data.length) / Float(_downloadSize!)
      
      if let block = _downloadBlock {
        block(progress: progress)
      }
    }
  }

  func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    var progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    if let block = _uploadBlock {
      block(progress: progress)
    }
  }
}