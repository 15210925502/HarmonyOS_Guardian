import { ValuesBucket } from '@kit.ArkData'
import dayjs from 'dayjs'
import duration from 'dayjs/plugin/duration'
import { EmptyTipsComp } from '../../../common/components'
import { CustomInputDialog } from '../../../common/dialog'
import { audioCapturerManager } from '../../../manager/AudioCapturerManager'
import { fileIo } from '@kit.CoreFileKit'
import { privacyRecorderDB } from '../../../dataBase/PrivacyRecorderDB'
import { PrivacyRecorderDBInfo } from './PrivacyRecorderDBInfo'

// 用于把毫秒格式化成 mm:ss 的相对时间插件
dayjs.extend(duration)

@Entry
@Component
struct RecorderIndexPage {
  @State list: PrivacyRecorderDBInfo[] = []
  @State tempInputText: string = ''
  @State onConfirmEnable: boolean = true
  // 当前播放的对象
  @State activeItem: PrivacyRecorderDBInfo | null = null
  @State isRecording: boolean = false
  // 是否处于播放状态
  @State isPlaying: boolean = false
  // 采集录音的时间
  @State recordingTime: number = 0
  @State playingTime: number = 0
  // 自定义弹窗层
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomInputDialog({
      title: '重命名音频',
      message: '支持下划线、数宇、英文字母与中文',
      inputText: this.tempInputText,
      onConfirm: async () => {
        // TODO：重命名录音
      },
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
  })
  private playingTimerId: number = -1
  private recordingTimerId: number = -1

  aboutToAppear(): void {
    audioCapturerManager.request()
    this.initDir()
    this.getList()
  }

  async getList() {
    this.list = await privacyRecorderDB.select()

  }

  //创建目录（文件）存放隐私录音
  initDir() {
    const context = getContext()
    const dirPath = context.filesDir + '/' + 'privacy_recorder'
    // 检查文件或者目录是否存在
    if (fileIo.accessSync(dirPath) === false) {
      fileIo.mkdirSync(dirPath)
    }
  }

  // 开始录音
  startRecorder() {
    this.startCounter()
    // 当前为录音状态
    this.isRecording = true
    const context = getContext()
    const filePath = context.filesDir + '/' + 'privacy_recorder' + '/' + Date.now() + '.wav'
    audioCapturerManager.startRecorder(filePath)
  }

  // 停止录音
  async stopRecorder() {
    this.stopCounter()
    this.isRecording = false
    // 停止声音采集
    const audioInfo = await audioCapturerManager.stopRecorder()
    /**
     * ⚠️⚠️⚠️⚠️
     *   await只能用于等待一个Promise对象的完成，如果异步操作没有返回一个Promise对象，
     await将无法起作用。在这种情况下，需要确保异步操作返回一个Promise对象。
     *   await在异步系列中不起作用可能是由于异步操作没有返回Promise对象、await没有在async函数中使用或者没有正确处理错误。
     通过确保异步操作返回Promise对象、将await放置在async函数中，并使用try-catch块处理错误，可以实现await的正确使用。
     */
    await privacyRecorderDB.insert({
      id: null, //新增时自动生成
      filePath: audioInfo.filePath,
      title: dayjs(audioInfo.date_added).format('录音 YYYY-MM-DD HH:mm:ss'),
      date_added: audioInfo.date_added,
      duration: audioInfo.duration
    })
    this.getList()
  }

  // 开启计时效果
  startCounter() {
    // 初始化秒数
    this.recordingTime = 0
    // 清除以前的定时器，确保只启用一个
    clearInterval(this.recordingTimerId)
    // 开启定时器
    this.recordingTimerId = setInterval(() => {
      // 秒数累加
      this.recordingTime++
    }, 1000)
  }

  // 结束计时效果
  stopCounter() {
    clearInterval(this.recordingTimerId)
  }

  // 音频 播放/暂停
  playAudio(item: PrivacyRecorderDBInfo) {
    this.activeItem = item
    if (this.isPlaying) {
      audioCapturerManager.stopPlayRenderer()
      // 停止渲染进度条
      this.stopPlayingCount()
    } else {
      audioCapturerManager.startPlayRenderer(item.filePath)
      // 开始渲染进度条
      this.startPlayingCount(item.duration)
    }
  }

  // 播放时间计时开始
  startPlayingCount(duration: number) {
    this.isPlaying = true
    // 保存当前时间
    this.playingTime = 0
    // 定义更新间隔，单位时毫秒
    const interval = 200
    // 停止计时器
    clearInterval(this.playingTimerId)
    this.playingTimerId = setInterval(() => {
      // 获取当前时间
      this.playingTime += interval
      if (this.playingTime > duration) {
        this.stopPlayingCount()
      }
    }, interval)
  }

  // 播放时间计时停止
  stopPlayingCount() {
    this.isPlaying = false
    // 停止计时器
    clearInterval(this.playingTimerId)
  }

