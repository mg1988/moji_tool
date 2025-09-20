import {OCRLine} from '../models/OCRResult'
import { Point } from '@kit.TestKit';

@Component
export struct  OCRText{
  @ObjectLink line:OCRLine;
  @State isRecognizing:boolean = false;
  @ObjectLink imageLocation: Point;
  build() {
    Text(this.line.value)
      .position({ x: (this.imageLocation.x+ this.line.getPosition().x)+'px', y: this.imageLocation.y+this.line.getPosition().y+'px' })
      .backgroundColor('#8196F380')
      .fontColor(Color.Red)
      .copyOption(CopyOptions.LocalDevice)
      .fontSize(14)
      .onClick(()=>{
        this.line.delete = !this.line.delete;
      })
      .decoration({
        type:this.line.delete?TextDecorationType.LineThrough:TextDecorationType.None,
        color:Color.Red
      })
      .borderRadius(4)
      .transition({
        // 添加过渡动画
        type: TransitionType.All,
        opacity: this.isRecognizing ? 0 : 1,
        translate: this.isRecognizing ? { x: 0, y: 10 } : { x: 0, y: 0 },
        scale: this.isRecognizing ? { x: 0.9, y: 0.9 } : { x: 1, y: 1 }
      })
  }
}