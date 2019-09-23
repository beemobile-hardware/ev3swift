import UIKit

/// A `UIView` that draws studs on its background.
class StuddedView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: StuddedView.self)
    static let collectionViewElementKind = String(describing: StuddedView.self)
    
    var studDimensions: StudDimensions = .invalid
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .legoLightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .legoLightGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        assert(studDimensions != .invalid, "Stud dimensions have not been set")
        
        let context = UIGraphicsGetCurrentContext()!
        let studColor = UIColor.legoStud.cgColor
        
        // Create a pattern to use as the fill color.
        let patternRenderer = UIGraphicsImageRenderer(size: CGSize(width: studDimensions.totalSize, height: studDimensions.totalSize))
        let patternImage = patternRenderer.image { context in
            let rect = CGRect(x: 0,
                              y: 0,
                              width: studDimensions.totalSize,
                              height: studDimensions.totalSize)
                .insetBy(dx: studDimensions.inset, dy: studDimensions.inset)
            
            context.cgContext.setStrokeColor(studColor)
            context.cgContext.strokeEllipse(in: rect)
        }
        let pattern = UIColor(patternImage: patternImage)
        
        // Fill the view with the pattern, rounded to the nearest whole brick size.
        context.setFillColor(pattern.cgColor)
        context.fill(CGRect(origin: .zero, size: bounds.size))
    }
}
