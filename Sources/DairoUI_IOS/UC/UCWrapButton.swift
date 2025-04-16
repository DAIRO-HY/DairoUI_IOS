import SwiftUI

/**
 * 填充方式
 */
enum FillType{
    
    /**
     * 无需填充
     */
    case NORMAL
    
    /**
     * 子控件宽度填充
     * 当所有子控件宽度总和小于容器有效宽度时,则平均将每个子控件拉宽,使两端填满
     */
    case WRAP_WIDTH
    
    /**
     * 控件之间的间隙填充
     * 当所有子控件宽度总和小于容器有效宽度时,则平均将每个子控件之间的间隙,使两端填满
     */
    case WRAP_SPACING
}


struct WrapStackItem{
    var label : String
    var width:CGFloat
}


/**
 *  自适应宽度的按钮布局视图
 */
struct UCWrapButton: View {
    
    //填充方式
    let fillType: FillType
    
    //控件之间的间距
    let spacing :CGFloat
    
    //当前屏幕宽度
#if os(iOS)
    let sWidth = UIScreen.main.bounds.width
#endif
#if os(macOS)
    let sWidth: CGFloat = 0 //@TODO: MAC平台代码尚未实现
#endif
    
    //一行有效宽度 = 屏幕宽度 - 控件之间的距离 * 2
    let enableRowWidth: CGFloat
    
    //控件边距值
    let itemPadding = 20
    
    //每个字占用的宽度
    let textScale = 8
    
    //按钮标题列表
    let labels: [String]
    
    let action: (String)->Void
    
    /**
     * parameter labels:按钮标题列表
     * parameter spacing:控件之间的间距
     */
    init(_ labels: [String], spacing: CGFloat = 10, fillType: FillType = .NORMAL, action: @escaping (String)->Void){
        self.fillType = fillType
        self.labels = labels
        self.spacing = spacing
        self.action = action
        
        //一行有效宽度 = 屏幕宽度 - 控件之间的距离 * 2
        self.enableRowWidth = sWidth - spacing * 2
    }
    
    /**
     * 生成每行数据
     */
    private func makeRows()-> [[WrapStackItem]]{
        
        //行列表
        var rows = [[WrapStackItem]]()
        var columns :[WrapStackItem] = []
        
        //当前子控件占用宽度
        var subWidth = CGFloat(0)
        for label in self.labels{
            
            let charCount = label.reduce(0) { (total, character) in
                let scalarValue = character.unicodeScalars.first!.value
                
                // 检查字符是半角还是全角
                //(0x0020...0x007E).contains(scalarValue) 判断字符是否是 ASCII 半角字符。
                //(0xFF61...0xFF9F).contains(scalarValue) 判断字符是否是半角片假名（通常也视为半角字符）。
                if (0x0020...0x007E).contains(scalarValue) || (0xFF61...0xFF9F).contains(scalarValue) {
                    // 半角字符加 1
                    return total + 1
                } else {
                    // 全角字符加 2
                    return total + 2
                }
            }
            
            // 计算当前控件的宽度
            var itemWidth = CGFloat(itemPadding + charCount * textScale)
            if itemWidth > enableRowWidth{
                itemWidth = enableRowWidth
            }
            
            //计算当行总宽度 = 之前的控件总宽度 + 本控件宽度 + 之前的控件数量 * 控件之间的间距
            let currentRowWidth = subWidth + itemWidth + CGFloat(columns.count) * spacing
            if currentRowWidth > enableRowWidth{
                rows.append(columns)
                columns = []
                subWidth = 0
            }
            subWidth += itemWidth
            columns.append(WrapStackItem(label: label, width: itemWidth))
        }
        if !columns.isEmpty{
            rows.append(columns)
        }
        if self.fillType == .WRAP_WIDTH{//宽度填充
            
            //将子控件的宽度挨个扩大,使其刚好能填充父控件,这样看起来好看点
            for i in 0 ..< rows.count{
                
                //子控件总宽度
                let subViewWidthTotal = rows[i].reduce(0){
                    $0 + $1.width
                }
                
                //减去间距之后容器宽度
                let enableViewWidth = enableRowWidth - CGFloat(rows[i].count - 1) * spacing
                
                //子控件放大倍率
                let scale = enableViewWidth / subViewWidthTotal
                
                for j in 0 ..< rows[i].count{
                    rows[i][j].width = rows[i][j].width * scale
                }
            }
        }
        return rows
    }
    
    /**
     * 获取子控件之间的间隙大小
     */
    private func getSpacingByColumns(_ columns: [WrapStackItem])->CGFloat{
        
        //子控件之间的间隙
        var itemViewSpacing = self.spacing
        if self.fillType == .WRAP_SPACING{//子控件之间的间隙填充
            
            //子控件总宽度
            let subViewWidthTotal = columns.reduce(0){
                $0 + $1.width
            }
            
            //减去间距之后容器宽度
            itemViewSpacing = (self.enableRowWidth - subViewWidthTotal)/CGFloat(columns.count - 1)
        }
        return itemViewSpacing
    }
    
    var body: some View {
        let rows = self.makeRows()
        return VStack{
            ForEach(rows.indices, id: \.self) { i in
                
                //计算子控件之间的解析
                let spacing = self.getSpacingByColumns(rows[i])
                HStack(spacing: spacing){
                    ForEach(rows[i].indices, id: \.self) { x in
                        let item = rows[i][x]
                        Button(action: {
                            self.action(item.label)
                        }){
                            Text(item.label)
                                .lineLimit(1)
                                .font(.subheadline)
                                .padding(.vertical,5)
                                .frame(width: item.width)
                                .foregroundColor(Color.gl.btnTextSecondary)
                        }
                        .background(Color.gl.bgSecondary)
                        .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                //                .background(Color.green)
            }
        }
        .padding(.horizontal,self.spacing)
    }
}

struct UCWrapButton_Previews: PreviewProvider {
    static let labels = ["刘德华","稻香","夜的方向","爱不爱我","稻香","爱不爱我爱不爱我爱不爱我爱不爱我爱不爱我爱不爱我爱不爱我爱不爱我爱不爱不爱我爱不爱我","夜的方向","爱不爱我","稻香","夜的方向","12","12","12","12","12","あ","ｱｲｳ"]
    static var previews: some View {
        VStack{
            Text("默认填充:")
            UCWrapButton(labels){
                debugPrint($0)
            }
            Text("间隙填充:")
            UCWrapButton(labels,fillType: .WRAP_SPACING){
                debugPrint($0)
            }
            Text("子控件宽度填充:")
            UCWrapButton(labels,fillType: .WRAP_WIDTH){
                debugPrint($0)
            }
        }
    }
}

