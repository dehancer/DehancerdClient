//
//  DehancerdApi.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ed25519
import PromiseKit
import ObjectMapper

public final class Session {
    
    public enum Errors:Error{
        case timeout(URL)
        case notAuthorized
    }
    
    public enum OpenMode {
        case reuse
        case new
    }
    
    public let timeout:TimeInterval

    public init(base url:URL, client: Pair, api: Pair, apiName: String, timeout:TimeInterval = 10) {
        self.url = url
        self.clientPair = client
        self.apiPair = api
        self.apiName = apiName
        self.timeout = timeout
        self.rpc = JsonRpc(base: url, timeout: timeout)
    }
    
    public func login(check state:Bool = true) -> Promise<Session> {
        return Promise { promise in
            
            after(.seconds(Int(self.timeout)))
                .done {
                    return promise.reject(Errors.timeout(self.url))
            }
            
            func geNew()  {
                get_new_token()
                    .done{ token in                        
                        self.accessToken = token
                        return promise.fulfill(self)
                    }                    
                    .catch{ error in
                        return promise.reject(error)
                }
            }
            
            if let token = accessToken {
                if state {
                    check_state(token: token)                      
                        .done{ token in
                            return promise.fulfill(self)
                        }
                        .catch{ errno in
                            return geNew()
                    }
                }
                else {
                    return promise.fulfill(self)
                }
            }
            else {
               return geNew()
            }
        }
    }
    
    public func set_user_info (info: UserInfo? = nil) -> Promise<Session> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let user = info != nil ? set_user_info_request(info:info!) : try set_user_info_request(key: self.clientPair.privateKey.encode(), token: token)
            
