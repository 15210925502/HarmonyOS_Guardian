import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

class PermissionManager {
  // 检查是否授权
  checkPermissions(permissions: Permissions[]) {
    // 创建应用权限管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 获取bundle包信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    // 提取TokenID
    const tokenID = bundleInfo.appInfo.accessTokenId
    // 检测是否授权
    const grantStatus = permissions.map(item => atManager.checkAccessTokenSync(tokenID, item))
    // 返回权限组的返回结果，所有元素都满足返回ture,否则返回false
    const isAuth = grantStatus.every(value => value === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    return isAuth
  }

  // 动态申请授权，（首次需要弹窗）
  async requestPermissions(permissions: Permissions[]) {
    // 创建应用权限管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 向用户申请 user_grant权限
    const requestResult = await atManager.requestPermissionsFromUser(getContext(), permissions)
    // every 检查权限是否都授权
    const isAuth = requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    // Promise.resolve(true) 返回成功，让await后面的代码继续执行
    // Promise.reject(false) 返回失败，让await后面的代码不被执行，Promise.reject(false)会被后面的catch捕获到
    return isAuth ? Promise.resolve(true) : Promise.reject(false)
  }

  // 打开系统设置的权限管理页，（处理授权结果）
  openPermissionSettingPage() {
    // 获取应用上下文，并通过as断言收窄类型为UIAbilityContext，否则context默认类型无法调用startAbility方法
    const context = getContext() as common.UIAbilityContext
    // 获取bundle包信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    context.startAbility({
      bundleName: 'com.huawei.hmos.settings', //固定写法CV:设置页面的包名
      abilityName: 'com.huawei.hmos.settings.MainAbility', //固定写法CV:设置页面的Ability名
      uri: 'application_info_entry', //固定写法CV:打开  设置-> 应用和元服务
      parameters: {
        // 打开指定应用（包）的详情页面
        pushParams: bundleInfo.name
      }
    })
  }
}

export const permissionManager = new PermissionManager()