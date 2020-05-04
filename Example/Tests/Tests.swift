// https://github.com/Quick/Quick

import Quick
import Nimble
import MsuCse

let AMEX_TEST_NUMBER = "349482295541627"
let VISA_TEST_CARD = "4341 7920 0000 0044"
let VISA_TEST_CARD_1 = "4111 1111 1111 1111 003"
let DINA_CARD_TEST_NUMBER_1 = "9891 3759 1834 2675"
let DINA_CARD_TEST_NUMBER_2 = "6556 7232 7591 8342"
let MAESTRO_TEST_NUMBER_1 = "6759 6498 2643 8453"
let MAESTRO_TEST_NUMBER_2 = "6772 5565 4321 31279"
let MASTER_CARD_TEST_NUMBER = "5555 5555 5555 4444"
let DISCOVER_TEST_CARD = "6011 0000 0000 0004"

protocol CseTestable {
    func test(_ cse: CSE) throws
}

struct TestDataExpiry {
    let month: Int
    let year: Int
    let testResult: Bool
}

struct TestDataCardNumber {
    let cardNumber: String
    let testResult: Bool
}

struct TestDataCardHolderName {
    let cardHolderName: String
    let testResult: Bool
}

struct TestDataDetectBrand {
    let cardNumber: String
    let cardBrand: CardBrand
}

struct TestDataCvv {
    let cvv: String
    let cardNumber: String?
    let testResult: Bool
}

struct TestDataCardToken {
    let cardToken: String
    let testResult: Bool
}

enum TestData {
    case isValidExpiry(TestDataExpiry)
    case isValidCardHolderName(TestDataCardHolderName)
    case detectBrand(TestDataDetectBrand)
    case isValidCVV(TestDataCvv)
    case isValidCardToken(TestDataCardToken)
    case isValidPan(TestDataCardNumber)
}

extension TestData: CseTestable {
    func test(_ cse: CSE) throws {
        switch self {
        case .isValidExpiry(let t):
            try t.test(cse)
        case .isValidCardHolderName(let t):
            try t.test(cse)
        case .detectBrand(let t):
            try t.test(cse)
        case .isValidCVV(let t):
            try t.test(cse)
        case .isValidCardToken(let t):
            try t.test(cse)
        case .isValidPan(let t):
            try t.test(cse)
        }
    }
}

extension TestDataExpiry: CseTestable {
    func test(_ cse: CSE) throws{
        expect(cse.isValidExpiry(month: self.month, year: self.year)) == self.testResult
    }
}

extension TestDataCardHolderName: CseTestable {
    func test(_ cse: CSE) throws{
        expect(cse.isValidCardHolderName(self.cardHolderName)) == self.testResult
    }
}

extension TestDataDetectBrand: CseTestable {
    func test(_ cse: CSE) throws {
        expect(cse.detectBrand(self.cardNumber)) == self.cardBrand
    }
}

extension TestDataCvv: CseTestable {
    func test(_ cse: CSE) throws {
        if let cardNumber = self.cardNumber {
            expect(cse.isValidCVV(cvv: self.cvv, pan: cardNumber)) == self.testResult
        } else {
            expect(cse.isValidCVV(self.cvv)) == self.testResult
        }
    }
}

extension TestDataCardToken: CseTestable {
    func test(_ cse: CSE) throws {
        expect(cse.isValidCardToken(self.cardToken)) == self.testResult
    }
}

extension TestDataCardNumber: CseTestable {
    func test(_ cse: CSE) throws {
        expect(cse.isValidPan(self.cardNumber)).to(be(self.testResult), description: "Expected \(self.testResult) for \(self.cardNumber)")
    }
}

