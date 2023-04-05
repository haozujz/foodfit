//
//  CachedAsyncImage.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 5/2/2023.
//

import Foundation
import SwiftUI

@MainActor
struct CachedAsyncImage<Content: View>: View{
    @EnvironmentObject private var imagesModel: ImagesModel
    private var key: String
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    @State private var url: URL?
    @State private var retries: Int = 0
    
    init (
        key: String,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.key = key
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View{
        if let cached = imagesModel.imageCache[key] {
            //let _ = print("loading image from cache: \(key)")
            content(.success(cached))
        } else if url == nil {
            //let _ = print("requesting image url from key: \(key)")
            ProgressView()
                .task {
                    do {
                        let newURL = try await imagesModel.getImageUrl(key: key)
                        DispatchQueue.main.async {
                            url = newURL
                        }
                    } catch {
                        print("\(error)")
                    }
                }
        } else {
            let _ = print("loading image from url")
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            
            imagesModel.imageCache[key] = image
        } else if case .failure = phase {
            //print("Image load from url failed")
            
            // Re-fetch url from key, eg. if token expired
            if retries < 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    url = nil
                    retries += 1
                }
            }
        }
        return content(phase)
    }
}

//fileprivate class ImageCache {
//    static private var cache: [String: Image] = [:]
//    static subscript(key: String) -> Image? {
//        get {
//            ImageCache.cache[key]
//        }
//        set {
//            ImageCache.cache[key] = newValue
//        }
//    }
//}
