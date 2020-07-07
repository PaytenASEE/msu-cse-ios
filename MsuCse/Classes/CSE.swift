//
//  CSE.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation

@available(iOS 10.0, *)
public class CSE {
    
    private var _errors: [String] = []
    
    public  var errors: [String] {
        get {
            return _errors
        }
    }
    private let cseApi: CSEApi
    
    public var hasErrors: Bool { errors.count > 0 }
    
    public init(developmentMode: Bool) {
        cseApi = CSEApiImpl(developmentMode: developmentMode)
    }
    
    public func isValidCVV(_ cvv: String) -> Bool {
        return CardUtils.isValidCVV(cvv)
    }
    
    public func isValidCVV(cvv: String, pan: String) -> Bool {
        return CardUtils.isValidCVV(cvv, pan: pan)
    }
    
    public func isValidCardHolderName(_ name: String) -> Bool {
        return CardUtils.isValidCardHolderName(name)
    }
    
    public func isValidPan(_ pan: String) -> Bool {
        return CardUtils.isValidPan(pan)
    }
    
    public func isValidCardToken(_ token: String) -> Bool {
        return CardUtils.isValidCardToken(token)
    }
    
    public func detectBrand(_ pan: String) -> CardBrand {
        return CardUtils.cardBrand(pan)
    }
    
    public func isValidExpiry(month: Int, year: Int) -> Bool {
        return CardUtils.isValidExpiry(month: month, year: year)
    }
    
    public func encrypt(cvv: String, nonce: String, _ callback: @escaping EncryptCallback) {
        encrypt(CvvEncryptionRequest(cvv: cvv, nonce: nonce), callback)
    }
    
    public func encrypt(pan: String,
                        cardHolderName: String,
                        expiryYear: Int,
                        expiryMonth: Int,
                        cvv: String,
                        nonce: String,_
        callback: @escaping EncryptCallback) {
        encrypt(CardEncryptRequest(pan: pan, cardHolderName: cardHolderName, year: expiryYear, month: expiryMonth, cvv: cvv, nonce: nonce), callback)
    }
    
    private func encrypt(_ request: EncryptRequest, _ callback: @escaping EncryptCallback) {
        _errors = []
        if !request.validate() {
            _errors = request.errors()
            DispatchQueue.main.async {callback(.error(EncryptionError.validationFailed))}
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                
                guard let cseApi = self?.cseApi else {
                    return
                }
                
                cseApi.fetchPublicKey {
                    r in
                    switch r {
                    case .error(let e):
                        DispatchQueue.main.async { callback(.error(.unknownException(e))) }
                    case .result(let publicKey):
                        let encrypted = RSAEncryption.encrypt(publicKey, plain: request.plain())
                        switch encrypted {
                        case .error(let e):
                            DispatchQueue.main.async { callback(.error(e)) }
                        case .success(let encrypted):
                            DispatchQueue.main.async { callback(.success(encrypted)) }
                        }
                    }
                }
            }
        }
    }
}

public typealias EncryptCallback = (EncryptResult) -> Void

public protocol EncryptRequest {
    func validate() -> Bool
    func errors() -> [String]
    func plain() -> String
}

public class CvvEncryptionRequest: EncryptRequest {
    let cvv: String
    let nonce: String
    
    init(cvv: String, nonce: String) {
        self.cvv = cvv
        self.nonce = nonce
    }
    
    private var _errors: [String] = []
    
    public func validate() -> Bool {
        _errors = []
        
        if !CardUtils.isValidCVV(cvv) {
            _errors.append("CVV_INVALID")
        }
        
        if !CardUtils.validateNonce(nonce) {
            _errors.append("NONCE_MISSING_OR_INVALID")
        }
        
        return _errors.isEmpty
    }
    
    public func errors() -> [String] {
        return _errors
    }
    
    public func plain() -> String {
        return "c=\(cvv)&n=\(nonce)"
    }
}

public class CardEncryptRequest: EncryptRequest {
    let pan: String
    let cardHolderName: String
    let year: Int
    let month: Int
    let cvv: String
    let nonce: String
    
