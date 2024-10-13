import { PRIVACY_PHOTO_FOLDER } from "../common/constants"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { camera, cameraPicker } from "@kit.CameraKit"
import { router } from "@kit.ArkUI"

class CameraPickerManager {
  // 相机拍照
  async takePhoto() {
    const context = getContext()
    // 沙箱路径
    const filePath = context.filesDir + '/' + PRIVACY_PHOTO_FOLDER + '/' + Date.now() + 'png'
    // 打开文件用于写入
    fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    // 调用相机拍照
    const pickerResult = await cameraPicker.pick(context,
      [cameraPicker.PickerMediaType.PHOTO], //PHOTO 拍照  VIDEO 录像
      {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK, //调用后摄像头
        // ⚠️⚠️⚠️⚠️
        // path转uri    fileUri.getUriFromPath(filePath)
        // uri转path    const file = await fileIo.open(uri)     file.path  或者  const file = fileIo.openSync(uri).path
        //图像保存路径，不写此属性默认会保存到相册，所有人都可查看；如果只想在应用内使用，就可以单独设置下路径，保存到沙箱
        // 此方法是吧 /xx/xxx  路径转换为  file://xxx 类型的路径
        saveUri: fileUri.getUriFromPath(filePath)
      })
    // 拍照成功返回地址
    if (pickerResult.resultCode === 0 && pickerResult.resultUri) {
      // 把拍照的文件路径写入到数据库
      //TODO: inset数据库
      // 不保留当前页面，替换成新页面，如果页面已存在，移动到栈顶显示
      router.replaceUrl({
        url: '/pages/Privacy/Photo/PhotoIndexPage'
        /**⚠️⚠️⚠️⚠️
         1.页面栈的最大容量上限为 32 个页面，使用 router.clear()方法可以清空页面栈，释放内存
         2.Router有两种页面跳转模式，分别是:
            router.pushUrl():目标页不会替换当前页，而是压入页面栈，因此可以用 router.back()返回当前页
             router.ReplaceUrl():目标页会替换当前页，当前页会被销毁并释放资源，无法返回当前页
         3.Router有两种页面实例模式，分别是:
            Standard :标准实例模式，每次调整都会新建一个目标页并压入栈顶。默认就是这种模式
            Single :单实例模式，如果目标页已经在栈中，则离栈顶最近的同Url页面会被移动到栈顶并重新加载
         */

        /**⚠️⚠️⚠️⚠️
         页面返回可以根据业务需要增加一个询问 对话框
         即在调用router.back()方法之前，可以先调用router.enableBackPageAlert()方法开启页面返回询问对话框功能。
         说明
         router.enableBackPageAler()方法开启页面返回询问对话框功能，只针对当前页面生效。
         例如在调用router.pushUr()或者router.replaceUr()方法，跳转后的页面均为新建页面，
         因此在页面返回之前均需要先调用router.enableBackPageAlert()方法之后页面返回询问对话框功能才会生效。
         如需关闭页面返回询问对话框功能，可以通过调用router.disableAlertBeforeBackPage()方法关闭该功能即可
         */

    /** ⚠️⚠️⚠️⚠️
     方式一:API9及以上，router.pushUr()方法新增了mode参数，
     可以将mode参数配置为router.RouterMode.Single单实例模式和router.RouterMode.Standard多实例模式。
     在单实例模式下:
          如果目标页面的ur在页面栈中已经存在同ur页面，离栈顶最近同ur页面会被移动到栈顶，移动后的页面为新建页，原来的页面仍然存在栈中，页面栈的元素数量不变;
          如果目标页面的ur在页面栈中不存在同ur页面，按多实例模式跳转，页面栈的元素数量会加1。
     方式二:API9及以上，router.replaceUr(0)方法新增了mode参数，
     可以将mode参数配置为router.RouterMode.Single单实例模式和router.RouterMode.Standard多实例模式。
          在单实例模式下:如果目标页面的ur在页面栈中已经存在同ur页面，离栈顶最近同ur页面会被移动到栈顶，替换当前页面，并销毁被替换的当前页面，移动后的页面为新建页，页面栈的元素数量会减1;
          如果目标页面的ur在页面栈中不存在同url页面，按多实例模式跳转，页面栈的元素数量不变。
     */
      }, router.RouterMode.Single)
    }
  }
}

export const cameraPickerManager = new CameraPickerManager()
