//
//  update-profile-exports.swift
//  DehancerdClient
//
//  Created by denis svinarchuk on 08/03/2019.
//

import Foundation
import ObjectMapper
import ed25519


public class update_profile_exports_request: Request {
    
    public typealias ResponseType = Bool
    
    public var method: String  { return "update-profile-exports" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        public var name:String = ""
        public var revision:Int = 0
        public var count:Int = 0
        public var files:Int = 0
        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            
            name           <- map["name"]
            revision       <- map["revision"]
            count          <- map["count"]
            files          <- map["files"]
        }
    }
    
    public init(
        key client_private_key: String,
        token: String,
        
        profile name: String,
        revision: Int,
        count: Int,
        files: Int
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        
        _params.name = name 
        _params.revision = revision 
        _params.count = count
        _params.files = files       
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
