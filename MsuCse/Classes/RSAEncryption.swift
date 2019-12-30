//
//  RSAEncryption.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation
import Security

@available(iOS 10.0, *)
internal class RSAEncryption {
    static func encrypt(_ publicKey: String, plain: String) -> EncryptionResult {
        
        guard let d = plain.data(using: .utf8) else {
            return .error(.encryptionFailed("Unable to transform \(plain) to data"))
        }
        
        do {
            guard let encrypted = try RSAUtils.encryptWithRSAPublicKey(data: d, pubkeyBase64: publicKey, tagName: "") else {
                return .error(.encryptionFailed("Encryption failed"))
            }
            let rv = encrypted.base64EncodedString(options: [])
            return .success(rv)
        } catch {
            return .error(.encryptionFailed(error.localizedDescription))
        }
    }
}

internal enum EncryptionResult {
    case success(String)
    case error(EncryptionError)
}

//
//  RsaUtils.swift
//  SwiftUtils
//
//  Created by Thanh Nguyen on 9/16/16.
//  Copyright © 2016 Thanh Nguyen. All rights reserved.
//----------------------------------------------------------------------
//  RSA utilities.
//  Credits:
//  - https://github.com/ideawu/Objective-C-RSA
//  - http://netsplit.com/swift-storing-key-pairs-in-the-keyring
//  - http://netsplit.com/swift-generating-keys-and-encrypting-and-decrypting-text
//  - http://hg.mozilla.org/services/fx-home/file/tip/Sources/NetworkAndStorage/CryptoUtils.m#l1036
//----------------------------------------------------------------------

@available(iOS 10.0, *)
internal class RSAUtils {

    private static let PADDING_FOR_DECRYPT = SecPadding()

    
    public class RSAUtilsError: NSError {
        init(_ message: String) {
            super.init(domain: "com.github.btnguyen2k.SwiftUtils.RSAUtils", code: 500, userInfo: [
                NSLocalizedDescriptionKey: message
            ])
        }

        @available(*, unavailable)
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // Base64 encode a block of data
    
    private static func base64Encode(_ data: Data) -> String {
        return data.base64EncodedString(options: [])
    }

    // Base64 decode a base64-ed string
    
    private static func base64Decode(_ strBase64: String) -> Data {
        let data = Data(base64Encoded: strBase64, options: [])
        return data!
    }

    /**
     * Deletes an existing RSA key specified by a tag from keychain.
     *
     * - Parameter tagName: tag name to query for RSA key from keychain
     */
    
    public static func deleteRSAKeyFromKeychain(_ tagName: String) {
        let queryFilter: [String: AnyObject] = [
            String(kSecClass)             : kSecClassKey,
            String(kSecAttrKeyType)       : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag): tagName as AnyObject
        ]
        SecItemDelete(queryFilter as CFDictionary)
    }

    /**
     * Gets an existing RSA key specified by a tag from keychain.
     *
     * - Parameter tagName: tag name to query for RSA key from keychain
     *
     * - Returns: SecKey reference to the RSA key
     */
    
    public static func getRSAKeyFromKeychain(_ tagName: String) -> SecKey? {
        let queryFilter: [String: AnyObject] = [
            String(kSecClass)             : kSecClassKey,
            String(kSecAttrKeyType)       : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag): tagName as AnyObject,
            //String(kSecAttrAccessible)    : kSecAttrAccessibleWhenUnlocked,
            String(kSecReturnRef)         : true as AnyObject
        ]

