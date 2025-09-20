import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LengthMetrics } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

import { dataSharePredicates } from '@kit.ArkData';
import { VideoInfo } from '../model/VideoInfo';
import { FileInoItem } from '../widget/file_info_item';
import { PdfFile } from '../model/PdfFile';
import { FileUtils } from '../utils/FileUtils';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { FileManager } from '../utils/FileManager';
import FileCapturer from '../utils/FileCapturer';
import { MP4Parser } from '@ohos/mp4parser';

let TAG = "VideoToTextPage"
@Builder
export function VideoToTextPageBuilder(){
  VideoToTextPage()
}


@Entry
@Component
export struct VideoToTextPage {
  asrEngine?: speechRecognizer.SpeechRecognitionEngine;
  @State sessionId: string = '123456';
  @State sessionId2: string = "1234567";
  @State files:VideoInfo[]= []
  @State isLoading:boolean = false;
  private mFileCapturer = new FileCapturer();
  aboutToAppear(): void {
    //初始化引擎
    // 创建引擎，通过callback形式返回
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "long" };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };
    // 调用createEngine方法
    speechRecognizer.createEngine(initParamsInfo,
      (err: BusinessError, speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          console.info('Succeeded in creating engine.');
          // 接收创建引擎的实例
          this.asrEngine = speechRecognitionEngine;
        } else {
          console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
        }
      });
  }

  build() {
    Navigation() {
      Stack(){
        List(){
          ForEach(this.files,(file:VideoInfo,index:number)=>{
           ListItem(){
             FileInoItem({file:file,callBack: async ()=>{
                  file.isLoading = true;
                  this.asrEngine!.finish(this.sessionId2)
                  let fileName = FileUtils.getFileNameFromUri(file.path);
                 let path = await FileManager.getVideoDocumentPath(this.getUIContext())+"/"+fileName;
                 // 将源视频放置到沙箱
                  await FileUtils.copyFile(file.path, path);
                   let outputPath = await FileManager.getVoiceDocumentPath(this.getUIContext())+"/"+fileName+".aac";
                  FileUtils.extractAudio(path,outputPath,{callBackResult:(code:number)=>{
                    if (code == 0) {
                      try {
                        file.audioPath = outputPath;
                        this.mFileCapturer.setFilePath(outputPath);
                        this.getUIContext().getPromptAction().showToast({
                          message: "音频分离成功！",
                          duration: 2000
                        })
                        this.audioToText(file);
                      } catch (e) {
                        hilog.error(0x0000, TAG, `Failed to extract audio. Error: `, e);
                      }
                    }else {
                      file.isLoading = false;
                      this.getUIContext().getPromptAction().showToast({
                        message: "音频分离失败！",
                        duration: 2000
                      })
                    }
                  }})
             }}).onClick(()=>{
               let pdfFile = new PdfFile(undefined,file.name,file.path,Date.now(),1);
               this.getUIContext().getRouter().pushUrl({url:"pages/VideoPlayPage",params:pdfFile})
             })
           }.margin(10)
          })
        }.position({top:0,left:0}).margin({bottom:60})
        Row(){
          Image($r('sys.media.ic_grid_video')).width(24).height(24)
          Column(){
            Text('普通用户转换不能超过 60s')

            Text('好评用户不限时长')
          }.alignItems(HorizontalAlign.Start).margin({left:10,top:10,bottom:10})
        }.position({bottom:LengthMetrics.vp(0),start:LengthMetrics.percent(0.5)})
        .translate({x:'-50%'})
        .padding({bottom:10,left:10,right:10})
        .backgroundColor($r('app.color.main_app_color'))
        .width('100%')
        if (this.isLoading){
          this.BuildRecognitionOverlay();
        }
      }.height('100%').width('100%')

    }
    .title("视频转文字")
    .titleMode(NavigationTitleMode.Mini)
    .padding({top:20})
    .menus([{
      value: "导入视频",
      icon:$r('sys.media.ohos_ic_public_video'),
      action: () => {
        this.selectImage();
      }
    }])
  }
  private async selectImage() {
    let uri = await this.openPhoto();
    if (uri === undefined) {
      hilog.error(0x0000, 'OCRDemo', "Failed to get uri.");
      return;
    }
    this.uriGetAssets(uri);
  }
  //根据资源查询对应的信息
  async uriGetAssets(fileUri:string) {
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.getUIContext().getHostContext());
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();////
      // 配置查询条件，使用PhotoViewPicker选择图片返回的uri进行查询
      predicates.equalTo('uri', fileUri);/////
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [photoAccessHelper.PhotoKeys.WIDTH, photoAccessHelper.PhotoKeys.HEIGHT,
          photoAccessHelper.PhotoKeys.TITLE, photoAccessHelper.PhotoKeys.SIZE, photoAccessHelper.PhotoKeys.DURATION],
        predicates: predicates
      };

      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);

      // 得到uri对应的PhotoAsset对象，读取文件的部分信息
      const asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      // 必须确保fetchOptions中包含SIZE和DURATION字段（重要！）
      const rawSize = asset.get(photoAccessHelper.PhotoKeys.SIZE); // 单位：字节
      const rawDuration = asset.get(photoAccessHelper.PhotoKeys.DURATION); // 单位：毫秒

      let videoInfo = new VideoInfo();
      // 添加格式转换逻辑
      videoInfo.name = asset.displayName;
      videoInfo.size = Number(rawSize);
      videoInfo.path = fileUri;
      videoInfo.videoTime = Number(rawDuration);
      videoInfo.audioMap = await FileUtils.getThumbnailByUrl(phAccessHelper,fileUri);

      hilog.info(0x0000,'asset displayName: ', asset.displayName);
      hilog.info(0x0000,'asset uri: ', asset.uri);
      hilog.info(0x0000,'asset photoType: ', asset.photoType.toString());
      hilog.info(0x0000,'asset width: ', asset.get(photoAccessHelper.PhotoKeys.WIDTH).toString());
      hilog.info(0x0000,'asset height: ', asset.get(photoAccessHelper.PhotoKeys.HEIGHT).toString());
      hilog.info(0x0000,'asset SIZE: ' , asset.get(photoAccessHelper.PhotoKeys.SIZE).toString());
      hilog.info(0x0000,'asset DURATION: ' , asset.get(photoAccessHelper.PhotoKeys.DURATION).toString());
      this.files.push(videoInfo);
    } catch (error) {
      hilog.error(0x0000,'uriGetAssets failed with err: ' , JSON.stringify(error));
    }
  }


  private openPhoto(): Promise<string> {
    return new Promise<string>((resolve) => {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        maxSelectNumber: 1
      }).then(async (res: photoAccessHelper.PhotoSelectResult) => {
        // 源视频沙箱路径
        this.isLoading = true;
        let url = res.photoUris[0];
       this.isLoading = false;
        resolve(url);
      }).catch((err: BusinessError) => {
        this.isLoading = false;
        hilog.error(0x0000, 'OCRDemo', `Failed to get photo image uri. code: ${err.code}, message: ${err.message}`);
        resolve('');
      })
    })
  }
  // 设置回调
  private setListener(file:VideoInfo) {
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        file.text = '';
        console.info(TAG, `onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(TAG, `onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        console.info(TAG, `onResult, sessionId: ${sessionId} result: ${JSON.stringify(result)}`);
        file.text = result.result;
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        file.isLoading = false;
        console.info(TAG, `onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      // 更多错误码请参考错误码参考
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error(TAG, `onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    }
    // 设置回调
    this.asrEngine!.setListener(setListener);
  };
  // 写音频流
  private async audioToText(videoFile:VideoInfo) {
    try {
      // Set the parameters related to the start of identification.
      let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: this.sessionId,
        audioInfo: audioParam
      }
      this.setListener(videoFile);
      this.asrEngine!.startListening(recognizerParams);
      let fileUrl = videoFile.audioPath.replace("file://", "/");
      this.mFileCapturer.setFilePath(fileUrl);
      let data: ArrayBuffer;
      this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
        data = dataBuffer;
        let uint8Array: Uint8Array = new Uint8Array(dataBuffer);
        this.asrEngine!.writeAudio(this.sessionId2, uint8Array);
      });
      await this.mFileCapturer.start();
      this.mFileCapturer.release();
    } catch (err) {
      videoFile.text = `Message: ${err.message}.`
      videoFile.isLoading = false;
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
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#00000040')
  }
}