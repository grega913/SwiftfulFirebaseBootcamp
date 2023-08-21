//
//  OnfirstAppearViewModifier.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by gs on 21/08/2023.
//

import Foundation
import SwiftUI

//modifier on the existing view
struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didAppear {
                    print("didAppear = false")
                    perform?()
                    didAppear = true
                }
            }
    }
    
    
}


extension View {
    
    func onfirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}

