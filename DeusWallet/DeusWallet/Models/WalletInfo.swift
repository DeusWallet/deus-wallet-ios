import Foundation

class WalletInfo : Codable {
    var d: String
   
    init(data: String) {
       self.d = data
    }
}
