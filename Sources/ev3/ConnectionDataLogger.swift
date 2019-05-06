import Foundation

protocol ConnectionDataLogger {
    func logConnectionData(_ data: ConnectionData, for mode: PortMode)
}

struct ConnectionData {
    typealias ValueAtTime = (value: Float, time: TimeInterval)
    
    private(set) var startTime: Date
    private(set) var minValue: Float
    private(set) var maxValue: Float
    
    fileprivate var values: [ValueAtTime]
    
    var count: Int {
        return values.count
    }
    
    var isEmpty: Bool {
        return values.isEmpty
    }
    
    var first: ValueAtTime? {
        return values.first
    }
    
    var last: ValueAtTime? {
        return values.last
    }
    
    subscript(index: Int) -> ValueAtTime {
        return values[index]
    }
    
    init(startTime: Date, initialValue: Float, mode: PortMode) {
        self.startTime = startTime
        minValue = Swift.min(initialValue, ConnectionData.defaultMinimum(for: mode))
        maxValue = Swift.max(initialValue, ConnectionData.defaultMaximum(for: mode))
        values = [(value: initialValue, time: 0)]
    }
    
    mutating func append(_ value: Float, for time: Date = Date()) {
        minValue = Swift.min(minValue, value)
        maxValue = Swift.max(maxValue, value)
        values.append((value: value, time: time.timeIntervalSince(startTime)))
    }
    
    func index(for time: TimeInterval) -> Int {
        if let firstIndexAfterTime = values.index(where: { $0.time > time }) {
            return Swift.max(0, firstIndexAfterTime - 1)
        }
        else {
            return Swift.max(0, values.count - 1)
        }
    }
    
    func value(for time: TimeInterval) -> Float {
        let index = self.index(for: time)
        guard index < count - 2 else { return values[index].value }
        
        // TODO: PDC, track between this and the next value
        return values[index].value
    }
}

extension ConnectionData: Sequence {
    func makeIterator() -> IndexingIterator<[ValueAtTime]> {
        return values.makeIterator()
    }
}

fileprivate extension ConnectionData {
    static func defaultMinimum(for mode: PortMode) -> Float {
        return -defaultMaximum(for: mode)
    }

    static func defaultMaximum(for mode: PortMode) -> Float {
        switch mode {
        case .angle:
            return 360.0
            
        case .power:
            return 100.0
            
        case .proximity:
            return 255.0
            
        case .touch:
            return 1.0
            
        case .color:
            return 10.0
            
        default:
            return 100.0
        }
    }
}
