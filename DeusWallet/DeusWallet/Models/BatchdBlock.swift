import Foundation

class BatchdBlock {
    var batchNo: Int
    var data: Data
    
    init(batchNo: Int, data: Data) {
        self.batchNo = batchNo
        self.data = data
    }
}
