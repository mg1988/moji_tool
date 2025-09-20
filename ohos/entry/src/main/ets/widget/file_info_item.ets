import { VideoInfo } from "../model/VideoInfo";
import { FileUtils } from "../utils/FileUtils";

@Component
export struct FileInoItem{
  @ObjectLink file:VideoInfo;
  callBack?:Function;

  build() {
    Column() {
      Stack() {
        Image(this.file.audioMap)
          .width('100%')
          .borderRadius(8)
          .height('70%')
          .borderRadius({
            topLeft:20,
            topRight:20
          })
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {

            Text(this.file.name)
              .fontColor('rgb(255, 255, 255)')
              .fontSize(15)
              .margin({ left: 10 })
            Text(FileUtils.formatDuration(this.file.videoTime))
              .fontColor('rgb(255, 255, 255)')
              .fontSize(15)
              .margin({ right: 10 })
          }
          .margin({ top: 10 })

        }.alignItems(HorizontalAlign.Start)
        .align(Alignment.Top)
        .height('70%')
        .width('100%')
        Text(this.file.text)
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Text(FileUtils.formatFileSize(this.file.size))
              .fontSize(15)
              .fontColor('rgb(255, 255, 255)')
              .margin({ left: 10 })
             Button(){
               Text("提取文本")
                 .fontColor($r('app.color.main_app_color'))
                 .fontSize(15)
                 .margin(5)
             }.backgroundColor(Color.White).padding({right:5})
            .onClick(()=>{
              if (this.callBack !== undefined) {
                this.callBack();
              }
            })
          }
          .margin({ bottom: 10 })
        }
        .height('70%')
        .width('100%')
        .justifyContent(FlexAlign.End)
         if (this.file.isLoading){
           this.BuildRecognitionOverlay();
         }
      }

    }
  }
  @Builder
   BuildRecognitionOverlay() {
    Column() {
      Row() {
        LoadingProgress()
          .color('#2196F3')
          .width(48)
          .height(48)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(100)
      .backgroundColor('#00000080')

      Text('正在转换...')
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ top: 16 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#00000040')
  }
}