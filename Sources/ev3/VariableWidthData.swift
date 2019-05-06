import Foundation

public struct VariableWidthData {
    /*
    #define   PRIMPAR_VALUE      0x3F
    #define   PRIMPAR_SHORT      0x00
    #define   PRIMPAR_CONST      0x00
    
    unsigned
    11111111 -> 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 = 255
    signed
    01111111 -> 1 + 2 + 4 + 8 + 16 + 32 + 64 = 127
    
    #define   PRIMPAR_LONG       0x80
    #define   PRIMPAR_1_BYTE     1
    #define   PRIMPAR_2_BYTES    2
    #define   PRIMPAR_4_BYTES    3
    
    // LC0 is one byte value -
    //   bit 7 says short or long
    //     0 = short format
    //       bit 6 says constant or variable
    //         0 = constant
    //           bit 5 says positive (0) or negative (1)
    //           value encode in bits 0 to 4 (+/- 31)
    //           000VVVV -> 1 + 2 + 4 + 8 + 16 = 31 (+/- 31)
    //         1 = variable
    //           bit 5 says local or global
    //           bottom 5 bits specify local or global index
    //     1 = long format
    //       bit 6 says constant or varaible
    //         0 = constant
    //           bit 5 says value or label
    //           0 says value
    //             bit 0 to 2 specity the byte count to follow, or zero terminated string
    //               000 or 100 = string, 001 = 1 byte, 010 = 2 bytes, 011 = 4 bytes
    //           1 says handle
    //         1 = variable
    //           bit 5 says local or global
    //           bit 4 says value or handle
#define LC0(v) ((v & PRIMPAR_VALUE) | PRIMPAR_SHORT | PRIMPAR_CONST)
#define LC1(v) (PRIMPAR_LONG  | PRIMPAR_CONST | PRIMPAR_1_BYTE),(v & 0xFF)
#define LC2(v) (PRIMPAR_LONG  | PRIMPAR_CONST | PRIMPAR_2_BYTES),(v & 0xFF),((v >> 8) & 0xFF)
#define LC4(v) (PRIMPAR_LONG  | PRIMPAR_CONST | PRIMPAR_4_BYTES),((ULONG)v & 0xFF),(((ULONG)v >> (ULONG)8) & 0xFF),(((ULONG)v >> (ULONG)16) & 0xFF),(((ULONG)v >> (ULONG)24) & 0xFF)
#define LCA(h) (PRIMPAR_LONG  | PRIMPAR_CONST | PRIMPAR_1_BYTE | PRIMPAR_ARRAY),(i & 0xFF)
    */
    fileprivate static let OneBytesToFollow: UInt8 = 0x81   // 0x10000001
    fileprivate static let TwoBytesToFollow: UInt8 = 0x82   // 0x10000010
    fileprivate static let FourBytesToFollow: UInt8 = 0x83  // 0x10000011
    fileprivate static let StringToFollow: UInt8 = 0x80    // 0x10000000
    //    private static let StringToFollow: UInt8 = 0x84    // 0x10000100
    public let value: Int32
    public func encode() -> Data {
        var data = Data()
        if value > -31 && value < 31 { // LC0(value) 
            var byte = value < 0 ? UInt8(abs(value) & 0x1F) ^ 0x3F + 0x01 : UInt8(abs(value) & 0x1F)
            data.append(&byte, count: 1)
        } else if value > -127 && value < 127 { // LC1(value)
            var lc1 = VariableWidthData.OneBytesToFollow
            data.append(&lc1, count: 1)
            var byte = UInt8(value & 0xFF)
            data.append(&byte, count: 1)
        } else if value > -32767 && value < 32767 { // LC2(value)
            // -144 2's complement 0x70FF - 0x0111 0000 1111 1111
            var lc2 = VariableWidthData.TwoBytesToFollow
            data.append(&lc2, count: 1)
            var byte1 = UInt8(value & 0xFF)
            data.append(&byte1, count: 1)
            var byte2 = UInt8((value >> 8) & 0xFF)
            data.append(&byte2, count: 1)
        } else { // LC4(value)
            var lc4 = VariableWidthData.FourBytesToFollow
            data.append(&lc4, count: 1)
            var byte1 = UInt8(value & 0xFF)
            data.append(&byte1, count: 1)
            var byte2 = UInt8((value >> 8) & 0xFF)
            data.append(&byte2, count: 1)
            var byte3 = UInt8((value >> 16) & 0xFF)
            data.append(&byte3, count: 1)
            var byte4 = UInt8((value >> 24) & 0xFF)
            data.append(&byte4, count: 1)
        }
        return data
    }
}
