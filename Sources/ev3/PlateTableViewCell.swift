import UIKit

@objc(PlateTableViewCell)
class PlateTableViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: PlateTableViewCell.self)
    
    static let timeFormatter = MeasurementFormatter()
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var timeLabel: GraphTimeLabel!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var graphScrollView: UIScrollView!
    @IBOutlet weak var graph: PortDataGraph!
    
    fileprivate var currentMode: PortMode?
    
    var userCodeState: UserCodeState = .ready {
        didSet {
            graphScrollView.isUserInteractionEnabled = userCodeState == .finished
        }
    }
    
    var maximumGraphOffset: CGFloat {
        return minimumGraphOffset + graph.plotWidth
    }
    
    var minimumGraphOffset: CGFloat {
        return -graphScrollView.bounds.size.width + graph.contentInset.left
    }
    
    weak var delegate: PlateTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitUpdatesFrequently | UIAccessibilityTraitStaticText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        graphScrollView.contentInset.left = graphScrollView.bounds.size.width - graph.contentInset.left
        graphScrollView.contentInset.right = -graph.bounds.size.width + graph.contentInset.left + graph.plotWidth
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.isHidden = false
    }
    
    func configure(with connection: PlateConnection, data: ConnectionData, mode: PortMode) {
        accessibilityLabel = connection.accessibleDescription
        backgroundColor = connection.color
        graph.markerFont = timeLabel.font
        
        timeLabel.opaqueBackgroundColor = connection.color
        portLabel.textColor = connection.color
        portLabel.layer.cornerRadius = 4.0
        portLabel.layer.masksToBounds = true
        portLabel.text = connection.port.localizedName
        typeLabel.text = connection.type.localizedName.localizedUppercase
        modeLabel.text = ""
        iconView.image = connection.type.image(for: .small)
        
        graphScrollView.delegate = nil
        defer {
            graphScrollView.delegate = self
        }

        graph.reset()
        logConnectionData(data, for: mode)
    }
    
    fileprivate func updateTimeLabel(with timeInterval: TimeInterval) {
        let time = Measurement(value: floor(timeInterval), unit: UnitDuration.baseUnit())
        timeLabel.text = PlateTableViewCell.timeFormatter.string(from: time)
        timeLabel.sizeToFit()
    }
    
    func scrollGraph(to xOffset: CGFloat) {
        guard userCodeState == .finished else { return }
        graphScrollView.contentOffset.x = xOffset
    }
}

protocol PlateTableViewCellDelegate: class {
    func plateTableViewCell(_ cell: PlateTableViewCell, didScrollTo xOffset: CGFloat)
}

extension PlateTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard userCodeState == .finished, let mode = currentMode, let connectionData = graph.connectionData, !connectionData.isEmpty else { return }
        
        let time: TimeInterval
        if let lastData = connectionData.last {
            time = min(max(TimeInterval((scrollView.contentOffset.x + scrollView.contentInset.left) / graph.pointsPerSecond), 0), lastData.time)
        }
        else {
            time = 0
        }
        
        valueLabel.text = mode.formattedValue(connectionData.value(for: time))
        updateTimeLabel(with: time)
        
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            let xOffset = min(max(scrollView.contentOffset.x, minimumGraphOffset), maximumGraphOffset)
            delegate?.plateTableViewCell(self, didScrollTo: xOffset)
        }
    }
}

extension PlateTableViewCell: ConnectionDataLogger {
    func logConnectionData(_ data: ConnectionData, for mode: PortMode) {
        guard let lastValue = data.last else { return }
        
        currentMode = mode
        valueLabel.text = mode.formattedValue(lastValue.value)
        modeLabel.text = mode.localizedName
        
        updateTimeLabel(with: lastValue.time)
        
        let absMaxValue = max(abs(data.minValue), abs(data.maxValue))
        minValueLabel.text = mode.formattedValue(-absMaxValue)
        maxValueLabel.text = mode.formattedValue(absMaxValue)
        
        graph.update(with: data)
        graphScrollView.layoutIfNeeded()
        graphScrollView.contentOffset.x = maximumGraphOffset
        
        // TODO: Localize when a stringsdict file has been setup
        let accessibleValue = mode.accessibleValue(lastValue.value)
        let accessibleTimeStamp = "\(Int(lastValue.time)) seconds"
        accessibilityValue = "\(accessibleValue), \(accessibleTimeStamp)"
    }
}
