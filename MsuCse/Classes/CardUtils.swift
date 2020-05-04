//
//  CardUtils.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation

internal class CardUtils {
    
    static let  LENGTH_COMMON_CARD = 16;
    static let  LENGTH_AMERICAN_EXPRESS = 15;
    static let  LENGTH_DINERS_CLUB = 14;
    static let MAESTRO_CARD_LENGTH = [12, 13, 14, 15, 16, 17, 18, 19]
    static let VISA_CARD_LENGTH = [16, 19]
    
    static let  PREFIXES_AMERICAN_EXPRESS = ["34", "37"]
    static let  PREFIXES_DISCOVER = ["60", "64", "65"]
    static let  PREFIXES_JCB = ["35"];
    static let  PREFIXES_DINERS_CLUB = ["300", "301", "302", "303", "304",
            "305", "309", "36", "38", "39"]
    static let  PREFIXES_VISA = ["4"];
    static let  PREFIXES_MASTERCARD = [
            "2221", "2222", "2223", "2224", "2225", "2226", "2227", "2228", "2229",
            "223", "224", "225", "226", "227", "228", "229",
            "23", "24", "25", "26",
            "270", "271", "2720",
            "50", "51", "52", "53", "54", "55", "67"
    ]
    
    static let  PREFIXES_UNIONPAY = ["62"]
    
    static let PREFIXES_MAESTRO = ["56", "58", "67", "502", "503", "506", "639", "5018", "6020"]
    
    static let PREFIXES_TROY = [
            "979200",
            "979201",
            "979202",
            "979203",
            "979204",
            "979205",
            "979206",
            "979207",
            "979208",
            "979209",
            "979210",
            "979211",
            "979212",
            "979213",
            "979214",
            "979215",
            "979216",
            "979217",
            "979218",
            "979219",
            "979220",
            "979221",
            "979222",
            "979223",
            "979224",
            "979225",
            "979226",
            "979227",
            "979228",
            "979229",
            "979230",
            "979231",
            "979232",
            "979233",
            "979234",
            "979235",
            "979236",
            "979237",
            "979238",
            "979239",
            "979240",
            "979241",
            "979242",
            "979243",
            "979244",
            "979245",
            "979246",
            "979247",
            "979248",
            "979249",
            "979250",
            "979251",
            "979252",
            "979253",
            "979254",
            "979255",
            "979256",
            "979257",
            "979258",
            "979259",
            "979260",
            "979261",
            "979262",
            "979263",
            "979264",
            "979265",
            "979266",
            "979267",
            "979268",
            "979269",
            "979270",
            "979271",
            "979272",
            "979273",
            "979274",
            "979275",
            "979276",
            "979277",
            "979278",
            "979279",
            "979280",
            "979281",
            "979282",
            "979283",
            "979284",
            "979285",
            "979286",
            "979287",
            "979288",
            "979289",
            "979290",
            "979291",
            "979292",
            "979293",
            "979294",
            "979295",
            "979296",
            "979297",
            "979298",
            "979299"
    ]
    
    static let PREFIX_DINACARD = "9891";
    static let PREFIXES_DINACARD: [String] = [
                PREFIX_DINACARD,
                "655670",
                "655671",
                "655672",
                "655673",
                "655674",
                "655675",
                "655676",
                "655677",
                "655678",
                "655679",
                "655680",
                "655681",
                "655682",
                "655683",
                "655684",
                "655685",
                "655686",
                "655687",
                "655688",
                "655689",
                "655690",
                "655691",
                "655692",
                "655693",
                "655694",
                "655695",
                "655696",
                "655697",
                "657371",
                "657372",
                "657373",
                "657374",
                "657375",
                "657376",
                "657377",
                "657378",
                "657379",
                "657380",
                "657381",
                "657382",
                "657383",
                "657384",
                "657385",
                "657386",
                "657387",
                "657388",
                "657389",
                "657390",
                "657391",
                "657392",
                "657393",
                "657394",
                "657395",
                "657396",
                "657397",
                "657398"
        ];
    
    static func isValidCVV(_ cvv: String) -> Bool {
        return isValidCVV(cvv, pan: nil)
    }
    
    static func isValidCVV(_ cvv: String, pan: String?) -> Bool {
        if cvv.count == 0 {
            return false
        }
        
        let cvvOnlyDigits = cvv.digits
        let detectedCardBrand = cardBrand(pan)
        
        return (detectedCardBrand == CardBrand.Unknown && cvvOnlyDigits.count >= 3 && cvvOnlyDigits.count <= 4 ) ||
            (detectedCardBrand == CardBrand.AmericanExpress && cvvOnlyDigits.count == 4) ||
            cvvOnlyDigits.count == 3
    }
    
