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