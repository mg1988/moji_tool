import { fileIo, fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { pdfService, PdfView, pdfViewManager } from '@kit.PDFKit';
import { File } from '../model/File';
import { ProgressButton, promptAction } from '@kit.ArkUI';
import { FileManager } from '../utils/FileManager';
import { BaseDao, DaoSession, Id, Property,GlobalContext } from '@ohos/dataorm';
import { PdfFile } from '../model/PdfFile';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { buffer } from '@kit.ArkTS';

@Builder
export function PdfPageBuilder() {
  PdfPage();
}

@Entry
@Component
struct PdfPage {
  private pdfDocument: pdfService.PdfDocument = new pdfService.PdfDocument();
  private controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();
  private context = this.getUIContext().getHostContext() as Context;
  @State loadResult: pdfService.ParseResult = pdfService.ParseResult.PARSE_ERROR_FORMAT;
  private session: DaoSession | undefined;
  private swiperController: SwiperController = new SwiperController();
  private index: number = 0;
  private file: File = {
    filePath: '',
    fileName: '',
    fileId: ''
  };
  @State files: string[] = [];
  @State result: boolean = false;
  @State title: string = '';
  @State value: number = 0;

  // 生成UUID

  // 存储到AssetStore
  aboutToAppear(): void {
    // 确保沙箱目录有input.pdf文档
    this.file = this.getUIContext().getRouter().getParams() as File;
    this.file.fileId = Date.now() + this.getUniqueId() + "";
    let filePath: string = this.file.filePath + '';
    this.title = this.file.fileName + '';
    this.pdfDocument.loadDocument(filePath);
    (async () => {
      // 该监听方法只能在文档加载前调用一次
      this.session = GlobalContext.getContext().getValue("daoSession") as DaoSession;
      this.controller.registerPageCountChangedListener((pageCount: number) => {
        hilog.info(0x0000, 'registerPageCountChanged-', pageCount.toString());
      });
      this.loadResult = await this.controller.loadDocument(filePath);

      // 注意：这里刚加载文档，请不要在这里立即设置PDF文档的预览方式
    })()
  }

  handleSaveButtonClick: SaveButtonCallback =
    async (event: ClickEvent, result: SaveButtonOnClickResult, error?: BusinessError) => {
      if (result == SaveButtonOnClickResult.SUCCESS) {
        try {
          const context = this.getUIContext().getHostContext();
          let helper = photoAccessHelper.getPhotoAccessHelper(context);
          // onClick触发后一分钟内通过createAsset接口创建图片文件，一分钟后createAsset权限收回。
          let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
          // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制。
          let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          // 写入文件
          let filePath = this.files[this.index];
          let fileUrl = fileUri.getUriFromPath(filePath.replace("file://", ""));
          const localFile: fs.File = fs.openSync(fileUrl, fs.OpenMode.READ_WRITE);
          const photoSize: number = fs.statSync(localFile.fd).size;
          let arrayBuffer: ArrayBuffer = new ArrayBuffer(photoSize);
          let readLength: number = fs.readSync(localFile.fd, arrayBuffer);
          let imageBuffer: ArrayBuffer = buffer.from(arrayBuffer, 0, readLength).buffer;
          await fileIo.write(file.fd, imageBuffer);
          // 关闭文件
          await fileIo.close(file.fd);
          this.getUIContext().getPromptAction().showToast({
            message: "保存成功！",
            duration: 2000,
            showMode: promptAction.ToastShowMode.TOP_MOST,
            bottom: 85
          });
        } catch (error) {
          console.error("error is " + JSON.stringify(error));
        }
      } else {
        console.error("errCode: " + error?.code);
        console.error("errMessage: " + error?.message);
      }
    };

  build() {
    Navigation() {
      if (this.result) {
        // 轮播组件
        this.buildSwiperImage()
      } else {
        Column() {
          // 选择Pdf文件
          PdfView({
            controller: this.controller,
            pageFit: pdfService.PageFit.FIT_WIDTH,
            showScroll: true
          }).id('pdfview_app_view').width('100%')
            .layoutWeight(1)
          if (this.loadResult === pdfService.ParseResult.PARSE_SUCCESS) {
            Stack({ alignContent: Alignment.Center }) {
              ProgressButton({
                progress:this.value,
                progressButtonWidth:120,
                content:'导出',
                enable:this.value <=0,
                clickCallback:async () => {
                  if (this.loadResult === pdfService.ParseResult.PARSE_SUCCESS) {
                    let basePath =  await FileManager.getPdfDocumentPath(this.getUIContext());
                    let isExist = fs.accessSync(basePath, fs.AccessModeType.EXIST)
                    if (!isExist) {
                      await fs.mkdir(basePath)
                    }
                    let outputPath = basePath + '/' + this.file.fileId + "/";
                    isExist = fs.accessSync(outputPath, fs.AccessModeType.EXIST)
                    if (!isExist) {
                      await fs.mkdir(outputPath)
                    }
                    let res =
                      this.pdfDocument.convertToImage(outputPath, pdfService.ImageFormat.PNG, (progress: number) => {
                        this.value = progress;
                        return progress;
                      });
                    this.getUIContext().getPromptAction().showToast({
                      message: res ? "导出成功" : "导出失败",
                      duration: 2000,
                      showMode: promptAction.ToastShowMode.TOP_MOST,
                      bottom: 85
                    });
                    if (!res) {
                      fs.rmdir(outputPath);
                    } else {
                      let pdfFile: PdfFile =
                        new PdfFile(undefined, this.file.fileName, this.file.filePath, Date.now(), 1);
                      this.session!.getBaseDao(PdfFile).insert(pdfFile).then((num: number) => {
                        console.log("num:" + num)
                      }).catch((err: BusinessError) => {
                        console.log("error:" + err.message)
                      });
                      fs.listFile(outputPath).then((files) => {
                        files.forEach(file => {
                          this.files.push("file://" + outputPath + file);
                        })
                      });
                      this.result = true;

                      // 将所有的页面转化为png图片，并存储在output文件夹里
                    }
                  }
                }
              }).id("button")
            }.width('100%').padding({ bottom: 20 })
          }
        }
      }

    }
    .title(this.title)
    .backButtonIcon($r('sys.media.ohos_ic_back'))
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: 20 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildSwiperImage() {
    // 轮播组件
    Swiper(this.swiperController) {
      ForEach(this.files, (path: string, index: number) => {
        Stack() {
          Image(path).width('100%').height('100%').objectFit(ImageFit.Contain);
          SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
            .backgroundColor(Color.Orange).onClick((this.handleSaveButtonClick))
            .iconSize(30)
            .align(Alignment.Bottom)
            .padding(0);
        };

      }, (path: string) => path);
    }.width('100%').height('100%')
    .onChange((index: number) => {
      console.info(index.toString());
      this.index = index;
    })
  }

  @
  Builder
  buildTitle() {
    Row() {
      Text(this.title).fontSize(14).margin({ left: 20 })
    }.alignItems(VerticalAlign.Center)
  }

}