            rpc.send(request: user) { result  in
                switch result {
                    
                case .success(let permit, let id):
                    
                    if !permit {
                        return promise.reject(JsonRpc.Errors.response(responseId: id, 
                                                                      code: ResponseCode.accessForbidden, 
                                                                      message: String.localizedStringWithFormat("Access forbidenn")))
                    }
                    else {                    
                        return promise.fulfill(self)
                    }
                    
                case .error(let error):
                    
                    return promise.reject(error)
                    
                }
            }
        }       
    }
    
    @available(*, deprecated, message: "Use instead: get_film_profile_list")
    public func get_list () -> Promise<[Profile]> {
       return get_film_profile_list()
    }
    
    public func get_film_profile_list () -> Promise<[Profile]> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let list = try get_film_profile_list_request(key: self.clientPair.privateKey.encode(), token: token)
            
            self.rpc.send(request: list) { result  in
                switch result {
                    
                    case .success(let data,_):
                        
                        return promise.fulfill(data)
                    
                    case .error(let error):
                        
                        return promise.reject(error)
                    
                }
            }
        }
    }
    
    public func get_camera_profile_list (id:String="", all:Bool = false) -> Promise<[CameraProfile]> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let list = try get_camera_profile_list_request(
                key: self.clientPair.privateKey.encode(),
                token: token,
                id: id,
                all: all
            )
            
            self.rpc.send(request: list) { result  in
                switch result {
                    
                    case .success(let data,_):
                        
                        return promise.fulfill(data)
                    
                    case .error(let error):
                        
                        return promise.reject(error)
                    
                }
            }
        }
    }
    
    public func get_camera_references () -> Promise<CameraReferences> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let list = try get_camera_references_request(key: self.clientPair.privateKey.encode(), token: token)
            
            self.rpc.send(request: list) { result  in
                switch result {
                    
                    case .success(let data,_):
                        
                        return promise.fulfill(data)
                    
                    case .error(let error):
                        
                        return promise.reject(error)
                    
                }
            }
        }
    }
    
    public func update_camera_reference (
        vendor:Vendor? = nil,
        model:Model? = nil,
        format:Format? = nil) -> Promise<Session> {
        
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
                                    
            let ref = try update_camera_reference_request(
                key: self.clientPair.privateKey.encode(),
                token: token,
                vendor: vendor,
                model: model,
                format:format
            )

            self.rpc.send(request: ref) { result  in
                switch result {

                    case .success(let permit, let id):
                        
                        if !permit {
                            return promise.reject(JsonRpc.Errors.response(responseId: id,
                                                                          code: ResponseCode.accessForbidden,
                                                                          message: String.localizedStringWithFormat("Access forbidenn")))
                        }
                        else {
                            return promise.fulfill(self)
                    }
                    
                    case .error(let error):

                        return promise.reject(error)

                }
            }
        }
    }
    
    public func get_statistic (name:String) -> Promise<Mappable> {
        return Promise { promise in                    
            
            let list = get_statistics_request(name: name)
            
            self.rpc.send(request: list) { result  in
                switch result {
                    
                case .success(let data,_):
                    
                    return promise.fulfill(data)
                    
                case .error(let error):
                    
                    return promise.reject(error)
                    
                }
            }
        }        
    }
    
    public func update_exports(profile name:String, revision: Int, export count:Int, files:Int) -> Promise<Session> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let exports = try update_profile_exports_request(key: self.clientPair.privateKey.encode(), 
                                                             token: token, 
                                                             profile: name, 
                                                             revision: revision, 
                                                             count: count, 
                                                             files: files) 
            
            self.rpc.send(request: exports) { result  in
                switch result {
                    
                case .success(let permit, let id):
                    
                    if !permit {
                        return promise.reject(JsonRpc.Errors.response(responseId: id, 
                                                                      code: ResponseCode.accessForbidden, 
                                                                      message: String.localizedStringWithFormat("Access forbidenn")))
                    }
                    else {    
                        return promise.fulfill(self)
                    }
                    
                case .error(let error):
                    return promise.reject(error)
                }
            }            
        }
    }
    
    public func upload_camera_profile(data: String) -> Promise<Session> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let exports = try upload_camera_profile_request(key: self.clientPair.privateKey.encode(),
                                                             token: token,
                                                             data: data)
            
            self.rpc.send(request: exports) { result  in
                switch result {
                    
                case .success(let permit, let id):
                    
                    if !permit {
                        return promise.reject(JsonRpc.Errors.response(responseId: id,
                                                                      code: ResponseCode.accessForbidden,
                                                                      message: String.localizedStringWithFormat("Access forbidenn")))
                    }
                    else {
                        return promise.fulfill(self)
                    }
                    
                case .error(let error):
                    return promise.reject(error)
                }
            }
        }
    }
    
    public func update_camera_profile(profile id:String, is_published: Bool) -> Promise<Session> {
        return Promise { promise in
            
            guard let token = self.accessToken else {
                return promise.reject(Errors.notAuthorized)
            }
            
            let exports = try update_camera_profile_request(key: self.clientPair.privateKey.encode(),
                                                             token: token,
                                                             profile: id,
                                                             is_published: is_published)
            
            self.rpc.send(request: exports) { result  in
                switch result {
                    
                case .success(let permit, let id):
                    
                    if !permit {
                        return promise.reject(JsonRpc.Errors.response(responseId: id,
                                                                      code: ResponseCode.accessForbidden,
                                                                      message: String.localizedStringWithFormat("Access forbidenn")))
                    }
                    else {
                        return promise.fulfill(self)
                    }
                    
                case .error(let error):
                    return promise.reject(error)
                }
            }
        }
    }
    
    private func get_new_token() -> Promise<String> {
        return Promise { promise in
            
            let auth = try get_auth_token_request(
                cuid: clientPair.publicKey.encode(),
                key: apiPair.privateKey.encode(),
                api: apiName)
                        
            rpc.send(request: auth) { result  in
                
                switch result {
                    
                case .success(let data,_):

                    return promise.fulfill(data.token)
                    
                case .error(let error):
                    
                    return promise.reject(error)
                    
                }
            }
        }
    }
    
    private func check_state(token: String) -> Promise<String> {
        
        return Promise { promise in
            
            let state = try get_cuid_state_request(key: self.clientPair.privateKey.encode(), token: token)
            
            self.rpc.send(request: state) { result  in
                switch result {
                case .success(let permit, let id):
                    
                    if !permit {
                        return promise.reject(JsonRpc.Errors.response(responseId: id, 
                                                                      code: ResponseCode.accessForbidden, 
                                                                      message: String.localizedStringWithFormat("Access forbidenn")))
                    }
                    else {
                        return promise.fulfill(token)
                    }
                    
                case .error(let error):
                    return promise.reject(error)
                }
            }   
        }
    }
       
    private let rpc:JsonRpc
    private var urlTask:URLSessionDataTask?
    private var url:URL
    private var clientPair:Pair
    private var apiName:String
    private var apiPair:Pair
    
    private let lock = NSLock();
    
    private var accessToken:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Session.accessTokenKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Session.accessTokenKey)
        }
    }
    
    private static let accessTokenKey = "dehancerd-api-access-token"
}
