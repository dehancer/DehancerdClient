//
//  get-camera-list.swift
//  CryptoSwift
//
//  Created by denn nevera on 11/10/2019.
//

import Foundation
import ObjectMapper
import ed25519

public class Vendor: Mappable {
    
    public var          id = ""
    public var        name = ""
    public var    caption  = ""
    public var description = ""
    
    public init(name: String) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        caption <- map["caption"]
        description <- map["description"]
    }
}

public class Format: Mappable {
    public var description = ""
    public var          id = ""
    public var        name = ""
    public var    revision = -1
    public var  types:[String] = []
    public var   vendor_id = ""
    
    public init(vendor id:String, name: String) {
        self.vendor_id = id
        self.name = name
        self.id = self.vendor_id + ":" + name.lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        description <- map["description"]
        id <- map["id"]
        name <- map["name"]
        revision <- map["revision"]
        types <- map["types"]
        vendor_id <- map["vendor_id"]
    }
}

public class CameraProfileReference: Mappable {
    
    public var   format_id = ""
    public var   url:URL?
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        format_id <- map["format_id"]
        if let context = map.context as? Context {
            url <- (map["url"], SignedURLTransform(context: context))
        }
        else {
            url <- (map["url"], URLTransform(shouldEncodeURLString: true))
        }
    }
}

public class Model: Mappable {
    public var description = ""
    public var          id = ""
    public var        name = ""
    public var     caption = ""
    public var   profiles:[CameraProfileReference] = []
    public var  formats:[String] = []
    public var   vendor_id = ""
    
    public init(vendor id: String, name: String) {
        self.vendor_id = id
        self.name = name
        self.id = self.vendor_id + ":" + name.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        description <- map["description"]
        id <- map["id"]
        name <- map["name"]
        caption <- map["caption"]
        profiles <- map["profiles"]
        formats <- map["formats"]
        vendor_id <- map["vendor_id"]
    }
}

public class CameraReferences: Mappable {
    
    public var formats:[Format] = []
    public var models:[Model]  = []
    public var vendors:[Vendor]  = []

    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        formats <- map["camera_formats"]
        models <- map["camera_models"]
        vendors <- map["camera_vendors"]
    }
}

internal class get_camera_references_request: Request {
    
    public typealias ResponseType = CameraReferences

    public var method: String  { return "get-camera-references" }
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
        if let o = object as? [String : Any] {
            return Mapper<CameraReferences>( context: Context(cuid: _params.cuid, signature: _params.signature),
                                    shouldIncludeNilValues: true).map(JSON: o) as! R
        }
        throw JsonRpc.Errors.parse(responseId: -1, code: ResponseCode.parseError, message: "Unknown response object type")
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}

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
