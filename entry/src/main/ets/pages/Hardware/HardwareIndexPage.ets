import { NavigationTitleBuilder } from '../../common/builders';
import { SENSOR_NAME_LIST, SensorName } from '../../common/constants';
import { themeManager } from '../../manager';
import deviceInfo from '@ohos.deviceInfo';
import process from '@ohos.process';
import dayjs from 'dayjs';
import duration from 'dayjs/plugin/duration';
import { connection } from '@kit.NetworkKit';
import { display } from '@kit.ArkUI';
import { sensor } from '@kit.SensorServiceKit';

dayjs.extend(duration)

@Entry
@Component
struct HardwareIndexPage {
  // 产品名称
  @State marketName: string = '-'
  // 系统版本
  @State osFullName: string = '-'
  // 系统软件API版本
  @State sdkApiVersion: string = '-'
  // 设备类型
  @State deviceType: string = '-'
  // 获取当前系统已运行的秒数
  @State uptime: number = 0
  // 网络类型
  @State netBearType: string = '-'
  // IP 地址
  @State IPAddress: string = '0.0.0.0'
  // 子网掩码
  @State subnetMask: string = '0.0.0.0'
  // 广播地址
  @State broadcastAddress: string = '0.0.0.0'
  // 屏幕分辨率（像素）
  @State displayHeight: number = 0
  @State displayWidth: number = 0
  // 屏幕刷新率（Hz）
  @State displayRefreshRate: number = 0
  // 像素密度（PPI）
  @State displayDensityDPI: number = 0
  // 支持的传感器id列表
  @State supportSensorIds: number[] = []

  aboutToAppear(): void {
    this.getDeviceInfo()
    this.getProcessInfo()
    this.getConnectionInfo()
    this.getDisplayInfo()
    this.getSensorInfo()
  }

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  // 获取设备信息
  getDeviceInfo() {
    // 产品名称，可区分模拟器，真机型号
    this.marketName = deviceInfo.marketName
    // 系统版本
    this.osFullName = deviceInfo.osFullName
    // 系统api版本
    this.sdkApiVersion = deviceInfo.sdkApiVersion.toString()
    // 设备类型，可区分，平板、手机、PC、车机、手表、电视等
    this.deviceType = deviceInfo.deviceType
  }

  getProcessInfo() {
    this.uptime = process.uptime()
  }

  getConnectionInfo() {
    const isDasDefaultNet = connection.hasDefaultNetSync()
    if (isDasDefaultNet) {
      this.getNetBearType()
      this.getNetProperties()
    } else {
      this.netBearType = '无网络'
    }
  }

  getNetBearType(){
    // 获取默认激活的数据网络
    const netHandle = connection.getDefaultNetSync()
// 获取网络的连接信息
   const netCapabilities = connection.getNetCapabilitiesSync(netHandle)
    if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
      this.netBearType = 'WIFI网络'
    }else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
      this.netBearType = '以太网络'
    }else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
      this.netBearType = '蜂窝网络'
    }else {
      this.netBearType = '未知'
    }
  }

  getNetProperties(){
    // 获取默认激活的数据网络
    const netHandle = connection.getDefaultNetSync()
    // 获取网络连接信息
    const connectionProperties = connection.getConnectionPropertiesSync(netHandle)
    // 提取链路信息
    const linkAddress = connectionProperties.linkAddresses[0]
    if (linkAddress) {
      // 获取IP地址
      this.IPAddress = linkAddress.address.address
    }
  }

  getDisplayInfo(){
    // 获取默认屏幕
    const defaultDisplay = display.getDefaultDisplaySync()
    // 获取分辨率
    this.displayWidth = defaultDisplay.width
    this.displayHeight = defaultDisplay.height
    // 获取刷新率
    this.displayRefreshRate = defaultDisplay.refreshRate
    // 获取像素密度
    this.displayDensityDPI = defaultDisplay.densityDPI
  }

  // 获取传感器信息
  async getSensorInfo(){
    // 获取所有传感器信息
    const list = await sensor.getSensorList()
    this.supportSensorIds = list.map(item => item.sensorId)
  }

  @Builder
  ListTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(500)
      .fontColor($r('app.color.font'))
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })
      .backgroundColor($r('app.color.white'))
  }

  build() {
    Navigation() {
      // 顶部硬件信息
      Column({ space: 20 }) {
        Text(this.marketName)
          .fontSize(16)
          .fontColor($r('app.color.white'))
        Column({ space: 10 }) {
          Text('系统版本：' + this.osFullName)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('API 版本：' + this.sdkApiVersion)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('设备类型：' + this.deviceType)
            .fontSize(12)
            .fontColor($r('app.color.white'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 30,
        bottom: 30
      })
      .alignItems(HorizontalAlign.Start)

      // 其他内容
      Column() {
        List() {
          ListItemGroup({ header: this.ListTitle('基本信息') }) {
            ListRow({ title: '上次启动', value: dayjs().subtract(this.uptime, 'second').format('YYYY-MM-DD HH:mm:ss') })
            ListRow({ title: '运行时间', value: dayjs.duration(this.uptime, 'second').format('D天H小时mm分') })
          }

          ListItemGroup({ header: this.ListTitle('网络信息') }) {
            ListRow({ title: '网络类型', value: this.netBearType })
            ListRow({ title: 'IP地址', value: this.IPAddress })
            ListRow({ title: '子网掩码', value: this.subnetMask })
            ListRow({ title: '广播地址', value: this.broadcastAddress })
          }

          ListItemGroup({ header: this.ListTitle('硬件特性') }) {
            // 屏幕信息
            ListRow({ title: '屏幕分辨率（像素）', value: `${this.displayHeight}x${this.displayWidth}` })
            ListRow({ title: '屏幕刷新率（Hz）', value: this.displayRefreshRate })
            ListRow({ title: '像素密度（PPI）', value: this.displayDensityDPI })
            // 传感器信息
            ForEach(SENSOR_NAME_LIST, (item: SensorName) => {
              ListRow({
                title: item.sensorName,
                value: this.supportSensorIds.includes(item.sensorId) ? '有' : '-'
              })
            })
          }
        }
        // 每组的间隔
        .divider({ strokeWidth: 10 })
        // 表头和表尾是否吸顶
        .sticky(StickyStyle.Header)
        .height('100%')
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .clip(true)
    }
    .title(NavigationTitleBuilder('硬件信息'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.4], [$r('app.color.white'), 0.4]]
    })
  }
}

@Component
struct ListRow {
  @Prop title: string = ''
  @Prop value: string | number = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(14)
        .fontColor($r('app.color.font'))
      Text(this.value.toString())
        .fontSize(12)
        .fontColor($r('app.color.font_sub'))
    }
    .padding({ left: 20, right: 20 })
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

