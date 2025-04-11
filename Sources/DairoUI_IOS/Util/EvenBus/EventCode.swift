enum EventCode: String{
    
    /**
     * 通知重新加载分类
     */
    case LOAD_CATE
    
    /**
     * 加载歌曲列表
     */
    case RELOAD_MUSIC
    
    /**
     * 播放进度发生变化
     */
    case PLAYER_PROGRESS
    
    /**
     * 播放器状态发生变化
     */
    case PLAYER_STATE_CHANGE

    /**
     * 播放器发生了异常
     */
    case PLAYER_ERROR

    /**
     * 重新加载了会员信息
     */
    case RELOAD_USER
    
    /**
     * 当前下载进度改变
     */
    case DOWNLOAD_PROGRESS
    
    case TOAST
    
    /**
     * 播放器的一些信息,比如播放错误等等
     */
    case PLAYER_MSG


    /**
     * 当前下载更新进度改变
     */
    case DOWNLOAD_APK_PROGRESS
}
