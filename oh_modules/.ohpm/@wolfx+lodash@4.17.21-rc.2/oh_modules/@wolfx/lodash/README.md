# @wolfx/lodash

## 简介

lodash for ArkTS. Built-in types, only necessary files are kept to reduce package size.

移植 `lodash.js` 到鸿蒙，针对鸿蒙做了优化，内置 `TS` 类型，仅保留了必要的文件以减少包体积。

## 安装

`ohpm install @wolfx/lodash`

## Example

```ets
import _ from '@wolfx/lodash';

@Entry
@Component
struct TestLodash {
  @State message: string = _.max([1, 2, 3]).toString();

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
```