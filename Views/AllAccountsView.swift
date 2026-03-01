//
//  AllAccountsView.swift
//  vipPolice
//
//  全部权益视图 - 显示所有已录入的会员账号
//

import SwiftUI

struct AllAccountsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if dataManager.accounts.isEmpty {
                    emptyStateView
                } else {
                    accountListView
                }
            }
            .navigationTitle("全部权益")
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
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("暂无会员账号")
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
    
    // MARK: - Account List
    
    private var accountListView: some View {
        List {
            ForEach(dataManager.accounts) { account in
                NavigationLink(destination: AccountDetailView(account: account)) {
                    AccountRow(account: account)
                }
            }
            .onDelete(perform: deleteAccounts)
        }
        .listStyle(.insetGrouped)
    }
    
    private func deleteAccounts(at offsets: IndexSet) {
        for index in offsets {
            let account = dataManager.accounts[index]
            dataManager.deleteAccount(account)
        }
    }
}

// MARK: - Account Row Component

struct AccountRow: View {
    let account: MemberAccount
    
    var body: some View {
        HStack(spacing: 12) {
            // Platform Icon
            Image(systemName: account.platform.iconName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(account.platform.themeColor)
                .cornerRadius(10)
            
            // Account Info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.headline)
                
                Text("\(account.benefits.count) 个权益")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Show expiring count if any
                let expiringCount = account.getExpiringSoonBenefits().count
                if expiringCount > 0 {
                    Text("\(expiringCount) 个即将过期")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// Preview removed for compatibility
