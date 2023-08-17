//
//  ProductCellView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 16/08/2023.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack (alignment: .top, spacing: 20) {
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
                
            } placeholder: {
                
                ProgressView()
            }
            .frame(width: 75, height: 75)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x:0, y:2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title ?? "n/a")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Price: $" + String(product.price ?? 0))
                Text("Rating: " + String(product.rating ?? 0))
                Text("Category: " + (product.category ?? "n/a"))
                Text("Brand: " + (product.brand ?? "n/a"))
            }
            
            .font(.callout)
            .foregroundColor(.secondary)
        }    }
}

struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellView(product: Product(
            id: 5,
            title: "Test",
            description: "Test",
            price: 15,
            discountPercentage: 15,
            rating: 15,
            stock: 15,
            brand: "kilo",
            category: "phone",
            thumbnail: "th",
            images: [])
        )
    }
}
