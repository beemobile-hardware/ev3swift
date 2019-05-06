import UIKit

@objc(PlateGridViewCell)
class PlateGridViewCell: UICollectionViewCell {
    static func reuseIdentifier(for style: GridPlateStyle) -> String {
        let baseIdentifier = String(describing: PlateGridViewCell.self)
        switch style {
        case .large:
            return baseIdentifier + "_large"
            
        case .medium:
            return baseIdentifier + "_medium"

        case .small:
            return baseIdentifier + "_small"
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var modesView: PortModeSwitcherView?
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitUpdatesFrequently | UIAccessibilityTraitStaticText

        // Add a gesture recognizer to enable changing mode by tapping anywhere on the cell.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        addGestureRecognizer(gestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.isHidden = false
    }
    
    func configure(with connection: PlateConnection, style: GridPlateStyle) {
        backgroundColor = connection.color
        titleLabel?.text = connection.type.localizedName.localizedUppercase
        modesView?.configure(with: connection)
        iconView.image = connection.type.image(for: style)
        
        accessibilityLabel = connection.accessibleDescription
        
        if PortMode.availableModes(for: connection.type).count > 1 {
            let changeModeAction = UIAccessibilityCustomAction(name: NSLocalizedString("Change mode", comment: "Voice Over description of action to change a port's mode"),
                                                               target: self, selector:#selector(changeToNextMode(_:)))
            accessibilityCustomActions = [changeModeAction]
        }
        else {
            accessibilityCustomActions = []
        }
    }
    
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized, let modesView = modesView else { return }
        
        if modesView.isHidden {
            changeToNextMode(sender)
        }
        else {
            handleTapGestureRecognizer(sender, forModesView: modesView)
        }
    }
    
    private func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer, forModesView modesView: PortModeSwitcherView) {
        // Unwrap the required information from the `modesView`.
        guard let currentMode = modesView.currentMode,
            let currentIndex = modesView.modes.index(of: currentMode)
        else {
            return
        }
        
        // Determine which mode to select.
        let newMode: PortMode
        let hitPoint = sender.location(in: self)
        if hitPoint.x < bounds.size.width / 2.0 && currentIndex > 0 {
            newMode = modesView.modes[currentIndex - 1]
        }
        else if hitPoint.x > bounds.size.width / 2.0 && currentIndex < modesView.modes.count - 1 {
            newMode = modesView.modes[currentIndex + 1]
        }
        else {
            return
        }
        
        // Call the `modeView`'s delegate to change the mode.
        modesView.delegate?.portModeSwitcherView(modesView, didSelect: newMode)
    }
    
    @objc func changeToNextMode(_ sender: Any) {
        // Unwrap the required information from the `modesView`.
        guard let modesView = modesView,
            let currentMode = modesView.currentMode,
            let currentIndex = modesView.modes.index(of: currentMode)
        else {
            return
        }
        
        // Call the `modeView`'s delegate to change the mode.
        let nextIndex = (currentIndex + 1) % modesView.modes.count
        modesView.delegate?.portModeSwitcherView(modesView, didSelect: modesView.modes[nextIndex])
    }
}

extension PlateGridViewCell: ConnectionDataLogger {
    func logConnectionData(_ data: ConnectionData, for mode: PortMode) {
        guard let mostRecentValue = data.last?.value else { return }
        
        valueLabel.text = mode.formattedValue(mostRecentValue)
        modesView?.currentMode = mode
        
        accessibilityValue = mode.accessibleValue(mostRecentValue)
    }
}
