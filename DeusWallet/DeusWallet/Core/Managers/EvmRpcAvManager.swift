import Foundation

import Foundation
import MarketKit
import EvmKit
import HsToolKit


class EvmRpcAvManager {
    private let evmRpcAvStorage: EvmRpcAvStorage
    private let evmRpcAvProvider: EvmRpcAvProvider
    private let logger: Logger

    init(evmRpcAvStorage: EvmRpcAvStorage, evmRpcAvProvider: EvmRpcAvProvider, logger: Logger){
        self.evmRpcAvStorage = evmRpcAvStorage
        self.evmRpcAvProvider = evmRpcAvProvider
        self.logger = logger
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            evmRpcAvProvider.callGet(baseUrl: AppConfig.evmRpcAvApiLink) { result in
                switch result {
                    case .success(let remoteEvmRpc):
                    let records = remoteEvmRpc.nodes
                        .enumerated()
                        .map { offset, element in EvmRpcAvRecord(
                            chainId:  remoteEvmRpc.chainId,
                            url: element.url,
                            height: element.height,
                            latency: element.latency
                        )}
        
                        evmRpcAvStorage.deleteAll()
                        evmRpcAvStorage.save(records: records)
                    
                    case .failure(let error):
                        self.logger.log(level: .error, message: "evmRpcAvProvider \(error)")
                }
            }
        }
    }
    
    func availableRpc(chainId: Int, transactionSource: EvmKit.TransactionSource) throws -> [EvmSyncSource] {
        let records: [EvmRpcAvRecord]  = try self.evmRpcAvStorage.records(chainId: chainId)
        
        let sortedRecords = records.sorted { (lhs, rhs) -> Bool in
//            if lhs.height == rhs.height {
//                return lhs.latency < rhs.latency
//            }
            return lhs.height > rhs.height
        }
       
        let evmSyncSource: [EvmSyncSource] = sortedRecords
            .enumerated()
            .map { offset, element in EvmSyncSource(
                name: element.url.components(separatedBy: "/")[2].components(separatedBy: ".").suffix(2).joined(separator: "."),
                rpcSource: .http(urls: [URL(string: element.url)!], auth: nil),
                transactionSource: transactionSource
            )}
        
        return Array(evmSyncSource.prefix(3))
    }
}
