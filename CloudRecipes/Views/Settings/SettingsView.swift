//
//  SettingsView.swift
//  scrap
//
//  Created by Joseph Zhu on 8/1/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authModel: AuthModel
    @EnvironmentObject private var imagesModel: ImagesModel

    @State private var pickedImage: UIImage?
    @State private var isUploadingAndFetchingImage = false
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("bg")
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ZStack {
                    ZStack(alignment: .top) {
                        WaveHeader(yOffset: 0.32)
                            .fill(Color("accent3"))
                            .frame(height: 200)
                            .shadow(radius: 6)

                        WaveHeader(yOffset: 0.24)
                            .fill(Color("accent3"))
                            .frame(height: 180)
                            .shadow(radius: 4)
                    }
                    
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            if !isUploadingAndFetchingImage, let url = imagesModel.avatarURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ZStack{
                                            ProgressView()
                                                .scaleEffect(4)
                                                .opacity(0.4)
                                            
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 100))
                                                .padding(20)
                                                .scaledToFill()
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        ZStack{
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 100))
                                                .padding(20)
                                                .scaledToFill()
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .task {
                                            do {
                                                let url = try await imagesModel.getImageUrl(key: authModel.signedInEmail)
                                                DispatchQueue.main.async {
                                                    imagesModel.avatarURL = url
                                                }
                                            } catch {
                                                print("\(error)")
                                            }
                                        }
                                    default:
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 100))
                                            .padding(20)
                                            .scaledToFill()
                                    }
                                }
                                .frame(width: 160, height: 160)
                            } else {
                                ZStack {
                                    if !isUploadingAndFetchingImage {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 100))
                                            .padding(20)
                                            .scaledToFill()
                                    } else {
                                        ProgressView()
                                            .scaleEffect(3)
                                    }
                                }
                                .frame(width: 160, height: 160)
                            }
                        }
                        .background(.white)
                        .clipShape(Circle())
                        .padding()
                        .shadow(radius: 16)
                        
                        Button(action: {
                            showingImagePicker = true
                        }, label: {
                            Image(systemName: "pencil")
                                .frame(width: 1.8, height: 1.8)
                                .font(.title2)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color("accent1"))
                                .clipShape(Circle())
                        })
                        .shadow(radius: 2)
                        .offset(x:-12, y:-16)
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(pickedImage: $pickedImage)
                        }
                    }
                    .offset(y: 60)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .onChange(of: pickedImage ?? nil) { _ in
                    guard let newImage = pickedImage else { return }
                    
                    Task {
                        isUploadingAndFetchingImage = true
                        print("uploading image")
                        // Slow, ~15sec
                        let _ = await imagesModel.uploadImage(key: authModel.signedInEmail, image: newImage)

                        print("downloading image")
                        let url = try await imagesModel.getImageUrl(key: authModel.signedInEmail)
                        
                        DispatchQueue.main.async {
                            imagesModel.avatarURL = url
                        }
                        isUploadingAndFetchingImage = false
                    }
                }
                
                VStack(spacing: 40) {
                    CustomTextField(value: $authModel.signedInEmail, placeholder: "", isSecure: false, imageName: "envelope", color: "black", opacity: 0.8)
                        .disabled(true)
                
                    NavigationLink(destination: {
                        ResetPasswordView()
                    }, label: {
                        CustomButtonLabel(text: "Reset Password", textColor: "textColor1", bgColor: "bg")
                    })
                    
                    Button(action: {
                        Task {
                            await authModel.signOutLocally()
                        }
                    }, label: {
                        CustomButtonLabel(text: "Log out", textColor: "white", bgColor: "accent2")
                    })
                }
                .padding(.top, 140)
                .padding(.horizontal, 32)
            }
            .ignoresSafeArea(.all, edges: [.top])
        }
    }
}

struct settingsN_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .ignoresSafeArea()
    }
}
