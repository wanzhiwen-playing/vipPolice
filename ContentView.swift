//
//  ContentView.swift
//  vipPolice
//
//  主视图 - Tab 导航
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    @State private var notificationsEnabled = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 本月待办 Tab
            MonthlyFocusView()
                .tabItem {
                    Label("本月待办", systemImage: "checklist")
                }
                .tag(0)
            
            // 全部权益 Tab
            AllAccountsView()
                .tabItem {
                    Label("全部权益", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            // 设置 Tab
            SettingsView(notificationsEnabled: $notificationsEnabled)
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(2)
        }
        .environmentObject(dataManager)
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: dataManager.accounts) { _, _ in
            if notificationsEnabled {
                scheduleNotifications()
            }
        }
    }
    
    private func checkNotificationStatus() {
        NotificationManager.shared.checkAuthorizationStatus { granted in
            notificationsEnabled = granted
        }
    }
    
    private func scheduleNotifications() {
        NotificationManager.shared.scheduleNotifications(for: dataManager.accounts)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var notificationsEnabled: Bool
    @State private var showingNotificationAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Notification Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text("到期提醒")
                        }
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        handleNotificationToggle(newValue)
                    }
                    
                    if notificationsEnabled {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("权益失效前5天将收到提醒")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("通知设置")
                } footer: {
                    Text("开启后，App 会在权益即将过期时发送通知提醒")
                }
                
                // Statistics Section
                Section {
                    HStack {
                        Text("已录入账号")
                        Spacer()
                        Text("\(dataManager.accounts.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总权益数")
                        Spacer()
                        let totalBenefits = dataManager.accounts.reduce(0) { $0 + $1.benefits.count }
                        Text("\(totalBenefits)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("本月待办")
                        Spacer()
                        Text("\(dataManager.getAllMonthlyTasks().count)")
                            .foregroundColor(.orange)
                    }
                } header: {
                    Text("统计信息")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("vipPolice 帮助您管理各平台会员权益")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
                
                // Debug Section (可选)
                #if DEBUG
                Section {
                    Button("查看待处理通知") {
                        NotificationManager.shared.getPendingNotifications { requests in
                            print("待处理通知数量: \(requests.count)")
                            for request in requests {
                                print("- \(request.identifier): \(request.content.body)")
                            }
                        }
                    }
                    
                    Button("清除所有通知") {
                        NotificationManager.shared.cancelAllNotifications()
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("调试选项")
                }
                #endif
            }
            .navigationTitle("设置")
        }
        .alert("需要通知权限", isPresented: $showingNotificationAlert) {
            Button("去设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("取消", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("请在系统设置中允许 vipPolice 发送通知")
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    NotificationManager.shared.scheduleNotifications(for: dataManager.accounts)
                } else {
                    notificationsEnabled = false
                    showingNotificationAlert = true
                }
            }
        } else {
            NotificationManager.shared.cancelAllNotifications()
        }
    }
}

// Preview removed for compatibility
