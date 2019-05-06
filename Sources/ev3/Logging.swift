import Foundation

let loggingEnabled = true
let communicatorEnabled = true

public func log(file: String = #file, function: String = #function, message: String) {
    if loggingEnabled {
        if communicatorEnabled || (!communicatorEnabled && !file.contains("EV3Communicator")) {
            let bridge = file as NSString
            let substring = bridge.substring(from: bridge.range(of: "/Sources/").location + 9)
            NSLog("Logging \(substring) \(function): \(message)")
        }
    }
}

public func logHex(_ data: Data) -> Void {
    log(message: "\(toHex(data))")
    log(message: "")
}

internal func toHex(_ data: Data) -> String {
    var it     = data.makeIterator()
    var result = ""
    var next   = it.next()
    while (next != nil) {
        let hex = String(format: "%2X", next!)
        result = result.appending(hex.characters.first == " " ? "0" + String(hex.characters.dropFirst()) : hex)
        result = result.appending(" ")
        next = it.next()
    }
    return result
}
