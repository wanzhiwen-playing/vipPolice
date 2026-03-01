//
//  MemberAccount.swift
//  vipPolice
//
//  会员账号数据模型
//

import Foundation
import SwiftUI

/// 平台信息
enum Platform: String, Codable, CaseIterable {
    case taobao = "淘宝"
    case jingdong = "京东"
    case meituan = "美团"
    case eleme = "饿了么"
    case custom = "其他"
    
    /// 平台主题色
    var themeColor: Color {
        switch self {
        case .taobao:
            return Color(red: 1.0, green: 0.4, blue: 0.0)  // 橙色
        case .jingdong:
            return Color(red: 0.9, green: 0.0, blue: 0.0)  // 红色
        case .meituan:
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // 黄色
        case .eleme:
            return Color(red: 0.0, green: 0.5, blue: 1.0)  // 蓝色
        case .custom:
            return Color.gray
        }
    }
    
    /// SF Symbol 图标
    var iconName: String {
        switch self {
        case .taobao:
            return "cart.fill"
        case .jingdong:
            return "bag.fill"
        case .meituan:
            return "fork.knife"
        case .eleme:
            return "takeoutbag.and.cup.and.straw.fill"
        case .custom:
            return "star.fill"
        }
    }
    
    /// 平台关键词（用于 OCR 识别）
    var keywords: [String] {
        switch self {
        case .taobao:
            return ["淘宝", "天猫", "88VIP", "淘气值"]
        case .jingdong:
            return ["京东", "PLUS", "京豆", "京券"]
        case .meituan:
            return ["美团", "外卖", "团购", "美团会员"]
        case .eleme:
            return ["饿了么", "饿了么会员", "超级会员"]
        case .custom:
            return []
        }
    }
}

/// 会员账号
struct MemberAccount: Identifiable, Codable {
    var id = UUID()
    var platform: Platform                // 平台名称
    var customPlatformName: String?       // 自定义平台名（当 platform 为 custom 时使用）
    var benefits: [Benefit]               // 权益数组
    var createdDate: Date = Date()        // 创建时间
    var lastUpdated: Date = Date()        // 最后更新时间
    
    /// 获取平台显示名称
    var displayName: String {
        if platform == .custom, let customName = customPlatformName {
            return customName
        }
        return platform.rawValue
    }
    
    /// 获取本月需要处理的权益
    func getBenefitsNeedingAttention() -> [Benefit] {
        return benefits.filter { $0.needsAttentionThisMonth() && !$0.isUsed }
    }
    
    /// 获取即将过期的权益（5天内）
    func getExpiringSoonBenefits() -> [Benefit] {
        return benefits.filter { $0.isExpiringSoon() && !$0.isUsed }
    }
    
    /// 获取待领取的权益（周期性且未使用）
    func getPendingPeriodicBenefits() -> [Benefit] {
        return benefits.filter { $0.type == .periodic && !$0.isUsed }
    }
}