class CSEExpirationDateValiditySpec: QuickSpec {
    override func spec() {
        describe("CSE.isValidExpiry") {
            it("should validate expiry date") {
                let cse = CSE(developmentMode: true)
                let now = Date()
                let currentYear = Calendar.current.component(.year, from: now)
                let currentMonth = Calendar.current.component(.month, from: now)
                
                let testValues: [TestData] = [
                    .isValidExpiry(TestDataExpiry(month: 10, year: 2018, testResult: false)),
                    // Test year normalization for passed year & month
                    .isValidExpiry(TestDataExpiry(month: 10, year: 18, testResult: false)),
                    .isValidExpiry(TestDataExpiry(month: 12, year: currentYear - 5, testResult: false)),
                    .isValidExpiry(TestDataExpiry(month: 12, year: currentYear, testResult: true)),
                    .isValidExpiry(TestDataExpiry(month: currentMonth, year: currentYear, testResult: true)),
                    .isValidExpiry(TestDataExpiry(month: currentMonth, year: currentYear + 20, testResult: true)),
                    .isValidExpiry(TestDataExpiry(month: currentMonth, year: currentYear - (currentYear / 100) * 100, testResult: true))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

class CSECardHolderNameValiditySpec: QuickSpec {
    override func spec() {
        describe("CSE.isValidCardHolderName") {
            
            it("should validate card holder name") {
                let cse = CSE(developmentMode: true)
                
                let testValues: [TestData] = [
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: "", testResult: false)),
                    // This is invalid as well, because we're trimming whitespace and newlines
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: "   ", testResult: false)),
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: "  A ", testResult: true)),
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: "John", testResult: true)),
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: String(repeating: "A", count: 128), testResult: true)),
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: "  \(String(repeating: "A", count: 128))   ", testResult: true)),
                    // 128 is max length for card holder name, thus 129 characters long name is invalid
                    .isValidCardHolderName(TestDataCardHolderName(cardHolderName: String(repeating: "A", count: 129), testResult: false))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