    private var _errors: [String] = []
    
    public init(pan: String, cardHolderName: String, year: Int, month: Int, cvv: String, nonce: String) {
        self.pan = pan.digits
        self.cardHolderName = cardHolderName
        self.year = year
        self.month = month
        self.cvv = cvv.digits
        self.nonce = nonce
    }
    
    public func validate() -> Bool {
        _errors = []
        
        if !CardUtils.isValidPan(pan) {
            _errors.append("PAN_INVALID")
        }
        
        if !CardUtils.isValidExpiry(month: month, year: year) {
            _errors.append("EXPIRY_INVALID")
        }
        
        if !CardUtils.isValidCardHolderName(cardHolderName) {
            _errors.append("CARD_HOLDER_NAME_INVALID")
        }
        
        if !CardUtils.isValidCVV(cvv, pan: pan) {
            _errors.append("CVV_INVALID")
        }
        
        if !CardUtils.validateNonce(nonce) {
            _errors.append("NONCE_MISSING_OR_INVALID")
        }
        
        return _errors.isEmpty
    }
    
    public func errors() -> [String] {
        return _errors
    }
    
    private static func paddedMonth(_ month: Int) -> String {
        if (month < 10) {
            return "0\(month)"
        } else {
            return "\(month)"
        }
    }
    
    public func plain() -> String {
        return "p=\(pan)&y=\(year)&m=\(CardEncryptRequest.paddedMonth(month))&c=\(cvv)&cn=\(cardHolderName)&n=\(nonce)"
    }
}

public enum EncryptResult {
    case success(String)
    case error(EncryptionError)
}

public enum EncryptionError: Error {
    case requestFailed
    case unknownException(Error)
    case validationFailed
    case publicKeyEncodingFailed(String)
    case encryptionFailed(String)
}

extension EncryptionError {
public static func ==(lhs: EncryptionError, rhs:EncryptionError) -> Bool {
    switch lhs {
    case .requestFailed:
        switch rhs {
        case .requestFailed:
            return true
        default:
            return false
        }
    case .validationFailed:
        switch rhs {
        case .validationFailed:
            return true
        default:
            return false
        }
    case .encryptionFailed(let a):
        switch rhs {
        case .encryptionFailed(let b):
            return a == b
        default:
            return false
        }
        
    case .publicKeyEncodingFailed(let a):
        switch rhs {
        case .publicKeyEncodingFailed(let b):
            return a == b
        default:
            return false
        }
        
    case .unknownException:
        switch rhs {
        case .unknownException:
            return true
        default:
            return false
        }
    }
    
    }
}

internal protocol CSEApi {
    func fetchPublicKey(_ callback: @escaping (PublicKeyFetchResult) -> Void)
}

internal class CSEApiImpl: CSEApi {
    
    let developmentMode: Bool
    var endpoint: String {
        if developmentMode {
           return  "https://test.merchantsafeunipay.com/msu/cse/publickey"
        } else {
            return "https://merchantsafeunipay.com/msu/cse/publickey"
        }
    }
    
    var publicKey: String?
    
    init(developmentMode: Bool) {
        self.developmentMode = developmentMode
    }
    
    func fetchPublicKey(_ callback: @escaping (PublicKeyFetchResult) -> Void) {
        
        if let publicKey = self.publicKey {
            callback(.result(publicKey))
            return
        }
        
        let url = URL(string: endpoint)!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error)  in
            if let error = error {
                callback(PublicKeyFetchResult.error(error))
            } else {
                if let data = data {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                        
                        guard let jsonObject = result else {
                            callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed, result nil")))
                            return
                        }
                        
                        guard let publicKey = jsonObject["publicKey"] else {
                            callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed, missing public key")))
                            return
                        }
                        
                        self?.publicKey = publicKey
                        
                        callback(.result(publicKey))
                        
                    } catch {
                            callback(.error(EncryptionError.publicKeyEncodingFailed(error.localizedDescription)))
                    }
                } else {
                    callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed")))
                }
            }
        }
        task.resume()
    }
}

enum PublicKeyFetchResult {
    case result(String)
    case error(Error)
}
