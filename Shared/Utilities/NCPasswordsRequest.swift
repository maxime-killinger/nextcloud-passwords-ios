import Foundation


protocol NCPasswordsRequest {
    
    associatedtype ResultType
    func encode() -> Data?
    func send(completion: @escaping (ResultType?) -> Void)
    func decode(data: Data) -> ResultType?
    
}


extension NCPasswordsRequest {
    
    func encode() -> Data? {
        nil
    }
    
}


extension NCPasswordsRequest {
    
    func get(action: String, credentials: Credentials, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "GET", credentials: credentials, completion: completion)
    }
    
    func post(action: String, credentials: Credentials, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "POST", credentials: credentials, completion: completion)
    }
    
    func patch(action: String, credentials: Credentials, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "PATCH", credentials: credentials, completion: completion)
    }
    
    func delete(action: String, credentials: Credentials, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "DELETE", credentials: credentials, completion: completion)
    }
    
    private func send(action: String, method: String, credentials: Credentials, completion: @escaping (ResultType?) -> Void) {
        guard let authorizationData = "\(credentials.user):\(credentials.password)".data(using: .utf8),
              let apiUrl = URL(string: credentials.server)?.appendingPathComponent("index.php/apps/passwords/api/1.0", isDirectory: true),
              let url = URL(string: action, relativeTo: apiUrl) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(authorizationData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        request.httpShouldHandleCookies = false
        request.httpBody = encode()
        
        URLSession(configuration: .default, delegate: nil, delegateQueue: .main).dataTask(with: request) {
            [self] data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(decode(data: data))
        }
        .resume()
    }
    
}
