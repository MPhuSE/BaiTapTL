//
//  Product.swift
//  hi123
//

import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let des: String
    let price: Double
    let imgURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, des, price, imgURL
    }
    
    init(id: String, name: String, des: String, price: Double, imgURL: String) {
        self.id = id
        self.name = name
        self.des = des
        self.price = price
        self.imgURL = imgURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Sản phẩm không có tên"
        self.des = try container.decodeIfPresent(String.self, forKey: .des) ?? ""
        self.imgURL = try container.decodeIfPresent(String.self, forKey: .imgURL) ?? ""
        
        // Handle various number representations safely
        if let doublePrice = try? container.decode(Double.self, forKey: .price) {
            self.price = doublePrice
        } else if let intPrice = try? container.decode(Int.self, forKey: .price) {
            self.price = Double(intPrice)
        } else if let strPrice = try? container.decode(String.self, forKey: .price), let parsed = Double(strPrice) {
            self.price = parsed
        } else {
            self.price = 0.0
        }
    }
    
    /// Định dạng giá tiền dạng VND (ví dụ: 4.000.000đ hoặc 971.290đ)
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        if price >= 10000 {
            let formatted = formatter.string(from: NSNumber(value: Int(price))) ?? "\(Int(price))"
            return "\(formatted)đ"
        } else {
            // Trường hợp dữ liệu mock API giá nhỏ (ví dụ 971.29), nhân 1000 hoặc hiển thị theo nghìn đồng
            let amount = Int(price * 1000)
            let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
            return "\(formatted)đ"
        }
    }
    
    /// Dữ liệu mẫu chuẩn từ slide thực hành UTH
    static let sample = Product(
        id: "nike-air-force-1",
        name: "Giày Nike Nam Nữ Chính Hãng - Nike Air Force 1 '07 LV8 - Màu Trắng | JapanSport HF2898-100",
        des: "Với giày chạy bộ, từng gram đều quan trọng. Đó là lý do tại sao đế giữa LIGHTSTRIKE PRO mới nhẹ hơn so với phiên bản trước. Mút foam để giữa siêu nhẹ và thoải mái này có lớp đệm đàn hồi được thiết kế để hạn chế tiêu hao năng lượng. Trong các mẫu giày tập luyện, công nghệ này được thiết kế nhằm hỗ trợ cơ bắp của vận động viên để họ có thể phục hồi nhanh hơn giữa các cuộc đua.",
        price: 4000000.0,
        imgURL: "https://mock.apidog.com/m1/890655-872447-default/v2/product"
    )
}
