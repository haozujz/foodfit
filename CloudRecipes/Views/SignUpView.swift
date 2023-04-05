//
//  SignUpView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 1/1/2023.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authModel: AuthModel
    
    @State private var isBusy = false
    @State private var showingAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
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
                    
                    Text("Create \nAccount")
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
                    
                    Button(action: {
                        isBusy = true
                        Task {
                            await authModel.signUp()
                            isBusy = false
                        }
                    }, label: {
                        CustomButtonLabel(text: authModel.buttonTimerCount == 11 ? "Send Verification Code" : "Please wait \(authModel.buttonTimerCount) seconds ... ", textColor: "white", bgColor: "accent2")
                                .padding(.horizontal, 24)
                    })
                    .disabled(isBusy || authModel.email.isEmpty || authModel.password.isEmpty || authModel.buttonTimerCount != 11)

                    CustomTextField(value: $authModel.confirmationCode, placeholder: "Verification Code", isSecure: false, imageName: "lock", color: "textColor1", opacity: 0.9)
                        .padding(.horizontal, 32)

                    Button(action: {
                        isBusy = true
                        Task {
                            do {
                                try await authModel.confirmSignUp()
                                alertMessage = "Sign up successful"
                                showingAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            } catch {
                                alertMessage = "\(error)"
                                showingAlert = true
                            }
                            isBusy = false
                        }
                    }, label: {
                        CustomButtonLabel(text: "Sign Up", textColor: "white", bgColor: "accent2")
                            .padding(.horizontal, 24)
                    })
                    .disabled(isBusy || authModel.confirmationCode.isEmpty)
                    .alert(alertMessage, isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "chevron.backward")
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(buttonTimer: .constant(Timer()), buttonTimerCount: .constant(1))
//    }
//}
