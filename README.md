# MsuCse

[![CI Status](https://img.shields.io/travis/jasmin.suljic/MsuCse.svg?style=flat)](https://travis-ci.org/jasmin.suljic/MsuCse)
[![Version](https://img.shields.io/cocoapods/v/MsuCse.svg?style=flat)](https://cocoapods.org/pods/MsuCse)
[![License](https://img.shields.io/cocoapods/l/MsuCse.svg?style=flat)](https://cocoapods.org/pods/MsuCse)
[![Platform](https://img.shields.io/cocoapods/p/MsuCse.svg?style=flat)](https://cocoapods.org/pods/MsuCse)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Client Side Encryption(CSE)

## Introduction
Client Side Encryption is a way to encrypt customer sensitive information on mobile device, before card data passes any other medium(i.e. merchant server). The model is suitable for merchants wanting to do API SALE/PREAUTH from their servers, because card data will pass encrypted on merchant server, this way avoiding the responsibility of "hosting" any card data on merchant side.

## How it works
Merchant must include MSU iOS CSE SDK in their mobile application:

```ruby
pod 'MsuCse'
```

The steps should be like this:
- include library in application
- initialize library
- After user has filled first 6 digits of pan you can issue a [SHOULDDO3D](https://test.merchantsafeunipay.com/msu/api/v2/doc#shouldDo3D) API Call to determine the next steps
- Customer has filled card data and clicks pay. If [SHOULDDO3D](https://test.merchantsafeunipay.com/msu/api/v2/doc#shouldDo3D) returned `YES`, then no CSE is needed as customer sensitive information will pass from Browser directly to MSU Servers via the Auth 3D flow. One of request parameters of the Auth 3D flow is `callbackUrl` which is an endpoint on merchant side that will receive the final 3D response, including `auth3DToken` if 3d authentication was successful. At this point you can call [API SALE](https://test.merchantsafeunipay.com/msu/api/v2/doc#sale) with the `auth3DToken`
- If [SHOULDDO3D](https://test.merchantsafeunipay.com/msu/api/v2/doc#shouldDo3D) returns `NO` or `OPTIONAL`, you may skip the 3D Journey and intercept main payment form by encrypting the data using the CSE SDK Payment With New Card

```swift
// Do not forget to import lib
// import MsuCse
let cse = CSE(developmentMode: true)
cse.encrypt(pan: "4355084355084358", cardHolderName: "Test Test", expiryYear: 2020, expiryMonth: 12, cvv: "000", nonce: nonce()) {
            result in
            switch result {
                case .error(let e):
                    print(e)
                case .success(let r):
                    print(r)
            }
        }
```

Payment with existing card/wallet, encrypting CVV
```swift
// Do not forget to import lib
// import MsuCse
let cse = CSE(developmentMode: true)
cse.encrypt(cvv: "123", nonce: nonce()) {
            result in
            switch result {
                case .error(let e):
                    print(e)
                case .success(let r):
                    print(r)
            }
        }
```

Example is available on this [link](https://github.com/PaytenASEE/msu-cse-ios/blob/master/Example/MsuCse/ViewController.swift)

# CSE SDK API Information

Make sure you have included library in application `Podfile` file.

- After including library instantiate `CSE` library:

```swift
// Change this to false if production
// If set to true MSU test environment is used for encryption, meaning encrypted values with developmentMode = true will not work on production env
let cse = CSE(developmentMode: true)
```
Available methods on `cse` object:
* encrypt card data
  * pan: valid pan
  * cardHolderName: non empty string
  * expiryYear: valid year, in `YYYY` format
  * expiryMonth: value from 1-12
  * cvv: valid cvv value, eg 123 is valid for VISA, 1234 is not
  * nonce: random generated alphanumeric value, max length 16 characters
  * callback: interface consisting of two methods: `onSuccess` and `onError`

Method signature:
```swift
func encrypt(pan: String,
             cardHolderName: String,
             expiryYear: Int,
             expiryMonth: Int,
             cvv: String,
             nonce: String,
             _ callback: @escaping EncryptCallback)
```

* encrypt cvv for existing card/wallet payment
  * cvv: valid cvv
  * nonce: random generated alphanumeric value, max length 16 characters

Method signature:
```swift
func encrypt(cvv: String, nonce: String, _ callback: @escaping EncryptCallback)
```
* property hasErrors: true if any errors occurred during encryption 
Property signature:
```swift

var hasErrors: Bool { errors.count > 0 }

```

* errors: list of errors ocurred during encryption
```swift
var errors: [String] = []
```

* isValidCardHolderName: returns true if card holder's name is non empty
Method signature:
```swift
func isValidCardHolderName(_ name: String) -> Bool
```
* isValidPan - returns true if pan is valid
Method signature:
```swift
func isValidPan(_ pan: String) -> Bool
```
* isValidCVV(cvv) - returs true if cvv is valid length
Method signature:
```swift
func isValidCVV(_ cvv: String) -> Bool
```

* isValidCVV(cvv, pan) - returs true if cvv is valid for brand detected from pan.
Method signature:
```swift
func isValidCVV(cvv: String, pan: String) -> Bool
```

* isValidExpiry(month, year) - returns true if expiry is valid
Method signature:
```swift
func isValidExpiry(month: Int, year: Int)
```

* isValidCardToken - returns true if card token length is greater or equal to 32 and less or equal to 64
Method signature:
```swift
func isValidCardToken(_ token: String) -> Bool
```

* detectBrand: returns detected card brand, or `CardBrand.UNKNOWN`
Method signature:
```swift
func detectBrand(_ pan: String) -> CardBrand
```


Usage example is available on [link](https://github.com/PaytenASEE/msu-cse-ios/blob/master/Example/MsuCse/ViewController.swift)

## License

MsuCse is available under the MIT license. See the LICENSE file for more info.
