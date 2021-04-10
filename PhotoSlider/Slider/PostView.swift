//
//  PostView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 10/04/21.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct PostView: View {
    
    let store: Store<Post, PostAction>
    
    let imageSide = UIScreen.main.bounds.width/2
    
    var body: some View {
        WithViewStore(store) { viewStore in
            WebImage(url: URL(string: viewStore.imageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSide, height: imageSide, alignment: .center)
                    .border(Color.black)
                    .clipped()
            
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            store: Store(
                initialState: Post(
                    id: "",
                    user: "",
                    description: "",
                    timestamp: 5,
                    imageURL: "",
                    likes: []
                ),
                reducer: postReducer,
                environment: PostEnvironment()
            )
        )
    }
}
