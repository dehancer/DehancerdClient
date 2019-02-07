//
//  DehancerdApi.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ed25519

public final class Session {
    
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
    
    @discardableResult public func authenticate(error exit:((Error)->())?=nil)  -> Future<Session> {
        
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
    fileprivate let lock = NSLock()
}

public extension Future where Value: Session {
    
    private func check(session: Session,
                       promise: Promise<Value>,
                       error error_hanler: @escaping ((Error)->Void), complete: @escaping (()->Void)) {
        do {
            
            let auth = try get_auth_token_request(
                cuid: session.clientPair.publicKey.encode(),
                key: session.apiPair.privateKey.encode(),
                api: session.apiName)
            
            session.rpc.send(request: auth) { result  in
                
                switch result {
                case .success(let data,_):
                    
                    session.lock.lock()
                    defer {
                        session.lock.unlock()
                    }
                    
                    session.accessToken =  data.token
                    
                    complete()
                    
                case .error(let error):
                    session.lock.lock()
                    defer {
                        session.lock.unlock()
                    }
                    session.accessToken = nil
                    promise.reject(with: error){
                        error_hanler(error)
                    }
                }
            }
        }
        catch {
            session.accessToken = nil
            promise.reject(with: error){
                error_hanler(error)
            }
        }
    }
    
    @discardableResult public func set_user(
        info: UserInfo? = nil,
        complete:((Result<Bool>) -> ())? = nil) -> Future<Value> {
        return chained { session in
            
            let promise = Promise<Value>()
            
            func set_user_info (token: String) {
                do {
                    
                    let user = info != nil ? set_user_info_request(info:info!) : try set_user_info_request(key: session.clientPair.privateKey.encode(), token: token)

                     //let user = try set_user_info_request(key: session.clientPair.privateKey.encode(), token: token)
                    
                    session.rpc.send(request: user) { result  in
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
            
            session.lock.lock()
            defer {
                session.lock.unlock()
            }
            
            guard let token = session.accessToken else {
                
                self.check(session: session,
                           promise: promise,
                           error: { error in
                            complete?(Result.error(error))
                }){
                    set_user_info(token: session.accessToken!)
                }
                
                return promise
            }
            
            set_user_info(token: token)

            return promise
        }
    }
    
     @discardableResult public func profile_list(complete:((Result<[Profile]>) -> ())? = nil) -> Future<Value> {
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
            
            session.lock.lock()
            defer {
                session.lock.unlock()
            }
            
            guard let token = session.accessToken else {

                self.check(session: session,
                           promise: promise,
                           error: { error in
                            complete?(Result.error(error))
                }) {
                    get_list(token: session.accessToken!)
                }
                return promise
            }
           
            get_list(token: token)
           
            return promise
        }
    }
}
