import Foundation
import SwiftUI


class EvmRpcAvProvider {
    private var deviceUuid : String

    enum ExternalServiceError: Error {
        case invalidURL
        case clientError(description: String)
        case serverError(statusCode: Int)
        case jsonDecodingError(description: String)
        case unexpectedResponse
    }
    
    init() {
        self.deviceUuid = EvmRpcAvProvider.getUniqueDeviceIdentifierAsString()
    }
    
    func generateRandomBytes() -> Data {
        var bytes = [UInt8](repeating: 0, count: 39)
        let _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let dataBlock = Data(bytes)
        return dataBlock
    }
    
    func callGet(baseUrl: String, completion: @escaping (Result<RemoteEvmRpc, ExternalServiceError>) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let hash = generateRandomBytes()
                                        
        guard let url = URL(string: "\(baseUrl)?timestamp=\(timestamp)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
                
        // Adding headers
        request.addValue(deviceUuid, forHTTPHeaderField: "x-client-uuid")
        request.addValue("iOS", forHTTPHeaderField: "x-client-platform")
        request.addValue(hash.base64EncodedString(), forHTTPHeaderField: "if-none-match")
        
        let session = URLSession.shared

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.clientError(description: error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unexpectedResponse))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data else {
                completion(.failure(.unexpectedResponse))
                return
            }
            
            do {
                 let nodes = try JSONDecoder().decode(RemoteEvmRpc.self, from: data)
                 completion(.success(nodes))

            } catch {
                completion(.failure(.jsonDecodingError(description: error.localizedDescription)))
            }
        }
        
        task.resume()
    }
}

extension EvmRpcAvProvider {
    public static func getUniqueDeviceIdentifierAsString() -> String {
        let serviceName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "DefaultServiceName"
        let accountName = "incoding"

        // Search for the existing keychain item
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ] as [String: Any]

        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecValueData as String] as? Data,
               let uuid = String(data: data, encoding: .utf8) {
                return uuid
            }
        }

        // No existing item found, create a new UUID and add it to the keychain
        let newUUID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let data = newUUID.data(using: .utf8)!

        let attributes = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: data
        ] as [String: Any]

        SecItemAdd(attributes as CFDictionary, nil)

        return newUUID
    }
}

