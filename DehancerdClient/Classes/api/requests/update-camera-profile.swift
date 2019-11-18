//
//  update-camera-profile.swift
//  DehancerCommon
//
//  Created by denn nevera on 13/10/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class update_camera_profile_request: Request {
    
    internal typealias ResponseType = Bool
    
    var method: String  { return "update-camera-profile" }
    var params: Params? { return _params }
    
    class ParamsHelper: Params {
        
        var cuid:String = ""
        var signature:String = ""
        var id:String = ""
        var is_published:Bool = false
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            
            id            <- map["id"]
            is_published  <- map["is_published"]
        }
    }
    
    init(
        key client_private_key: String,
        token: String,
        
        profile id: String,
        is_published:Bool
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        
        _params.id = id
        _params.is_published = is_published
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
