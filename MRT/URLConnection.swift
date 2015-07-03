//
//  URLConnection.swift
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

private let _SomeManagerSharedInstance = URLConnection()

class URLConnection: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {
  
  static let sharedInstance = URLConnection()
  
  var _downloadCompletionBlock: ((data: NSData, url: NSURL) -> Void)?
  var _downloadProgressBlock: ((progress: Float) -> Void)?
  var _uploadCompletionBlock: (() -> Void)?
  var _uploadProgressBlock: ((progress: Float) -> Void)?
  
  func asyncConnectionWithURLString(urlString: String?, completionBlock completion:((NSData, NSURLResponse) -> Void), errorBlock: ((error: NSError) -> Void)) {
    let request = NSURLRequest(URL: NSURL(string: urlString!)!)
    asyncConnectionWithRequest(request, completion: completion, errorBlock: errorBlock)
  }
  
  func asyncConnectionWithRequest(request:NSURLRequest!, completion:(data: NSData, response: NSURLResponse) -> Void, errorBlock: ((error: NSError) -> Void)) {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    
    let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
      if error == nil {
        completion(data: data!, response: response!)
      } else {
        errorBlock(error: error!)
      }
    }
    
    task!.resume()
  }
  
  func asyncConnectionDownload(request: NSURLRequest!, completion: (data: NSData, url: NSURL) -> Void, errorBlock: (error: NSError) -> Void, downloadProgressBlock: ((progress: Float) -> Void)?) {
    _downloadCompletionBlock = completion
    _downloadProgressBlock = downloadProgressBlock
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    let task = session.downloadTaskWithRequest(request)

    task!.resume()
  }
  
  func asyncConnectionUpload(request: NSURLRequest!, data: NSData!, completion: () -> Void, errorBlock: (error: NSError) -> Void, uploadProgressBlock: ((progress: Float) -> Void)?) {
    _uploadCompletionBlock = completion
    _uploadProgressBlock = uploadProgressBlock
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    let task = session.uploadTaskWithRequest(request, fromData: data)
    
    task!.resume()
  }

  // MARK: - NSURLSessionDelegate
  
  func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
  }
  
  // MARK: - NSURLSessionTaskDelegate
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
    let newRequest : NSURLRequest? = request
    print(newRequest?.description)
    completionHandler(newRequest)
  }
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    if let block = _uploadProgressBlock {
      block(progress: progress)
    }
  }
  
  // MARK: - NSURLSessionDownloadTaskDelegate
  
  func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    if let block = _downloadProgressBlock {
      block(progress: progress)
    }
  }
  
  func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    print("location \(location.path)")
    
    let fileManager = NSFileManager.defaultManager()
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let documentsDirectory = NSURL(string: documentsPath)
    
    let originalUrl = downloadTask.originalRequest?.URL
    let destinationUrl = documentsDirectory!.URLByAppendingPathComponent(originalUrl!.lastPathComponent!)
    print("destinationUrl \(destinationUrl.path)")
    
    do {
      try fileManager.removeItemAtPath(destinationUrl.path!)
    } catch let error {
      print("remove file error: \(error)")
    }
    
    do {
      try fileManager.copyItemAtPath(location.path!, toPath: destinationUrl.path!)
    } catch let error {
      print("copy file error \(error)")
    }
    
    if let fileData = fileManager.contentsAtPath(destinationUrl.path!) {
      if let block = _downloadCompletionBlock {
        block(data: fileData, url: destinationUrl)
      }
    }
  }
}