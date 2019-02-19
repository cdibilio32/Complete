//
//  PurchaseManager.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/5/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import Foundation
import StoreKit

// Enums
public enum Result<T> {
    case failure(SelfieServiceError)
    case success(T)
}

public enum SelfieServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

// Type Alias
typealias CompletionHandler = (_ success:Bool) -> ()
public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void
public typealias SessionId = String


// --- Class ---
class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // Singleton
    static let instance = PurchaseManager()
    
    // --- Instance Variables ---
    var activityIndicator:UIActivityIndicatorView!
    var activityContainer:UIView!
    
    
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
    func purchaseSubscription(renewing:String, activityIndicator:UIActivityIndicatorView, activityContainer:UIView, onComplete: @escaping CompletionHandler) {
        // Set Activity Spinner
        startActivityIndicator(activityIndicator: activityIndicator, container: activityContainer)
        
        // Process Payment
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
            products = response.products
        }
    }
    
    // Call back for product request if failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
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
                stopActivityIndicator()
                transactionComplete?(true)
                break
            case .failed:
                debugPrint("case: failed")
                stopActivityIndicator()
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
    
    
    
    
    
    
    
    
    
    // --- Receipts ---
    // Upload Receipt
    func uploadReceipt(completion: ((_ success: Bool, _ currentSessionId:String, _ currentSubscription: PaidSubscription?) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            upload(receipt: receiptData) { (result) in
                switch result {
                case .success(let result):
                    let currentSessionId = result.sessionId
                    let currentSubscription = result.currentSubscription
                    
                    completion?(true, currentSessionId, currentSubscription)
                    
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error)")
                    completion?(false, "nil", PaidSubscription(json: ["nil":"nil"])!)
                }
            }
        }
    }
    
    // Load data from receipt
    /// Trade receipt for session id
    private func upload(receipt data: Data, completion: @escaping (UploadReceiptCompletion)) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": appSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion(.failure(.other(error)))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                let session = Session(receiptData: data, parsedReceipt: json)
                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
                completion(.success(result))
            }
        }
        
        task.resume()
    }
    
    // Load Receipt
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
    
    
    
    
    
    // --- Helper Functions ---
    // Stop activity indicator
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.activityContainer.isHidden = true
    }
    
    // Start activity spinner
    func startActivityIndicator(activityIndicator:UIActivityIndicatorView, container:UIView) {
        // Set Instance Variables
        self.activityIndicator = activityIndicator
        self.activityContainer = container
        
        // Start Activity
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        self.activityContainer.isHidden = false
    }
    
    
}
