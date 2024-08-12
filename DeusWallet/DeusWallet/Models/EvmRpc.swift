import Foundation

struct EvmRpc: Codable {
    var url: String
    var height: Int
    var latency: Int
}

struct RemoteEvmRpc: Codable {
    enum CodingKeys: String, CodingKey {
       case chainId = "chainId"
       case nodes = "nodes"
    }
    
    var chainId: Int
    var nodes: [EvmRpc]
}
