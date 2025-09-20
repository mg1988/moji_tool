import { textRecognition } from '@kit.CoreVisionKit'
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { OCRBlock, OCRLine, OCRResult } from '../models/OCRResult';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { OCRText } from '../widget/OCRText';
import { Point } from '@kit.TestKit';
import { File } from '../model/File';

@Builder
export function OCRPageBuilder() {
  OCRPage();
}

@Entry
@Component
struct OCRPage {
  private imageSource: image.ImageSource | undefined = undefined;
  @State chooseImage: PixelMap | undefined = undefined;
  @State ocrResult: OCRResult | null = null;
  @State isRecognizing: boolean = false;
  @State showOverlay: boolean = false;
  @State recognitionProgress: number = 0;
  @State imageLocation: Point = { x: 0, y: 0 };

  async aboutToAppear(): Promise<void> {
    const initResult = await textRecognition.init();
    // 确保沙箱目录有input.pdf文档
   let file = this.getUIContext().getRouter().getParams() as File;
    if (file !== undefined && file.filePath !== undefined) {
      this.loadImage(file.filePath);
    }
    hilog.info(0x0000, 'OCRDemo', `OCR service initialization result:${initResult}`);
  }

  async aboutToDisappear(): Promise<void> {
    await textRecognition.release();
    hilog.info(0x0000, 'OCRDemo', 'OCR service released successfully');
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

      Text('正在识别中...')
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

  build() {
    Stack() {
      // 主要内容区域
      Stack() {
        if (this.chooseImage) {
          Stack() {
            Image(this.chooseImage)
              .objectFit(ImageFit.Contain)
              .borderRadius(12)
              .onAreaChange((oldValue: Area, newValue: Area) => {
                let x = newValue.position.x as number;
                let y = newValue.position.y as number;
                //将 popup的显示在 按钮的下面
                this.imageLocation = { x: x, y: y }
                // this.pos= newValue.position
              })
            if (this.ocrResult) {
              Stack({ alignContent: Alignment.TopStart }) {
                ForEach(this.ocrResult.blocks, (block: OCRBlock) => {
                  ForEach(block.lines, (line: OCRLine) => {
                    OCRText({ line: line, isRecognizing: this.isRecognizing, imageLocation: this.imageLocation })
                  })
                })
                Button({ type: ButtonType.Capsule }) {
                  Row() {
                    Image($r('sys.media.ohos_ic_public_text'))
                      .width(24)
                      .height(24)
                      .margin({ right: 8 })
                    Text('导出选中的文字')
                      .fontSize(16)
                      .fontColor(Color.Black)
                  }
                }
                .padding(10)
                .position({bottom:LengthMetrics.vp(30),start:LengthMetrics.percent(0.5)})
                .translate({x:'-50%'})
                .alignSelf(ItemAlign.Center)
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({ url: "pages/OCRResultPage", params: this.ocrResult })
                })
              }.width('100%')
              .alignContent(Alignment.Center)
              .height('100%').backgroundColor('#61000000')
            } else {
              Button({ type: ButtonType.Capsule }) {
                Row() {
                  Image($r('sys.media.ai_recognize'))
                    .width(24)
                    .height(24)
                    .margin({ right: 8 })
                  Text('识别')
                    .fontSize(16)
                    .fontColor(Color.Black)
                }
              }
              .position({bottom:LengthMetrics.vp(30),start:LengthMetrics.percent(0.5)})
              .translate({x:'-50%'})
              .backgroundColor(Color.Transparent)
              .height(48)
              .enabled(!this.isRecognizing)
              .onClick(() => this.textRecognitionTest())
            }
            if (this.isRecognizing) {
              this.BuildRecognitionOverlay()
            }
          }
          .width('100%')
          .height('100%')
        } else {
          Column() {
            Image($r('sys.media.ic_grid_image'))
              .width(120)
              .height(120)
              .opacity(0.5)
            Text('点击下方按钮选择图片')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
            // 底部按钮区域
            Button({ type: ButtonType.Capsule }) {
              Row() {
                Image($r('sys.media.ohos_ic_public_camera'))
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
                Text('选择图片')
                  .fontSize(16)
                  .fontColor(Color.White)
              }
            }
            .width('40%')
            .height(48)
            .backgroundColor('#2196F3')
            .margin({ right: 12, top: 10 })
            .onClick(() => this.selectImage())

          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .backgroundColor('#F5F5F5')

    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
  }

  private textRecognitionTest() {
    if (!this.chooseImage) {
      this.getUIContext().getPromptAction().showToast({ message: '请先选择图片' });
      return;
    }

    this.isRecognizing = true;
    this.ocrResult = null;

    // 调用文本识别接口
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: this.chooseImage
    };
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };

    // 添加识别超时保护
    const timeout = setTimeout(() => {
      if (this.isRecognizing) {
        this.isRecognizing = false;
        promptAction.showToast({ message: '识别超时，请重试' });
      }
    }, 30000);

    textRecognition.recognizeText(visionInfo, textConfiguration)
      .then((data: textRecognition.TextRecognitionResult) => {
        clearTimeout(timeout);
        this.isRecognizing = false;

        // 识别成功，获取对应的结果
        let recognitionString = JSON.stringify(data);
        hilog.info(0x0000, 'OCRDemo', `Succeeded in recognizing text:&nbsp;${recognitionString}`);

        // 解析识别结果并创建OCRResult实例
        this.ocrResult = OCRResult.fromJSON(recognitionString);

        // 显示成功提示
        promptAction.showToast({
          message: `识别完成，共识别出${this.ocrResult.blocks.length}个文本块`,
          duration: 2000
        });
      })
      .catch((error: BusinessError) => {
        clearTimeout(timeout);
        this.isRecognizing = false;
        hilog.error(0x0000, 'OCRDemo', `Failed to recognize text. Code: ${error.code}, message: ${error.message}`);

        // 显示错误提示
        promptAction.showToast({
          message: `识别失败: ${error.message}`,
          duration: 3000
        });
      });
  }

  private async selectImage() {
    let uri = await this.openPhoto();
    if (uri === undefined) {
      hilog.error(0x0000, 'OCRDemo', "Failed to get uri.");
      return;
    }
    this.loadImage(uri);
  }

  private openPhoto(): Promise<string> {
    return new Promise<string>((resolve) => {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      }).then((res: photoAccessHelper.PhotoSelectResult) => {
        resolve(res.photoUris[0]);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'OCRDemo', `Failed to get photo image uri. code: ${err.code}, message: ${err.message}`);
        resolve('');
      })
    })
  }

  private loadImage(name: string) {
    setTimeout(async () => {
      try {
        let fileSource = await fileIo.open(name, fileIo.OpenMode.READ_ONLY);
        this.imageSource = image.createImageSource(fileSource.fd);
        this.chooseImage = await this.imageSource.createPixelMap();
        await fileIo.close(fileSource);
        let file = this.getUIContext().getRouter().getParams() as File;
        if (file !== undefined) {
          this.textRecognitionTest();
        }
      } catch (error) {
        hilog.error(0x0000, 'OCRDemo', `Failed to open file. Error: ${error}`);
      }
    }, 100)
  }
}