import { FlutterPlugin, FlutterPluginBinding, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { Navi } from '../Navi';
import { router } from '@kit.ArkUI';
import { File } from '../model/File';
import { PdfFile } from '../model/PdfFile'
import { DaoSession, GlobalContext } from '@ohos/dataorm';
import { BusinessError } from '@kit.BasicServicesKit';

export class NativePlugin implements FlutterPlugin {
  private channel?: MethodChannel;

  getUniqueClassName(): string {
    return 'CameraPlugin'
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'com.mg.voice/native')
    this.channel.setMethodCallHandler({
      onMethodCall: (call, result) => {
        switch (call.method) {
          case "videoToTextPage":
            {
              Navi.toPage('pages/VideoToTextPage', undefined);
            }
            break;
          case "OCRImage":{
            //打开页面
            // 回传数据给 Flutter
            let args: Map<string, object> = call.args;
            let file: File = {
              fileName: args.get("fileName") + "",
              filePath: args.get("filePath") + "",
              fileId: "default_id"
            }
            Navi.toPage('pages/OCRPage', file);
          }
          break;
          case "pdfToImage": {
            //打开页面
            // 回传数据给 Flutter
            let args: Map<string, object> = call.args;
            let file: File = {
              fileName: args.get("fileName") + "",
              filePath: args.get("filePath") + "",
              fileId: "default_id"
            }
            Navi.toPage('pages/PdfPage', file);

            this.pdfToImage(result)
          }
            break;
          case "getPdfHistory": {
            // 该监听方法只能在文档加载前调用一次
            let session = GlobalContext.getContext().getValue("daoSession") as DaoSession;

            session.getBaseDao(PdfFile)
              .queryBuilder()
              .build()
              .list()
              .then((pdfFiles: PdfFile[]) => {
                result.success(JSON.stringify(pdfFiles));
                console.log(pdfFiles.length + "");
              })
              .catch((error: BusinessError) => {
                console.log("错误")
              })
          }
            break;
          case "deletePdfFile": {
            // 该监听方法只能在文档加载前调用一次
            let session = GlobalContext.getContext().getValue("daoSession") as DaoSession;
            let id: number = Number.parseInt(call.args.get("id"));
            session.getBaseDao(PdfFile).deleteByKeySync(id);
          }
          break;
          case "gotoVoice":{
            Navi.toPage('pages/VoicePage', undefined);
          }
          break;
          default:
            result.notImplemented()
            break;
        }
      }
    })
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
  }

  // native api
  pdfToImage(result: MethodResult) {

    result.success('跳转成功...')
  }
}