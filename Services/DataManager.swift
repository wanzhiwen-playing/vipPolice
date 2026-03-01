//
//  DataManager.swift
//  vipPolice
//
//  数据管理器 - 负责数据持久化和状态管理
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var accounts: [MemberAccount] = []
    
    private let saveKey = "SavedAccounts"
    
    init() {
        loadAccounts()
    }
    
    // MARK: - CRUD Operations
    
    /// 添加新账号
    func addAccount(_ account: MemberAccount) {
        accounts.append(account)
        saveAccounts()
    }
    
    /// 更新账号
    func updateAccount(_ account: MemberAccount) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            var updatedAccount = account
            updatedAccount.lastUpdated = Date()
            accounts[index] = updatedAccount
            saveAccounts()
        }
    }
    
    /// 删除账号
    func deleteAccount(_ account: MemberAccount) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()
    }
    
    /// 更新权益状态
    func toggleBenefitUsed(accountId: UUID, benefitId: UUID) {
        if let accountIndex = accounts.firstIndex(where: { $0.id == accountId }),
           let benefitIndex = accounts[accountIndex].benefits.firstIndex(where: { $0.id == benefitId }) {
            accounts[accountIndex].benefits[benefitIndex].isUsed.toggle()
            accounts[accountIndex].lastUpdated = Date()
            saveAccounts()
        }
    }
    
    // MARK: - Query Methods
    
    /// 获取所有本月需要处理的权益
    func getAllMonthlyTasks() -> [(account: MemberAccount, benefit: Benefit)] {
        var tasks: [(MemberAccount, Benefit)] = []
        
        for account in accounts {
            let benefits = account.getBenefitsNeedingAttention()
            for benefit in benefits {
                tasks.append((account, benefit))
            }
        }
        
        return tasks.sorted { $0.benefit.expiryDate ?? Date.distantFuture < $1.benefit.expiryDate ?? Date.distantFuture }
    }
    
    /// 获取即将过期的权益（用于通知）
    func getExpiringSoonBenefits() -> [(account: MemberAccount, benefit: Benefit)] {
        var expiring: [(MemberAccount, Benefit)] = []
        
        for account in accounts {
            let benefits = account.getExpiringSoonBenefits()
            for benefit in benefits {
                expiring.append((account, benefit))
            }
        }
        
        return expiring
    }
    
    // MARK: - Persistence
    
    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([MemberAccount].self, from: data) {
            accounts = decoded
        }
    }
}
