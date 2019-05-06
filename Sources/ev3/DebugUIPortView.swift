import Foundation
import UIKit

class DebugUIPortView: UIView, DebugUIPortDelegate {
    
    var port: DebugUIPort? {
        didSet {
            port?.delegate = self
        }
    }
    
    let displayLabel = UILabel()
    let partImageView = UIImageView(frame: CGRect.zero)
    let modeImageView = UIImageView(frame: CGRect.zero)
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0).cgColor
        alpha = 0.5
        
        displayLabel.text = ""
        displayLabel.textAlignment = .center
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.font = UIFont.systemFont(ofSize: 20.0)
        //displayLabel.backgroundColor = UIColor.blue
        addSubview(displayLabel)
        
        displayLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        displayLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        displayLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        displayLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        //bottomView.backgroundColor = UIColor.purple
        addSubview(bottomView)
        
        bottomView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
        bottomView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        partImageView.contentMode = .scaleAspectFit
        partImageView.translatesAutoresizingMaskIntoConstraints = false
        //modeImageView.backgroundColor = UIColor.orange
        bottomView.addSubview(partImageView)
        
        partImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        partImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        partImageView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        partImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        modeImageView.contentMode = .scaleAspectFit
        modeImageView.translatesAutoresizingMaskIntoConstraints = false
        //modeImageView.backgroundColor = UIColor.yellow
        bottomView.addSubview(modeImageView)
        
        modeImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        modeImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        modeImageView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        modeImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -2.0).isActive = true
        
        let divider = UIView()
        divider.backgroundColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        
        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        divider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        divider.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func partAdded() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
        })
        partUpdated()
    }
    
    func partRemoved() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.5
        })
    }
    
    func partUpdated() {
        guard let part = port?.part else {
            return
        }
        displayLabel.text = part.displayString
        partImageView.image = part.image
        modeImageView.image = part.modeImage
        alpha = 1.0
    }
}
