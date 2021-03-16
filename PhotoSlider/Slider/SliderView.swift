//
//  SliderView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import SwiftUI

struct SliderView: View {
    
    let data = Array(1...10).map { "item \($0)" }
    
    let layout = [
        GridItem(.flexible(minimum: 150)),
        GridItem(.flexible(minimum: 150))
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: layout, content: {
                    ForEach(data, id: \.self) { item in
                        Image("image_placeholder")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(50)
                            .frame(height: 150)
                            .foregroundColor(.green)
                    }
                })
                .padding(10)
            }
            Button("Add") {
                print("TODO: open image picker")
            }
        }
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView()
    }
}
