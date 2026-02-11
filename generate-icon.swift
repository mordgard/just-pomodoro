import Foundation
import CoreGraphics
import ImageIO
import CoreServices

// Generate JPom text icon for the app
let iconSizes = [
    (16, "16x16"),
    (32, "32x32"),
    (64, "32x32@2x"),
    (128, "128x128"),
    (256, "128x128@2x"),
    (512, "256x256@2x"),
    (1024, "512x512@2x")
]

func generateJPomIcon(size: Int) -> CGImage? {
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
    
    // Fill background with nice gradient
    let gradientColors = [
        CGColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1.0), // Tomato red
        CGColor(red: 0.85, green: 0.20, blue: 0.10, alpha: 1.0)  // Darker red
    ]
    
    // Draw rounded rect background
    let cornerRadius: CGFloat = 180.0 * scale
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // Simple gradient fill
    context.addPath(path)
    context.clip()
    
    // Draw gradient
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: gradientColors as CFArray,
                              locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: height), options: [])
    
    // Draw "JP" text
    let text = "JP"
    let fontSize: CGFloat = 500 * scale
    
    // Calculate text position (center)
    let textRect = CGRect(x: width * 0.15, y: height * 0.15, width: width * 0.7, height: height * 0.7)
    
    // Draw text with white color and shadow
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    
    // Simple white circle as background for text
    let circleRect = CGRect(x: width * 0.1, y: height * 0.1, width: width * 0.8, height: height * 0.8)
    context.fillEllipse(in: circleRect)
    
    // Draw red circle inside
    context.setFillColor(CGColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1.0))
    let innerCircleRect = CGRect(x: width * 0.15, y: height * 0.15, width: width * 0.7, height: height * 0.7)
    context.fillEllipse(in: innerCircleRect)
    
    // Draw "JP" text in white
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    
    // For simplicity, draw a white rectangle as "J" and "P" would be complex without CoreText
    // Instead draw a simple clock/timer symbol
    let centerX = width / 2
    let centerY = height / 2
    let clockRadius = min(width, height) * 0.25
    
    // Draw clock face outline
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.setLineWidth(8 * scale)
    context.strokeEllipse(in: CGRect(x: centerX - clockRadius, y: centerY - clockRadius, width: clockRadius * 2, height: clockRadius * 2))
    
    // Draw clock hands
    context.setLineWidth(6 * scale)
    context.setLineCap(.round)
    
    // Hour hand (pointing up)
    context.move(to: CGPoint(x: centerX, y: centerY))
    context.addLine(to: CGPoint(x: centerX, y: centerY - clockRadius * 0.6))
    context.strokePath()
    
    // Minute hand (pointing right)
    context.move(to: CGPoint(x: centerX, y: centerY))
    context.addLine(to: CGPoint(x: centerX + clockRadius * 0.4, y: centerY))
    context.strokePath()
    
    return context.makeImage()
}

// Generate icons for each size
let outputDir = FileManager.default.currentDirectoryPath + "/Just Pomodoro/Resources/Assets.xcassets/AppIcon.appiconset"

// Create output directory if it doesn't exist
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)

for (size, name) in iconSizes {
    if let image = generateJPomIcon(size: size) {
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
