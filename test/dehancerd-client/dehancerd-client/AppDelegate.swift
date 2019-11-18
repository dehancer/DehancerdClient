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
//import DehancerCommon
import PromiseKit

struct Config {
    
    static let mode = DehancerdClient.Session.OpenMode.reuse
    
    static let url =  URL(string: "http://127.0.0.1:8042/v1/api")!
    //static let url =  URL(string: "https://165.227.54.8/v1/api")!   
    //static let url =  URL(string: "https://update.dehancer.com/v1/api")!

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
    
    let downloadManager = DownloadManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      
        Swift.print("Register the follow api access: ")
        Swift.print("                         token: ", Config.accessPair.publicKey.encode())
        Swift.print("                          name: ", Config.accessName)

        let session = Session(base: Config.url,
                              client: Config.cuid,
                              api: Config.accessPair,
                              apiName: Config.accessName,
                              timeout: 60)

        session
            .get_statistic(name: "common")
            .done { result in
                debugPrint("get_statistic: ", result.toJSON())
            }.catch { error in
                debugPrint("Session error: ", error)
        }
        
        session
            .login()
            .then { session -> Promise<Session> in
                debugPrint("Session login: ", session)
                return session.set_user_info()
        }
        .then { session -> Promise<Session> in
                        
            let vendor = Vendor(name: "Arri")
            
            vendor.caption = "ARRI AG"
            vendor.description = "ARRI Media International is a department of the worldwide established ARRI Group and operates as an international sales agent for feature films. Our main genre focus when acquiring for worldwide distribution is on FAMILY ENTERTAINMENT (live action & full animation), DRAMAS (prestigious festival contenders) and GENRE (horror, thriller, action and sci-fi)."
            
            let model = Model(vendor: vendor.id, name: "Alexa LF")
            model.description = "ARRI is a large-format camera system consists of the ALEXA LF camera, ARRI Signature Prime lenses, LPL lens mount and PL-to-LPL Adapter."
            model.caption = "Alexa LF"
            
            let format = Format(vendor: vendor.id, name: "Rec 709")
            format.types = ["photo", "video"]
            
            return session.update_camera_reference(vendor: vendor, model: model, format: format)
            //return session.update_camera_reference(format: format)
            
        }
        .done({ _ in
            
        })
        .catch { error in
            debugPrint("Session error: ", error)
        }

    }
//
//    func applicationWillFinishLaunching(_ aNotification: Notification) {
//        Swift.print("Register the follow api access: ")
//        Swift.print("                         token: ", Config.accessPair.publicKey.encode())
//        Swift.print("                          name: ", Config.accessName)
//
//
//        downloadManager.onProgress = { progress in
//            debugPrint(" /// onProgress: ", progress)
//        }
//
//        downloadManager.onDownload = { profile, url in
//            if let p = profile as? Profile {
//                debugPrint(" /// film onDownload: ", p.caption)
//            }
//            else if let p = profile as? CameraProfile {
//                debugPrint(" /// camera onDownload: ", p.caption)
//            }
//        }
//
//        downloadManager.onComplete = { error in
//            debugPrint(" /// onComplete: \(String(describing: error))")
//        }
//
//
//        let session = Session(base: Config.url,
//                              client: Config.cuid,
//                              api: Config.accessPair,
//                              apiName: Config.accessName,
//                              timeout: 60)
        
//        session
//            .login()
//            .then { session -> Promise<Session> in
//                debugPrint("Session login: ", session)
//                return session.set_user_info()
//        }
//        .done { session in
//
//            session
//                .get_film_profile_list()
//                .done{ profiles in
//
//                    self.downloadManager.add(profiles: profiles)
//
//            }
//            .catch{ error in debugPrint("Session get_list error: ", error) }
//        }
//        .catch { error in
//            debugPrint("Session error: ", error)
//        }

//        session
//            .login()
//            .then { session -> Promise<Session> in
//                debugPrint("Session login: ", session)
//                return session.set_user_info()
//            }
//            .done { session in
//
//            }
//            .catch { error in
//                debugPrint("Session error: ", error)
//        }
        
//        var base64 = "Some data".data(using: .utf8)?.base64EncodedString() ?? ""
//
//        session
//            .upload_camera_profile(profile: "Test", data: base64)
//            .done{ session in
//
//        }
//        .catch{ error in debugPrint("Session get_list error: ", error) }
            
        
//        session
//            .login()
//            .then { session -> Promise<Session> in
//                debugPrint("Session login: ", session)
//                return session.set_user_info()
//        }
//        .done { session in
//
//            session
//                .get_camera_profile_list(all:true)
//                .done{ profiles in
//
//                    for p in profiles {
//                        Swift.print(p.toJSON())
//                    }
//
//                    self.downloadManager.add(profiles: profiles)
//
//            }
//            .catch{ error in debugPrint("Session get_list error: ", error) }
//        }
//        .catch { error in
//            debugPrint("Session error: ", error)
//        }
//
        
//        session
//            .get_camera_references()
//            .done{ cameras in
//
//                for f in cameras.formats {
//                    Swift.print("Format: ", f.toJSON())
//                }
//
//                for m in cameras.models {
//                    Swift.print("Model: ", m.toJSON())
//                }
//
//                for v in cameras.vendors {
//                    Swift.print("Vendor: ", v.toJSON())
//                }
//
//
//            }
//            .catch{ error in debugPrint("Session get_list error: ", error) }
//
//
//        session
//            .login()
//            .done { session in
//                session
//                    .update_camera_profile(profile: "Apple-8_8S_8P-FiLMiC_Pro_Log_V2",
//                                           is_published: false)
//                    .catch{ error in
//                        debugPrint("Session error update_exports: ", error)
//                }
//        }
//        .catch{ error in
//            debugPrint("Session error update_exports: ", error)
//        }
//
        
//        session
//            .login(check: false)
//            .done { session in
//                session
//                    .update_exports(profile: "Agfacolor 100", revision: 2, export: 1, files: 1)
//                    .catch{ error in
//                        debugPrint("Session error update_exports: ", error)
//                }
//            }
//            .catch{ error in
//                debugPrint("Session error update_exports: ", error)
//        }
//
//    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

