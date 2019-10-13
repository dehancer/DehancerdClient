//
//  DownloadManager.swift
//  DehancerdClient
//
//  Created by denis svinarchuk on 09/03/2019.
//

import Foundation

public protocol TaskContainerProtocol {
    var profile:Any {get}
    var task:URLSessionDownloadTask { get }
    var totalBytesWritten:Int64 { get set }
    var totalBytesExpectedToWrite:Int64 { get set }
    var isDownloaded:Bool { get set }
}

public class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
        
   
    private struct TaskContainer: TaskContainerProtocol{
        let profile:Any
        let task:URLSessionDownloadTask
        var totalBytesWritten:Int64 = 0
        var totalBytesExpectedToWrite:Int64 = 0
        var isDownloaded = false
        init(profile:Profile,task:URLSessionDownloadTask) {
            self.profile = profile 
            self.task = task
            self.totalBytesExpectedToWrite = Int64(profile.file_size)
        }
    }
    
    private struct TaskCameraContainer: TaskContainerProtocol{
           let profile:Any
           let task:URLSessionDownloadTask
           var totalBytesWritten:Int64 = 0
           var totalBytesExpectedToWrite:Int64 = 0
           var isDownloaded = false
           init(profile:CameraProfile,task:URLSessionDownloadTask) {
               self.profile = profile
               self.task = task
               self.totalBytesExpectedToWrite = Int64(profile.file_size)
           }
       }
    
    public let timeout:TimeInterval 
    
    public func add(profiles: [Profile]) {
        lock.lock(); defer { lock.unlock() }
        for profile in profiles {
            
            guard let url = profile.url else { continue }
            
            let request = URLRequest(url: url, 
                                     cachePolicy: .reloadIgnoringCacheData, 
                                     timeoutInterval: self.timeout)
                                    
            let task = session.downloadTask(with: request)
            tasks[task.taskIdentifier] = TaskContainer(profile: profile, task: task)
        }
        resume()
    }
    
    public func add(profiles: [CameraProfile]) {
           lock.lock(); defer { lock.unlock() }
           for profile in profiles {
               
               guard let url = profile.url else { continue }
               
               let request = URLRequest(url: url,
                                        cachePolicy: .reloadIgnoringCacheData,
                                        timeoutInterval: self.timeout)
                                       
               let task = session.downloadTask(with: request)
               tasks[task.taskIdentifier] = TaskCameraContainer(profile: profile, task: task)
           }
           resume()
       }
    
        
    public init(timeout:TimeInterval = 60) {        
        self.timeout = timeout
        super.init()
    }
    
    private func resume() {
        for t in tasks {
            t.value.task.resume()
        }
    }
    
    public var onProgress: ((_ progress:CGFloat) -> ())? = nil
    public var onDownload: ((_ profile:Any, _ location:URL) -> ())? = nil
    public var onComplete: ((_ error:Error?) -> ())? = nil
    
    private var tasks:[Int:TaskContainerProtocol] = [:]
    
    private lazy var session : URLSession = {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")

        return URLSession(configuration: config,
                          delegate: self,
                          delegateQueue: OperationQueue())
    }()
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                                    
        lock.lock(); defer { lock.unlock() }  
        
        guard tasks.count > 0 else { return }
        
        tasks[downloadTask.taskIdentifier]?.totalBytesWritten = totalBytesWritten
        
        let progress = tasks.compactMap { _, task -> CGFloat? in
            if totalBytesExpectedToWrite > 0 {
                return CGFloat(task.totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
            }
            else if task.totalBytesExpectedToWrite > 0 {
                return CGFloat(task.totalBytesWritten) / CGFloat(task.totalBytesExpectedToWrite)
            }
            else {
                return 1
            }
        }
        
        if tasks.count == 0 {
            onProgress?(1.0)
        }
        else {
            let p = progress.reduce(0.0, +)/CGFloat(tasks.count)
            onProgress?(p >= 0.999 ? 1 : p)
        }
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let profile = tasks[downloadTask.taskIdentifier]?.profile {
            tasks[downloadTask.taskIdentifier]?.isDownloaded = true
            onDownload?(profile, location)            
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let progress = tasks.compactMap { _, task -> Bool? in 
            return task.isDownloaded ? true : nil            
        }
        
        if progress.count == self.tasks.count && self.tasks.count > 0  || self.tasks.count == 0{
            self.lock.lock(); defer { self.lock.unlock() }
            self.tasks.removeAll()
            self.onComplete?(nil)
        }        
        
        if let e = error {
            self.onComplete?(e)
        }
    }
    
    private let lock = NSLock() 
}
