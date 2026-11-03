//
//  ProductViewModel.swift
//  hi123
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ProductViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isShowingSample: Bool = false
    
    // API endpoint theo đề bài
    let apiURLString = "https://mock.apidog.com/m1/890655-872447-default/v2/product"
    
    /// Hàm xử lý bất đồng bộ (Asynchronous) gọi GET API để lấy thông tin sản phẩm
    func fetchProduct() async {
        guard !isLoading else { return }
        
        isShowingSample = false
        isLoading = true
        errorMessage = nil
        
        do {
            guard let url = URL(string: apiURLString) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 15
            
            // Xử lý bất đồng bộ sử dụng Swift Concurrency (async/await)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
            }
            
            // Thêm độ trễ nhẹ (0.4s) nếu mạng quá nhanh để người dùng quan sát rõ hiệu ứng nút loading
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            let decodedProduct = try JSONDecoder().decode(Product.self, from: data)
            self.product = decodedProduct
        } catch {
            print("Lỗi khi tải API: \(error)")
            self.errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Chuyển đổi sang dữ liệu mẫu đúng hình ảnh slide thực hành
    func showSampleData() {
        self.isShowingSample = true
        self.product = Product.sample
        self.errorMessage = nil
    }
}
