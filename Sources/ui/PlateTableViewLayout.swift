import UIKit

class PlateTableViewLayout: PlateCollectionViewLayout {

    private var itemBrickSize: BrickSize = .zero
    
    override var includePortsAndLines: Bool {
        return false
    }

    override func prepare() {
        super.prepare()
        
        itemBrickSize = BrickSize(width: studdedViewSize.width, height: 20)
        itemSize = itemBrickSize.cgSize(with: studDimensions)
        minimumLineSpacing = studDimensions.totalSize
        minimumInteritemSpacing = studDimensions.totalSize
        sectionInset = UIEdgeInsets(top: (studDimensions.totalSize * 5) + layoutOffset.height, left: 0, bottom: studDimensions.totalSize * 2, right: 0)
        
        delegate?.plateCollectionViewLayoutDidChange(self)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        attributes.append(layoutAttributesForStuddedView())
        attributes.append(layoutAttributesForMask(isOutput: true))
        attributes.append(layoutAttributesForMask(isOutput: false))
        attributes.append(layoutAttributesForPortsView(isOutput: true))
        attributes.append(layoutAttributesForPortsView(isOutput: false))

        return attributes
    }
}
