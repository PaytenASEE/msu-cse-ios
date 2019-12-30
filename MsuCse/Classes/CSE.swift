//
//  CSE.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation

@available(iOS 10.0, *)
public class CSE {
    var errors: [String] = []
    private let cseApi: CSEApi
    
    var hasErrors: Bool { errors.count > 0 }
    
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

public typealias EncryptCallback = (EncryptResult) -> Void

internal protocol EncryptRequest {
    func validate() -> Bool
    func errors() -> [String]
    func plain() -> String
}

internal class CvvEncryptionRequest: EncryptRequest {
    let cvv: String
    let nonce: String
    
    init(cvv: String, nonce: String) {
        self.cvv = cvv
        self.nonce = nonce
    }
    
    private var _errors: [String] = []
    
    func validate() -> Bool {
        _errors = []
        
        if !CardUtils.isValidCVV(cvv) {
            _errors.append("CVV_INVALID")
        }
        
        if !CardUtils.validateNonce(nonce) {
            _errors.append("NONCE_MISSING_OR_INVALID")
        }
        
        return _errors.isEmpty
    }
    
    func errors() -> [String] {
        return _errors
    }
    
    func plain() -> String {
        return "c=\(cvv)&n=\(nonce)"
    }
}

internal class CardEncryptRequest: EncryptRequest {
    let pan: String
    let cardHolderName: String
    let year: Int
    let month: Int
    let cvv: String
    let nonce: String
    
    private var _errors: [String] = []
    
    init(pan: String, cardHolderName: String, year: Int, month: Int, cvv: String, nonce: String) {
        self.pan = pan.digits
        self.cardHolderName = cardHolderName
        self.year = year
        self.month = month
        self.cvv = cvv.digits
        self.nonce = nonce
    }
    
    func validate() -> Bool {
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
    
    func errors() -> [String] {
        return _errors
    }
    
    func plain() -> String {
        return "p=\(pan)&y=\(year)&m=\(month)&c=\(cvv)&cn=\(cardHolderName)&n=\(nonce)"
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
    
    init(developmentMode: Bool) {
        self.developmentMode = developmentMode
    }
    
    func fetchPublicKey(_ callback: @escaping (PublicKeyFetchResult) -> Void) {
        
callback(.result("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhGNpIhKTlCi1iwKEbFD2CTL0AYbMV+QCaP/5bl2hkBjgkQdG931Vep7Z4gVCSYCmmE4T8d1TIdkNoTPwOltzoX9Z1pI/EoqktNLlS3re+dApPU36FHGaGaPCfNR+/zJ1Pd1qazaZ5SJhFyf17KU9HLi7w9WYRJVGDWj6CJKeefWYLclLThD+SBCmpJTqhDdFRt9bW1LwSqfshmSzxI7jHTqnj+o4Ikv2xC4V7bIwjzmUk7t4IzT+rJcin+oB+Xgq+stxvZodZrpSZbXnPNObSIsVCxXqdDz1lXjkwMc9aV0X5KqOjEK87QjguPAGsba3AfbWIWjzuR3xoAVzQRo+tQIDAQAB"))
        
        return
        
//        let url = URL(string: endpoint)!
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                callback(PublicKeyFetchResult.error(error))
//            } else {
//                if let data = data {
//                    do {
//                        let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
//                        
//                        guard let jsonObject = result else {
//                            callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed, result nil")))
//                            return
//                        }
//                        
//                        guard let publicKey = jsonObject["publicKey"] else {
//                            callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed, missing public key")))
//                            return
//                        }
//                        
//                        callback(.result(publicKey))
//                        
//                    } catch {
//                            callback(.error(EncryptionError.publicKeyEncodingFailed(error.localizedDescription)))
//                    }
//                } else {
//                    callback(.error(EncryptionError.publicKeyEncodingFailed("Decoding failed")))
//                }
//            }
//        }
//        task.resume()
    }
}

enum PublicKeyFetchResult {
    case result(String)
    case error(Error)
}
