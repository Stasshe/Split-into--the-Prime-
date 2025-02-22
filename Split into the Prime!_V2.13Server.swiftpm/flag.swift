import SwiftUI
import SpriteKit
import ObjectiveC

extension SKSpriteNode {
    private static var canSplitKey: UInt8 = 0 // 新しいキーとして静的変数を使用
    
    var canSplit: Bool {
        get {
            return objc_getAssociatedObject(self, &Self.canSplitKey) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &Self.canSplitKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
