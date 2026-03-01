//
//  ImagePickerView.swift
//  vipPolice
//
//  图片选择器 - 用于选择截图并进行 OCR 识别
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var recognizedText = ""
    @State private var parsedAccount: MemberAccount?
    @State private var showingVerification = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isProcessing {
                    processingView
                } else if let image = selectedImage {
                    imagePreviewView(image: image)
                } else {
                    photoPickerView
                }
            }
            .navigationTitle("添加会员截图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingVerification) {
                if let account = parsedAccount {
                    VerificationView(account: account) { verifiedAccount in
                        dataManager.addAccount(verifiedAccount)
                        dismiss()
                    }
                }
            }
            .alert("识别失败", isPresented: .constant(errorMessage != nil)) {
                Button("重新选择") {
                    errorMessage = nil
                    selectedImage = nil
                    selectedItem = nil
                }
                Button("取消", role: .cancel) {
                    dismiss()
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - Photo Picker View
    
    private var photoPickerView: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("选择会员页面截图")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("支持识别淘宝、京东、美团等平台的会员权益信息")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("从相册选择", systemImage: "photo.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await processImage(image)
                    }
                }
            }
        }
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("正在识别中...")
                .font(.headline)
            
            Text("请稍候，正在分析图片内容")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Image Preview View
    
    private func imagePreviewView(image: UIImage) -> some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .shadow(radius: 5)
            
            Text("图片已选择")
                .font(.headline)
            
            Button {
                selectedImage = nil
                selectedItem = nil
            } label: {
                Label("重新选择", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Process Image
    
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        
        OCRParser.recognizeText(from: image) { text in
            DispatchQueue.main.async {
                if let text = text {
                    recognizedText = text
                    
                    // 解析文本
                    if let account = OCRParser.parseOCRText(text: text) {
                        parsedAccount = account
                        isProcessing = false
                        showingVerification = true
                    } else {
                        isProcessing = false
                        errorMessage = "无法识别图片中的会员信息，请确保截图包含平台名称和权益信息。"
                    }
                } else {
                    isProcessing = false
                    errorMessage = "图片识别失败，请重试。"
                }
            }
        }
    }
}

#Preview {
    ImagePickerView()
        .environmentObject(DataManager())
}
