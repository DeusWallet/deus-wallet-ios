import CommonCrypto
import ComponentKit
import CryptoSwift
import Foundation
import HsCryptoKit
import HsExtensions
import Scrypt

enum BackupCryptoHelper {
    static let defaultCypher = "aes-128-ctr"
    static let defaultKdf = "scrypt"
    
    static let PBKDF2_NUM_OF_ITERATIONS = 5000
    static let PBKDF2_KEY_LENGTH = 32
    static let PBKDF2_SALT_LENGTH = 32
    static let AES256_IV_LENGTH = 16
    static let ENCRYPTED_DATA_OFFSET = PBKDF2_SALT_LENGTH + AES256_IV_LENGTH
    static let BLOCK_MAX_SIZE = 32

    private static func ivData(hex: String) throws -> Data { // initial vector for AES128 must be 16 bytes
        guard hex.count == 2 * kCCKeySizeAES128 else {
            throw CodingError.ivSizeError
        }

        guard let keyData = hex.hs.hexData else {
            throw CodingError.ivDataError
        }
        return keyData
    }

    private static func cryptCTR(iv: Data, key: Data, data: Data, option: CCOperation) throws -> Data {
        let cryptorPointer = UnsafeMutablePointer<CCCryptorRef?>.allocate(capacity: 1)
        key.withUnsafeBytes { key in
            _ = try? iv.withUnsafeBytes { iv in
                let status = CCCryptorCreateWithMode(
                    option,
                    CCMode(kCCModeCTR),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCPadding(ccNoPadding),
                    iv.baseAddress!,
                    key.baseAddress!,
                    key.count,
                    nil,
                    0,
                    0,
                    0,
                    cryptorPointer
                )
                guard status == kCCSuccess else {
                    throw CodingError.cryptError
                }
            }
        }
        let cryptor: CCCryptorRef = cryptorPointer.pointee!

        var resultData = data
        let count = data.count

        _ = resultData.withUnsafeMutableBytes {
            CCCryptorUpdate(cryptor, $0.baseAddress!, count, $0.baseAddress!, count, nil)
        }

        CCCryptorRelease(cryptor)

        return Data(resultData)
    }
}

extension BackupCryptoHelper {
    public static func generateInitialVector(len: Int = 16) -> Data {
        Data(Array(0 ..< len).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
    }

    public static func makeScrypt(pass: Data, salt: Data, dkLen: Int, N: UInt64, r: UInt32, p: UInt32) throws -> Data {
        let result: [UInt8]
        #if DEBUG
            result = try scrypt(
                password: pass.bytes,
                salt: salt.bytes,
                length: dkLen,
                N: N,
                r: r,
                p: p
            )
        #else
            let scryptVar = try Scrypt(
                password: pass.bytes,
                salt: salt.bytes,
                dkLen: dkLen,
                N: Int(N),
                r: Int(r),
                p: Int(p)
            )
            result = try scryptVar.calculate()
        #endif
        return Data(result)
    }

    public static func AES128(operation: Operation, ivHex: String, pass: String, message: Data, kdf: KdfParams) throws -> Data {
        do {
            let key = try BackupCryptoHelper.makeScrypt(
                pass: pass.hs.data,
                salt: kdf.salt.hs.data,
                dkLen: kdf.dklen,
                N: kdf.n,
                r: kdf.r,
                p: kdf.p
            )
            let ivData = try ivData(hex: ivHex)

            return try cryptCTR(iv: ivData, key: key, data: message, option: operation.ccValue)
        } catch {
            if error is PKCS5.PBKDF2.Error || error is ScryptError {
                throw CodingError.cantCreateScryptKey(error)
            }
            throw error
        }
    }

    public static func mac(pass: String, message: Data, kdf: KdfParams) throws -> Data {
        let key = try BackupCryptoHelper.makeScrypt(
            pass: pass.hs.data,
            salt: kdf.salt.hs.data,
            dkLen: kdf.dklen,
            N: kdf.n,
            r: kdf.r,
            p: kdf.p
        )
        let startIndex = kdf.dklen / 2
        let lastHalfKey = key.suffix(from: startIndex)
        let data = lastHalfKey + message

        return Crypto.sha3(data)
    }

    public static func isValid(macHex: String, pass: String, message: Data, kdf: KdfParams) throws -> Bool {
        let sha3 = try mac(pass: pass, message: message, kdf: kdf)
        return macHex == sha3.hs.hex
    }
    
    public static func splitDataIntoBlocks(data: Data, blockSize: Int) -> [Data] {
        var blocks: [Data] = []

        var index = 0
        while index < data.count {
            let end = min(index + blockSize, data.count)
            let block = data.subdata(in: index..<end)
            blocks.append(block)
            index += blockSize
        }

        return blocks
    }
    
    public static func padData(data: Data, blockSize: Int) -> Data {
        let dataLength = data.count

        if dataLength >= blockSize {
            return data
        }

        let paddingSize = blockSize - dataLength
        var paddedData = data
        let padding = Data(repeating: 0, count: paddingSize)
        paddedData.append(padding)
        return paddedData
    }
    
    public static func calculateCRC32(buffer: Data) -> UInt32 {
        var crcTable = [UInt32](repeating: 0, count: 256)

        for i in 0..<256 {
            var crc = UInt32(i)
            for _ in 0..<8 {
                crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1
            }
            crcTable[i] = crc
        }

        var crc: UInt32 = 0xffffffff
        for byte in buffer {
            let index = Int((crc ^ UInt32(byte)) & 0xff)
            crc = (crc >> 8) ^ crcTable[index]
        }

        return crc ^ 0xffffffff
    }
    
    public static func keyFromPasswordAndSalt(password: String, salt: Data) -> Data? {
        let passwordData = password.data(using: .utf8)!
        let hashedPasswordData = sha256(data: passwordData)
        var derivedKey = Data(repeating: 0, count: BackupCryptoHelper.PBKDF2_KEY_LENGTH)

        let result = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                hashedPasswordData.withUnsafeBytes { hashedPasswordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        hashedPasswordBytes.bindMemory(to: UInt8.self).baseAddress,
                        hashedPasswordData.count,
                        saltBytes.bindMemory(to: UInt8.self).baseAddress,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(BackupCryptoHelper.PBKDF2_NUM_OF_ITERATIONS),
                        derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                        BackupCryptoHelper.PBKDF2_KEY_LENGTH
                    )
                }
            }
        }
        
        return result == kCCSuccess ? derivedKey : nil
    }
    
    public static func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    public static func toHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
}

extension BackupCryptoHelper {
    enum Operation {
        case encrypt
        case decrypt

        var ccValue: CCOperation {
            switch self {
            case .encrypt: return CCOperation(kCCEncrypt)
            case .decrypt: return CCOperation(kCCDecrypt)
            }
        }
    }

    enum CodingError: Error {
        case cantCreateScryptKey(Error)
        case ivSizeError
        case ivDataError
        case cryptError
    }
}
