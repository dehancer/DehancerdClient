//
//  DownloadManager.swift
//  DehancerdClient
//
//  Created by denis svinarchuk on 09/03/2019.
//

import Foundation

public class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    private struct TaskContainer{
        let profile:Profile
        let task:URLSessionDownloadTask
        var totalBytesWritten:Int64 = 0
        var totalBytesExpectedToWrite:Int64 = 0
    }    
    
    public func add(profiles: [Profile]) {
        for profile in profiles {
            guard let url = profile.url else { continue }
            let request = URLRequest(url: url, 
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, 
                                     timeoutInterval: 10)
            let task = session.downloadTask(with: request) //.downloadTask(with: url)
            tasks[task.taskIdentifier] = TaskContainer(profile: profile, 
                                                       task: task, 
                                                       totalBytesWritten: 0, 
                                                       totalBytesExpectedToWrite: 0)
        }
        resume()
    }
    
    private func resume() {
        for t in tasks {
            t.value.task.resume()
        }
    }
    
    public var onProgress: ((_ progress:CGFloat) -> ())? = nil
    public var onDownload: ((_ profile:Profile, _ location:URL) -> ())? = nil
    public var onComplete: ((_ error:Error?) -> ())? = nil
    
    private var tasks:[Int:TaskContainer] = [:]
    
    private lazy var session : URLSession = {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        
        return URLSession(configuration: config,
                          delegate: self,
                          delegateQueue: OperationQueue())
    }()
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard tasks.count > 0 else { return }
        
        tasks[downloadTask.taskIdentifier]?.totalBytesWritten = totalBytesWritten
        tasks[downloadTask.taskIdentifier]?.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        
        let progress = tasks.compactMap { _, task -> CGFloat? in
            if task.totalBytesExpectedToWrite > 0 {
                return CGFloat(task.totalBytesWritten) / CGFloat(task.totalBytesExpectedToWrite)
            }
            else {
                return nil
            }
        }
        
        onProgress?(progress.reduce(0.0, +)/CGFloat(tasks.count))
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let profile = tasks[downloadTask.taskIdentifier]?.profile {
            onDownload?(profile, location)            
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in                        
            if downloads.count <= 1 {
                self.tasks.removeAll()
                self.onComplete?(nil)
            }
        }
        
        if let e = error {
            self.onComplete?(e)
        }
    }
}
