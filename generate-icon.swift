import Foundation
import CoreGraphics
import ImageIO
import CoreServices

// Generate JPom text icon for the app with proper macOS icon sizing
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
    let width = CGFloat(size)
    let height = CGFloat(size)
    
    // Create context with better quality settings
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
    
    // Enable anti-aliasing for smoother edges
    context.setShouldAntialias(true)
    context.setAllowsAntialiasing(true)
    
    // macOS app icons have about 15% padding (template icon size is smaller than canvas)
    let padding: CGFloat = width * 0.12
    let contentWidth = width - (padding * 2)
    let contentHeight = height - (padding * 2)
    
    // Fill background with nice gradient
    let gradientColors = [
        CGColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1.0), // Tomato red
        CGColor(red: 0.85, green: 0.20, blue: 0.10, alpha: 1.0)  // Darker red
    ]
    
    // Draw rounded rect background with padding
    // Corner radius should scale with icon size but not be too large
    let cornerRadius: CGFloat = min(contentWidth, contentHeight) * 0.22
    let rect = CGRect(x: padding, y: padding, width: contentWidth, height: contentHeight)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // Save context state before clipping
    context.saveGState()
    
    // Draw gradient background
    context.addPath(path)
    context.clip()
    
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: gradientColors as CFArray,
                              locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: height), options: [])
    
    // Restore context state
    context.restoreGState()
    
    // Draw white circle as background for clock (centered in padded area, slightly smaller)
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    let circleSize = min(contentWidth, contentHeight) * 0.75 // Slightly smaller circle
    let circleRect = CGRect(
        x: padding + (contentWidth - circleSize) / 2,
        y: padding + (contentHeight - circleSize) / 2,
        width: circleSize,
        height: circleSize
    )
    context.fillEllipse(in: circleRect)
    
    // Draw red circle inside
    context.setFillColor(CGColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1.0))
    let innerCircleSize = circleSize * 0.85
    let innerCircleRect = CGRect(
        x: padding + (contentWidth - innerCircleSize) / 2,
        y: padding + (contentHeight - innerCircleSize) / 2,
        width: innerCircleSize,
        height: innerCircleSize
    )
    context.fillEllipse(in: innerCircleRect)
    
    // Draw clock/timer symbol (centered in padded area)
    let centerX = padding + contentWidth / 2
    let centerY = padding + contentHeight / 2
    let clockRadius = min(contentWidth, contentHeight) * 0.20 // Slightly smaller
    
    // Draw clock face outline with thicker lines for better visibility
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.setLineWidth(max(2.0, CGFloat(size) / 128.0)) // Scale line width with icon size, minimum 2px
    context.strokeEllipse(in: CGRect(x: centerX - clockRadius, y: centerY - clockRadius, width: clockRadius * 2, height: clockRadius * 2))
    
    // Draw clock hands with appropriate thickness
    context.setLineWidth(max(1.5, CGFloat(size) / 170.0))
    context.setLineCap(.round)
    context.setLineJoin(.round)
    
    // Hour hand (pointing to 10 o'clock)
    context.move(to: CGPoint(x: centerX, y: centerY))
    context.addLine(to: CGPoint(x: centerX - clockRadius * 0.35, y: centerY - clockRadius * 0.5))
    context.strokePath()
    
    // Minute hand (pointing to 2 o'clock)
    context.move(to: CGPoint(x: centerX, y: centerY))
    context.addLine(to: CGPoint(x: centerX + clockRadius * 0.45, y: centerY - clockRadius * 0.35))
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
