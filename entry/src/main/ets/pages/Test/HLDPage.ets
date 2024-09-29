import { cleanerManager, permissionManager } from '../../manager'
import { dataSharePredicates } from '@kit.ArkData'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { promptAction } from '@kit.ArkUI'
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit'

@Entry
@Component
struct HLDPage {

  build() {
    Navigation() {
      Column({ space: 10 }) {
        Button('获取图片权限')
          .onClick(() => {
            this.requestPermissions()
          })
        Button('删除图片')
          .onClick(()=>{
            this.deleteAllPhotos()
          })
      }
    }
    .title('测试页入口')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }

  // 动态申请授权，（首次需要弹窗）
  async requestPermissions1(permissions: Permissions[]) {
    // 创建应用权限管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 向用户申请 user_grant权限
    const requestResult = await atManager.requestPermissionsFromUser(getContext(this), permissions)
    // every 检查权限是否都授权
    const isAuth = requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    // Promise.resolve(true) 返回成功，让await后面的代码继续执行
    // Promise.reject(false) 返回失败，让await后面的代码不被执行，Promise.reject(false)会被后面的catch捕获到
    return isAuth ? Promise.resolve(true) : Promise.reject(false)
  }

  async requestPermissions() {
    try {
      // 申请权限
      await this.requestPermissions1(['ohos.permission.READ_IMAGEVIDEO', 'ohos.permission.WRITE_IMAGEVIDEO'])
    } catch {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '手机瘦身功能需要获取权限，请在系统设置中打开相册开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      if (dialogRes.index === 1) {
        permissionManager.openPermissionSettingPage()
      }
    }
  }

  // 删除所有图片
  async deleteAllPhotos() {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext(this))
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions);
      let asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(this), [asset.uri]);
      console.info('deleteAssets successfully');
    } catch (err) {
      console.error(`deleteAssetsDemo failed with error: ${err.code}, ${err.message}`);
    }
  }
}