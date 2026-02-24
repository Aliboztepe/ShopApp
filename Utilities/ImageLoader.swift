import Foundation
import UIKit
import SDWebImage

class ImageLoader {
    
    // MARK: - Singleton
    static let shared = ImageLoader()
    private init() {
        configureSDWebImage()
    }
    
    // MARK: - Configuration
    private func configureSDWebImage() {
        SDImageCache.shared.config.maxMemoryCost = 100 * 1024 * 1024
        SDImageCache.shared.config.maxDiskSize = 200 * 1024 * 1024
        SDImageCache.shared.config.maxDiskAge = 60 * 60 * 24 * 7
        SDWebImageDownloader.shared.config.downloadTimeout = 15.0
    }
    
    // MARK: - Load Image
    func loadImage(from urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
        imageView.image = placeholder ?? UIImage(systemName: "photo")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.sd_setImage(
            with: url,
            placeholderImage: placeholder ?? UIImage(systemName: "photo"),
            options: [.retryFailed, .progressiveLoad],
            completed: { image, error, cacheType, imageURL in
                if let error = error {
                    print("Image load error: \(error.localizedDescription)")
                } else if let image = image {
                    print("Image loaded: \(cacheType == .memory ? "Memory" : cacheType == .disk ? "Disk" : "Network")")
                }
            }
        )
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
    }
    
    // MARK: - Cache Info
    func getCacheSize(completion: @escaping (String) -> Void) {
        SDImageCache.shared.calculateSize { fileCount, totalSize in
            let sizeMB = Double(totalSize) / 1024.0 / 1024.0
            let info = String(format: "%.2f MB (%d files)", sizeMB, fileCount)
            completion(info)
        }
    }
}
