//
//  GLLine.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/11.
//

import SwiftUI

/**
 线
 */
struct Line: View {
    var body: some View {
        Divider().background(Color.gl.line)//线
    }
}

struct GLLine_Previews: PreviewProvider {
    static var previews: some View {
        Line()
    }
}
