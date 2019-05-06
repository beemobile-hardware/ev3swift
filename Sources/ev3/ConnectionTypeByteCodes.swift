public enum ConnectionTypeByteCode: UInt8 {
    case CONN_UNKNOWN               = 0x6F
    case CONN_DAISYCHAIN            = 0x75
    case CONN_NXT_COLOR             = 0x76
    case CONN_NXT_DUMB              = 0x77
    case CONN_NXT_IIC               = 0x78
    
    case CONN_INPUT_DUMB            = 0x79
    case CONN_INPUT_UART            = 0x7A
    
    case CONN_OUTPUT_DUMB           = 0x7B
    case CONN_OUTPUT_INTELLIGENT    = 0x7C
    case CONN_OUTPUT_TACHO          = 0x7D
    case CONN_NONE                  = 0x7E
    case CONN_ERROR                 = 0x7f
}