  @Builder
  ListItemSwipeActionEnd() {
    Row() {
      Button("重命名")
        .type(ButtonType.Normal)
        .height('100%')
        .aspectRatio(1)
        .backgroundColor('#CECFCF')
        .onClick(() => {
          // TODO：录音重命名
        })
      Button("删除")
        .type(ButtonType.Normal)
        .height('100%')
        .aspectRatio(1)
        .backgroundColor('#FF5E5D')
        .onClick(() => {
          // TODO：删除录音
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          if (this.list.length) {
            List() {
              ListItemGroup() {
                ForEach(this.list, (item: PrivacyRecorderDBInfo) => {
                  ListItem() {
                    Row({ space: 20 }) {
                      Column({ space: 10 }) {
                        Text(item.title)
                          .fontSize(16)
                          .fontColor($r('app.color.font2'))
                        // 录音进度条
                        if (this.activeItem?.id === item.id && this.isPlaying) {
                          Row({ space: 5 }) {
                            Text(dayjs(this.playingTime)
                              .format('mm:ss'))
                              .fontSize(12)
                              .fontColor($r('app.color.font_sub'))
                            Progress({
                              value: this.playingTime, //播放时间（单位：毫秒）
                              total: item.duration,   //总时间（单位：毫秒）
                            })
                          }
                          .padding({ right: 20 })
                        } else {
                          Text(dayjs(item.date_added)
                            .format('YYYY年MM月DD日 HH:mm:ss'))
                            .fontSize(12)
                            .fontColor($r('app.color.font_sub'))
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Column() {
                        Image(
                          this.activeItem?.id === item.id && this.isPlaying ?
                          $r('sys.media.ohos_ic_public_pause') :
                          $r("app.media.ic_public_play")
                        )
                          .width(22)
                          .aspectRatio(1)
                          .fillColor('#A6B6C4')
                        Text(dayjs.duration(item.duration)
                          .format('mm:ss'))
                          .fontSize(12)
                          .fontColor('#A6B6C4')
                          .lineHeight(25)
                      }
                      .justifyContent(FlexAlign.Center)
                      .height('100%')
                      .onClick(() => {
                        // 播放音频
                        this.playAudio(item)
                      })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding({ left: 15, right: 15 })
                  }
                  .height(72)
                  .transition({ type: TransitionType.Delete, opacity: 0 })
                  .swipeAction({
                    end: {
                      builder: this.ListItemSwipeActionEnd(),
                      onStateChange: (state) => {
                        if (state === SwipeActionState.EXPANDED) {
                          // 保存当前滑动的数据
                          this.activeItem = item
                        }
                      }
                    },
                    edgeEffect: SwipeEdgeEffect.None,
                  })
                })
              }
              .padding({ bottom: 126 })
              .divider({
                strokeWidth: 1,
                color: $r('app.color.border'),
                startMargin: 15,
                endMargin: 15
              })
            }
            // 每行之间的分界线
            .width('100%')
            .height('100%')
          } else {
            EmptyTipsComp({ title: '您还没有任何隐私录音\n点击下面的按钮开始创建' })
          }
        }
        .height('100%')

        // 录音按钮
        Column() {
          Image($r('app.media.ic_circle_recorder'))
            .width(56)
            .aspectRatio(1)
            .onClick(() => {
              // 开始录音
              this.startRecorder()
            })
        }
        .width('100%')
        .height(126)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 15, right: 15 })

        // 停止录音
        Column({ space: 15 }) {
          Row({ space: 12 }) {
            Row() {
              ForEach(Array.from({ length: 12 }), () => {
                Column()
                  .width(5)
                  .height(16)
                  .backgroundColor('#80ffffff')
                  .borderRadius(5 / 2)
              })
            }
            .width(110)
            .justifyContent(FlexAlign.SpaceBetween)

            // 图标
            Image($r('app.media.ic_recorder_fill'))
              .height('100%')

            Row() {
              ForEach(Array.from({ length: 12 }), () => {
                Column()
                  .width(5)
                  .height(16)
                  .backgroundColor('#80ffffff')
                  .borderRadius(5 / 2)
              })
            }
            .width(110)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(58)
          .margin({ top: 40 })

          Text(
            dayjs(this.recordingTime * 1000)
              .format(this.recordingTime > 1000 * 60 * 60 ? 'HH:mm:ss' : 'mm:ss')
          )
            .fontSize(18)
            .lineHeight(25)
            .fontWeight(700)
            .fontColor($r('app.color.white'))

          Row() {
            Button('停止录音')
              .type(ButtonType.Normal)
              .width('100%')
              .backgroundColor($r('app.color.brand'))
              .border({ width: 1, color: $r('app.color.white') })
              .borderRadius(10)
              .onClick(() => {
                // 停止录音
                this.stopRecorder()
              })
          }
          .padding({ left: 15, right: 15 })
        }
        .width('101%')
        .height(222)
        .backgroundImage('/common/images/RecorderAddPage_bg_bottom.png')
        .backgroundImageSize(ImageSize.Cover)
        .visibility(this.isRecording ? Visibility.Visible : Visibility.None)
      }
      .height('100%')
    }
    .title('录音')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .linearGradient({
      angle: 180,
      colors: this.isRecording ? [[$r('app.color.white'), 0.95], [$r('app.color.brand'), 0.95]] :
        [[$r('app.color.white'), 0], [$r('app.color.white'), 1]]
    })
  }
}