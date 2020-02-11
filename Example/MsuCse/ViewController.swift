//
//  ViewController.swift
//  MsuCse
//
//  Created by jasmin.suljic@monri.com
//  
//

import UIKit
import MsuCse

class ViewController: UIViewController {
    
    var cse: CSE!

    override func viewDidLoad() {
        super.viewDidLoad()
        cse = CSE(developmentMode: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func usageExample(sender: UIButton) {
        let visaPan = "4111 1111 1111 1111"
        if (cse.isValidPan(visaPan)) {
            print("Pan is valid")
        }

        if (cse.isValidCardHolderName("John")) {
            print("cardholder name is valid");
        }

        if (cse.isValidCVV("123")) {
            print("cvv is valid");
        }

        if (!cse.isValidCVV(cvv: "1234", pan: visaPan)) {
            print("cvv 1234 is not valid for VISA card");
        }

        let invalidCardToken = String(repeating: "E", count: 65)
        if (!cse.isValidCardToken(invalidCardToken)) {
            print("card token is invalid");
        }

        if (!cse.isValidExpiry(month: 10, year: 2018)) {
            print("Expiry year in past");
        }
        
        if (cse.isValidExpiry(month: 10, year: 2020)) {
            print("Valid expiry");
        }

        // dinacard - 989100
        let cardBrand = cse.detectBrand("989100");

        if (cardBrand == CardBrand.Dinacard) {
            print("Detected brand is dinacard");
        }
    }
    
    @IBAction func encryptCardExample(sender: UIButton) {
        cse.encrypt(pan: "4355084355084358", cardHolderName: "Test Test", expiryYear: 2020, expiryMonth: 12, cvv: "000", nonce: nonce()) {
            result in
            switch result {
                case .error(let e):
                    print(e)
                case .success(let r):
                    print(r)
            }
        }
    }
    
    func nonce() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<16).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func encryptCvvExample(sender: UIButton) {
        cse.encrypt(cvv: "123", nonce: nonce()) {
            result in
            switch result {
                case .error(let e):
                    print(e)
                case .success(let r):
                    print(r)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

