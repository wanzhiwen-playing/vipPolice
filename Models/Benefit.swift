//
//  Benefit.swift
//  vipPolice
//
//  权益数据模型
//

import Foundation

/// 权益类型
enum BenefitType: String, Codable, CaseIterable {
    case periodic = "周期性重置"      // 每月重置
    case oneTime = "一次性到期"       // 绝对过期时间
}

/// 单个权益
struct Benefit: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String                    // 权益名称（如：免邮券、红包）
    var type: BenefitType                // 类型（周期性/一次性）
    var value: String                    // 数量或金额（如："¥5"、"3张"）
    var resetDay: Int?                   // 每月重置日（1-31，仅周期性有效）
    var expiryDate: Date?                // 绝对过期时间（仅一次性有效）
    var constraint: String?              // 使用限制（如：限自营、满30可用）
    var isUsed: Bool = false             // 是否已使用/已领取
    
    /// 判断是否在本月需要处理
    func needsAttentionThisMonth() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        switch type {
        case .periodic:
            // 周期性权益：检查是否在本月重置日附近
            guard let resetDay = resetDay else { return false }
            let currentDay = calendar.component(.day, from: now)
            // 如果还没到重置日，或者刚过重置日不久（5天内）
            return currentDay <= resetDay || (currentDay - resetDay) <= 5
            
        case .oneTime:
            // 一次性权益：检查是否在本月过期
            guard let expiryDate = expiryDate else { return false }
            let expiryMonth = calendar.component(.month, from: expiryDate)
            let expiryYear = calendar.component(.year, from: expiryDate)
            return expiryMonth == currentMonth && expiryYear == currentYear
        }
    }
    
    /// 判断是否即将过期（5天内）
    func isExpiringSoon() -> Bool {
        guard let expiryDate = expiryDate else { return false }
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
        return daysUntilExpiry >= 0 && daysUntilExpiry <= 5
    }
    
    /// 获取显示文本
    func getDisplayText() -> String {
        var text = "\(title) - \(value)"
        
        if let constraint = constraint {
            text += "\n\(constraint)"
        }
        
        switch type {
        case .periodic:
            if let resetDay = resetDay {
                text += "\n每月\(resetDay)日重置"
            }
        case .oneTime:
            if let expiryDate = expiryDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                text += "\n有效期至 \(formatter.string(from: expiryDate))"
            }
        }
        
        return text
    }
}
