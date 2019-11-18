//
//  upload-camera-profile.swift
//  DehancerdClient
//
//  Created by denn nevera on 12/10/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class upload_camera_profile_request: Request {
    
    typealias ResponseType = Bool
    
    var method: String  { return "upload-camera-profile" }
    var params: Params? { return _params }
    
    class ParamsHelper: Params {
        
        var cuid:String = ""
        var signature:String = ""
        var data:String = ""
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            
            cuid           <- map["cuid"]
            signature      <- map["signature"]
            data           <- map["data"]
        }
    }
    
    init(
        key client_private_key: String,
        token: String,        
        data: String
        ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        _params.data = data
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
