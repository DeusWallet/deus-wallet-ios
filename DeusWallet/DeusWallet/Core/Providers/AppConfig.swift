import Foundation
import MarketKit
import UIKit

enum AppConfig {
    static let label = "io.deus.wallet"
    static let backupSalt = "deus"

    static let companyName = "Deus Wallet Aps LTD"
    static let reportEmail = "support@deuswallet.com"
    static let companyWebPageLink = "https://deuswallet.com"
    static let appWebPageLink = "https://deuswallet.com"
    static let analyticsLink = "https://deuswallet.com/analytics"
    static let evmRpcAvApiLink = "https://api.deuswallet.com/chains/1/rpc"
    static let appGitHubAccount = "DeusWallet"
    static let appGitHubRepository = "deus-wallet-ios"
    static let appTwitterAccount = "DeusWallet"
    static let appTelegramAccount = "DeusWallet"
    static let appRedditAccount = "DeusWallet"
    static let mempoolSpaceUrl = "https://mempool.space"
    static let guidesIndexUrl = URL(string: "https://raw.githubusercontent.com/DeusWallet/blockchain-crypto-guides/main/index.json")!
    static let faqIndexUrl = URL(string: "https://raw.githubusercontent.com/DeusWallet/deus-wallet-faq/master/faq.json")!
    static let donationAddresses: [BlockchainType: String] = [
        .bitcoin: "bc1qaxrlzf6sy9qn8jn0hh089x7s39k8k2v6zjpy39",
        .bitcoinCash: "bitcoincash:qpeqzngzffry6rcljjad3rrgq0rwaskyayszldrd92",
        .ecash: "ecash:qrpt506n98xj7wecwvgrh24he0249ra4fgmn74czxh",
        .litecoin: "ltc1q5rdzr90870tpcnfedapgwa58xtg73hamknuykz",
        .dash: "XmcadAG31i37ptNYYBUcGhmqLxmb524Xwy",
        .zcash: "zs1ar0pk2k83e76zmglr05glyz27lfkc4sd9h8638g5uxl8sxwgkrwspus2jcsxqq00f4qu5ldfxwm",
        .ethereum: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .binanceSmartChain: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .binanceChain: "bnb1gu6ja93dhlfzw2w3ev2vfvmk729yhhyd337xrs",
        .polygon: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .avalanche: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .optimism: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .arbitrumOne: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .gnosis: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .fantom: "0xF273227e5B5ea97C37Ff1515a24b0401D6426d6F",
        .ton: "UQDJJUo6hXP3lwt-mO7AhrIsyKxdHUElbJFu0bJQ4gj3FpOG",
        .tron: "TLN3FbTpqopdbxK2Js3L8vv68jgxC9AMEc",
        .solana: "85tAa61kkn1bAJ4q1oCKrXYLdLQp7ECg6SYgajgUmcQu",
    ]

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    static var appId: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    static var appName: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    }

    static var marketApiUrl: String {
        (Bundle.main.object(forInfoDictionaryKey: "MarketApiUrl") as? String) ?? ""
    }

    static var officeMode: Bool {
        Bundle.main.object(forInfoDictionaryKey: "OfficeMode") as? String == "true"
    }

    static var etherscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "EtherscanApiKey") as? String) ?? ""
    }

    static var arbiscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "ArbiscanApiKey") as? String) ?? ""
    }

    static var gnosisscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "GnosisscanApiKey") as? String) ?? ""
    }

    static var ftmscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "FtmscanApiKey") as? String) ?? ""
    }

    static var optimismEtherscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OptimismEtherscanApiKey") as? String) ?? ""
    }

    static var bscscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "BscscanApiKey") as? String) ?? ""
    }

    static var polygonscanKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "PolygonscanApiKey") as? String) ?? ""
    }

    static var snowtraceKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "SnowtraceApiKey") as? String) ?? ""
    }

    static var twitterBearerToken: String? {
        (Bundle.main.object(forInfoDictionaryKey: "TwitterBearerToken") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var hsProviderApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "HsProviderApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var tronGridApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "TronGridApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var walletConnectV2ProjectKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "WallectConnectV2ProjectKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var unstoppableDomainsApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "UnstoppableDomainsApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var oneInchApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "oneInchApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var defaultWords: String {
        Bundle.main.object(forInfoDictionaryKey: "DefaultWords") as? String ?? ""
    }

    static var defaultPassphrase: String {
        Bundle.main.object(forInfoDictionaryKey: "DefaultPassphrase") as? String ?? ""
    }

    static var sharedCloudContainer: String? {
        Bundle.main.object(forInfoDictionaryKey: "SharedCloudContainerId") as? String
    }

    static var privateCloudContainer: String? {
        Bundle.main.object(forInfoDictionaryKey: "PrivateCloudContainerId") as? String
    }

    static var openSeaApiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OpenSeaApiKey") as? String) ?? ""
    }

    static var swapEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "SwapEnabled") as? String == "true"
    }

    static var donateEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "DonateEnabled") as? String == "true"
    }
}
