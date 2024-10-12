// 指纹或面容ID（生物特征识别）
import { userAuth } from '@kit.UserAuthenticationKit'

class UserAuthManager {
  // 认证信任等级，等级越高，指纹或面容识别越严格
  authTrustLevel: userAuth.AuthTrustLevel = userAuth.AuthTrustLevel.ATL3
  // 认证类型列表
  authTypes: userAuth.UserAuthType[] = [
    userAuth.UserAuthType.PIN, //锁屏密码
    userAuth.UserAuthType.FACE, //面部识别
    userAuth.UserAuthType.FINGERPRINT//指纹识别
  ]
  // 设置认证参数
  private authParam: userAuth.AuthParam = {
    // 挑战值，用来防重防攻击
    challenge: new Uint8Array([49, 49, 49, 49, 49, 49]),
    // 认证类型列表
    authType: this.authTypes,
    // 认证信任等级
    authTrustLevel: this.authTrustLevel
  }
  // 配置认证界面
  private widgetParam: userAuth.WidgetParam = {
    // 用户认证界面的标题，仅在PIN/指纹、密码时展示
    title: '请进行身份认证'
  }

  // 查询认证能力是否识别，有一项支持即可
  checkUserAuthSupport() {
    // 遍历认证类型列表
    const res = this.authTypes.map((item) => {
      // 检查是否可用
      try {
        // ⚠️⚠️⚠️首先要在模拟器设置页面，添加锁屏密码
        userAuth.getAvailableStatus(item, this.authTrustLevel)
        return true
      } catch {
        return false
      }
    })
    // ⚠️⚠️⚠️some  有一项为true,就返回true
    // ⚠️⚠️⚠️every 所有项为true,才返回true
    // 有一项为true,就返回true
    return res.some(v => v === true)
  }

  //⚠️⚠️⚠️ 发起原生用户认证
  // 首先要申请权限:ohos.permission.ACCESS_BIOMETRIC。
  // 1.调用 getUserAuthInstance 获取认证对象。
  //1.1 指定用户认证相关参数AuthParam(包括挑战值、认证类型UserAuthType列表和认证等级AuthTrustLevel)、配置认证控件界面widgetParam,
  //2.调用 UserAuthInstance.on 接口订阅认证结果。
  //3.调用 UserAuthInstance.start 接口发起认证
  // 通过IAuthCallback回调返回认证结果UserAuthResult。
  // 当认证成功时返回认证通过类型(UserAuthType)和令牌信息(AuthToken)。

  startUserAuth(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      // 获取认证对象
      const userAuthInstance = userAuth.getUserAuthInstance(this.authParam, this.widgetParam)
      // 订阅认证结果
      userAuthInstance.on('result', {
        onResult(result) {
          if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
            resolve(true)
          } else {
            reject(false)
          }
          // 认证结束后，关闭订阅，释放资源
          userAuthInstance.off('result')
        }
      })
      // 开始认证
      userAuthInstance.start()
    })
  }
}

export const userAuthManager = new UserAuthManager()