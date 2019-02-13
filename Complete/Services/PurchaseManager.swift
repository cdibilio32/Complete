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
        debugPrint(SKPaymentQueue.canMakePayments())
        debugPrint(products.count)
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            // Store completion handler
            transactionComplete = onComplete
            debugPrint("in purchase subscription")
            // Get Subscription type and payment
            let payment:SKPayment
            if renewing == "monthly" {
                payment = SKPayment(product: products[0])
                debugPrint("in monthly")
            } else {
                payment = SKPayment(product: products[1])
                debugPrint("in yearly")
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
    
    // Restore Purchase
    func restorePurchases(onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() {
            transactionComplete = onComplete
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            onComplete(false)
        }
    }
    
    
    
    
    // --- Delegate functions for SKProductRequestDelegate ---
    // Call back when product request is recieved
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            debugPrint("In product request")
            debugPrint(response.products.count)
            debugPrint("successful product request")
            products = response.products
        }
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
                debugPrint("case: purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.standard.set(true, forKey: "subscriber")
                DataService.instance.updateUserSubscription(subValue: true)
                transactionComplete?(true)
                break
            case .failed:
                debugPrint("case: failed")
                transactionComplete?(false)
                break
            case .restored:
                debugPrint("case: restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.standard.set(true, forKey: "subscriber")
                DataService.instance.updateUserSubscription(subValue: true)
                transactionComplete?(true)
                break
                // Let it go to default for now
//            case .purchasing:
//                break
//            case .deferred:
//                break

            default:
                debugPrint("case: default")
                transactionComplete?(false)
                break
            }
        }
    }
    
    
}
