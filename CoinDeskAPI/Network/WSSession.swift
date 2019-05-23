//
//  WSSession.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation

//
// WSSession
//   Implements a generic WebService session that can handle all remote web-service requests. There is
//   no need to alter this class in order to add additional services or endpoints; instead, create new enum
//   that conforms to the "WSEndpointProtocol" and pass it to WSSession along with a codable response model.
//

// web-service endpoints should conform to this protocol
public protocol WSEndpointProtocol {
    // webservice path generation
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var params: [URLQueryItem] { get }
    // custom response decoding
    func decode<T:Decodable>(with data: Data, decodingType: T.Type) -> WSResponse<T>;
}

// WebService specific errors
public enum WSError: Error {
    case urlCreationError
    case unknownError
    case badResponse(Int)
    case networkError(Error)
    case parseError(Error)
    
    var localizedDescription: String {
        switch self {
        case .urlCreationError: return "Unable to generate service URL"
        case .unknownError: return "Unknown networking error"
        case .badResponse(let code): return "Bad response code: \(code)"
        case .networkError(let error): return "Network error: " + error.localizedDescription
        case .parseError(let error): return "Error parsing JSON: \(error)"
        }
    }
}

// WebService response format
public enum WSResponse<T:Decodable> {
    case success(T)
    case error(WSError)
}

// WebService completion handler
public typealias WSCompletionHandler<T:Decodable> = (WSResponse<T>) -> Void

// WebService session singleton
final public class WSSession {
    static let shared : URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        let session = URLSession(configuration: configuration)
        return session
    }()
}

// MARK: - Generic WebServiceSession
extension WSSession {
    
    internal func generateURL(_ endpoint: WSEndpointProtocol) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.params
        return urlComponents.url
    }
    
    public func get<T:Decodable>(_ endpoint: WSEndpointProtocol, responseType: T.Type, callback: @escaping WSCompletionHandler<T>) -> URLSessionDataTask? {
        var task: URLSessionDataTask? = nil
        
        // generate service path
        guard let requeustURL = generateURL(endpoint) else {
            callback(.error(WSError.urlCreationError))
            return task
        }
        
        // invoke download on background thread
        task = WSSession.shared.dataTask(with: requeustURL) { data, response, error in
            
            // error check - no error code
            if let errorMessage = error {
                DispatchQueue.main.async {
                    callback(.error(WSError.networkError(errorMessage)))
                }
                return
            }
            // error check - valid response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    callback(.error(WSError.badResponse(-1)))
                }
                return
            }
            // error check - valid status code
            guard httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    callback(.error(WSError.badResponse(httpResponse.statusCode)))
                }
                return
            }
            // error check - valid payload
            guard let data = data else {
                DispatchQueue.main.async {
                    callback(.error(WSError.unknownError))
                }
                return
            }
            
            // parse/map response
            let decoded: WSResponse<T> = endpoint.decode(with: data, decodingType: T.self)

            DispatchQueue.main.async {
                switch decoded {
                case .success(let result):
                    callback(.success(result))
                case .error(let error):
                    callback(.error(WSError.parseError(error)))
                }
            }
        }
        task?.resume()
        
        return task // task handle returned to caller
    }
}
