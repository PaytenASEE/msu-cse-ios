// https://github.com/Quick/Quick

import Quick
import Nimble
import MsuCse

protocol CseTestable {
    func test(_ cse: CSE) throws
}

struct TestDataExpiry {
    let month: Int
    let year: Int
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

enum TestData {
    case isValidExpiry(TestDataExpiry)
    case isValidCardHolderName(TestDataCardHolderName)
    case detectBrand(TestDataDetectBrand)
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

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        
        describe("Msu.isValidExpiry") {
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
                // Test normalized years, this test is good for next 80 years :) @2020
                .isValidExpiry(TestDataExpiry(month: currentMonth, year: currentYear - 2000, testResult: true))
            ]
            
            testValues.forEach {
                data in
                try? data.test(cse)
            }
        }
        
        describe("Msu.isValidCardHolderName") {
            
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
        
        describe("Msu.isValidCardHolderName") {
            let cse = CSE(developmentMode: true)
            
            let testValues: [TestData] = [
                .detectBrand(TestDataDetectBrand(cardNumber: "", cardBrand: .Unknown)),
                .detectBrand(TestDataDetectBrand(cardNumber: "4111 11", cardBrand: .Visa)),
                // Test whitespace trimmable input
                .detectBrand(TestDataDetectBrand(cardNumber: "  411111   ", cardBrand: .Visa)),
                .detectBrand(TestDataDetectBrand(cardNumber: "5555 5555 5555 4444", cardBrand: .Mastercard)),
                .detectBrand(TestDataDetectBrand(cardNumber: "349482295541627", cardBrand: .AmericanExpress)),
                .detectBrand(TestDataDetectBrand(cardNumber: "9891 3759 1834 2675", cardBrand: .Dinacard)),
                .detectBrand(TestDataDetectBrand(cardNumber: "6556 7232 7591 8342", cardBrand: .Dinacard)),
                .detectBrand(TestDataDetectBrand(cardNumber: "6011 0000 0000 0004", cardBrand: .Discover))
            ]
            
            testValues.forEach {
                data in
                try? data.test(cse)
            }
        }
        
//        describe("these will fail") {
//            
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    DispatchQueue.main.async {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        Thread.sleep(forTimeInterval: 0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
    }
}
