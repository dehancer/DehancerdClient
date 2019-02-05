//
//  JsonRpc.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ObjectMapper

public enum ResponseCode:Int {
    case parseError            = -32700
    case invalidRequest        = -32600
    case methodNotFound        = -32601
    case invalidParams         = -32602
    case internalError         = -32603
    case serverErrorStart      = -32099
    case saerverErrorEnd       = -32000
    case unknownErrorCode      = -32001
    
    case notAuthorized         = -40001
    case accessForbidden       = -40003
    case clientNotRegistered   = -40004
}

public enum Result<T> {
    case success(T,Int)
    case error(Error)
}

public class Response:Mappable {
    public required init?(map: Map) {}
    public func mapping(map: Map) {}
}

public class Params:Mappable {
    public required init?(map: Map) {}
    public func mapping(map: Map) {}
}

public protocol Request {
    
    typealias ResponsObject = Any
    associatedtype ResponseType//:Response
    
    var method:String {get}
    var params:Params? {get}
    func response<R>(_ object: ResponsObject) throws -> R
}


public class JsonRpc {
    
    public init (base url:URL) {
        self.url = url
    }
    
    public func send<T:Request>(request object: T,
                                complete: @escaping ((Result<T.ResponseType>) -> ())) {

        let id = nextId
        let methodName = object.method
        let params = Mapper().toJSON(object.params ?? Params(JSON: [:])!)
       
        let json
            = ["jsonrpc":"2.0",
               "method":methodName,
               "params": params,
               "id": "\(id)"] as [String : Any]
        
        do {
                        
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            var r = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0)
            
            r.httpMethod = "POST"
            r.httpBody = data
            
            URLSession(configuration: .default).dataTask(with: r) {
                
                data, response, error in
                
                if let error = error {
                    complete(Result.error(error))
                    return
                }
                
                do {
                    if let data = data {
                        
                        let d = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        
                        let retId = Int("\(d["id"] ?? "-1")") ?? -1
                        
                        if let result = d["result"] {
                            
                            let o:T.ResponseType = try object.response(result)
                            let r = Result.success(o, retId)
                            complete(r)
                            
                         
                        }
                        else if let e =  d["error"] as? [String: Any] {
                            
                            let error = NSError(domain: "com.dehancer.json.rpc",
                                                code: e["code"] as? Int ?? -1,
                                                userInfo: [
                                                    "RequestId": retId,
                                                    NSLocalizedDescriptionKey :  e["message"] as? String ?? "Unkown error",
                                                    NSLocalizedFailureReasonErrorKey:
                                                        String.localizedStringWithFormat("Rpc error")])
                            
                            complete(Result.error(error))
                        }
                        else {
                            let error = NSError(domain: "com.dehancer.json.rpc",
                                                code:  -1,
                                                userInfo: [
                                                    "RequestId": retId,
                                                    NSLocalizedDescriptionKey : "Null responsed data",
                                                    NSLocalizedFailureReasonErrorKey:
                                                        String.localizedStringWithFormat("Rpc error")])
                            complete(Result.error(error))
                        }
                    }
                    else {
                        let description = String
                            .localizedStringWithFormat("Response for method %@ could not be parsed", methodName)
                        
                        let e = NSError(domain: "com.dehancer.json.rpc",
                                        code: -1,
                                        userInfo: [
                                            NSLocalizedDescriptionKey : description,
                                            NSLocalizedFailureReasonErrorKey:
                                                String.localizedStringWithFormat("Rpc response parser error")])
                        complete(Result.error(e))
                    }
                }
                    
                catch {
                    complete(Result.error(error))
                }
                
                }.resume()
        }
        catch {
            complete(Result.error(error))
        }
    }
    
    private var nextId:Int {
        let lock = NSLock()
        lock.lock()
        defer {
            lock.unlock()
        }
        JsonRpc.idCounter += 1
        return JsonRpc.idCounter;
    }
    private var url:URL
    private static var idCounter:Int = 0
}