class CSEDetectBrandSpec: QuickSpec {
    override func spec() {
        
        describe("CSE.detectBrand") {
            it("should detect brand correctly") {
                let cse = CSE(developmentMode: true)
                
                let testValues: [TestData] = [
                    .detectBrand(TestDataDetectBrand(cardNumber: "", cardBrand: .Unknown)),
                    .detectBrand(TestDataDetectBrand(cardNumber: "4111 11", cardBrand: .Visa)),
                    // Test whitespace trimmable input
                    .detectBrand(TestDataDetectBrand(cardNumber: "  411111   ", cardBrand: .Visa)),
                    .detectBrand(TestDataDetectBrand(cardNumber: "4111 1111 1111 1111", cardBrand: .Visa)),
                    .detectBrand(TestDataDetectBrand(cardNumber: VISA_TEST_CARD_1, cardBrand: .Visa)),
                    .detectBrand(TestDataDetectBrand(cardNumber: MASTER_CARD_TEST_NUMBER, cardBrand: .Mastercard)),
                    .detectBrand(TestDataDetectBrand(cardNumber: AMEX_TEST_NUMBER, cardBrand: .AmericanExpress)),
                    .detectBrand(TestDataDetectBrand(cardNumber: DINA_CARD_TEST_NUMBER_1, cardBrand: .Dinacard)),
                    .detectBrand(TestDataDetectBrand(cardNumber: DINA_CARD_TEST_NUMBER_2, cardBrand: .Dinacard)),
                    .detectBrand(TestDataDetectBrand(cardNumber: DISCOVER_TEST_CARD, cardBrand: .Discover)),
                    .detectBrand(TestDataDetectBrand(cardNumber: MAESTRO_TEST_NUMBER_1, cardBrand: .Maestro)),
                    .detectBrand(TestDataDetectBrand(cardNumber: MAESTRO_TEST_NUMBER_2, cardBrand: .Maestro)),
                    .detectBrand(TestDataDetectBrand(cardNumber: "6759649826438453", cardBrand: .Maestro)),
                    .detectBrand(TestDataDetectBrand(cardNumber: "5890040000000016", cardBrand: .Maestro)),
                    .detectBrand(TestDataDetectBrand(cardNumber: "5892830000000000", cardBrand: .Maestro))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

class CSEPanValiditySpec: QuickSpec {
    override func spec() {
        var cse: CSE!
        
        beforeEach {
            cse = CSE(developmentMode: true)
        }
        
        describe("CSE.isValidPan") {
            it("should return false for invalid card number") {
                let testValues: [TestData] = [
                    .isValidPan(TestDataCardNumber(cardNumber: "4111 1111 1111 111", testResult: false)),
                    .isValidPan(TestDataCardNumber(cardNumber: "5555 5555 5555 4443", testResult: false)),
                    .isValidPan(TestDataCardNumber(cardNumber: MASTER_CARD_TEST_NUMBER + "bla 1", testResult: false)),
                    .isValidPan(TestDataCardNumber(cardNumber: AMEX_TEST_NUMBER + " 321", testResult: false))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
            
            it("should return true for valid card number") {
                let testValues: [TestData] = [
                    .isValidPan(TestDataCardNumber(cardNumber: VISA_TEST_CARD, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: VISA_TEST_CARD_1, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: AMEX_TEST_NUMBER, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: DINA_CARD_TEST_NUMBER_1, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: DINA_CARD_TEST_NUMBER_2, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: MASTER_CARD_TEST_NUMBER, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: DISCOVER_TEST_CARD, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: MAESTRO_TEST_NUMBER_1, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: MAESTRO_TEST_NUMBER_2, testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: "6759649826438453", testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: "5890040000000016", testResult: true)),
                    .isValidPan(TestDataCardNumber(cardNumber: "5892830000000000", testResult: true))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

class CSECvvValiditySpec: QuickSpec {
    override func spec() {
        
        var cse: CSE!
        
        beforeEach {
            cse = CSE(developmentMode: true)
        }
        
        describe("CSE.isValidCvv") {
            
            it("should validate CVV correctly only based on CVV") {
                let testValues: [TestData] = [
                    .isValidCVV(TestDataCvv(cvv: "", cardNumber: nil, testResult: false)),
                    .isValidCVV(TestDataCvv(cvv: "12", cardNumber: nil, testResult: false)),
                    .isValidCVV(TestDataCvv(cvv: " 12", cardNumber: nil, testResult: false)),
                    .isValidCVV(TestDataCvv(cvv: "abc", cardNumber: nil, testResult: false)),
                    .isValidCVV(TestDataCvv(cvv: "abc123", cardNumber: nil, testResult: true)),
                    .isValidCVV(TestDataCvv(cvv: "123", cardNumber: nil, testResult: true)),
                    .isValidCVV(TestDataCvv(cvv: "1234", cardNumber: nil, testResult: true))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
            
            it("should validate CVV correctly with cardNumber present for non amex cards") {
                let threeDigitsCvvValidCardNumbers = [
                    MASTER_CARD_TEST_NUMBER,
                    DINA_CARD_TEST_NUMBER_1,
                    DINA_CARD_TEST_NUMBER_2,
                    DISCOVER_TEST_CARD,
                    VISA_TEST_CARD
                ]
                
                let testData1: [TestData] = threeDigitsCvvValidCardNumbers.map({
                        cardNumber in
                        TestData.isValidCVV(TestDataCvv(cvv: "123", cardNumber: cardNumber, testResult: true))
                    })
                
                let testData2: [TestData] = threeDigitsCvvValidCardNumbers.map({
                        cardNumber in
                        TestData.isValidCVV(TestDataCvv(cvv: "1234", cardNumber: cardNumber, testResult: false))
                    })
                
                let testValues: [TestData] = testData1 + testData2
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
            
            it("should validate CVV correctly with cardNumber present for AMEX cards") {
                let testValues: [TestData] = [
                    .isValidCVV(TestDataCvv(cvv: "123", cardNumber: AMEX_TEST_NUMBER, testResult: true)),
                    .isValidCVV(TestDataCvv(cvv: "1234", cardNumber: AMEX_TEST_NUMBER, testResult: true))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

class CSECardTokenValiditySpec: QuickSpec {
    override func spec() {
        describe("CSE.isValidCardToken") {
            
            let cse = CSE(developmentMode: true)
            
            it("should return false for invalid card tokens") {
                let testValues: [TestData] = [
                    .isValidCardToken(TestDataCardToken(cardToken: "", testResult: false)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: 31), testResult: false)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: Int.random(in: 0..<32)), testResult: false)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: 65), testResult: false))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
            
            it("should return true for valid card tokens") {
                
                let testValues: [TestData] = [
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: 32), testResult: true)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: 64), testResult: true)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: 48), testResult: true)),
                    .isValidCardToken(TestDataCardToken(cardToken: String(repeating: "A", count: Int.random(in: 32...48)), testResult: true))
                ]
                
                testValues.forEach {
                    data in
                    try? data.test(cse)
                }
            }
        }
    }
}

