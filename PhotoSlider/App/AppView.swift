//
//  AppView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                switch viewStore.uiState {
                case .slider:
                    SliderView()
                default:
                    LoginView()
                }
            }
            .onAppear(perform: {
                viewStore.send(.validateSession)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(uiState: .login),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
