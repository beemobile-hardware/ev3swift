import UIKit

extension UICollectionViewLayoutAttributes {
    struct ZIndex {
        static let cell = 10
        static let header = 20
        static let footer = 20
        static let studs = 0
        static let mask = 15
    }

    convenience init(forCellWith indexPath: IndexPath, brickRect: BrickRect, studDimensions: StudDimensions, offset: CGSize) {
        self.init(forCellWith: indexPath)
        updateGeometry(with: brickRect, studDimensions: studDimensions, offset: offset)
        zIndex = ZIndex.cell
    }
    
    convenience init(forSupplementaryViewOfKind kind: String, with indexPath: IndexPath, brickRect: BrickRect, studDimensions: StudDimensions, offset: CGSize) {
        self.init(forSupplementaryViewOfKind: kind, with: indexPath)
        updateGeometry(with: brickRect, studDimensions: studDimensions, offset: offset)

        switch kind {
        case UICollectionElementKindSectionHeader:
            zIndex = ZIndex.header
            
        case UICollectionElementKindSectionFooter:
            zIndex = ZIndex.footer
            
        case StuddedView.collectionViewElementKind:
            zIndex = ZIndex.studs
            
        case PlateCollectionViewMask.collectionViewElementKind:
            zIndex = ZIndex.mask
            
        default:
            break
        }
    }
    
    private func updateGeometry(with brickRect: BrickRect, studDimensions: StudDimensions, offset: CGSize) {
        frame = brickRect.cgRect(with: studDimensions)
        frame.origin.x += offset.width
        frame.origin.y += offset.height
        
        center = CGPoint(x: frame.origin.x + (frame.size.width / 2.0), y: frame.origin.y + (frame.size.height / 2.0))
        size = frame.size
        bounds = CGRect(origin: .zero, size: size)
    }
}
