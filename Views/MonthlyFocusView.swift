//
//  MonthlyFocusView.swift
//  vipPolice
//
//  本月待办视图 - 显示当月需要处理的任务
//

import SwiftUI

struct MonthlyFocusView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if dataManager.getAllMonthlyTasks().isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("本月待办")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("本月暂无待办")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("点击右上角 + 添加会员截图")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showingImagePicker = true
            } label: {
                Label("添加截图", systemImage: "photo.on.rectangle.angled")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
    
    // MARK: - Task List
    
    private var taskListView: some View {
        List {
            let tasks = dataManager.getAllMonthlyTasks()
            
            // 待领取部分
            let pendingTasks = tasks.filter { $0.benefit.type == .periodic }
            if !pendingTasks.isEmpty {
                Section {
                    ForEach(pendingTasks, id: \.benefit.id) { task in
                        TaskRow(
                            account: task.account,
                            benefit: task.benefit,
                            onToggle: {
                                dataManager.toggleBenefitUsed(
                                    accountId: task.account.id,
                                    benefitId: task.benefit.id
                                )
                            }
                        )
                    }
                } header: {
                    Text("待领取")
                        .font(.headline)
                }
            }
            
            // 待使用部分
            let expiringTasks = tasks.filter { $0.benefit.type == .oneTime }
            if !expiringTasks.isEmpty {
                Section {
                    ForEach(expiringTasks, id: \.benefit.id) { task in
                        TaskRow(
                            account: task.account,
                            benefit: task.benefit,
                            onToggle: {
                                dataManager.toggleBenefitUsed(
                                    accountId: task.account.id,
                                    benefitId: task.benefit.id
                                )
                            }
                        )
                    }
                } header: {
                    Text("待使用（即将过期）")
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Task Row Component

struct TaskRow: View {
    let account: MemberAccount
    let benefit: Benefit
    let onToggle: () -> Void
    
    private var formattedExpiryDate: String {
        guard let expiryDate = benefit.expiryDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: expiryDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                onToggle()
            } label: {
                Image(systemName: benefit.isUsed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(benefit.isUsed ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Platform Icon
            Image(systemName: account.platform.iconName)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(account.platform.themeColor)
                .cornerRadius(8)
            
            // Benefit Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(account.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if benefit.isExpiringSoon() {
                        Text("即将过期")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                
                Text(benefit.title)
                    .font(.headline)
                
                Text(benefit.value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if let constraint = benefit.constraint {
                    Text(constraint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Date Info
                if benefit.type == .periodic, let resetDay = benefit.resetDay {
                    Text("每月\(resetDay)日重置")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else if benefit.expiryDate != nil {
                    Text("有效期至 \(formattedExpiryDate)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(benefit.isUsed ? 0.5 : 1.0)
    }
}

// Preview removed for compatibility
