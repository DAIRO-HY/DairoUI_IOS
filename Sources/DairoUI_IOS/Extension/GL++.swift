//
//  GL++.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/6.
//

public struct GL<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol GLCompatible {}
public extension GLCompatible {
    public static var gl: GL<Self>.Type {
        get { GL<Self>.self }
        set {}
    }
    var gl: GL<Self>{
        get { GL(self) }
        set {}
    }
}

