//
//  ImagesModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import Foundation
import SwiftUI
import Amplify

@MainActor
final class ImagesModel: ObservableObject {
    @Published var avatarURL: URL?
    
    enum imageFetchError: Error {
        case error(String)
    }
    
    var imageCache = ImageCache()
    class ImageCache {
        var cache: [String: Image] = [:]
        subscript(key: String) -> Image? {
            get {
                cache[key]
            }
            set {
                cache[key] = newValue
            }
        }
    }
    
    func downloadImage(key: String) async -> UIImage? {
        let downloadTask = Amplify.Storage.downloadData(key: key)
        Task {
            for await _ in await downloadTask.progress {
                //print("Progress: \(progress)")
            }
        }
        
        do {
            let data = try await downloadTask.value
            print("Fetched Image data: \(data)")
            
            return UIImage(data: data)
        } catch(let error) {
            print("Error: \(error)")
            return nil
        }
    }
    
    func getImageUrl(key: String) async throws -> URL {
        let downloadTask = Amplify.Storage.downloadData(key: key)
        Task {
            for await _ in await downloadTask.progress {
                //print("Progress: \(progress)")
            }
        }
        
        do {
            let url = try await Amplify.Storage.getURL(key: key)
            print("Fetched Image Url for key: \(key)")
            //token can expire
            return url
        } catch(let error) {
            print("Error: \(error)")
            throw imageFetchError.error("Image URL fetch failed with error \(error)")
        }
    }
    
    func uploadImage(key: String, image: UIImage) async {
        let data = image.jpegData(compressionQuality: 1)!
        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: data
        )
        Task {
            for await progress in await uploadTask.progress {
                print("Progress: \(progress)")
            }
        }
        
        do {
            let value = try await uploadTask.value
            print("Completed: \(value)")
        } catch(let error) {
            print("Error: \(error)")
        }
    }
    
    func deleteImage(key: String) async {
        do {
            let removedKey = try await Amplify.Storage.remove(key: "myKey")
            print("Deleted \(removedKey)")
        } catch(let error) {
            print("Error: \(error)")
        }
        
//        let sink = Amplify.Publisher.create {
//            try await Amplify.Storage.remove(key: key)
//        }.sink {
//            if case let .failure(error) = $0 {
//                print("Failed: \(error)")
//            }
//        } receiveValue: { removedKey in
//            print("Deleted \(removedKey)")
//        }
    }
}
