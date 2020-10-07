const httpsGet = function (url, data = {}) {
  return new Promise((resolve, reject) => {
    wx.request({
      method: "GET",
      url: 'https://yourdomin.cn/api/' + url,
      data: data,
      success: function (res) {
        resolve(res)
      },
      fail: function (err) {
        reject(err)
      }
    })
  })
}
const httpsPost = function (url, data = {}) {
  return new Promise((resolve, reject) => {
    wx.request({
      header: {"Content-Type": "application/x-www-form-urlencoded"},
      method: "POST",
      url: 'https://yourdomin.cn/api/' + url,
      data: data,
      success: function (res) {
        resolve(res)
      },
      fail: function (err) {
        reject(err)
      }
    })
  })
}
const json2Form = function (json) {
  var str = [];
  for (var p in json) {
    str.push(encodeURIComponent(p) + "=" + encodeURIComponent(json[p]));
  }
  return str.join("&");
}
const networkError = function () {
  wx.showModal({
    title: '网络连接失败',
    content: '请检查网络设置',
    showCancel: false
  })
}
module.exports = {
  httpsGet: httpsGet,
  httpsPost: httpsPost,
  networkError: networkError,
  json2Form: json2Form
}