//
//  OCRParser.swift
//  vipPolice
//
//  本地规则解析引擎
//

import Foundation
import Vision
import UIKit

class OCRParser {
    
    /// 从图片中识别文字
    static func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        // 设置识别语言为简体中文和英文
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    /// 解析 OCR 文本，提取会员账号信息
    static func parseOCRText(text: String) -> MemberAccount? {
        let lines = text.components(separatedBy: .newlines)
        
        // 1. 识别平台
        guard let platform = detectPlatform(from: lines) else {
            return nil
        }
        
        // 2. 提取权益信息
        let benefits = extractBenefits(from: lines, platform: platform)
        
        guard !benefits.isEmpty else {
            return nil
        }
        
        // 3. 创建会员账号
        return MemberAccount(
            platform: platform,
            benefits: benefits
        )
    }
    
    // MARK: - Private Methods
    
    /// 检测平台
    private static func detectPlatform(from lines: [String]) -> Platform? {
        let fullText = lines.joined(separator: " ")
        
        for platform in Platform.allCases where platform != .custom {
            for keyword in platform.keywords {
                if fullText.contains(keyword) {
                    return platform
                }
            }
        }
        
        return nil
    }
    
    /// 提取权益信息
    private static func extractBenefits(from lines: [String], platform: Platform) -> [Benefit] {
        var benefits: [Benefit] = []
        
        // 遍历每一行，寻找权益信息
        for (index, line) in lines.enumerated() {
            // 提取红包/优惠券金额
            if let benefit = extractMoneyBenefit(from: line, nearbyLines: getNearbyLines(lines, index: index)) {
                benefits.append(benefit)
            }
            
            // 提取券的数量
            if let benefit = extractCouponBenefit(from: line, nearbyLines: getNearbyLines(lines, index: index)) {
                benefits.append(benefit)
            }
            
            // 提取积分/豆
            if let benefit = extractPointsBenefit(from: line, platform: platform, nearbyLines: getNearbyLines(lines, index: index)) {
                benefits.append(benefit)
            }
        }
        
        return benefits
    }
    
    /// 获取附近的行（用于上下文分析）
    private static func getNearbyLines(_ lines: [String], index: Int, range: Int = 2) -> [String] {
        let start = max(0, index - range)
        let end = min(lines.count - 1, index + range)
        return Array(lines[start...end])
    }
    
    /// 提取金额类权益（红包、优惠券）
    private static func extractMoneyBenefit(from line: String, nearbyLines: [String]) -> Benefit? {
        // 匹配金额：¥数字 或 数字元
        let moneyPattern = #"[¥￥]?\s*(\d+(?:\.\d+)?)\s*元?"#
        
        guard let regex = try? NSRegularExpression(pattern: moneyPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let amountRange = Range(match.range(at: 1), in: line) else {
            return nil
        }
        
        let amount = String(line[amountRange])
        
        // 判断权益类型
        var title = "优惠券"
        if line.contains("红包") {
            title = "红包"
        } else if line.contains("券") {
            title = "优惠券"
        } else if line.contains("免邮") {
            title = "免邮券"
        }
        
        // 提取使用限制
        let constraint = extractConstraint(from: nearbyLines)
        
        // 提取过期时间
        let expiryDate = extractExpiryDate(from: nearbyLines)
        
        return Benefit(
            title: title,
            type: expiryDate != nil ? .oneTime : .periodic,
            value: "¥\(amount)",
            resetDay: nil,
            expiryDate: expiryDate,
            constraint: constraint
        )
    }
    
    /// 提取券数量类权益
    private static func extractCouponBenefit(from line: String, nearbyLines: [String]) -> Benefit? {
        // 匹配：数字张券、数字个券
        let couponPattern = #"(\d+)\s*[张个]\s*[券卡]"#
        
        guard let regex = try? NSRegularExpression(pattern: couponPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let countRange = Range(match.range(at: 1), in: line) else {
            return nil
        }
        
        let count = String(line[countRange])
        
        var title = "优惠券"
        if line.contains("免邮") {
            title = "免邮券"
        } else if line.contains("满减") {
            title = "满减券"
        }
        
        let constraint = extractConstraint(from: nearbyLines)
        let expiryDate = extractExpiryDate(from: nearbyLines)
        
        return Benefit(
            title: title,
            type: expiryDate != nil ? .oneTime : .periodic,
            value: "\(count)张",
            resetDay: nil,
            expiryDate: expiryDate,
            constraint: constraint
        )
    }
    
    /// 提取积分/豆类权益
    private static func extractPointsBenefit(from line: String, platform: Platform, nearbyLines: [String]) -> Benefit? {
        var pointsPattern = ""
        var title = ""
        
        switch platform {
        case .jingdong:
            pointsPattern = #"(\d+)\s*京豆"#
            title = "京豆"
        case .taobao:
            pointsPattern = #"(\d+)\s*淘气值"#
            title = "淘气值"
        default:
            pointsPattern = #"(\d+)\s*积分"#
            title = "积分"
        }
        
        guard let regex = try? NSRegularExpression(pattern: pointsPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let pointsRange = Range(match.range(at: 1), in: line) else {
            return nil
        }
        
        let points = String(line[pointsRange])
        
        return Benefit(
            title: title,
            type: .periodic,
            value: points,
            resetDay: 1,  // 默认每月1日重置
            expiryDate: nil,
            constraint: nil
        )
    }
    
    /// 提取使用限制
    private static func extractConstraint(from lines: [String]) -> String? {
        let fullText = lines.joined(separator: " ")
        
        // 常见限制关键词
        let constraintPatterns = [
            #"限[自营|指定].*?使用"#,
            #"满\s*(\d+).*?可用"#,
            #"仅限.*?使用"#,
            #"不含.*?商品"#
        ]
        
        for pattern in constraintPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: fullText, range: NSRange(fullText.startIndex..., in: fullText)),
               let range = Range(match.range, in: fullText) {
                return String(fullText[range])
            }
        }
        
        return nil
    }
    
    /// 提取过期时间
    private static func extractExpiryDate(from lines: [String]) -> Date? {
        let fullText = lines.joined(separator: " ")
        
        // 匹配日期格式：2024-12-31、2024.12.31、2024/12/31
        let datePattern = #"(?:有效期至|到期时间|过期时间)?[:：]?\s*(\d{4})[-./年](\d{1,2})[-./月](\d{1,2})"#
        
        guard let regex = try? NSRegularExpression(pattern: datePattern),
              let match = regex.firstMatch(in: fullText, range: NSRange(fullText.startIndex..., in: fullText)),
              let yearRange = Range(match.range(at: 1), in: fullText),
              let monthRange = Range(match.range(at: 2), in: fullText),
              let dayRange = Range(match.range(at: 3), in: fullText) else {
            return nil
        }
        
        let year = Int(fullText[yearRange]) ?? 0
        let month = Int(fullText[monthRange]) ?? 0
        let day = Int(fullText[dayRange]) ?? 0
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return Calendar.current.date(from: components)
    }
}
