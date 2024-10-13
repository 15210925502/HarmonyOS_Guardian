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
            //事件
            // 点击事件:onClick(()=>{})
            // 输入框变化内容事件:onChange((value是输入的内容)=>{})
            // 键盘点击提交事件(回车):onSubmit(()=>{})
            // 输入框聚焦onFocus、失焦onBlur
            // 区域大小变化onAreaChange
            .onClick(async () => {
            const logger = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
              //提示方法3
              //轻提示：土司  promptAction.showToast({})
              //重提示：弹层  promptAction.showDialog({})
              //重提示：弹层(无需引入包)  AlertDialog.show({})
              // 弹层配置：
              // title,message,buttons
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