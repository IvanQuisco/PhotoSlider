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
    
    let store: Store<FormattedPost, PostAction>
    
    let imageSide = UIScreen.main.bounds.width/2
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                
                WebImage(url: URL(string: viewStore.post.imageURL))
                    .placeholder(
                        content: {
                            Image("loading")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .opacity(0.3)
                        }
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSide, height: imageSide, alignment: .center)
                    .border(Color.black)
                    .clipped()

                if viewStore.likedByUser {
                    VStack {
                        HStack {
                            ZStack {
                                Image(systemName: "heart.circle")
                                    .resizable()
                                    .frame(width: imageSide/4, height: imageSide/4, alignment: .center)
                                    .foregroundColor(Color.pink)
                                    .opacity(0.9)
                                    .background(Color(.sRGB, white: 1, opacity: 0.5))
                                    .cornerRadius(imageSide/4)
                                Text(viewStore.post.likes.count.description)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(4)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(Date(timeIntervalSince1970: viewStore.post.timestamp).formatted())
                            .font(.footnote)
                            .foregroundColor(Color.black)
                            .background(Color.white)
                    }
                }
                .padding([.bottom, .trailing], 1)
            }
            .onTapGesture(count: 2, perform: {
                viewStore.send(.evaluateLikes)
            })
            .animation(.default)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            store: Store(
                initialState: FormattedPost(
                    post: Post(
                        id: "",
                        user: "",
                        description: "",
                        timestamp: 5,
                        imageURL: "",
                        likes: []
                    ),
                    likedByUser: false),
                reducer: postReducer,
                environment: PostEnvironment()
            )
        )
    }
}


extension Date {
    func formatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
