//
//  NotificationManager.swift
//  vipPolice
//
//  通知管理器 - 负责权益到期提醒
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission
    
    /// 请求通知权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// 检查通知权限状态
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    /// 为所有即将过期的权益安排通知
    func scheduleNotifications(for accounts: [MemberAccount]) {
        // 先清除所有现有通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for account in accounts {
            for benefit in account.benefits where !benefit.isUsed {
                scheduleNotification(for: benefit, account: account)
            }
        }
    }
    
    /// 为单个权益安排通知
    private func scheduleNotification(for benefit: Benefit, account: MemberAccount) {
        let content = UNMutableNotificationContent()
        content.title = "\(account.displayName) 权益提醒"
        content.sound = .default
        
        var triggerDate: Date?
        
        switch benefit.type {
        case .periodic:
            // 周期性权益：在重置日前一天提醒
            if let resetDay = benefit.resetDay {
                content.body = "\(benefit.title) 将在每月\(resetDay)日重置，记得领取！"
                
                var components = DateComponents()
                components.day = resetDay - 1
                components.hour = 9
                components.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "periodic_\(benefit.id.uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
            
        case .oneTime:
            // 一次性权益：在过期前5天提醒
            if let expiryDate = benefit.expiryDate {
                let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
                
                if daysUntilExpiry >= 5 {
                    // 在过期前5天提醒
                    triggerDate = Calendar.current.date(byAdding: .day, value: -5, to: expiryDate)
                    content.body = "\(benefit.title) 还有5天过期，记得使用！"
                } else if daysUntilExpiry > 0 {
                    // 如果已经不足5天，立即提醒
                    triggerDate = Date().addingTimeInterval(60) // 1分钟后提醒
                    content.body = "\(benefit.title) 即将过期，请尽快使用！"
                }
                
                if let triggerDate = triggerDate {
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "onetime_\(benefit.id.uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// 取消特定权益的通知
    func cancelNotification(for benefitId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                "periodic_\(benefitId.uuidString)",
                "onetime_\(benefitId.uuidString)"
            ]
        )
    }
    
    /// 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Debug
    
    /// 获取所有待处理的通知（用于调试）
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}
