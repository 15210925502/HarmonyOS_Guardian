import { camera, cameraPicker } from '@kit.CameraKit'

@Entry
@Component
struct CameraPickerTestPage {
  @State imageUri: string = ''

  build() {
    Navigation() {
      Scroll() {
        Column() {
          Button('拍照')
            .onClick(async () => {
              const pickerResult = await cameraPicker.pick(getContext(), [cameraPicker.PickerMediaType.PHOTO], {
                cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
              })
              if (pickerResult.resultUri && pickerResult.resultCode === 0) {
                this.imageUri = pickerResult.resultUri
              }
            })
          Image(this.imageUri)
            .width(200)
        }.constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('拍照')
    .titleMode(NavigationTitleMode.Mini)
  }
}