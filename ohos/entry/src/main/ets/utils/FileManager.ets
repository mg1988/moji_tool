import fs from '@ohos.file.fs';
export class FileManager{

  static  documentPath(context:UIContext):string{
    let outputPath = context.getHostContext()?.filesDir;
    return outputPath!;
  }
  /**
   * 存储pdf文件的目录
   * @param context
   * @returns
   */
  static async getPdfDocumentPath(context:UIContext): Promise<string>{
    let path = FileManager.documentPath(context)+"/pdf";
    let isExist = fs.accessSync(path, fs.AccessModeType.EXIST)
    if (!isExist) {
      await fs.mkdir(path)
    }
    return path;
  }
  /**
   * 获取音频文件路径
   * @param context
   * @returns
   */
  static async getVoiceDocumentPath(context:UIContext): Promise<string>{
    let path = FileManager.documentPath(context)+"/voice";
    let isExist = fs.accessSync(path, fs.AccessModeType.EXIST)
    if (!isExist) {
      await fs.mkdir(path)
    }
    return path;
  }
  /**
   * 存储视频文件的目录
   * @param context
   * @returns
   */
  static async getVideoDocumentPath(context:UIContext): Promise<string>{
    let path = FileManager.documentPath(context)+"/video";
    let isExist = fs.accessSync(path, fs.AccessModeType.EXIST)
    if (!isExist) {
      await fs.mkdir(path)
    }
    return path;
  }
}