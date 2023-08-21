//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 16/08/2023.
//

import SwiftUI
import FirebaseFirestore




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
                    .contextMenu {
                        Button("Add to favorites") {
                            viewModel.addUserFavoriteProduct(productId: product.id)
                        }
                    }
                
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
