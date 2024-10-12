import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PrivacySettings } from '../common/constants';
import { PRIVACY_SETTINGS } from '../common/constants';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('/pages/Privacy/Note/NoteIndexPage'.slice(1), (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      // 持久化数据，整个项目一个字段只需要初始化一次
      PersistentStorage.persistProp('isHidePrivacy',false)
      // 隐私空间持久化存储
      PersistentStorage.persistProp<PrivacySettings>(PRIVACY_SETTINGS,{})
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
      router.back({url:'pages/Index'})
    }
  }
}
