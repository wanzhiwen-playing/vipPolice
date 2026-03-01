//
//  VerificationView.swift
//  vipPolice
//
//  验证视图 - 用户手动校验和微调 OCR 识别结果
//

import SwiftUI

struct VerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var account: MemberAccount
    let onConfirm: (MemberAccount) -> Void
    
    init(account: MemberAccount, onConfirm: @escaping (MemberAccount) -> Void) {
        _account = State(initialValue: account)
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Platform Section
                Section {
                    HStack {
                        Image(systemName: account.platform.iconName)
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(account.platform.themeColor)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Text("识别平台")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(account.displayName)
                                .font(.headline)
                        }
                        .padding(.leading, 8)
                    }
                } header: {
                    Text("平台信息")
                } footer: {
                    Text("请确认识别的平台是否正确")
                }
                
                // Benefits Section
                Section {
                    ForEach(account.benefits.indices, id: \.self) { index in
                        BenefitEditRow(benefit: $account.benefits[index])
                    }
                } header: {
                    HStack {
                        Text("识别到的权益")
                        Spacer()
                        Text("共 \(account.benefits.count) 个")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("请仔细核对金额、日期等信息，点击可编辑")
                }
                
                // Tips Section
                Section {
                    Label("OCR 识别可能不完全准确", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label("建议仔细核对到期时间和金额", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .navigationTitle("确认识别结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确认") {
                        onConfirm(account)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Benefit Edit Row

struct BenefitEditRow: View {
    @Binding var benefit: Benefit
    @State private var showingEditSheet = false
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(benefit.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.blue)
                }
                
                Text(benefit.value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if let constraint = benefit.constraint {
                    Text(constraint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    
                    if benefit.type == .periodic, let resetDay = benefit.resetDay {
                        Text("每月\(resetDay)日重置")
                            .font(.caption)
                    } else if let expiryDate = benefit.expiryDate {
                        Text("有效期至 \(formattedExpiryDate(expiryDate))")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingEditSheet) {
            BenefitEditSheet(benefit: $benefit)
        }
    }
    
    private func formattedExpiryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Benefit Edit Sheet

struct BenefitEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var benefit: Benefit
    
    @State private var title: String
    @State private var value: String
    @State private var type: BenefitType
    @State private var resetDay: Int
    @State private var expiryDate: Date
    @State private var constraint: String
    
    init(benefit: Binding<Benefit>) {
        _benefit = benefit
        _title = State(initialValue: benefit.wrappedValue.title)
        _value = State(initialValue: benefit.wrappedValue.value)
        _type = State(initialValue: benefit.wrappedValue.type)
        _resetDay = State(initialValue: benefit.wrappedValue.resetDay ?? 1)
        _expiryDate = State(initialValue: benefit.wrappedValue.expiryDate ?? Date())
        _constraint = State(initialValue: benefit.wrappedValue.constraint ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("权益名称", text: $title)
                    TextField("数量或金额", text: $value)
                }
                
                Section("类型") {
                    Picker("权益类型", selection: $type) {
                        ForEach(BenefitType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if type == .periodic {
                        Stepper("每月 \(resetDay) 日重置", value: $resetDay, in: 1...31)
                    } else {
                        DatePicker("过期时间", selection: $expiryDate, displayedComponents: .date)
                    }
                }
                
                Section("使用限制") {
                    TextField("使用限制（可选）", text: $constraint)
                }
            }
            .navigationTitle("编辑权益")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        benefit.title = title
                        benefit.value = value
                        benefit.type = type
                        benefit.resetDay = type == .periodic ? resetDay : nil
                        benefit.expiryDate = type == .oneTime ? expiryDate : nil
                        benefit.constraint = constraint.isEmpty ? nil : constraint
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Preview removed for compatibility
