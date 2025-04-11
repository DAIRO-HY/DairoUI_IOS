//
//  TextFiledIcon.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/5.
//

import SwiftUI

//自定义带图标的文本输入框
struct UCEmailCodeTextField: View {
    
    /**
     * 注册验证码
     */
    static let TYPE_REGISTRY = "REGISTRY"

    /**
     * 密码重置验证码
     */
    static let TYPE_REPWD = "REPWD"

    /**
     * 绑定邮箱
     */
    static let TYPE_BIND_EMAIL = "BIND_EMAIL"
    
    @ObservedObject private var vm: GLEmailCodeTextFieldViewModel
    init(code: Binding<String>, email: String, type: String) {
        self.vm = GLEmailCodeTextFieldViewModel(code: code, email: email, type: type)
    }
    
    /** 初始化
     - parameter email:要发送的email地址
     - parameter code:绑定的验证码
     */
//    init(email: String,code: Binding<String>){
//        self.vm = GLEmailCodeTextFieldViewModel(email: email, code: code)
//    }
    
    /**
     发送验证码按钮
     */
    private var sendCodeBtn: AnyView {
        let btn = Button(action: {
            self.vm.onSendCodeClick()
            
        }){
            if self.vm.mResendCodeTime > 0 {
                Text("\(self.vm.mResendCodeTime)秒后可再次发送").font(.body)
            }else{
                Text("发送验证码").font(.body)
            }
        }
        return AnyView(btn)
    }
    
    var body: some View {
        UCTextFiled(icon:"a.square.fill", text: self.vm.code, hide:"验证码", rightView: sendCodeBtn).onDisappear{
            self.vm.mIsClose = true
        }
    }
}

struct GGLEmailCodeTextField_Previews: PreviewProvider {
    @State static var previewText = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@qq.com"
    static var previews: some View {
        UCTextFiled(icon:"lock.square.fill",text: $previewText, rightView: AnyView(Text("发送验证码")))
    }
}


@MainActor
private class GLEmailCodeTextFieldViewModel : ObservableObject{
    
    /**
     * 验证码类型
     */
    private let type: String
    
    /**
     * 邮箱
     */
    private let email: String
    
    /**
     * 邮箱验证码
     */
    let code: Binding<String>
        
    /**
     * 再次发送验证码倒计时
     */
    @Published var mResendCodeTime = 0
    
    /**
     * 标记页面是否已经关闭
     */
    var mIsClose = false
    init(code: Binding<String>, email: String, type: String) {
        debugPrint("-->GLEmailCodeTextFieldViewModel.init")
        self.code = code
        self.email = email
        self.type = type
    }
    
    /**
     * 发送注册验证码
     */
    func onSendCodeClick(){
        if self.mResendCodeTime > 0 {
            return
        }
//        EmailApi.sendCode(email: self.email, type: self.type).post{
//            self.mResendCodeTime = 60
//            self.startResendTimer()
//        }
    }
    
    /**
     * 开始倒计时
     */
    private func startResendTimer(){
        Task{
            while(self.mResendCodeTime > 0){
                if self.mIsClose {
                    break
                }
                await MainActor.run {
                    self.mResendCodeTime -= 1
                }
                
                //等待1秒
                await Task.sleep(1_000_000_000)
                debugPrint("-->\(self.mResendCodeTime)")
            }
        }
    }
    
    deinit{
        debugPrint("-->GLEmailCodeTextFieldViewModel.deinit")
    }
}


