//
//  upload-camera-profile.swift
//  DehancerdClient
//
//  Created by denn nevera on 12/10/2019.
//

import Foundation
import ObjectMapper
import ed25519

public class upload_camera_profile_request: Request {
    
    public typealias ResponseType = Bool
    
    public var method: String  { return "upload-camera-profile" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        public var id:String = ""
        public var data:String = ""
        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            
            id           <- map["id"]
            data           <- map["data"]
        }
    }
    
    public init(
        key client_private_key: String,
        token: String,
        
        profile id: String,
        data: String
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        
        _params.id = id
        _params.data = data
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}