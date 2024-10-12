import { router } from '@kit.ArkUI'
import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'
import { encryptMD5 } from '../../../common/utils/encryptMD5'
import { userAuthManager } from '../../../manager/UserAuthManager'

@Entry
@Component
struct AuthPatternLockPage {
  // 获取 AppStorage 的数据
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 输入的密码
  @State inputPasswords: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 错误输入次数
  @State errorInputCount: number = 0
  // 是否允许操作
  @State isEnable: boolean = true
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 图形密码控制器
  private patternLockController: PatternLockController = new PatternLockController()

  setErrorMessage(message: string) {
    this.errorMessage = message
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
  }

  clearErrorMessage() {
    this.errorMessage = ''
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
  }

  onPatternComplete(input: number[]) {
    // 更新线条颜色，临时使用
    this.inputPasswords = input
    if (input.length < 4) {
      this.setErrorMessage('密码小于4位，请重新输入')
    } else {
      this.clearErrorMessage()
      if (this.privacySettings.patternPassword === encryptMD5(input.toString())) {
        router.pushUrl({ url: '/pages/Privacy/PrivacyIndexPage'.slice(1) })
      } else {
        this.setErrorMessage('密码不正确，请重新输入')
      }
    }
    // 输入完成后，清空界面
    this.timeoutID = setTimeout(() => {
      this.patternLockController.reset()
      this.inputPasswords = []
    }, 500)
  }

  aboutToAppear(): void {
    // 模拟器不支持，所有返回都是false
    this.startUserAuth()
  }

  // 生物识别认证
  startUserAuth() {
    // 判断是否有认证权限
    if (userAuthManager.checkUserAuthSupport()) {
      // 有的话，开始认证
      userAuthManager.startUserAuth()
      // 认证成功，跳转到主页
      router.pushUrl({ url: 'pages/Privacy/PrivacyIndexPage' })
    }
  }

  build() {
    Column() {
      // 标题
      Navigation() {
        Column() {
          Text('patternPassword：' + this.privacySettings.patternPassword)
          Text('passwords：' + this.inputPasswords.toString())
        }

        Column({ space: 20 }) {
          Column({ space: 10 }) {
            // 请输入密码
            Text(this.isEnable ? '请输入密码' : '隐私空间已锁定')
              .fontSize(16)
              .fontColor($r('app.color.font'))
            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(12)
                .fontColor($r('app.color.danger'))
            } else {
              Text('输入密码进入隐私空间')
                .fontSize(12)
                .fontColor($r('app.color.font_sub'))
            }
          }

          PatternLock(this.patternLockController)
            .sideLength(320)// 宽高
            .circleRadius(12)// 圆点半径
            .pathStrokeWidth(10)// 线宽度
            .regularColor('#ffd9d9d9')// 未选中圆点色
            .activeColor('#800a59f7')// 经过圆点色
            .selectedColor(this.errorMessage && this.inputPasswords.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
            .pathColor(this.errorMessage && this.inputPasswords.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
            .enabled(this.isEnable)
            .onDotConnect(() => {
              // 密码输入选中宫格圆点时触发该回调
              clearTimeout(this.timeoutID)
            })
            .onPatternComplete((input: number[]) => {
              // 密码输入结束时触发该回调
              this.onPatternComplete(input)
            })

          Row({ space: 20 }) {
            Text('忘记密码')
              .fontSize(14)
              .fontColor($r('app.color.font2'))
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Privacy/Auth/ForgetPasswordPage',
                })
              })
          }
        }
        .padding({ top: 140 })
      }
      .title('隐私空间')
      .titleMode(NavigationTitleMode.Mini)
      .mode(NavigationMode.Stack)
      .hideTitleBar(false)
    }
    .height('100%')
  }
}