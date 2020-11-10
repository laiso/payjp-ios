//
//  PAY.JP APIClient.swift
//  https://pay.jp/docs/api/
//

import Foundation
#if canImport(PassKit)
import PassKit

// swiftlint:disable function_parameter_count

/// PAY.JP API client.
/// cf. https://pay.jp/docs/api/#introduction
@objc(PAYAPIClient) public class APIClient: NSObject {

    let accountsService: AccountsServiceType
    let tokensService: TokenServiceType
    let nsErrorConverter: NSErrorConverterType

    /// Shared instance.
    @objc(sharedClient) public static let shared = APIClient()

    public var tokenOperationObserver: TokenOperationObserverType {
        return self.tokensService.tokenOperationObserver
    }

    private init(
        accountsService: AccountsServiceType = AccountsService.shared,
        tokensService: TokenServiceType = TokenService.shared,
        nsErrorConverter: NSErrorConverterType = NSErrorConverter.shared
    ) {
        self.accountsService = accountsService
        self.tokensService = tokensService
        self.nsErrorConverter = nsErrorConverter
    }

    /// Create PAY.JP Token
    /// - parameter token:         ApplePay Token
    /// - parameter completion:    completion action
    @nonobjc
    public func createToken(
        with token: PKPaymentToken,
        completion: @escaping (Result<Token, APIError>) -> Void
    ) {
        tokensService.createTokenForApplePay(paymentToken: token, completion: completion)
    }

    /// Create PAY.JP Token
    /// - parameter cardNumber:         Credit card number `1234123412341234`
    /// - parameter cvc:                Credit card cvc e.g. `123`
    /// - parameter expirationMonth:    Credit card expiration month `01`
    /// - parameter expirationYear:     Credit card expiration year `2020`
    /// - parameter name:               Credit card holder name `TARO YAMADA`
    /// - parameter completion:         completion action
    @nonobjc
    public func createToken(
        with cardNumber: String,
        cvc: String,
        expirationMonth: String,
        expirationYear: String,
        name: String? = nil,
        tenantId: String? = nil,
        completion: @escaping (Result<Token, APIError>) -> Void
    ) {
        tokensService.createToken(cardNumber: cardNumber,
                                  cvc: cvc,
                                  expirationMonth: expirationMonth,
                                  expirationYear: expirationYear,
                                  name: name,
                                  tenantId: tenantId,
                                  completion: completion)
    }

    /// Create PAY.JP Token
    /// - parameter token:         3DSecure Token
    /// - parameter completion:    completion action
    @nonobjc
    public func createToken(
        with token: ThreeDSecureToken,
        completion: @escaping (Result<Token, APIError>) -> Void
    ) {
        tokensService.createTokenForThreeDSecure(tdsId: token.identifier, completion: completion)
    }

    /// GET PAY.JP Token
    /// - parameter tokenId:       identifier of the Token
    /// - parameter completion:    completion action
    @nonobjc
    public func getToken(
        with tokenId: String,
        completion: @escaping (Result<Token, APIError>) -> Void
    ) {
        tokensService.getToken(with: tokenId, completion: completion)
    }

    /// GET PAY.JP CardBrands
    /// - parameter tenantId:      identifier of the Tenant
    /// - parameter completion:    completion action
    @nonobjc
    public func getAcceptedBrands(
        with tenantId: String?,
        completion: CardBrandsResult?
    ) {
        accountsService.getAcceptedBrands(tenantId: tenantId, completion: completion)
    }
}

/// Objective-C API
extension APIClient {
    @objc public func createTokenWith(
        _ token: PKPaymentToken,
        completionHandler: @escaping (Token?, NSError?) -> Void
    ) {
        createToken(with: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                completionHandler(result, nil)
            case .failure(let error):
                completionHandler(nil, self.nsErrorConverter.convert(from: error))
            }
        }
    }

    @objc public func createTokenWith(
        _ cardNumber: String,
        cvc: String,
        expirationMonth: String,
        expirationYear: String,
        name: String?,
        tenantId: String?,
        completionHandler: @escaping (Token?, NSError?) -> Void
    ) {
        createToken(with: cardNumber,
                    cvc: cvc,
                    expirationMonth: expirationMonth,
                    expirationYear: expirationYear,
                    name: name,
                    tenantId: tenantId
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                completionHandler(result, nil)
            case .failure(let error):
                completionHandler(nil, self.nsErrorConverter.convert(from: error))
            }
        }
    }

    @objc public func createTokenWithTds(
        _ token: ThreeDSecureToken,
        completionHandler: @escaping (Token?, NSError?) -> Void
    ) {
        createToken(with: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                completionHandler(result, nil)
            case .failure(let error):
                completionHandler(nil, self.nsErrorConverter.convert(from: error))
            }
        }
    }

    @objc public func getTokenWith(_ tokenId: String,
                                   completionHandler: @escaping (Token?, NSError?) -> Void) {
        getToken(with: tokenId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                completionHandler(result, nil)
            case .failure(let error):
                completionHandler(nil, self.nsErrorConverter.convert(from: error))
            }
        }
    }

    @objc public func getAcceptedBrandsWith(
        _ tenantId: String?,
        completionHandler: @escaping ([NSString]?, NSError?) -> Void
    ) {
        getAcceptedBrands(with: tenantId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                let converted = result.map { (brand: CardBrand) -> NSString in return brand.rawValue as NSString }
                completionHandler(converted, nil)
            case .failure(let error):
                completionHandler(nil, self.nsErrorConverter.convert(from: error))
            }
        }
    }
}
// swiftlint:enable function_parameter_count
#endif