    static func isValidCardHolderName(_ name: String) -> Bool {
        let v = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return v.count > 0 && v.count <= 128
    }
    
    static func cardBrand(_ pan: String?) -> CardBrand {
        guard let pan = pan else {
            return CardBrand.Unknown
        }
        
        return possibleCardBrand(pan)
    }
    
    static func isValidPan(_ pan: String) -> Bool {
        let panOnlyDigits = pan.digits
        return isValidLuhnNumber(panOnlyDigits) && isValidCardLength(panOnlyDigits)
    }
    
    static func isValidCardLength(_ pan: String) -> Bool {
        let cardBrand = possibleCardBrand(pan)
        if cardBrand == .Unknown {
            return false
        }
        
        let length = pan.count
        
        switch cardBrand {
        case .AmericanExpress:
            return length == LENGTH_AMERICAN_EXPRESS
        case .DinersClub:
            return length == LENGTH_DINERS_CLUB
        case .Visa:
            return VISA_CARD_LENGTH.contains(length)
        case .Maestro:
            return MAESTRO_CARD_LENGTH.contains(length)
        default:
            return length == LENGTH_COMMON_CARD
        }
    }
    
    static func possibleCardBrand(_ pan: String) -> CardBrand {
        let spacelessCardNumber = pan.digits
        
        if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_AMERICAN_EXPRESS)) {
            return CardBrand.AmericanExpress;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_DINACARD)) {
            return CardBrand.Dinacard;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber,prefixes: PREFIXES_DISCOVER)) {
            return CardBrand.Discover;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_JCB)) {
            return CardBrand.Jcb;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_DINERS_CLUB)) {
            return CardBrand.DinersClub;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_VISA)) {
            return CardBrand.Visa;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_MAESTRO)) {
            return CardBrand.Maestro;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_MASTERCARD)) {
            return CardBrand.Mastercard;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_UNIONPAY)) {
            return CardBrand.UnionPay;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_TROY)) {
            return CardBrand.Troy;
        } else {
            return CardBrand.Unknown;
        }
    }
    
    static func isValidLuhnNumber(_ pan: String) -> Bool {
        return luhnCheck(pan)
    }
    
    static func isValidCardToken(_ token: String) -> Bool {
        return token.count >= 32 && token.count <= 64
    }
    
    static func isValidExpiry(month: Int, year: Int) -> Bool {
        if !validateExpMonth(month) {
            return false
        }
        
        let now = Date()
        
        if !validateExpYear(now: now, year: year) {
            return false
        }
        
        return !hasMonthPassed(year: year, month: month, now: now)
        
    }
    
    static func hasMonthPassed(year: Int, month: Int, now: Date) -> Bool {
        
        if hasYearPassed(year, now: now) {
            return true
        }
        
        let calendar = Calendar.current
        let normalizedYear = normalizeYear(year, now: now)
        
        return normalizedYear == calendar.component(.year, from: now) && month < calendar.component(.month, from: now)
    }
    
    static func validateExpMonth(_ month: Int) -> Bool {
        return month >= 1 && month <= 12
    }
    
    static func validateExpYear(now: Date, year: Int) -> Bool {
        return !hasYearPassed(year, now: now)
    }
    
    static func hasYearPassed(_ year: Int, now: Date) -> Bool {
        let normalized = normalizeYear(year, now: now)
        let calendar = Calendar.current
        return normalized < calendar.component(.year, from: now)
    }
    
    static func normalizeYear(_ year: Int, now: Date) -> Int {
        if year < 100 && year >= 0 {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: now)
            let prefix = Int("\(currentYear)"[0...1] + "00")!
            return prefix + year
        }
        
        return year
    }
    
    static func validateNonce(_ nonce: String) -> Bool {
        return nonce.count > 0 && nonce.count <= 16
    }
}

internal func luhnCheck(_ number: String) -> Bool {
    var sum = 0
    let digitStrings = number.reversed().map { String($0) }

    for tuple in digitStrings.enumerated() {
        if let digit = Int(tuple.element) {
            let odd = tuple.offset % 2 == 1

            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        } else {
            return false
        }
    }
    return sum % 10 == 0
}


extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

extension String {
  subscript(_ i: Int) -> String {
    let idx1 = index(startIndex, offsetBy: i)
    let idx2 = index(idx1, offsetBy: 1)
    return String(self[idx1..<idx2])
  }

  subscript (r: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: r.lowerBound)
    let end = index(startIndex, offsetBy: r.upperBound)
    return String(self[start ..< end])
  }

  subscript (r: CountableClosedRange<Int>) -> String {
    let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
    let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
    return String(self[startIndex...endIndex])
  }
}
