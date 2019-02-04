//
//  get-auth-token.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ObjectMapper
import ed25519

internal class get_auth_token_request: Request {

    public typealias ResponseType = ResponseHelper

    public let api_name:String

    public var method: String  { return "get-auth-token" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        public var token:String = ""
        public var cuid:String = ""
        public var digest:String = ""
        public var signature:String = ""
        override public func mapping(map: Map) {
            super.mapping(map: map)
            token <- map["api-access-token"]
            cuid <- map["cuid"]
            digest <- map["digest"]
            signature <- map["signature"]
        }
    }
    
    public class ResponseHelper: Response {
        
        public var token: String { return _token }
        
        public convenience init?(_ token: String) {
            self.init(JSON: ["token": token])
        }
        override public func mapping(map: Map) {
            super.mapping(map: map)
            _token <- map["token"]
        }
        private var _token: String = ""
    }
    
  
    public init(cuid public_key:String,
                key access_token_private_key: String,
                api name: String) throws {
        
        api_name = name
        
        let digest = Digest { (calculator) in
            calculator.append(Seed())
            calculator.append(self.api_name)
        }
        
        let pair = try Pair(fromPrivateKey: access_token_private_key)
        
        _params.token = pair.publicKey.encode()
        _params.signature = pair.sign(digest).encode()
        _params.cuid = public_key
        _params.digest = digest.encode()
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return ResponseHelper("\(object)") as! R
    }
        
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
