//
//  Double.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 23/04/2022.
//

import Foundation

extension Double {
    
    /// Convert a Double into Currency with 2 decimals
    /// ```
    /// Convert 1234.56 to RM1,234.56
    /// ```
    private var currencyFormatter2: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true // (?)
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    /// Convert a Double into Currency as a String with 2 decimals
    /// ```
    /// Convert 1234.56 to "RM1,234.56"
    /// ```
    func asCurrencyWith2Decimals(currency: Currency) -> String {
        let number = NSNumber(value: self)
        let formatter = currencyFormatter2
        formatter.currencyCode = currency.currencyCode
        formatter.currencySymbol = currency.currencySymbol
        return formatter.string(from: number) ?? "$0.00"
    }
    
    /// Convert a Double into Currency with 2,6 decimals
    /// ```
    /// Convert 1234.56 to RM1,234.56
    /// Convert 12.3456 to RM12.3456
    /// Convert 0.123456 to RM0.123456
    /// ```
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true // (?)
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }
    
    /// Convert a Double into Currency as a String with 2,6 decimals
    /// ```
    /// Convert 1234.56 to "RM1,234.56"
    /// Convert 12.3456 to "RM12.3456"
    /// Convert 0.123456 to "RM0.123456"
    /// ```
    func asCurrencyWith6Decimals(currency: Currency) -> String {
        let number = NSNumber(value: self)
        let formatter = currencyFormatter
        formatter.currencyCode = currency.currencyCode
        formatter.currencySymbol = currency.currencySymbol
        return formatter.string(from: number) ?? "$0.00"
    }
    
    /// Convert a Double into String representation
    /// ```
    /// Convert 1.23456 to "1.23"
    /// ```
    func asNumberString() -> String {
        return String(format: "%.2f", self)
    }
    
    /// Convert a Double into String representation with % symbol
    /// ```
    /// Convert "1.23" to "1.23%"
    /// ```
    func asPercentString() -> String {
        return asNumberString() + "%"
    }
}
