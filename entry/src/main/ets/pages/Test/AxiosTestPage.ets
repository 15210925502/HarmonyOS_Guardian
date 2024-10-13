import { axiosInstance, AxiosResponseData } from '../../common/utils'
import { promptAction } from '@kit.ArkUI'
import { LoginInfoResponse, LOGIN_INFO } from '../../common/constants'

// 账号密码登录模型
export interface PostUserLoginPasswdData {
  // 用户名
  passwd?: string
  // 手机号
  phone?: string
}

// 后端数据响应模型<R>
export interface ServiceResponse<R> {
  code: number
  msg?: string
  resTime?: Date
  result?: R
  tips?: string
}

// // 登录Result
// export interface LoginInfoResult {
//   accessToken?: string
//   avatar?: string
//   nickname?: string
//   renewalToken?: string
// }

// 获取用户信息
export interface GetUserMeResponse {
  avatar?: string
  nickname?: string
}

@Entry
@Component
struct AxiosTestPage {
  // 定义头像数据
  @State avatar: string = ''
  // 持久化
  @StorageLink(LOGIN_INFO) loginInfo: LoginInfoResponse = {}

  build() {
    Navigation() {
      Scroll() {
        Column() {
          if (this.avatar) {
            Image(this.avatar)
              .width(150)
          }
          Button('请求工具-发送登录请求')
            .onClick(async () => {
              /**
               * axios 范型参数:
               *       第一个范型参数:会被覆盖掉，所以没啥呀
               *       第二个范型参数:约束后端返回数据的类型 - 重点学习
               *       第三个范型参数:约束请求体(data)参数的类型 - 重点学习
               */
              const result =
                await axiosInstance.post<null, AxiosResponseData<LoginInfoResponse>, PostUserLoginPasswdData>('/user/login/passwd',
                  {
                    phone: '120666666666',
                    passwd: '888itcast.CN764%...'
                  })
              // 下面代码只有请求成功的时候才往下执行，错误就中断下面的执行
              this.avatar = result.data.result.avatar as string
              this.loginInfo = result.data.result
            })
          Button('请求工具-发送获取我的用户信息')
            .onClick(async () => {
              const reslut = await axiosInstance.get<null, AxiosResponseData<GetUserMeResponse>>('/user/me')
              this.avatar = reslut.data.result.avatar as string
            })
        }.constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('Axios网络请求封装')
    .titleMode(NavigationTitleMode.Mini)
  }
}