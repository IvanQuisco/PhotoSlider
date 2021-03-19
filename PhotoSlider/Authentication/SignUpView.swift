//
//  SignUpView.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 19/03/21.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    
    let store: Store<AuthState, AuthAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 20) {
                    TextField(
                        "Email",
                        text: viewStore.binding(
                            get:  { $0.newUser.email },
                            send: { AuthAction.signUpEmail($0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .cornerRadius(10)
                    
                    SecureField(
                        "Password",
                        text: viewStore.binding(
                            get: { $0.newUser.password },
                            send: { AuthAction.signUpPassword($0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.asciiCapable)
                    .textContentType(.password)
                    
                    SecureField(
                        "Confirm password",
                        text: viewStore.binding(
                            get: { $0.passwordConfirmation },
                            send: { AuthAction.signUpPasswordConfirmation($0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.asciiCapable)
                    .textContentType(.password)
                    
                    if !viewStore.signUpMatchingPasswords &&
                        viewStore.newUser.validCretentials &&
                        !viewStore.passwordConfirmation.isEmpty {
                        Text("Password do not match")
                            .foregroundColor(.orange)
                            .font(.caption2)
                    }
                    

                }
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button {
                        viewStore.send(.signUpButtonTapped)
                    } label: {
                        Text("Create user and log in")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                    .background(viewStore.isSignUpButtonEnabled ? Color.green : Color.gray)
                    .cornerRadius(10)
                    .disabled(!viewStore.isSignUpButtonEnabled)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("New user", displayMode: .large)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(
            store: Store(
                initialState: AuthState(),
                reducer: authReducer,
                environment: AuthEnvironment(firebaseManager: FirebaseManager())
            )
        )
    }
}

