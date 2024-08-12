import Foundation
import GRDB

class EvmRpcAvRecord: Record {
    var chainId: Int
    var url: String
    var height: Int
    var latency: Int

    init(chainId: Int, url: String, height: Int, latency: Int) {
        self.chainId = chainId
        self.url = url
        self.height = height
        self.latency = latency

        super.init()
    }

    override class var databaseTableName: String {
        "evmRpcAv"
    }

    enum Columns: String, ColumnExpression {
        case chainId
        case url
        case height
        case latency
    }

    required init(row: Row) throws {
        chainId = row[Columns.chainId]
        url = row[Columns.url]
        height = row[Columns.height]
        latency = row[Columns.latency]

        try super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.chainId] = chainId
        container[Columns.url] = url
        container[Columns.height] = height
        container[Columns.latency] = latency
    }
}
