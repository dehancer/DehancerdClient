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

struct Config {
    
    static let mode = Session.OpenMode.reuse
    
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
    static let cuid = try! Pair(secretPhrase: "dehancerd test client")
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        Swift.print("Register the follow api access: ")
        Swift.print("                         token: ", Config.accessPair.publicKey.encode())
        Swift.print("                          name: ", Config.accessName)
        
        do {
            
            try Session(base:   Config.url,
                        client: Config.cuid,
                        api:    Config.accessPair, apiName: Config.accessName
                )
                
                .open(mode: Config.mode) { result in
                    switch result {
                        
                    case .success(let token, let id):
                        
                        Swift.print(" token:  ", token, id)
                        
                    case .error(let error):
                        OperationQueue.main.addOperation {
                            NSAlert(error: error).runModal()
                        }
                    }
                }
                
                .get_profile_list { result  in
                    switch result {
                    case .success(let d, _):
                        
                        for i in d {
                            Swift.print(" list:  ", i.toJSON())
                        }
                        
                    case .error(let error):
                        Swift.print(" error:  ", error)
                    }
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

