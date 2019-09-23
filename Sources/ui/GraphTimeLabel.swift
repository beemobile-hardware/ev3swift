import UIKit

@objc(GraphTimeLabel)
class GraphTimeLabel: UILabel {
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 2, right: 20)
    
    var opaqueBackgroundColor: UIColor?
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = super.intrinsicContentSize
        fittingSize.width += insets.left + insets.right
        fittingSize.height += insets.top + insets.bottom
        
        return fittingSize
    }
    
    override func drawText(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
            let opaqueBackgroundColor = opaqueBackgroundColor,
            let colorSpace = context.colorSpace else {
            return
        }
        
        // Create a gradient a background color that fades out.
        let colors = [opaqueBackgroundColor.withAlphaComponent(0.0).cgColor,
                      opaqueBackgroundColor.cgColor,
                      opaqueBackgroundColor.cgColor,
                      opaqueBackgroundColor.withAlphaComponent(0.0).cgColor
                      ]
        let normalizedInsetWidth = insets.left / bounds.size.width
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as NSArray as CFArray, locations: [0, normalizedInsetWidth, 1 - normalizedInsetWidth, 1.0]) else {
            return
        }
        
        // Draw the background gradient and text.
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: rect.size.width, y: 0), options: [])
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
