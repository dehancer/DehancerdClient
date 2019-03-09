//
//  AppDelegate.swift
//  dehancerd-client
//
//  Created by denn on 03/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Cocoa
import ed25519
import ObjectMapper
import DehancerdClient
import PromiseKit

struct Config {
    
    static let mode = DehancerdClient.Session.OpenMode.reuse
    
    static let url =  URL(string: "http://127.0.0.1:8042/v1/api")!
    
    //
    // Test api access token generator
    // shoild be add in dehancerd db
    //
    static let accessPair = try! Pair(secretPhrase: "dehancerd test api")
    
    //
    // Api client name
    //
    static let accessName = "Test Api"
    
    //
    // Client unique id
    //
    static let cuid = try! Pair(secretPhrase: "dehancerd test client 6")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let downloadManager = DownloadManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Swift.print("Register the follow api access: ")
        Swift.print("                         token: ", Config.accessPair.publicKey.encode())
        Swift.print("                          name: ", Config.accessName)
        

        downloadManager.onProgress = { progress in
            debugPrint(" /// onProgress: ", progress)
        }
        
        downloadManager.onDownload = { profile, url in
            debugPrint(" /// onDownload: ", profile.caption)
        }
        
        downloadManager.onComplete = { error in
            debugPrint(" /// onComplete: \(String(describing: error))")
        }
        
        do {
            let session = try Session(base: Config.url, 
                                      client: Config.cuid, 
                                      api: Config.accessPair, 
                                      apiName: Config.accessName, 
                                      timeout: 10)
            
            session
                .login()
                .then { session -> Promise<Session> in
                    debugPrint("Session login: ", session)
                    return session.set_user_info()
                }                
                .done { session in
                    
                    session
                        .get_list()
                        .done{ profiles in
                            
                            self.downloadManager.add(profiles: profiles)
                            
                        }
                        .catch{ error in debugPrint("Session get_list error: ", error) }                                      
                }
                .catch { error in
                    debugPrint("Session error: ", error)
            }
            
            session
                .login(check: false)
                .done { session in
                    session
                        .update_exports(profile: "Agfacolor 100", revision: 2, export: 3, files: 100) 
                        .catch{ error in
                            debugPrint("Session error update_exports: ", error)
                    }
                }
                .catch{ error in
                    debugPrint("Session error update_exports: ", error)
                }
        }
        catch {
            OperationQueue.main.addOperation {
                NSAlert(error: error).runModal()
            }
        }
        
    }    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

