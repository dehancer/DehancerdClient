//
//  get-camera-list.swift
//  CryptoSwift
//
//  Created by denn nevera on 11/10/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class update_camera_reference_request: Request {
    
    public typealias ResponseType = Bool

    public var method: String  { return "update-camera-reference" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        public var vendor:Vendor?
        public var model:Model?
        public var format:Format?

        override public func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
            vendor <- map["vendor"]
            model <- map["model"]
            format <- map["format"]
        }
    }
    
    public init(key client_private_key: String,
                token: String,
                vendor:Vendor? = nil,
                model:Model? = nil,
                format:Format? = nil
    ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }

        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        _params.vendor = vendor
        _params.model = model
        _params.format = format
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
