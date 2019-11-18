//
//  set-user-info.swift
//  DehancerdClient
//
//  Created by denn on 06/02/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class set_user_info_request: Request {
    
    typealias ResponseType = Bool
    typealias ParamsHelper = UserInfo
    
    var method: String  { return "set-user-info" }
    var params: Params? { return _params }
    
    
    init(info:UserInfo) {
        _params = info
    }
    
    init(
        key client_private_key: String,
        token: String,
        
        name: String? = nil,
        full_name: String? = nil,
        email: String? = nil,
        client_name: String? = nil,
        client_version: String? = nil
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        
        _params.name = name ?? NSUserName()
        _params.full_name = full_name ?? NSFullUserName()
        _params.email = email ?? ""
        _params.client_name = client_name ?? Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
      
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build =  Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        _params.client_version = "\(version)(\(build))"
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
