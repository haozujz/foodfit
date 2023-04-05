//
//  AuthView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 21/12/2022.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authModel: AuthModel
    
    @State private var isBusy: Bool = false
    @State private var isCreateAccountMode: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color("bg")
                    .ignoresSafeArea()
  
                VStack(spacing: 52) {
                    ZStack(alignment: .top) {
                        WaveHeader(yOffset: 0.32)
                            .fill(Color("accent3"))
                            .frame(height: 300)
                            .shadow(radius: 6)
                        
                        WaveHeader(yOffset: 0.24)
                            .fill(Color("accent3"))
                            .frame(height: 280)
                            .shadow(radius: 3)
                        
                        Text("Welcome \nBack")
                            .foregroundColor(.white)
                            .font(.system(size: 35, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 52)
                            .padding(.top, 124)
                    }
                    
                    VStack(spacing: 26) {
                        CustomTextField(value: $authModel.email, placeholder: "Email", isSecure: false,  imageName: "envelope", color: "textColor1", opacity: 0.8)
                            .padding(.horizontal, 32)
                        
                        CustomTextField(value: $authModel.password, placeholder: "Password", isSecure: true, imageName: "lock", color: "textColor1", opacity: 0.8)
                            .padding(.horizontal, 32)
                        
                        NavigationLink(destination: ResetPasswordView(), label: {
                            Text("Forgot Password?")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 32)
                        })
                        
                        Button(action: {
                            isBusy = true
//                            Task {
//                                await authModel.signIn()
//                                isBusy = false
//                            }
                            //"error("Sign in failed: AuthError: There is already a user in signedIn state. SignOut the user first before calling signIn\nRecovery suggestion: Operation performed is not a valid operation for the current auth state")"
                            
                            Task {
                                do {
                                    try await authModel.signIn()
                                } catch {
                                    alertMessage = "\(error)"
                                    showingAlert = true
                                }
                                isBusy = false
                            }
                        }, label: {
                            CustomButtonLabel(text: "Log in", textColor: "white", bgColor: "accent2")
                                .padding(.horizontal, 32)
                        })
                        .disabled(isBusy || authModel.email.isEmpty || authModel.password.isEmpty)
                        .alert(alertMessage, isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {
                                // Awkward, fix error enum later
                                print(alertMessage)
                                
                                if alertMessage.hasPrefix("error(\"Sign in failed: AuthError: There is already a user in signedIn state") {
                                    Task {
                                        await authModel.signOutLocally()
                                        print("Attempted sign out locally")
                                    }
                                }
                                
                            }
                        }
                            
                        LabelledDivider(label: "or", color: "textColor1")
                            .padding(.horizontal, 32)
                        
                        NavigationLink(destination: SignUpView(), label: {
                            CustomButtonLabel(text: "Create account", textColor: "textColor1", bgColor: "bg")
                                .padding(.horizontal, 32)
                        })
// For testing
//                        Button(action: {
//                            isBusy = true
//                            Task {
//                                await authModel.checkStatus()
//                                isBusy = false
//                            }
//                        }, label: {
//                            Text("Check Status")
//                        })
//                        .disabled(isBusy)
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
            
        }
        
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
