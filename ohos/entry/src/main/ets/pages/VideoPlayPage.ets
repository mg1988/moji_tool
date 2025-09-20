import { PdfFile } from "../model/PdfFile";

@Builder
export function VideoPlayPageBuilder(){
  VideoPlayPage()
}
@Entry
@Component
export struct VideoPlayPage{
  private controller: VideoController = new VideoController()
  @State videoSrc: string = '';
  aboutToAppear(): void {
    let pdfFile = this.getUIContext().getRouter().getParams() as PdfFile;
    this.videoSrc = pdfFile.filePath;
  }
  build() {
    Navigation(){
      Stack(){
        if (this.videoSrc !== undefined && this.videoSrc.length >0){
          Video({
            src: this.videoSrc,  // 设置视频源
            controller: this.controller //设置视频控制器，可以控制视频的播放状态
          }) .muted(false) // 设置是否静音
            .controls(true) // 设置是否显示默认控制条
            .position({top:0,left:0})
            .width('100%')
            .height('100%')
            .autoPlay(false) // 设置是否自动播放
            .loop(false) // 设置是否循环播放
            .objectFit(ImageFit.Contain) // 设置视频填充模式
            .onUpdate((event) => { // 更新事件回调
              console.info("Video update.");
            })
            .onPrepared((event) => { // 准备事件回调
              console.info("Video prepared.");
            })
            .onError(() => { // 失败事件回调
              console.error("Video error.");
            })
            .onStop(() => { // 停止事件回调
              console.info("Video stopped.");
            })
        }
      }
    }.padding({bottom:10})
  }
}