//
//  APIClient.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//

import Foundation

/// This protocol is responsible to execute a Request
/// by calling the underlyning layer i.e. URLSession
/// As output for a Request it should provide a Response.

protocol APIClient {
    
    var session: URLSession { get }
    
    func fetch<T: Codable>(with request: URLRequest, decode: @escaping (Codable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
}
extension APIClient {
    
    /// number of seconds
    var connectionTimout: Float {
        get { return 60.0 }
    }
    typealias JSONTaskCompletionHandler = (Codable?, APIError?) -> Void
    
    /// To make the a request along with the decoder with the given data
    ///
    /// - Parameters:
    ///   - request: URLRequest
    ///   - decodingType: decoding type
    ///   - completion: check JSONTaskCompletionHandler
    /// - Returns: URLSessionDataTask
    fileprivate func decodingTask<T: Codable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let task =  URLSession.shared.dataTask(with: request) { ( data,response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.status! == .ok {
                if let data = data {
                    do {
                        debugPrint("Base URL: \(String(request.url?.absoluteString ?? "")) \r\n Request: \(String(data: request.httpBody ?? Data(), encoding: .utf8)) \r\n Response: \(String(data: data, encoding: .utf8) ?? "error")")
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            }else if httpResponse.status! == .unauthorized {
                completion(nil, .unauthorized)
            }
            
        }
        return task
    }
    
    /// To make the a request with the given data
    ///
    /// - Parameters:
    ///   - request: urlrequest
    ///   - decode: decode object
    ///   - completion: check Result<T, APIError>
    func fetch<T: Codable>(with request: URLRequest, decode: @escaping (Codable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        //self.index = 0
        let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
            //MARK: change to main queue
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
}


