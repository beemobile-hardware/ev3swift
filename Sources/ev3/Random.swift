import Foundation

/**
 Function gives a random number less than or equal to another number and optionally greater than or equal to a third number.
 
 **Example**: Simulate a six sided die by generating a random number between 1 and 6:
 
 `random(min: 1, max: 6)`
 
 **Example**: Generate a random number less than or equal to 1000:
 
 `random(max: 1000)`
 
 - parameters:
    - min: Takes a `Float` specifying the smallest allowed random number. If this is not given, `0` will be used.
    - max: Takes a `Float` specifying the largest allowed random number.
 */
public func random(min: Float = 0, max: Float) -> Float {
    assert( min <= max, "Min has to be <= max")
    return  Float(arc4random_uniform(UInt32(max - min) * 1000)) / 1000 + min
}
