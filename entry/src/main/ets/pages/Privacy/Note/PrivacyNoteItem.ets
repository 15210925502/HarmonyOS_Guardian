// 隐私笔记的类型
import { ValuesBucket } from '@kit.ArkData'

// ValuesBucket  数据库类型约束
export interface PrivacyNoteDBInfo extends ValuesBucket {
  id: number | null //新增时id 设置为null，可实现id 自增
  title: string
  content: string
  date_added: number
}