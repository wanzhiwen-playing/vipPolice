//
//  AccountDetailView.swift
//  vipPolice
//
//  账号详情视图 - 显示单个平台的所有权益
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let account: MemberAccount
    
    var body: some View {
        List {
            // Platform Header
            Section {
                HStack {
                    Image(systemName: account.platform.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(account.platform.themeColor)
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("共 \(account.benefits.count) 个权益")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("更新于 \(formattedDate(account.lastUpdated))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            // Benefits List
            if !account.benefits.isEmpty {
                Section {
                    ForEach(account.benefits) { benefit in
                        BenefitDetailRow(
                            account: account,
                            benefit: benefit,
                            onToggle: {
                                dataManager.toggleBenefitUsed(
                                    accountId: account.id,
                                    benefitId: benefit.id
                                )
                            }
                        )
                    }
                } header: {
                    Text("权益列表")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("权益详情")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formattedExpiryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Benefit Detail Row

struct BenefitDetailRow: View {
    let account: MemberAccount
    let benefit: Benefit
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Checkbox
                Button {
                    onToggle()
                } label: {
                    Image(systemName: benefit.isUsed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(benefit.isUsed ? .green : .gray)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(benefit.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        // Type Badge
                        Text(benefit.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(benefit.type == .periodic ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(benefit.type == .periodic ? .blue : .orange)
                            .cornerRadius(4)
                    }
                    
                    Text(benefit.value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(account.platform.themeColor)
                }
            }
            
            // Constraint
            if let constraint = benefit.constraint {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(constraint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 32)
            }
            
            // Date Info
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if benefit.type == .periodic, let resetDay = benefit.resetDay {
                    Text("每月\(resetDay)日重置")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else if let expiryDate = benefit.expiryDate {
                    HStack {
                        Text("有效期至 \(formattedExpiryDate(expiryDate))")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        if benefit.isExpiringSoon() {
                            Text("即将过期")
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(3)
                        }
                    }
                }
            }
            .padding(.leading, 32)
        }
        .padding(.vertical, 4)
        .opacity(benefit.isUsed ? 0.5 : 1.0)
    }
}

// Preview removed for compatibility
