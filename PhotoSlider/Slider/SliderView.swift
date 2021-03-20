//
//  SliderView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import SwiftUI
import ComposableArchitecture

struct SliderView: View {
    
    let store: Store<SliderState, SliderAction>
    
    let layout = [
        GridItem(.flexible(minimum: 150)),
        GridItem(.flexible(minimum: 150))
    ]
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: layout, content: {
                            ForEach(viewStore.imageDataSource, id: \.self) { item in
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
                .navigationBarTitle("Home", displayMode: .large)
                .navigationBarItems(trailing: Button(action: {
                    viewStore.send(.logOut)
                }, label: {
                    Text("Log out")
                }))
            }
        }
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(
            store: Store(
                initialState: SliderState(),
                reducer: sliderReducer,
                environment: SliderEnvironmnet(firebaseManager: FirebaseManager())
            )
        )
    }
}
