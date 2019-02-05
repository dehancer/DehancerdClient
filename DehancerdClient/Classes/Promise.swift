//
//  Promise.swift
//  dehancerd-client
//
//  Created by denn on 05/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation

public enum FutureResult<Value> {
    case value(Value)
    case error(Error)
}

public class Future<Value> {
    
    fileprivate var result: FutureResult<Value>? {        
        didSet {
            result.map(report)
        }
    }
    
    private lazy var callbacks = [(FutureResult<Value>) -> Void]()

    func observe(with callback: @escaping (FutureResult<Value>) -> Void) {
        callbacks.append(callback)
        // If a result has already been set, call the callback directly
        result.map(callback)
    }

    private func report(result: FutureResult<Value>) {
        for callback in callbacks {
            callback(result)
        }
    }
}

public class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()

        // If the value was already known at the time the promise
        // was constructed, we can report the value directly
        result = value.map(FutureResult.value)
    }

    func resolve(with value: Value, complete: (()->())?=nil) {
        result = .value(value)
        complete?()
    }

    func reject(with error: Error, complete: (()->())?=nil) {
        result = .error(error)
        complete?()
    }
}

public extension Future {
    
    public func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
       
        let promise = Promise<NextValue>()

        observe { result in
            switch result {
            case .value(let value):
                do {
                    
                    let future = try closure(value)

                    future.observe { result in
                        switch result {
                        
                        case .value(let value):
                        
                            promise.resolve(with: value)
                            
                        case .error(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .error(let error):
                promise.reject(with: error)
            }
        }

        return promise
    }

    public func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
        return chained { value in
            return try Promise(value: closure(value))
        }
    }
}
