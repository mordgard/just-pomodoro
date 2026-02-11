import Foundation
import CoreGraphics
import ImageIO
import CoreServices

// Generate a simple tomato icon for the app
let iconSizes = [
    (16, "16x16"),
    (32, "32x32"),
    (64, "32x32@2x"),
    (128, "128x128"),
    (256, "128x128@2x"),
    (512, "256x256@2x"),
    (1024, "512x512@2x")
]

func generateTomatoIcon(size: Int) -> CGImage? {
    let scale = CGFloat(size) / 1024.0
    let width = CGFloat(size)
    let height = CGFloat(size)
    
    // Create context
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return nil
    }
    
    // Fill background with tomato red
    let backgroundColor = CGColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1.0)
    context.setFillColor(backgroundColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    
    // Add rounded corners mask
    let cornerRadius: CGFloat = 180.0 * scale
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    context.addPath(path)
    context.clip()
    
    // Redraw background
    context.setFillColor(backgroundColor)
    context.fill(rect)
    
    // Draw green stem on top
    let stemColor = CGColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
    context.setFillColor(stemColor)
    
    // Stem base
    let stemWidth: CGFloat = 120.0 * scale
    let stemHeight: CGFloat = 80.0 * scale
    let stemX = (width - stemWidth) / 2
    let stemY = height * 0.15
    context.fillEllipse(in: CGRect(x: stemX, y: stemY, width: stemWidth, height: stemHeight))
    
    // Stem leaves
    context.setFillColor(stemColor)
    let leafSize: CGFloat = 60.0 * scale
    // Left leaf
    context.fillEllipse(in: CGRect(x: stemX - leafSize * 0.5, y: stemY + stemHeight * 0.3, width: leafSize, height: leafSize))
    // Right leaf
    context.fillEllipse(in: CGRect(x: stemX + stemWidth - leafSize * 0.5, y: stemY + stemHeight * 0.3, width: leafSize, height: leafSize))
    // Top leaf
    context.fillEllipse(in: CGRect(x: stemX + stemWidth * 0.25, y: stemY - leafSize * 0.5, width: leafSize, height: leafSize))
    
    // Draw highlight/shine on tomato
    let highlightColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    context.setFillColor(highlightColor)
    let highlightRect = CGRect(
        x: width * 0.15,
        y: height * 0.2,
        width: width * 0.25,
        height: height * 0.15
    )
    context.fillEllipse(in: highlightRect)
    
    return context.makeImage()
}

// Generate icons for each size
let outputDir = FileManager.default.currentDirectoryPath + "/Just Pomodoro/Resources/Assets.xcassets/AppIcon.appiconset"

// Create output directory if it doesn't exist
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)

for (size, name) in iconSizes {
    if let image = generateTomatoIcon(size: size) {
        let url = URL(fileURLWithPath: outputDir + "/icon_\(name).png")
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else {
            print("Failed to create destination for \(name)")
            continue
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        
        print("Generated: icon_\(name).png")
    } else {
        print("Failed to generate icon for \(name)")
    }
}

print("App icon generation complete!")
