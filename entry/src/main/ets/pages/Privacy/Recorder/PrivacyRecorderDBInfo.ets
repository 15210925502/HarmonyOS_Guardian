// 隐私录音的类型
import { ValuesBucket } from '@kit.ArkData'

// ValuesBucket  数据库类型约束
export interface PrivacyRecorderDBInfo extends ValuesBucket {
  id: number | null //新增时id 设置为null，可实现id 自增
  filePath: string
  title: string
  date_added: number
  duration: number
}