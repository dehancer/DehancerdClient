//
//  set-user-info.swift
//  DehancerdClient
//
//  Created by denn on 06/02/2019.
//

import Foundation
import ObjectMapper
import ed25519

public typealias UserInfo = set_user_info_request.ParamsHelper

public class set_user_info_request: Request {
    
    public typealias ResponseType = Bool
    
    public var method: String  { return "set-user-info" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        public var name:String = ""
        public var full_name:String = ""
        public var email:String = ""
        public var client_name:String = ""
        public var client_version:String = ""
        
        override public func mapping(map: Map) {
            super.mapping(map: map)
           
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            
            name           <- map["name"]
            full_name      <- map["full-name"]
            email          <- map["email"]
            client_name    <- map["client-name"]
            client_version <- map["client-version"]
        }
    }
    
    public init(info:UserInfo) {
        _params = info
    }
    
    public init(
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
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
