
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { NativePlugin } from '../plugins/NativePlugin';
import { DataManager } from '../utils/DataManager';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    // 注册插件
    flutterEngine.getPlugins()?.add(new NativePlugin());
    new DataManager().init(this);
  }
  // onWindowStageCreate(windowStage: window.WindowStage): void {
  //   // Main window is created, set main page for this ability
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
  //   let context = this.context;
  //   let resourceManager: resourceManager.ResourceManager = context.resourceManager;
  //   AppStorage.setOrCreate('resourceManager', resourceManager);
  //   windowStage.loadContent('pages/Index', (err, data) => {
  //     if (err.code) {
  //       hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
  //       return;
  //     }
  //     hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
  //
  //     let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext()
  //     AppStorage.setOrCreate('uiContext', uiContext);
  //   });
  // }
  // onWindowStageDestroy(): void {
  //   // Main window is destroyed, release UI related resources
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  // }
  //
  // onForeground(): void {
  //   // Ability has brought to foreground
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  // }
  //
  // onBackground(): void {
  //   // Ability has back to background
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  // }
}
