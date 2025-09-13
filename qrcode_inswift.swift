import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// Reusable QR view
struct QRCodeView: View {
    let text: String
    var size: CGFloat = 260
    var quietZone: CGFloat = 20   // white padding around the code

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        if let img = makeQR(from: text, size: size, quietZone: quietZone) {
            Image(uiImage: img)
                .interpolation(.none)      // keep modules crisp
                .resizable()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8, y: 6)
        } else {
            Color.gray.opacity(0.2)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func makeQR(from string: String, size: CGFloat, quietZone: CGFloat) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel") // L/M/Q/H

        guard let output = filter.outputImage else { return nil }

        // Scale CIImage to desired point size (no blur)
        let base = output.extent.size
        let scale = size / max(base.width, base.height)
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Draw into a UIImage with a white quiet zone
        let finalSize = CGSize(width: size + quietZone*2, height: size + quietZone*2)
        UIGraphicsBeginImageContextWithOptions(finalSize, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: finalSize))

        if let cg = context.createCGImage(scaled, from: scaled.extent) {
            UIImage(cgImage: cg).draw(in: CGRect(x: quietZone, y: quietZone, width: size, height: size))
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

// Use anywhere you want the QR
struct MainView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("My Personl QR")
                .font(.title3.bold())
            QRCodeView(text: "ENTER YOUR LINK", size: 260, quietZone: 20)
        }
        .padding()
    }
}

#Preview {
    MainView()
}
