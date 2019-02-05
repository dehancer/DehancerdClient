//
//  DehancerdApi.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ed25519

final class Session {
    
    public enum OpenMode {
        case reuse
        case new
    }
    
    public init(base url:URL, client: Pair, api: Pair, apiName: String) throws {
        self.url = url
        self.clientPair = client
        self.apiPair = api
        self.apiName = apiName
        self.rpc = JsonRpc(base: url)
    }
    
    @discardableResult public func connect(error exit:((Error)->())?=nil)  -> Future<Session> {
        
        let promise = Promise<Session>()
        
        func error_handler(error:Error) {
            self.accessToken = nil
            promise.reject(with: error){
                exit?(error)
            }
        }
        
        func get_new_token() {
            do {
               
                let auth = try get_auth_token_request(
                    cuid: clientPair.publicKey.encode(),
                    key: apiPair.privateKey.encode(),
                    api: apiName)

                rpc.send(request: auth) { result  in

                    switch result {
                        
                    case .success(let data,_):
                        self.accessToken =  data.token
                        promise.resolve(with: self)

                    case .error(let error):
                       error_handler(error: error)
                    }
                }
            }
            catch {
                error_handler(error: error)
            }
        }
        
        func check_state(token: String) {
            do {
                let state = try get_cuid_state_request(key: self.clientPair.privateKey.encode(), token: token)
                
                self.rpc.send(request: state) { result  in
                    switch result {
                    case .success(let permit, _):
                        
                        if !permit {
                            self.accessToken = nil
                            get_new_token()
                        }
                        else {
                            promise.resolve(with: self)
                        }
                        
                    case .error(let error):
                        error_handler(error: error)
                    }
                }
            }
            catch {
                error_handler(error: error)
            }
        }

        if let token = accessToken {
            check_state(token: token)
        }
        else {
            get_new_token()
        }
        
        return promise
    }
    
    fileprivate let rpc:JsonRpc
    fileprivate var urlTask:URLSessionDataTask?
    fileprivate var url:URL
    fileprivate var clientPair:Pair
    fileprivate var apiName:String
    fileprivate var apiPair:Pair
    
    fileprivate var accessToken:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Session.accessTokenKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Session.accessTokenKey)
        }
    }
    
    fileprivate static let accessTokenKey = "dehancerd-api-access-token"
}

extension Future where Value: Session {
        
     @discardableResult func profile_list(complete:((Result<[Profile]>) -> ())? = nil) -> Future<Value> {
        return chained { session in
            
            let promise = Promise<Value>()
            
            func get_list (token: String) {
                do {
                    let list = try get_profile_list_request(key: session.clientPair.privateKey.encode(), token: token)
                    
                    session.rpc.send(request: list) { result  in
                        switch result {
                            
                        case .success(let data, let id):
                            
                            promise.resolve(with: session) {
                                complete?(Result.success(data, id))
                            }
                            
                        case .error(let error):
                            promise.reject(with: error){
                                complete?(Result.error(error))
                            }
                        }
                    }
                }
                catch {
                    promise.reject(with: error){
                        complete?(Result.error(error))
                    }
                }
                
            }
            
            guard let token = session.accessToken else {
                
                do {
                    
                    let auth = try get_auth_token_request(
                        cuid: session.clientPair.publicKey.encode(),
                        key: session.apiPair.privateKey.encode(),
                        api: session.apiName)
                    
                    session.rpc.send(request: auth) { result  in
                        
                        switch result {
                        case .success(let data,_):
                            
                            session.accessToken =  data.token
                            
                            get_list(token: session.accessToken!)
                            
                            //promise.resolve(with: self) {
                            //    complete?(Result.success(data.token, id))
                            //}
                            
                        case .error(let error):
                            
                            session.accessToken = nil
                            
                            promise.reject(with: error){
                                complete?(Result.error(error))
                            }
                        }
                    }
                }
                catch {
                    session.accessToken = nil
                    promise.reject(with: error){
                        complete?(Result.error(error))
                    }
                }
                
                return promise
            }
           
            get_list(token: token)
           
            return promise
        }
    }
}
