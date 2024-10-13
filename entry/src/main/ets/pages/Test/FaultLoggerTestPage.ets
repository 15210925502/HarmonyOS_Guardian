import { FaultLogger } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct FaultLoggerTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column() {
          Button('模拟没有被捕获的错误日志')
            .onClick(() => {
              // 抛出异常，程序会闪退，可以在EntryAbility中注册错误管理器，这样就不会闪退
              throw new Error('我没被捕捉到。。。嘿嘿')
            })
          Button('获取上报错误日志信息')
            .onClick(async () => {
            const logger = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
              AlertDialog.show({ message: JSON.stringify(logger, null, 2) })
          })
        }.constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('上报错误日志')
    .titleMode(NavigationTitleMode.Mini)
  }
}