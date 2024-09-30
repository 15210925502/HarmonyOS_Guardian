import { Permissions } from '@kit.AbilityKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { permissionManager } from './PermissionManager'
import { promptAction } from '@kit.ArkUI'
import { dataSharePredicates } from '@kit.ArkData'

class CleanerManager {
  // 权限
  private permissions: Permissions[] = ['ohos.permission.READ_IMAGEVIDEO', 'ohos.permission.WRITE_IMAGEVIDEO']
  // 图片资源
  private photoAssets: photoAccessHelper.PhotoAsset[] = []
  // 图片字段
  private fetchColumns: photoAccessHelper.PhotoKeys[] = [
  // 图片添加时间，得到时间戳是毫秒级，跟普通时间戳秒级少3位数，最后转成日期时要乘以1000
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    // 图片大小
    photoAccessHelper.PhotoKeys.SIZE
  ]

  // 图片权限
  async requestPermissions() {
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '手机瘦身功能需要获取权限，请在系统设置中打开相册开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      if (dialogRes.index === 1) {
        permissionManager.openPermissionSettingPage()
      }
    }
  }

  // 获取所有图片/视频
  async getAssets() {
    // 获取图片管理器，建立检查条件，用于获取资源
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    // 准备谓词，（查询条件）
    const predicates = new dataSharePredicates.DataSharePredicates()
    // predicates.orderByAsc() 按字段从小到大
    // predicates.orderByAsc(photoAccessHelper.PhotoKeys.DATE_ADDED)
    // 获取目标图片资源
    // ⚠️⚠️⚠️调用getAssets时，需提前申请IMAGEVIDEO的权限，否则调用失败
    const fetchResult = await phAccessHelper.getAssets({
      // 基础字段，可传入空数组
      // fetchColumns: [],
      // 要想获取图片大小、添加日期等部分信息，必须在此数组中添加，才可获取
      fetchColumns: this.fetchColumns,
      predicates //如果名字一样，可省略，如下
      // predicates:predicates
    })
    // 获取第一张图片
    // const photoAsset = await fetchResult.getFirstObject()
    //  获取所有图片
    const photoAssets = await fetchResult.getAllObjects()
    return photoAssets
  }

  // 获取图片截屏列表
  async getScreenShortList() {
    const list = await this.getAssets()
    // 获取图片名称，然后判断是否包含Screenshot字段，包含说明是截屏图片
    // filter：是过滤函数
    return list.filter(item => item.displayName.includes('Screenshot'))
  }

  // 获取用户图片列表
  async getUserList() {
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    const predicates = new dataSharePredicates.DataSharePredicates()
    const fetchResult = await phAccessHelper.getAlbums(
      photoAccessHelper.AlbumType.USER, //相册类型（用户相册，系统相册）
      photoAccessHelper.AlbumSubtype.USER_GENERIC, //相册子类型（用户相册，收藏夹，视频相册）
      {
        fetchColumns: [],
        predicates: predicates
      }//可选参数
    )
    const list = fetchResult.getAllObjects()
    return list
  }

  // 获取视频列表
  async getVideoList() {
    const list = await this.getAssets()
    return list.filter(item => item.photoType === photoAccessHelper.PhotoType.VIDEO)
  }

  // 删除图片
  async deletePhotos(urls: string[]) {
    // 获取所有图片
    const photoAssets = await this.getAssets()
    const list = photoAssets.filter(item => urls.includes(item.uri))
    // 将图片放入回收站（删除）
    return photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), list)
  }

  // 删除所有图片
  async deleteAllPhotos() {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions);
      let photoAssetList: Array<photoAccessHelper.PhotoAsset>  = await fetchResult.getAllObjects();
      await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), photoAssetList);
      console.info('deleteAssets successfully');
    } catch (err) {
      console.error(`deleteAssetsDemo failed with error: ${err.code}, ${err.message}`);
    }
  }
}

export const cleanerManager = new CleanerManager()