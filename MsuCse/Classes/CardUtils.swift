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
    ];
    static let  PREFIXES_UNIONPAY = ["62"];
    
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

                // (0[0-4])
                PREFIX_DINACARD + "00",
                PREFIX_DINACARD + "01",
                PREFIX_DINACARD + "02",
                PREFIX_DINACARD + "03",
                PREFIX_DINACARD + "04",
    //          PREFIX_DINACARD +    0[6-7]
                PREFIX_DINACARD + "06",
                PREFIX_DINACARD + "07",

                // 01
                PREFIX_DINACARD + "09",
                // 1-5
                PREFIX_DINACARD + "11",
                PREFIX_DINACARD + "12",
                PREFIX_DINACARD + "13",
                PREFIX_DINACARD + "14",
                PREFIX_DINACARD + "15",

                // 7-9
                PREFIX_DINACARD + "17",
                PREFIX_DINACARD + "18",
                PREFIX_DINACARD + "19",
                // 2[1-5]
                PREFIX_DINACARD + "21",
                PREFIX_DINACARD + "22",
                PREFIX_DINACARD + "23",
                PREFIX_DINACARD + "24",
                PREFIX_DINACARD + "25",
                // 27, 29, 30, 31, 35, 36
                PREFIX_DINACARD + "27",
                PREFIX_DINACARD + "29",
                PREFIX_DINACARD + "30",
                PREFIX_DINACARD + "31",
                PREFIX_DINACARD + "35",
                PREFIX_DINACARD + "36",
                // 4[0-4]
                PREFIX_DINACARD + "40",
                PREFIX_DINACARD + "41",
                PREFIX_DINACARD + "42",
                PREFIX_DINACARD + "43",
                PREFIX_DINACARD + "44",
                // 46, 49
                PREFIX_DINACARD + "46",
                PREFIX_DINACARD + "49",
                PREFIX_DINACARD + "50",
                // 5[0-3]
                PREFIX_DINACARD + "51",
                PREFIX_DINACARD + "52",
                PREFIX_DINACARD + "53",
                // 5[5-9]
                PREFIX_DINACARD + "55",
                PREFIX_DINACARD + "56",
                PREFIX_DINACARD + "57",
                PREFIX_DINACARD + "58",
                PREFIX_DINACARD + "59",
                // 6[0-1]
                PREFIX_DINACARD + "60",
                PREFIX_DINACARD + "61",
                // 6[4-9]
                PREFIX_DINACARD + "64",
                PREFIX_DINACARD + "65",
                PREFIX_DINACARD + "66",
                PREFIX_DINACARD + "67",
                PREFIX_DINACARD + "68",
                PREFIX_DINACARD + "69",
                // 70
                PREFIX_DINACARD + "70",
                // 7[3-8]
                PREFIX_DINACARD + "73",
                PREFIX_DINACARD + "74",
                PREFIX_DINACARD + "75",
                PREFIX_DINACARD + "76",
                PREFIX_DINACARD + "77",
                PREFIX_DINACARD + "78",
                // 80
                PREFIX_DINACARD + "80",
                // 8[6-9]
                PREFIX_DINACARD + "86",
                PREFIX_DINACARD + "87",
                PREFIX_DINACARD + "88",
                PREFIX_DINACARD + "89"
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
        return name.count <= 128
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
        default:
            return length == LENGTH_COMMON_CARD
        }
    }
    
    static func possibleCardBrand(_ pan: String) -> CardBrand {
        let spacelessCardNumber = pan.digits
        
        if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_AMERICAN_EXPRESS)) {
            return CardBrand.AmericanExpress;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber,prefixes: PREFIXES_DISCOVER)) {
            return CardBrand.Discover;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_JCB)) {
            return CardBrand.Jcb;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_DINERS_CLUB)) {
            return CardBrand.DinersClub;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_VISA)) {
            return CardBrand.Visa;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_MASTERCARD)) {
            return CardBrand.Mastercard;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_UNIONPAY)) {
            return CardBrand.UnionPay;
        } else if (CSETextUtils.hasAnyPrefix(spacelessCardNumber, prefixes: PREFIXES_DINACARD)) {
            return CardBrand.Dinacard;
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
        return hasYearPassed(year, now: now)
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
        return nonce.count <= 16
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
