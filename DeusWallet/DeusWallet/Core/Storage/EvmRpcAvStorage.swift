import GRDB

class EvmRpcAvStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
}

extension EvmRpcAvStorage {
    func getAll() throws -> [EvmRpcAvRecord] {
        try dbPool.read { db in
            try EvmRpcAvRecord.fetchAll(db)
        }
    }

    func records(chainId: Int) throws -> [EvmRpcAvRecord] {
        try dbPool.read { db in
            try EvmRpcAvRecord.filter(EvmRpcAvRecord.Columns.chainId == chainId).fetchAll(db)
        }
    }

    func save(record: EvmRpcAvRecord) throws {
        _ = try dbPool.write { db in
            try record.insert(db)
        }
    }
    
    func save(records: [EvmRpcAvRecord]) {
        _ = try! dbPool.write { db in
            for record in records {
                try record.insert(db)
            }
        }
    }

    func delete(chainId: Int, url: String) throws {
        _ = try dbPool.write { db in
            try EvmRpcAvRecord.filter(EvmRpcAvRecord.Columns.chainId == chainId && EvmRpcAvRecord.Columns.url == url).deleteAll(db)
        }
    }
    
    func deleteAll() {
        _ = try! dbPool.write { db in
            try EvmRpcAvRecord
                .deleteAll(db)
        }
    }
}
