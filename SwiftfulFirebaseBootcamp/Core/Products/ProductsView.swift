//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 16/08/2023.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProductsViewModel: ObservableObject {
    
    
    // function to download product from the site and insert them into our DB
    
//    func downloadProductsAndUploadToFirebase() {
//        // https://dummyjson.com/products
//
//        guard let url = URL(string: "https://dummyjson.com/products") else { return }
//
//        Task {
//            do {
//                let(data, response) = try await URLSession.shared.data(from:url)
//                let products = try JSONDecoder().decode(ProductArray.self, from: data)
//                let productArray = products.products
//
//                for product in productArray {
//                    print("Product.rating: \(String(describing: product.rating))")
//                    try? await ProductsManager.shared.uploadProduct(product: product)
//                }
//
//                print("Success: \(products.products.count)")
//            } catch {
//                print("error downloading products")
//            }
//        }
//
//    }
    
    @Published private(set) var products: [Product] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
    
    
//    func getAllProducts() async throws {
//        self.products = try await ProductsManager.shared.getAllProducts()
//
//    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
        
//        switch option {
//        case .noFilter:
//            self.products = try await ProductsManager.shared.getAllProducts()
//        case .priceHigh:
//            // query DB
//            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: true)
//
//        case .priceLow:
//            self.products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: false)
//
//        }
        
    }
    
    
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey: String? {
            if self == .noCategory {
                return nil
            }
            return self.rawValue
        }
        
    }
    
    
    func categorySelected(option: CategoryOption) async throws {
        
        self.selectedCategory = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
        
//        switch option {
//        case .noCategory:
//            self.products = try await ProductsManager.shared.getAllProducts()
//        case .smartphones, .laptops, .fragrances:
//            self.products = try await ProductsManager.shared.getAllProductsForCategory(category: option.rawValue)
//        }
        
    }
    
    func getProducts() {

        Task {
           let (newProducts, lastDocument) = try await ProductsManager.shared
                .getAllProducts(priceDescending: selectedFilter?.priceDescending,
                                forCategory: selectedCategory?.categoryKey,
                                count: 10,
                                lastDocument: lastDocument)
            
            self.products.append(contentsOf: newProducts)
            
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            
            

        }
    }
    
    func getProductsCount() {
        Task {
            let count = try await ProductsManager.shared.getAllProductsCount()
            print("ALL PRODUCT COUNT: \(count)")
        }
    }
    
//    func getProductsByRating() {
//        print("getProductsByRating")
//        Task {
////            let newProducts = try await ProductsManager.shared.getProductsByRating(count: 3, lastRating: self.products.last?.rating)
//
//            let (newProducts, lastDocument) = try await ProductsManager.shared
//                .getProductsByRating(count: 3, lastDocument: lastDocument)
//            self.products.append(contentsOf: newProducts)
//            self.lastDocument = lastDocument
//
//        }
//
//    }
    
    
    
}


struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            /*
            Button("Fetch more objects") {
                viewModel.getProductsByRating()
            }
            */
            
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                
                if product == viewModel.products.last {
                    ProgressView()
                        .onAppear {
                            print("fetching more products")
                            viewModel.getProducts()
                        }
                }
                
            }
        }
            .navigationTitle("Products")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "None")") {
                        ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                            Button(filterOption.rawValue) {
                                Task {
                                   try? await viewModel.filterSelected(option:filterOption)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "None")") {
                        ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { categoryOption in
                            Button(categoryOption.rawValue) {
                                Task {
                                    try? await viewModel.categorySelected(option:categoryOption)
                                }
                            }
                        }
                    }
                }
            })

            .onAppear {
                viewModel.getProductsCount()
                viewModel.getProducts()
                //viewModel.downloadProductsAndUploadToFirebase()
            }
        
        /*
            .onAppear {
                // we only did this one to fill our DB
                //viewModel.downloadProductsAndUploadToFirebase()
                
                
            }
         */
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductsView()
        }
        
    }
}