        var keyPtr: AnyObject?
        let result = SecItemCopyMatching(queryFilter as CFDictionary, &keyPtr)
        if ( result != noErr || keyPtr == nil ) {
            return nil
        }
        return keyPtr as! SecKey?
    }

    /**
     * Adds a RSA public key to keychain and returns its SecKey reference.
     *
     * - Parameter pubkeyBase64: X509 public key in base64 (data between "-----BEGIN PUBLIC KEY-----" and "-----END PUBLIC KEY-----")
     * - Parameter tagName: tag name to store RSA key to keychain
     *
     * - Throws: `RSAUtilsError` if the input key is indeed not a X509 public key
     *
     * - Returns: SecKey reference to the RSA public key.
     */
    
    public static func addRSAPublicKey(_ pubkeyBase64: String, tagName: String) throws -> SecKey? {
        let fullRange = NSRange(location: 0, length: pubkeyBase64.lengthOfBytes(using: .utf8))
        let regExp = try! NSRegularExpression(pattern: "(-----BEGIN.*?-----)|(-----END.*?-----)|\\s+", options: [])
        let myPubkeyBase64 = regExp.stringByReplacingMatches(in: pubkeyBase64, options: [], range: fullRange, withTemplate: "")
        return try addRSAPublicKey(base64Decode(myPubkeyBase64), tagName: tagName)
    }

    /**
     * Adds a RSA pubic key to keychain and returns its SecKey reference.
     *
     * - Parameter pubkey: X509 public key
     * - Parameter tagName: tag name to store RSA key to keychain
     *
     * - Throws: `RSAUtilsError` if the input key is not a valid X509 public key
     *
     * - Returns: SecKey reference to the RSA public key.
     */
    
    private static func addRSAPublicKey(_ pubkey: Data, tagName: String) throws -> SecKey? {
        // Delete any old lingering key with the same tag
        deleteRSAKeyFromKeychain(tagName)

        let pubkeyData = pubkey

        // Add persistent version of the key to system keychain
        //var prt1: Unmanaged<AnyObject>?
        let queryFilter: [String : Any] = [
            (kSecClass as String)              : kSecClassKey,
            (kSecAttrKeyType as String)        : kSecAttrKeyTypeRSA,
            (kSecAttrApplicationTag as String) : tagName,
            (kSecValueData as String)          : pubkeyData,
            (kSecAttrKeyClass as String)       : kSecAttrKeyClassPublic,
            (kSecReturnPersistentRef as String): true
            ] as [String : Any]
        let result = SecItemAdd(queryFilter as CFDictionary, nil)
        if ((result != noErr) && (result != errSecDuplicateItem)) {
            return nil
        }

        return getRSAKeyFromKeychain(tagName)
    }
    
    

    /**
     * Encrypts data with a RSA key.
     *
     * - Parameter data: the data to be encrypted
     * - Parameter rsaKeyRef: the RSA key
     * - Parameter padding: padding used for encryption
     *
     * - Returns: the data in encrypted form
     */
    public static func encryptWithRSAKey2(_ data: Data, rsaKeyRef: SecKey, padding: SecPadding) -> Data? {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(rsaKeyRef,
                                                         algorithm,
                                                         data as CFData,
                                                         &error) as Data? else {
                                                            return nil
        }
        
        return cipherText
    }

    /*----------------------------------------------------------------------*/

    /**
     * Encrypts data using RSA public key.
     *
     * Note: the public key will be stored in keychain specified by tagName.
     *
     * - Parameter data: data to be encrypted
     * - Parameter pubkeyBase64: X509 public key in base64 (data between "-----BEGIN PUBLIC KEY-----" and "-----END PUBLIC KEY-----")
     * - Parameter tagName: tag name to store RSA key to keychain
     *
     * - Throws: `RSAUtilsError` if the supplied key is not a valid X509 public key
     *
     * - Returns: the data in encrypted form
     */
    
    public static func encryptWithRSAPublicKey(data: Data, pubkeyBase64: String, tagName: String) throws -> Data? {
        let tagName1 = "PUBIC-" + String(pubkeyBase64.hashValue)
        var keyRef = getRSAKeyFromKeychain(tagName1)
        if ( keyRef == nil ) {
            keyRef = try addRSAPublicKey(pubkeyBase64, tagName: tagName1)
        }
        if ( keyRef == nil ) {
            return nil
        }

        return encryptWithRSAKey2(data, rsaKeyRef: keyRef!, padding: SecPadding.OAEP)
    }

}
