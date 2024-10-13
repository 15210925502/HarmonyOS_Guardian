import { Permissions } from '@kit.AbilityKit'
import { permissionManager } from '.'
import { promptAction } from '@kit.ArkUI'
import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit'

// 停止录音采集时，返回录音文件关键信息
interface AudioInfo {
  filePath: string //文件路径
  date_added: number //创建时间
  duration: number //持续时长
}

class AudioCapturerManager {
  // -----------权限-----------start
  private permissions: Permissions[] = ["ohos.permission.MICROPHONE"]
  // -----------权限-----------end

  // -----------音频采集和播放共用-----------start
  // 音频流配置
  private audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, //采样率
    channels: audio.AudioChannel.CHANNEL_2, //通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, //采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW   //编码格式
  }
  // -----------音频采集和播放共用-----------end

  // -----------音频采集-----------start
  // 音频采集器配置
  private audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }
  // 音频采集器实例
  private audioCapturer: audio.AudioCapturer | null = null
  //采集音频的文件路径
  private filePath: string = ''
  //采集录音的开始时间
  private date_added: number = 0
  // -----------音频采集-----------end

  // -----------音频播放-----------start
  // 音频渲染器配置
  private audioRecorderInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_MOVIE, //播放类型，MOVIE表示用喇叭播放
    rendererFlags: 0
  }
  // 音频渲染器实例
  private audioRenderer: audio.AudioRenderer | null = null

  // 获取音频渲染器（播放器）
  async getAudioRenderer() {
    if (!this.audioRenderer) {
      this.audioRenderer = await audio.createAudioRenderer({
        streamInfo: this.audioStreamInfo,
        rendererInfo: this.audioRecorderInfo
      })
    }
    return this.audioRenderer
  }

  // -----------音频播放-----------start


  // 初始化权限
  async request() {
    try {
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启，弹窗提示
      promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '录音功能需要获取权限，请在系统设置中打开麦克风权限',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '确定', color: $r('app.color.brand') }
        ]
      }).then((res) => {
        // 打开设置
        if (res.index === 1) {
          permissionManager.openPermissionSettingPage()
        }
      })
    }
  }

  // 创建/获取音频采集器
  async getAudioCapturer() {
    if (!this.audioCapturer) {
      this.audioCapturer = await audio.createAudioCapturer({
        streamInfo: this.audioStreamInfo,
        capturerInfo: this.audioCapturerInfo
      })
    }
    return this.audioCapturer
  }

  // 开始录音采集
  async startRecorder(filePath: string) {
    // 保存文件路径和创建时间
    this.filePath = filePath
    this.date_added = Date.now()

    // 打开文件，注意设置模式
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    // 创建音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 订阅(读取音频采集器的数据流，写入到打开的文件中)
    audioCapturer.on('readData', (buffer) => {
      fileIo.writeSync(file.fd, buffer)
    })
    // 开始采集
    audioCapturer.start()
  }

  /**
   * 结束录音采集
   */
  async stopRecorder(): Promise<AudioInfo> {
    // 获取音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 停止录音采集
    audioCapturer.stop()
    // 释放资源和硬件占用
    audioCapturer.release()
    // 释放变量，对象重新赋值为null，可以自动被垃圾回收机制清理
    this.audioCapturer = null

    // 停止录音采集时，返回录音文件关键信息
    return {
      filePath: this.filePath,
      date_added: this.date_added,
      duration: Date.now() - this.date_added
    }
  }

  // 播放录音
  async startPlayRenderer(filePath: string) {
    // 根据路径打开文件
    const file = fileIo.openSync(filePath)
    // 获取文件信息，如果读取时已经超出文件大小，自动停止
    const stat = fileIo.statSync(file.fd)
    // 获取音频渲染器（播放器）
    await this.getAudioRenderer()
    // 累加值，用于播放完毕后，自动停止
    let bufferSize = 0
    // 调用on('writeData')方法，订阅监听音频数据写入回调
    this.audioRenderer!.on('writeData', (buffer) => {
      fileIo.readSync(file.fd, buffer)
      bufferSize += buffer.byteLength
      if (bufferSize >= stat.size) {
        this.releaseAudioRenderer()
      }
    })
    // 启动音频渲染器（播放器）
    this.audioRenderer!.start()
  }

  // 停止播放
  async stopPlayRenderer() {
    // 获取音频渲染器（播放器）
    await this.getAudioRenderer()
    if ([audio.AudioState.STATE_RUNNING, audio.AudioState.STATE_PAUSED].includes(this.audioRenderer!.state)) {
      this.releaseAudioRenderer()
    }
  }

  // 释放资源
  async releaseAudioRenderer() {
    await this.audioRenderer!.stop() //停止渲染器（播放器）
    this.audioRenderer!.release() //释放资源
    this.audioRenderer = null //释放变量
  }
}

export const audioCapturerManager = new AudioCapturerManager()