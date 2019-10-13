//
//  url-transform.swift
//  DehancerdClient
//
//  Created by denn nevera on 11/10/2019.
//

import Foundation

import Foundation
import ObjectMapper
import ed25519

public struct Context: MapContext {
    public var cuid:String = ""
    public var signature:String = ""
}

extension String {
    mutating func appendItem(_ item: String, value:String)  {
        self.append(item)
        self.append("=")
        self.append(value)
    }
}

public class SignedURLTransform: TransformType {
    public typealias Object = URL
    public typealias JSON = String
    private let context: Context
    
    public init(context: Context) {
        self.context = context
    }

    open func transformFromJSON(_ value: Any?) -> URL? {
        guard var URLString = value as? String else { return nil }
        
        URLString.append("?")
        URLString.appendItem("cuid", value: context.cuid)
        URLString.append("&")
        URLString.appendItem("signature", value: context.signature)

        guard let escapedURLString = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: escapedURLString)
    }
    
    open func transformToJSON(_ value: URL?) -> String? {
        if let URL = value {
            return URL.absoluteString
        }
        return nil
    }
}
