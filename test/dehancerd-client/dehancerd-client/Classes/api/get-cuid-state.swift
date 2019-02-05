//
//  get_cuid_state_request.swift
//  dehancerd-client
//
//  Created by denn on 05/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation

import Foundation
import ObjectMapper
import ed25519

internal class get_cuid_state_request: Request {
    
    public typealias ResponseType = Bool
    
    public var method: String  { return "get-cuid-state" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
        }
    }
    
    public init(key client_private_key: String, token: String) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }
        
        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return object as! R
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
