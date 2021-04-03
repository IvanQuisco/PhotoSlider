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
                            ForEach(viewStore.imageDataSource, id: \.id) { item in
                                if let image = UIImage(data: item.data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
//                                        .cornerRadius(50)
                                        .frame(height: 150)
                                        .foregroundColor(.green)
                                } else {
                                    Image("image_placeholder")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
//                                        .cornerRadius(50)
                                        .frame(height: 150)
                                        .foregroundColor(.green)
                                }
                            }
                        })
                        .padding(10)
                    }

                    if let imageData = viewStore.selectedImageData, let image = UIImage(data: imageData) {
                        SelectedImageView(
                            image: image,
                            onUploadButtonTap: { viewStore.send(.uploadPhotoButtonTapped) },
                            onCancelButtonTap: { viewStore.send(.cancelButtonTapped) }
                        )
                        .padding(.bottom, 10)
                    } else {
                        ActionButton(
                            title: "Photo",
                            image: Image(systemName: "photo"),
                            backgroundColor: Color.blue,
                            onTap: { viewStore.send(.presentPickerButtonTapped(true)) }
                        )
                        .padding(.bottom, 10)
                    }
     
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: { $0.isPickerViewPresented },
                        send: SliderAction.presentPickerButtonTapped(false)
                    )
                ) {
                    CustomImagePickerView(
                        sourceType: .photoLibrary,
                        selectedImage: viewStore.binding(
                            get: { $0.selectedImageData },
                            send: { SliderAction.imageData($0) }
                        )
                    )
                }
                .navigationBarTitle("Home", displayMode: .large)
                .navigationBarItems(trailing:
                                        VStack {
                                            Button(action: {
                                                viewStore.send(.logOut)
                                            }, label: {
                                                Text("Log out")
                                            })
                                            Text(viewStore.currentUser?.email ?? "")
                                                .font(.caption2)
                                        }
                )
            }
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
    

    struct SelectedImageView: View {
        let image: UIImage

        var onUploadButtonTap: () -> Void
        
        var onCancelButtonTap: () -> Void
        
        let side: CGFloat = 200

        var body: some View {
            VStack(spacing: 5) {
                Text("Selected Image:")
                    .font(.footnote)
                
                HStack {
                    Spacer()
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: side, maxWidth: side, minHeight: side, maxHeight: side)
                    
                    Spacer()
                }
                
                HStack {
                    ActionButton(
                        title: "Cancel",
                        image: Image(systemName: "trash"),
                        backgroundColor: Color.red,
                        onTap: { onCancelButtonTap() }
                    )
                    
                    ActionButton(
                        title: "Upload",
                        image: Image(systemName: "cloud"),
                        backgroundColor: Color.green,
                        onTap: { onUploadButtonTap() }
                    )
                }
            }
        }
    }

    struct ActionButton: View {
        var title: String
        var image: Image
        var backgroundColor: Color
        var onTap: () -> Void
        
        var body: some View {
            Button(action: {
                onTap()
            }) {
                HStack {
                    image
                        .font(.system(size: 20))
                    
                    Text(title)
                        .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
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
                environment: .default
            )
        )
    }
}
