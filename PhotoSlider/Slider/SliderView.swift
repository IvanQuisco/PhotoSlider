//
//  SliderView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct SliderView: View {
    
    let store: Store<SliderState, SliderAction>

    let imageSide = UIScreen.main.bounds.width/2
    
    let layout = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width/2)),
        GridItem(.flexible(minimum: UIScreen.main.bounds.width/2))
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            LoadingView(
                isShowing: viewStore.binding(
                    get: { $0.isActivityPresented },
                    send: { _ in SliderAction.stopActivity }
                ), content: {
                NavigationView {
                    VStack {
                        if viewStore.photosPresented == .user {
                            Text(" You can not like your own photos. 😉 ")
                        }
                        
                        ScrollView {
                            LazyVGrid(columns: layout) {
                                ForEachStore(
                                    self.store.scope(
                                        state: \.filteredPosts,
                                        action: SliderAction.post(index:action:)
                                    ),
                                    content: PostView.init(store:)
                                )
                            }
                        }

                        if viewStore.photosPresented == .all {
                            if let imageData = viewStore.selectedImageData, let image = UIImage(data: imageData) {
                                SelectedImageView(
                                    image: image,
                                    onUploadButtonTap: { viewStore.send(.uploadPhotoButtonTapped) },
                                    onCancelButtonTap: { viewStore.send(.cancelButtonTapped) },
                                    onImageTap: { viewStore.send(.presentPickerButtonTapped(true)) }
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
                    .navigationBarTitle(viewStore.photosPresented == .all ? "Home" : (viewStore.currentUser?.email) ?? "User", displayMode: .large)
                    .navigationBarItems(trailing:
                                            HStack(spacing: 30) {
                                                Button(action: {
                                                    viewStore.send(.switchPhotosPresentation)
                                                }, label: {
                                                    Image(systemName: viewStore.photosPresented == .all ? "person.fill" : "person.3.fill")
                                                })
                                                .disabled(viewStore.selectedImageData != nil)

                                                Button(action: {
                                                    viewStore.send(.logOut)
                                                }, label: {
                                                    Image(systemName: "xmark.seal.fill")
                                                })
                                            }
                    )
                }
            })
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
            .animation(.default)
        }
    }
    

    struct SelectedImageView: View {
        let image: UIImage

        var onUploadButtonTap: () -> Void
        
        var onCancelButtonTap: () -> Void
        
        var onImageTap: () -> Void
        
        let side: CGFloat = 200

        var body: some View {
            VStack(spacing: 5) {
                Divider()
                
                Text("Selected Image:")
                    .font(.footnote)
                
                HStack {
                    Spacer()
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .border(Color.green, width: 4)
                        .frame(minWidth: side, maxWidth: side, minHeight: side, maxHeight: side)
                        .onTapGesture { onImageTap() }
                    
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
