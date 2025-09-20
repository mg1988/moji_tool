import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { dataSharePredicates } from "@kit.ArkData";
import { hilog } from "@kit.PerformanceAnalysisKit";
import {ICallBack, IFrameCallBack, MP4Parser} from "@ohos/mp4parser";
import { util } from "@kit.ArkTS";
import fs from '@ohos.file.fs';

export  class FileUtils{
  // 文件大小格式化（支持B/KB/MB自动转换）
  static  formatFileSize(bytes: number): string {
    const units = ['B', 'KB', 'MB'];
    let size = bytes;
    let unitIndex = 0;

    while (size >= 1000 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return `${size.toFixed(2)}${units[unitIndex]}`;
  }

  // 时长格式化（HH:MM:SS）
  static formatDuration(milliseconds: number): string {
    const totalSeconds = Math.floor(milliseconds / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    return [hours, minutes, seconds]
      .map(v => v.toString().padStart(2, '0'))
      .join(':');
  }

  /**
   * 获取预览图片
   * @param phAccessHelper
   * @param fileUri
   * @returns
   */
  static async getThumbnailByUrl(phAccessHelper: photoAccessHelper.PhotoAccessHelper,fileUri:string): Promise<PixelMap | null> {
    try {
      // 获取视频资源
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', fileUri);
      let videoFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets({
          fetchColumns: ['width', 'height', 'orientation'],
          predicates: predicates
        });
      let asset: photoAccessHelper.PhotoAsset = await videoFetchResult.getFirstObject();

      // 配置缩略图参数
      let thumbnailSize: Size = { width: 0, height: 0 };
      if (asset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 90 ||
        asset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 270) {
        thumbnailSize.width = asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
        thumbnailSize.height = asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
      } else {
        thumbnailSize.width = asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
        thumbnailSize.height = asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
      }
      return asset.getThumbnail(thumbnailSize);
    } catch (error) {
      hilog.error(0x0000, '', `get acquireThumbnail failed, error: ${JSON.stringify(error)}`);
      return null;
    }
  }
  /**
   * 视频提取音频到本地
   * @param sourceVideoSandboxPath
   * @param splitAudioOutputPath
   * @param callBack
   */
  static  extractAudioToPcm(sourceVideoSandboxPath: string, splitAudioOutputPath: string,callBack:ICallBack) {
    // 执行提取音频指令
   //  ffmpeg -i input.aac -f s16le output.pcm
   let path = util.format('ffmpeg -i %s -f s16le %s', sourceVideoSandboxPath, splitAudioOutputPath);
    MP4Parser.ffmpegCmd(path,
      callBack);
  }
  static  extractAudio(sourceVideoSandboxPath: string, splitAudioOutputPath: string,callBack:ICallBack) {
    // 执行提取音频指令
    let path = util.format('ffmpeg -i %s -c:a copy -vn %s -y', sourceVideoSandboxPath, splitAudioOutputPath);
    MP4Parser.ffmpegCmd(path,
      callBack);
  }
  /**
   * 将源文件sourceUri复制到目标路径destinationPath
   * @param sourceUri
   * @param destinationPath
   */
  static  copyFile(sourceUri: string, destinationPath: string) {
    let sourceFile: fs.File | null = null;
    let destFile: fs.File | null = null;
    try {
      sourceFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);
      destFile = fs.openSync(destinationPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(sourceFile.fd, destFile.fd);
    } catch (err) {
      hilog.error(0x0000, 'CopyFile', `Failed to copy file：${err.message}`);
    } finally {
      if (sourceFile) {
        fs.closeSync(sourceFile);
      }
      if (destFile) {
        fs.closeSync(destFile);
      }
    }
  }
  // 从URI中提取文件名
  static  getFileNameFromUri(uri: string): string {
    const SEGMENTS = uri.split('/');
    return SEGMENTS[SEGMENTS.length - 1];
  }
}