import UIKit

@objc(RoundedButton)
class RoundedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .legoRed
        setTitleColor(.white, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        layer.masksToBounds = true
        layer.cornerRadius = bounds.size.height / 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2.0
    }
}
