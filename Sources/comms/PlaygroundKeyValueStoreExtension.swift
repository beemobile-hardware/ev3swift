import Foundation
import ExternalAccessory
import PlaygroundSupport

fileprivate let connectedBricksKey = "connectedBricks"
fileprivate let selectedBrickConnectionIDKey = "selectedBrickConnectionID"

extension PlaygroundKeyValueStore {
    
    private func convertBricks(_ key: String, _ value: PlaygroundValue) -> (Int, String)? {
        guard let connID = Int(key), case let .string(name) = value else {
            return nil
        }
        return (connID, name)
    }
    
    var connectedBricks: [Int: String]? {
        get {
            guard let playgroundValues = dictionary(forKey: connectedBricksKey) else {
                return nil
            }
            
            var bricks = [Int: String]()
            
            for (k, v) in playgroundValues {
                if let connID = Int(k), case let .string(name) = v {
                    bricks[connID] = name
                }
            }
            
            return bricks
        }
        
        set(bricks) {
            guard let bricks = bricks else {
                self[connectedBricksKey] = nil
                return
            }
            
            var playgroundValues = [String: PlaygroundValue]()
            
            for (k, v) in bricks {
                playgroundValues[String(k)] = .string(v)
            }
            
            self[connectedBricksKey] = .dictionary(playgroundValues)
        }
    }
    
    var selectedBrickConnectionID: Int? {
        get {
            guard case let .integer(connectionID)? = self[selectedBrickConnectionIDKey] else {
                return nil
            }
            
            return connectionID
        }
        
        set(connectionID) {
            guard let connectionID = connectionID else {
                self[selectedBrickConnectionIDKey] = nil
                return
            }
            
            self[selectedBrickConnectionIDKey] = .integer(connectionID)
        }
    }
}
