//
//  CSEEncryptValiditySpec.swift
//  MsuCse_Tests
//
//  Created by Jasmin Suljic on 11/02/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

// https://github.com/Quick/Quick

import Quick
import Nimble
import MsuCse

internal protocol InvalidPayload {
    associatedtype Element: Comparable
    var error: String {get}
    var payload: Element {get}
}

struct InvalidStringValue: InvalidPayload {
    let payload: String
    typealias Element = String
    let error: String
}

struct InvalidIntValue: InvalidPayload {
    let payload: Int
    typealias Element = Int
    let error: String
}

class CSEEncryptValiditySpec: QuickSpec {
    override func spec() {
        
        func errorValidator(cse: CSE,
                            validationMessages: Set<String>,
                            error: EncryptionError,
                            expectedError: EncryptionError,
                            done: @escaping () -> Void) {
            
            if expectedError == error {
                expect(cse.hasErrors) == true
                
                expect(cse.errors.count) == validationMessages.count
                
                validationMessages.forEach {
                    m in
                    expect(cse.errors.contains(m)) == true
                }
            } else {
               fail("Received error \(error), expected \(expectedError)")
                
            }
            done()
        }
        
        var cse: CSE!
        
        beforeEach {
            cse = CSE(developmentMode: true)
        }
        
        describe("CSE.encryptCardDetails") {
            
            it("should return .error(e) when card payload is incorrect") {
                
                waitUntil(timeout: 20) {
                    done in
                    
                    let pan = InvalidStringValue(payload: "", error: "PAN_INVALID")
                    let cvv = InvalidStringValue(payload: "", error: "CVV_INVALID")
                    let cardHolderName = InvalidStringValue(payload: "", error: "CARD_HOLDER_NAME_INVALID")
                    let expiryYear = InvalidIntValue(payload: 2000, error: "EXPIRY_INVALID")
                    let expiryMonth = InvalidIntValue(payload: 12, error: "EXPIRY_INVALID")
                    let nonce = InvalidStringValue(payload: "", error: "NONCE_MISSING_OR_INVALID")
                    var validationMessages: Set = [pan.error]
                    
                    [cvv, cardHolderName, nonce].forEach {
                        v in
                        validationMessages.insert(v.error)
                    }
                    
                    [expiryYear, expiryMonth].forEach {
                        v in
                        validationMessages.insert(v.error)
                    }
                    
                    cse.encrypt(pan: pan.payload,
                                cardHolderName:cardHolderName.payload,
                                expiryYear: expiryYear.payload,
                                expiryMonth: expiryMonth.payload,
                                cvv: cvv.payload,
                                nonce: nonce.payload) {result in
                        switch result {
                        case .error(let e):
                            errorValidator(cse: cse, validationMessages: validationMessages, error: e, expectedError: .validationFailed, done: done)
                        case .success(let s):
                            fail("Received success \(s), expected error")
                            done()
                        }
                    }
                }
            }
        
            it("should return .success(token) when card payload is correct") {
                waitUntil(timeout: 20) {
                    done in
                    let year = Calendar.current.component(.year, from:Date()) + 1
                    cse.encrypt(pan: VISA_TEST_CARD, cardHolderName: "John Doe", expiryYear: year, expiryMonth: 12, cvv: "123", nonce: "nonce") {
                        result in
                        switch result {
                        case .error(let e):
                            fail("Received error \(e), expected success")
                            done()
                        case .success(_):
                            expect(cse.hasErrors) == false
                            expect(cse.errors.count) == 0
                            done()
                        }
                    }
                }
            }
            
        }
        
        describe("CSE.encryptCvv") {
            it("should return .error(e) when card payload is incorrect") {
                waitUntil(timeout: 20) {
                    done in
                    let cvv = InvalidStringValue(payload: "", error: "CVV_INVALID")
                    let nonce = InvalidStringValue(payload: "", error: "NONCE_MISSING_OR_INVALID")
                    let validationMessages: Set = [cvv.error, nonce.error]
                    
                    cse.encrypt(cvv: cvv.payload, nonce: nonce.payload) {
                        result in
                        switch result {
                        case .error(let e):
                            errorValidator(cse: cse, validationMessages: validationMessages, error: e, expectedError: .validationFailed, done: done)
                        case .success(let s):
                            fail("Received success \(s), expected error")
                            done()
                        }
                    }
                }
            }
            
            it("should return .success(e) when card payload is correct") {
                waitUntil(timeout: 20) {
                    done in
                    cse.encrypt(cvv: "123", nonce: String(repeating: "A", count: 16)) {
                        result in
                        switch result {
                        case .error(let e):
                            fail("Received error \(e), expected success")
                            done()
                        case .success(_):
                            expect(cse.hasErrors) == false
                            expect(cse.errors.count) == 0
                            done()
                        }
                    }
                }
            }
        }
    }
}
