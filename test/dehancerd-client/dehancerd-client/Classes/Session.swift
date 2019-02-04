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
    
    @discardableResult public func open(mode: OpenMode = .reuse, complete:((Result<String>) -> ())? = nil) -> Session {
        
        if mode == .reuse, let token = accessToken {
            complete?(Result.success(token, -1))
        }
        else {
            
            do {
                let auth = try get_auth_token_request(
                    cuid: clientPair.publicKey.encode(),
                    key: apiPair.privateKey.encode(),
                    api: apiName)
                
                rpc.send(request: auth) { result  in
                    switch result {
                    case .success(let data, let id):
                        
                        self.accessToken =  data.token
                        complete?(Result.success(data.token, id))
                        
                    case .error(let error):
                        
                        complete?(Result.error(error))
                        
                    }
                }
            }
            catch {
                complete?(Result.error(error))
            }
        }
        
        return self
    }
    
    @discardableResult public func get_profile_list(complete:((Result<[Profile]>) -> ())? = nil) -> Session {
        
        guard let token = self.accessToken else {
            fatalError("Access token should be recieved from server or restore from local storage...")
        }
        
        do {
            let list = try get_profile_list_request(key: clientPair.privateKey.encode(), token: token)
            
            rpc.send(request: list) { result  in
                switch result {
                    
                case .success(let data, let id):
                    
                    complete?(Result.success(data.list, id))
                    
                case .error(let error):
                    
                    complete?(Result.error(error))
                    
                }
            }
        }
        catch {
            complete?(Result.error(error))
        }
        
        return self
    }
    
    private let rpc:JsonRpc
    private var urlTask:URLSessionDataTask?
    private var url:URL
    private var clientPair:Pair
    private var apiName:String
    private var apiPair:Pair
    
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
