import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'
import { promptAction, router } from '@kit.ArkUI'
import { encryptMD5 } from '../../../common/utils/encryptMD5'

interface RouterParams {
  isForgetPassword?: boolean
}

@Entry
@Component
struct AuthPatternLockSettingsPage {
  // 获取隐私空间设置
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 正在输入的图形密码
  @State inputPassword: number[] = []
  // 第一次输入的密码
  @State firstPassword: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 路由参数
  @State routerParams: RouterParams = {}
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 控制器
  private patternLockController: PatternLockController = new PatternLockController()

  build() {
    Navigation() {
      Column() {
        Text('当前输入的临时密码：' + this.inputPassword)
        Text('第一次输入的密码：' + this.firstPassword)
      }

      Column({ space: 20 }) {
        Column({ space: 10 }) {
          // 请输入密码
          Text(this.firstPassword.length === 0 ? '设置手势密码' : '再次确认手势密码')
            .fontSize(16)
            .fontColor($r('app.color.font'))
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor($r('app.color.danger'))
          } else {
            Text(this.firstPassword.length === 0 ? '请绘制手势密码，至少链接4个点' : '请再次输入确认手势密码')
              .fontSize(12)
              .fontColor($r('app.color.font_sub'))
          }
        }

        PatternLock(this.patternLockController)
          .sideLength(320)// 宽高
          .circleRadius(12)// 圆点半径
          .pathStrokeWidth(10)// 线宽度
          .regularColor('#d9d9d9')// 未选中圆点色
          .activeColor('#800a59f7')// 经过圆点色
          .selectedColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
          .pathColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
          .onDotConnect(() => {
            // 密码输入选中宫格圆点时触发该回调
            clearTimeout(this.timeoutID)
          })
          .onPatternComplete((input: number[]) => {
            this.inputPassword = input
            // 密码输入结束时触发该回调
            if (input.length < 4) {
              this.errorMessage = '输入错误，最少连接4个点,请重新输入'
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
            } else {
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
              this.errorMessage = ''
              if (this.firstPassword.length > 0) {
                // 对象对比是对比的内存地址
                // 对比两次输入密码是否一致
                if (this.firstPassword.toString() === input.toString()) {
                  promptAction.showToast({ message: '密码设置成功' })
                  this.privacySettings.patternPassword = encryptMD5(input.toString())
                  router.pushUrl({url:'/pages/Privacy/PrivacyIndexPage'.slice(1)})
                } else {
                  this.errorMessage = '两次输入密码一致'
                  this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
                }
              } else {
                // 保存首次输入的密码
                this.firstPassword = input
              }
            }
            setTimeout(() => {
              this.timeoutID = this.patternLockController.reset()
              this.inputPassword = []
            }, 500)
          })
      }
      .padding({ top: 140 })
    }
    .title('隐私空间')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}