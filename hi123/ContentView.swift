//
//  ContentView.swift
//  hi123
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background màu xám nhạt tinh tế theo giao diện iOS
                Color(red: 0.96, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Top Header (Product detail + nút back cyan)
                    headerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                    
                    ScrollView {
                        VStack(spacing: 18) {
                            // MARK: - Thẻ Card Sản Phẩm (Giống 100% hình mẫu slide)
                            productCard
                            
                            // MARK: - Endpoint Badge thông tin bài thực hành UTH
                            apiInfoBadge
                            
                            // MARK: - Hiển thị lỗi nếu có (Xử lý ngoại lệ bất đồng bộ)
                            if let error = viewModel.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .lineLimit(2)
                                    Spacer()
                                    Button("Thử lại") {
                                        Task {
                                            await viewModel.fetchProduct()
                                        }
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.blue)
                                }
                                .padding(10)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(10)
                            }
                            
                            // MARK: - Nút Loading xử lý bất đồng bộ (Async/Await)
                            asyncLoadingButton
                            
                            // MARK: - Nút chuyển đổi xem mẫu Slide hoặc API Live
                            modeSwitchSection
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.fetchProduct()
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                // Tự động gọi API bất đồng bộ khi màn hình xuất hiện lần đầu
                if viewModel.product == nil {
                    await viewModel.fetchProduct()
                }
            }
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: 14) {
            // Nút Back hình tròn màu cyan/xanh dương giống hệt slide
            Button(action: {
                // Action khi bấm back (nếu có navigation)
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.18, green: 0.72, blue: 0.94))
                        .frame(width: 38, height: 38)
                        .shadow(color: Color(red: 0.18, green: 0.72, blue: 0.94).opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Tiêu đề "Product detail"
            Text("Product detail")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(Color(red: 0.12, green: 0.23, blue: 0.38))
            
            Spacer()
        }
    }
    
    // MARK: - Product Card
    private var productCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Container màu cam chứa hình ảnh sản phẩm
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.92, green: 0.33, blue: 0.18))
                    .frame(height: 250)
                
                if viewModel.isLoading && viewModel.product == nil {
                    VStack(spacing: 10) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.4)
                        Text("Đang tải hình ảnh...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else if viewModel.isShowingSample {
                    // Hiển thị ảnh giày mẫu từ slide
                    Image("sample_shoe")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .padding(8)
                } else if let product = viewModel.product {
                    // Tải ảnh từ API bất đồng bộ qua AsyncImage
                    AsyncImage(url: URL(string: product.imgURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 210)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 4)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case .failure:
                            // Fallback nếu ảnh mock API bị lỗi
                            Image("sample_shoe")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .padding(8)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            
            // Thông tin chi tiết sản phẩm
            VStack(alignment: .leading, spacing: 6) {
                // Tên sản phẩm
                Text(viewModel.product?.name ?? "Đang nạp tên sản phẩm...")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.15, blue: 0.20))
                    .lineLimit(3)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
                
                // Giá sản phẩm (màu đỏ đậm như slide)
                Text(viewModel.product != nil ? "Giá: \(viewModel.product!.formattedPrice)" : "Giá: ---")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.84, green: 0.15, blue: 0.15))
                    .padding(.top, 2)
                
                // Mô tả chi tiết sản phẩm
                Text(viewModel.product?.des ?? "Đang tải mô tả sản phẩm...")
                    .font(.system(size: 12.5))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
                    .padding(.bottom, 14)
            }
            .padding(.horizontal, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
    
    // MARK: - Nút Loading Xử Lý Bất Đồng Bộ
    private var asyncLoadingButton: some View {
        Button(action: {
            Task {
                await viewModel.fetchProduct()
            }
        }) {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    // Spinner loading quay tròn khi đang xử lý bất đồng bộ
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.05)
                    
                    Text("Đang tải dữ liệu bất đồng bộ...")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tải lại dữ liệu (Async API)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: viewModel.isLoading
                        ? [Color.gray, Color.gray.opacity(0.8)]
                        : [Color(red: 0.18, green: 0.72, blue: 0.94), Color(red: 0.05, green: 0.50, blue: 0.88)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: viewModel.isLoading
                    ? Color.clear
                    : Color(red: 0.18, green: 0.72, blue: 0.94).opacity(0.35),
                radius: 8,
                x: 0,
                y: 4
            )
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
        }
        .disabled(viewModel.isLoading) // Ngăn người dùng spam khi đang gọi mạng bất đồng bộ
    }
    
    // MARK: - Chuyển đổi chế độ (Live API vs Slide Sample)
    private var modeSwitchSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.fetchProduct()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 12))
                    Text("Gọi API Live")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(!viewModel.isShowingSample ? .blue : .secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(!viewModel.isShowingSample ? Color.blue.opacity(0.12) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(!viewModel.isShowingSample ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            Button(action: {
                viewModel.showSampleData()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 12))
                    Text("Dữ liệu mẫu Slide")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(viewModel.isShowingSample ? .orange : .secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.isShowingSample ? Color.orange.opacity(0.12) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.isShowingSample ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - API Info Badge
    private var apiInfoBadge: some View {
        HStack(spacing: 6) {
            Text("GET")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(red: 0.15, green: 0.65, blue: 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(viewModel.apiURLString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
