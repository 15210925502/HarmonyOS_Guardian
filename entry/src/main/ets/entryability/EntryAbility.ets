import { AbilityConstant, errorManager, UIAbility, Want } from '@kit.AbilityKit';
import { promptAction, router, window } from '@kit.ArkUI';
import { FaultLogger, hilog } from '@kit.PerformanceAnalysisKit';
import { LoginInfoResponse, LOGIN_INFO, PrivacySettings } from '../common/constants';
import { PRIVACY_SETTINGS } from '../common/constants';
import { JSON } from '@kit.ArkTS';
import axios from '@ohos/axios';

let errorManagerID = -1

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // ⚠️⚠️⚠️  注册错误管理器
    errorManagerID = errorManager.on('error', {
      // 应用注册后，当应用产生未捕获catch的异常时的调用，做统一的错误管理
      async onUnhandledException() {
        const logger = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
        const currentFaultLog = logger[0]
        console.log('errorMessage', JSON.stringify(currentFaultLog))
        // 数据上传到后台
        await axios.post('https://xxxxxx',currentFaultLog)
        promptAction.showToast({
          message: '出现的未知错误，已自动上报到后台'
        })
      }
    })
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    // 销毁错误管理器
    errorManager.off('error',errorManagerID)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('/pages/Index'.slice(1), (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      // 持久化数据，整个项目一个字段只需要初始化一次
      PersistentStorage.persistProp('isHidePrivacy', false)
      // 隐私空间持久化存储
      PersistentStorage.persistProp<PrivacySettings>(PRIVACY_SETTINGS, {})
      // 登录后的用户信息
      PersistentStorage.persistProp<LoginInfoResponse>(LOGIN_INFO,{})
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  // 切前台
  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  // 切后台
  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    const routState = router.getState()
    // 判断切后台时，是否为隐私页面
    if (routState.path.includes('pages/Privacy')) {
      router.back({
        url: 'pages/Index'
      })
    }
  }
}
