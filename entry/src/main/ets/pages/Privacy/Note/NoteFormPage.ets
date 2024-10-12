// 页面参数
import { privacyNoteDB } from '../../../dataBase/PrivacyNoteDB'
import { prompt, promptAction, router } from '@kit.ArkUI'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

interface RouterParams {
  id?: number
}

@Entry
@Component
struct NoteDetailPage {
  // 标题
  @State title: string = ''
  // 内容
  @State content: string = ''
  // 页面参数
  @State routerParams: RouterParams = {}

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams
    if (params) {
      this.routerParams = params
      // 获取详细数据
      this.getDetail()
    }
  }

  // 分享笔记,模拟器不支持
  // 在帮助 api参考中搜索share kit 可查看相关内容
  sharNote() {
    try {
      // 构建分享数据
      const sharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
        title:this.title,
        content:this.content
      })
      // 构建分享控制器（显示分享面板，注册分享关闭事件）
      const shareController = new systemShare.ShareController(sharedData)
      const context = getContext() as common.UIAbilityContext
      // 显示分享面板
      shareController.show(context,{
        previewMode:systemShare.SharePreviewMode.DETAIL,
        selectionMode:systemShare.SelectionMode.SINGLE,

        // anchor:'shareButtonId',  //配置分享面板关联的控件ID

        // 配置分享面板显示的坐标
        // anchor:{
        //   // 必选，锚点坐标
        //   windowOffset:{x:100,y:100},
        //   // 可选，组件的宽高，配置后会综合计算组件的大小
        //   size:{width:50,height:50}
        // }

      })

      // 监听分享关闭事件
      shareController.on('dismiss',() => {
        promptAction.showToast({message:'分享成功，有奖励'})
      })
    }catch {
      promptAction.showToast({message:'不支持分享功能'})
    }
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text('保存')
        .fontSize(16)
        .fontColor(this.title.trim() !== '' ? $r('app.color.font') : $r('app.color.font_sub'))
        .enabled(this.title.trim() !== '')
        .onClick(() => {
          //保存(新增/修改)
          this.onSubmit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  // 点击返回按钮时触发,只有页面级别的才可调用，自定义组件不可用
  onBackPress(): boolean | void {
    // 如果有id就恢复默认返回事件
    if (this.routerParams.id) {
      return false
    }
    promptAction.showDialog({
      title: '温馨提示',
      message: '您输入的内容还没有保存，确定返回吗？',
      alignment: DialogAlignment.Center,
      buttons: [
        { text: '取消', color: $r('app.color.font_sub') },
        { text: '确定', color: $r('app.color.brand') }
      ]
    }).then((res) => {
      if (res.index === 1) {
        router.back()
      }
    })
    // 返回true，可阻断系统默认返回
    return true
  }

  async getDetail() {
    const list = await privacyNoteDB.select(this.routerParams.id)
    const detail = list[0]
    if (detail) {
      this.title = detail.title
      this.content = detail.content
    }
  }

  // 新增/保存数据
  async onSubmit() {
    if (this.routerParams.id) {
      // 更新数据
      privacyNoteDB.update({
        id: this.routerParams.id,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    } else {
      // 插入数据
      await privacyNoteDB.insert({
        id: null,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    }
    promptAction.showToast({ message: this.routerParams.id ? '更新数据成功' : '新增数据成功！' })
    router.back()
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 10 }) {
          Text('标题')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextInput({ placeholder: '请输入笔记标题', text: this.title })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .padding({ left: 10 })
            .onChange((text) => {
              this.title = text
            })
            .onSubmit(() => {
              // TODO：提交表单(新增/修改)
            })
          Text('内容')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextArea({ placeholder: '请输入笔记内容', text: this.content })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .layoutWeight(1)
            .padding(10)
            .onChange((text) => {
              this.content = text
            })
        }
        .padding({ bottom: 160 })

        if (this.routerParams.id) {
          // 底部按钮
          Row({ space: 10 }) {
            Button('删除')
              .type(ButtonType.Normal)
              .backgroundColor('#FF5E5D')
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：删除
              })
            Button('分享')
              .type(ButtonType.Normal)
              .backgroundColor($r('app.color.brand'))
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                //分享
                this.sharNote()
              })
          }
          .padding({ bottom: 80 })
        }
      }
      .padding({ left: 15, right: 15, top: 20 })

    }
    .title('笔记')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())

  }
}