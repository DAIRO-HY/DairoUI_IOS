//
//  GL++.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/6.
//

struct GL<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol GLCompatible {}
extension GLCompatible {
    static var gl: GL<Self>.Type {
        get { GL<Self>.self }
        set {}
    }
    var gl: GL<Self>{
        get { GL(self) }
        set {}
    }
}

