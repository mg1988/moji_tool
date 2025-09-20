import { speechRecognizer } from "@kit.CoreSpeechKit";
import { AsyncCallback, BusinessError } from "@kit.BasicServicesKit";

export class SpeechRecognizerUtil{
  /**
   * 监听识别
   * @param sessionId
   * @param asrEngine
   */
  static  startListeningForRecording(sessionId:string,asrEngine: speechRecognizer.SpeechRecognitionEngine) {
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 } //audioInfo参数配置请参考AudioInfo
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 20000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    asrEngine.startListening(recognizerParams);
  };

}