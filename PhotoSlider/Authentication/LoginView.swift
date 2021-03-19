//
//  LoginView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    let store: Store<AuthState, AuthAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    VStack(spacing: 20) {
                        TextField(
                            "Email",
                            text: viewStore.binding(
                                get:  { $0.loginUser.email },
                                send: { AuthAction.loginEmail($0) }
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .cornerRadius(10)
                        
                        SecureField(
                            "Password",
                            text: viewStore.binding(
                                get: { $0.loginUser.password },
                                send: { AuthAction.loginPassword($0) }
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.asciiCapable)
                        .textContentType(.password)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button {
                            viewStore.send(.loginButtonTapped)
                        } label: {
                            Text("Log In")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background( viewStore.isLogInButtonEnabled ? Color.green : Color.gray)
                        .cornerRadius(10)
                        .disabled(!viewStore.isLogInButtonEnabled)
                        
                        NavigationLink(
                            destination: SignUpView(store: store),
                            label: { Text("Sign Up") }
                        )
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(Color.pink)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 30)

                }
                .padding(.horizontal, 30)
                .navigationBarTitle("Login", displayMode: .large)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: Store(
                initialState: AuthState(),
                reducer: authReducer,
                environment: AuthEnvironment(firebaseManager: FirebaseManager())
            )
        )
    }
}
