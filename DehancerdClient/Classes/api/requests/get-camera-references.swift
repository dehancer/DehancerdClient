//
//  get-camera-references.swift
//  DehancerCommon
//
//  Created by denn nevera on 18/11/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class get_camera_references_request: Request {
    
    typealias ResponseType = CameraReferences

    var method: String  { return "get-camera-references" }
    var params: Params? { return _params }
    
    class ParamsHelper: Params {
        
        var cuid:String = ""
        var signature:String = ""
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
        }
    }
    
    init(key client_private_key: String, token: String) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }

        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        if let o = object as? [String : Any] {
            return Mapper<CameraReferences>( context: Context(cuid: _params.cuid, signature: _params.signature),
                                    shouldIncludeNilValues: true).map(JSON: o) as! R
        }
        throw JsonRpc.Errors.parse(responseId: -1, code: ResponseCode.parseError, message: "Unknown response object type")
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
