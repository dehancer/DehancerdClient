//
//  DownloadManager.swift
//  dehancerd-client
//
//  Created by denis svinarchuk on 09/03/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import DehancerdClient

public class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    struct TaskContainer{
        let profile:Profile
        let task:URLSessionDownloadTask
    }
    
    public func add(profile: Profile) {
        if let url = profile.url {
            let task = session.downloadTask(with: url)
            tasks[task.taskIdentifier] = TaskContainer(profile: profile, task: task)
            task.resume()
        }
    }
    
    public func resume() {
        //        for t in tasks {
        //            t.value.task.resume()
        //        }
    }
    
    public var onProgress: ((_ progress:CGFloat) -> ())? = nil
    public var onDownload: ((_ profile:Profile, _ location:URL) -> ())? = nil
    public var onComplete: (() -> ())? = nil
    
    private var tasks:[Int:TaskContainer] = [:]
    
    private lazy var session : URLSession = {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config,
                          delegate: self,
                          delegateQueue: OperationQueue())
    }()
    
    private func calculateProgress(session : URLSession, completionHandler : ((CGFloat) -> ())?) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler?(CGFloat(progress.reduce(0.0, +)/Float(downloads.count)))
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if totalBytesExpectedToWrite > 0 {
            calculateProgress(session: session, completionHandler: self.onProgress)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let profile = tasks[downloadTask.taskIdentifier]?.profile {
            onDownload?(profile, location)
            
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            debugPrint("### .... getTasksWithCompletionHandler ", tasks.count, downloads.count)
            if downloads.count <= 1 {
                self.tasks.removeAll()
                self.onComplete?()
            }
        }
        if let e = error {
            debugPrint("didCompleteWithError: ", e)
            //ErrorLog.append(error: e)
        }
    }
}
