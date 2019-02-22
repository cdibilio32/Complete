/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
    
    return formatter
}()

public struct PaidSubscription {
    
    public enum Level {
        case one
        case all
        
        init?(productId: String) {
            if productId.contains(WeeklySubscriptionProductId) {
                self = .one
            } else if productId.contains("allaccess") {
                self = .all
            } else {
                return nil
            }
        }
    }
    
    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date
    public let level: Level
    
    public var isActive: Bool {
        // is current date between purchaseDate and expiresDate?
        return (purchaseDate...expiresDate).contains(Date())
    }
    
    init?(json: [String: Any]) {
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString)
            else {
                return nil
        }
        
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        self.level = Level(productId: productId) ?? .all // if we've botched the productId give them all access :]
        
    }
}

