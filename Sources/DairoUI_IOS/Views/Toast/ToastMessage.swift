public struct ToastMessage{
    
    /**
     * 小时显示时间
     */
    public let delay : Double
    
    /**
     * 消息内容
     */
    public let message : String
    
    public init(delay: Double, message: String) {
        self.delay = delay
        self.message = message
    }
}
