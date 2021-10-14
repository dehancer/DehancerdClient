//
//  upload-common-profile.swift
//  DehancerCommon
//
//  Created by denn nevera on 14/10/2021.
//

import Foundation
import ObjectMapper
import ed25519

internal class upload_common_profile_request: Request {
    
    typealias ResponseType = Bool
    
    var method: String  { return "upload-xxx-profile" }
    var params: Params? { return _params }
    
    class ParamsHelper: Params {
        
        var cuid:String = ""
        var signature:String = ""
        var data:String = ""
        var is_published:Bool?

        override func mapping(map: Map) {
            super.mapping(map: map)
            
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            data           <- map["data"]
            is_published   <- map["is_published"]
        }
    }
    
    init(
        key client_private_key: String,
        token: String,
        data: String,
        is_published: Bool? = nil
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        _params.data = data
        _params.is_published = is_published
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
