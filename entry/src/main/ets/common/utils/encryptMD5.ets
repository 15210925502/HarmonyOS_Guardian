import CryptoJS from '@ohos/crypto-js'

// md5加密
export function encryptMD5(str: string) {
  return CryptoJS.MD5(str).toString()
}