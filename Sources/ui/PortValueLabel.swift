import UIKit

@objc(PortValueLabel)
class PortValueLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard text != oldValue else { return }
            fontThatFits = nil
        }
    }
    
    private var fontThatFits: UIFont?
    
    private var lastFittingSize: CGSize?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // If the size of the label has changed, any cached font is now invalid.
        if lastFittingSize != bounds.size {
            fontThatFits = nil
            setNeedsDisplay()
        }
    }
    
    override func drawText(in rect: CGRect) {
        guard let text = text else { return }
        
        // Setup attributes to draw with, using a font size that will fit the space.
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font(fitting: rect.size),
            NSAttributedStringKey.foregroundColor: textColor
        ]
        
        // Calculate the rect to draw the text into.
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        let textRect: CGRect
        switch textAlignment {
        case .left:
            textRect = CGRect(x: 0, y: floor(rect.midY - textSize.height / 2.0),
                              width: textSize.width, height: textSize.height)
            
        case .right:
            textRect = CGRect(x: rect.maxX - textSize.width,
                              y: floor(rect.midY - textSize.height / 2.0),
                              width: textSize.width, height: textSize.height)
            
        default:
            textRect = CGRect(x: floor(rect.midX - textSize.width / 2.0),
                              y: floor(rect.midY - textSize.height / 2.0),
                              width: textSize.width, height: textSize.height)
            
        }
        
        (text as NSString).draw(in: textRect, withAttributes: textAttributes)
    }
    
    private func font(fitting size: CGSize) -> UIFont {
        guard let text = text else { return font }
        
        // Return the font if it's already been determined.
        if let fontThatFits = fontThatFits {
            return fontThatFits
        }
        
        // Calculate a font size that can be used to draw the text in the specified size.
        var fontSize: CGFloat = font.pointSize
        var fontStepSize: CGFloat = fontSize / 2.0
        var isShrinking = true
        
        while fontStepSize > 0.9 {
            while self.text(text, fits: size, with: font.withSize(fontSize)) != isShrinking && fontSize > 1.0 {
                // Make sure the size doesn't reach zero if we're shrinking the font.
                while isShrinking && fontSize <= fontStepSize {
                    fontStepSize /= 2.0
                }
                
                fontSize += isShrinking ? fontStepSize * -1 : fontStepSize
            }
            
            fontStepSize /= 2.0
            isShrinking = !isShrinking
        }
        
        // Cache and return a font that's no larger than the maximum font size.
        fontSize = min(fontSize, font.pointSize)
        fontThatFits = font.withSize(floor(fontSize))
        lastFittingSize = size
        
        return fontThatFits!
    }
    
    private func text(_ text: String, fits size: CGSize, with font: UIFont) -> Bool {
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font
        ]
        
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        return textSize.width < size.width && textSize.height < size.height
    }
}
