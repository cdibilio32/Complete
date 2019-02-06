//
//  PurchaseManager.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/5/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import Foundation
import StoreKit

typealias CompletionHandler = (_ success:Bool) -> ()

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // Singleton
    static let instance = PurchaseManager()
    
    // --- Instance Variables ---
    
    
    // Product Data
    var productRequest:SKProductsRequest!
    var products = [SKProduct]()
    var transactionComplete:CompletionHandler?
    
    
    
    
    
    // --- Functions ---
    // Request all Products from Apple
    func fetchProducts() {
        // Purchase ID's
        let productStrings = Set(["ChuckDibilio.Jotitt", "ChuckDibilio.Jotitt.YearlySubscription"])
        
        // Request Products
        productRequest = SKProductsRequest(productIdentifiers: productStrings)
        productRequest.delegate = self
        productRequest.start()
    }
    
    // Apply Purchases
    func purchaseSubscription(renewing:String, onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            // Store completion handler
            transactionComplete = onComplete
            
            // Get Subscription type and payment
            let payment:SKPayment
            if renewing == "monthly" {
                payment = SKPayment(product: products[0])
            } else {
                payment = SKPayment(product: products[1])
            }
            
            // Start Processing Payment
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
        
        // return false that couldn't purchase
        else {
            onComplete(false)
        }
    }
    
    
    
    
    // --- Delegate functions for SKProductRequestDelegate ---
    // Call back when product request is recieved
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        if response.products.count > 0 {
//            debugPrint("successful product request")
//            products = response.products
//        }
        debugPrint("In product request")
        debugPrint(response.products.count)
    }
    
    // Call back for product request if failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("In request failed")
        debugPrint(error.localizedDescription)
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.standard.set(true, forKey: "subscriber")
                transactionComplete?(true)
                break
            case .purchasing:
                break
            case .deferred:
                break
            case .failed:
                transactionComplete?(false)
                debugPrint("in failed")
                break
            case .restored:
                break
            default:
                transactionComplete?(false)
                debugPrint("in default")
                break
            }
        }
    }
    
    
}
