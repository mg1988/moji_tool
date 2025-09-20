import { OCRBlock, OCRLine, OCRResult } from "../models/OCRResult"
import { LengthMetrics, PromptAction } from "@kit.ArkUI";

@Builder
export function OCRResultPageBuilder(result: OCRResult) {
  OCRResultPage(result)
}

@Entry
@Component
export struct OCRResultPage {
  @State result: OCRResult | undefined = undefined;
  @State value: string = "";
  controller: TextAreaController = new TextAreaController();
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  constructor(result?: OCRResult) {
    super();
    this.result = result;
  }

  aboutToAppear(): void {
    this.result = this.getUIContext().getRouter().getParams() as OCRResult;
    this.getValue();
  }

  build() {
    Navigation() {
      Stack() {
        TextArea({
          text: this.value,
          placeholder: 'The text area can hold an unlimited amount of text. input your word...',
          controller: this.controller
        })
          .placeholderFont({ size: 16, weight: 400 })
          .width(336)
          .height('60%')
          .margin(20)
          .fontSize(16)
          .fontColor('#182431')
          .backgroundColor('#FFFFFF')
          .showCounter(true, { thresholdPercentage: 50, highlightBorder: true })
          //计数器显示效果为用户当前输入字符数/最大字符限制数。最大字符限制数通过maxLength()接口设置。
          //如果用户当前输入字符数达到最大字符限制乘50%（thresholdPercentage）。字符计数器显示。
          //用户设置highlightBorder为false时，配置取消红色边框。不设置此参数时，默认为true。
          .onChange((value: string) => {
            this.value = value;
          })
          .position({ top: 0 })
        Row() {
          Button({ type: ButtonType.Capsule }) {
            Row() {
              Image($r('sys.media.AI_subtitles'))
                .width(24)
                .height(24)
                .margin({ right: 8 })
              Text('AI总结')
                .fontSize(16)
                .fontColor(Color.Black)
            }
          }.onClick(()=>{
            this.promptAction.showToast({message:"敬请期待！"})
          }).backgroundColor(Color.Transparent)
        }
        .position({ bottom: LengthMetrics.vp(30), start: LengthMetrics.percent(0.5) })
        .translate({ x: '-50%' })
      }.height('100%').alignContent(Alignment.Center)
    }
    .padding({ top: 20 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .title("文字校对")
    .titleMode(NavigationTitleMode.Mini)
  }

  getValue() {
    this.result?.blocks.forEach((block: OCRBlock, index: number) => {
      block.lines.forEach((line: OCRLine, i: number) => {
        if (!line.delete) {
          if (this.value === '') {
            this.value = line.value;
          } else {
            this.value += "\n" + line.value;
          }
        }
      })
    })
  }
}