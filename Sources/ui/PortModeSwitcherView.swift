import UIKit

@objc(PortModeSwitcherView)
class PortModeSwitcherView: UIStackView {
    
    @IBOutlet weak var currentModeLabel: UILabel!

    @IBOutlet var previousModeButton: UIButton!
    
    @IBOutlet var nextModeButton: UIButton!
    
    weak var delegate: PortModeSwitcherViewDelegate?
    
    private(set) var connection: PlateConnection?
    
    private(set) var modes: [PortMode] = []
    
    private var isNavigationVisible = true {
        didSet {
            guard isNavigationVisible != oldValue else { return }
            
            if isNavigationVisible {
                insertArrangedSubview(previousModeButton, at: 0)
                insertArrangedSubview(nextModeButton, at: arrangedSubviews.count)
            }
            else {
                removeArrangedSubview(previousModeButton)
                removeArrangedSubview(nextModeButton)
            }
        }
    }
    
    var currentMode: PortMode? {
        didSet {
            updateButtonStates()
        }
    }
    
    // MARK: Configuration

    func configure(with connection: PlateConnection) {
        self.connection = connection
        self.modes = PortMode.availableModes(for: connection.type)
        self.currentMode = nil
        
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        guard let mode = currentMode, let index = modes.index(of: mode) else {
            currentModeLabel.text = " "
            isNavigationVisible = false
            return
        }
        
        currentModeLabel.text = mode.localizedName
        
        if modes.count < 2 {
            isNavigationVisible = false
        }
        else {
            isNavigationVisible = true
            previousModeButton.isEnabled = index > 0
            nextModeButton.isEnabled = index < modes.count - 1
        }
    }
    
    // MARK: IBActions
    
    @IBAction func didTapChangeMode(_ sender: UIButton) {
        guard let mode = currentMode, var index = modes.index(of: mode) else { return }
        
        if sender == previousModeButton && index > 0 {
            index -= 1
        }
        else if sender == nextModeButton && index < modes.count - 1 {
            index += 1
        }
        
        delegate?.portModeSwitcherView(self, didSelect: modes[index])
    }
}

protocol PortModeSwitcherViewDelegate: class {
    func portModeSwitcherView(_ switcherView: PortModeSwitcherView, didSelect mode: PortMode)
}
