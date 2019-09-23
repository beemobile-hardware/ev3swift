import UIKit

@objc(PlateCollectionViewMask)
class PlateCollectionViewMask: UICollectionReusableView {
    static let reuseIdentifier = String(describing: PlateCollectionViewMask.self)
    static let collectionViewElementKind = String(describing: PlateCollectionViewMask.self)
    
    let studdedView = StuddedView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .legoLightGray
        studdedView.frame.size = bounds.size
        studdedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(studdedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
