// 云函数入口文件
const cloud = require('wx-server-sdk')
cloud.init()
const db = cloud.database()
// 云函数入口函数
exports.main = async (event, context) => {
  const result = await db.collection('udid').where({
    "openid": event.openid
  }).get()
  if (result.data.length == 0) {
    //数据库没有就保存
    db.collection('udid').add({
      data: {
        openid: event.openid,
        udid: event.udid
      },
      success: res => {},
      fail: err => {}
    })
  } else {
    //数据库有就更新数据
    db.collection('udid').doc(result.data[0]._id).update({
      data: {
        udid: event.udid
      }
    })
  }
}