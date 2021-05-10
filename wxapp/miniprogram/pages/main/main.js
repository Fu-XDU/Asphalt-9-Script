// miniprogram/pages/main/main.js
const app = getApp()
const util = require("../../utils/util.js")
import Notify from '../../components/Vant-Weapp/notify/notify';
Page({

  /**
   * 页面的初始数据
   */
  data: {
    settings: {
      'mode': {
        title: "模式选择",
        options: {
          value: ["多人刷声望", "赛事模式", "多人刷包"],
          index: [0, 1, 2]
        },
        index: 0
      },
      'switch': {
        title: "没油没票后动作(赛事模式)",
        options: {
          value: ["多人刷声望", "多人刷包", "等30分钟", "等60分钟"],
          index: [0, 1, 2, 3]
        },
        index: 0
      },
      'path': {
        title: "路线选择(所有模式)",
        options: {
          value: ["左", "中", "右", "随机"],
          index: [0, 1, 2, 3]
        },
        index: 0
      },
      'gamenum': {
        title: "赛事位置选择",
        options: {
          value: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"],
          index: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        },
        index: 0
      },
      'chooseCarorNot': {
        title: "赛事是否选车",
        options: {
          value: ["是", "否"],
          index: [0, 1]
        },
        index: 0
      },
      'carplace': {
        title: "赛事用车位置选择(赛事模式)",
        options: {
          value: ["中间上", "中间下", "左上", "左下", "右上（被寻车满星时）"],
          index: [0, 1, 2, 3, 4]
        },
        index: 0
      },
      'backifallstar': {
        title: "赛事选车是否返回一次(被寻车满星时)",
        options: {
          value: ["是", "否"],
          index: [0, 1]
        },
        index: 0
      },
      'PVPatBest': {
        title: "传奇是否刷多人",
        options: {
          value: ["是", "否"],
          index: [0, 1]
        },
        index: 0
      },
      'savePower': {
        title: "节能模式",
        options: {
          value: ["开", "关"],
          index: [0, 1]
        },
        index: 0
      },
      'lowerCar': {
        title: "多人选低一段车辆(白银及以上)",
        options: {
          value: ["开", "关"],
          index: [0, 1]
        },
        index: 0
      },
      'changeCar': {
        title: "赛事没油是否换车",
        options: {
          value: ["开", "关"],
          index: [0, 1]
        },
        index: 0
      },
      'watchAds': {
        title: "赛事没油是否看广告(建议配合插件VideoAdsSpeed开20倍使用)",
        options: {
          value: ["开(有20倍广告加速)", "关", "开(没有广告加速)"],
          index: [0, 1, 2]
        },
        index: 0
      },
      'timeout_backPVE': {
        title: "需要过多久返回赛事模式或寻车模式(分钟)",
        value: ""
      },
      'skipcar': {
        title: "多人跳车(填0不跳)",
        value: ""
      },
      'timeout_parallelRead': {
        title: "顶号重连(分钟)",
        value: ""
      },
      'email': {
        title: "接收日志的QQ邮箱的QQ号",
        value: ""
      },
    },
    showSettings: false,
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    const _this = this
    util.login().then((res) => {
      app.globalData.openid = res.result.openid
      try {
        var value = wx.getStorageSync('udid')
        if (value) {
          console.log("获取缓存成功", value)
          _this.setData({
            udid: value
          })
          _this.query()
        } else {
          wx.cloud.database().collection('udid').where({
            openid: app.globalData.openid
          }).get({
            success: function (result) {
              if (result.data.length > 0) {
                console.log("从数据库查询到数据", result)
                _this.setData({
                  udid: result.data[0].udid
                })
                _this.query()
              }
            },
            fail(err) {
              util.networkError(err);
            }
          })
        }
      } catch (e) {
        console.error("获取缓存失败", e)
      }
    })
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function () {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function () {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {

  },
  getArrayIndex: function (arr, obj) {
    var i = arr.length;
    while (i--) {
      if (arr[i] === obj) {
        return i;
      }
    }
    return -1;
  },
  saveSettings: function (valueList) {
    //邮箱为空则初始化为空格
    if (!valueList[valueList.length - 1]) valueList[valueList.length - 1] = " "
    var i = 0
    for (var key in this.data.settings) {
      if (i <= 11) {
        this.data.settings[key].index =
          this.getArrayIndex(this.data.settings[key].options.value, valueList[i++])
      } else {
        this.data.settings[key].value = valueList[i++]
      }
    }
    this.setData({
      settings: this.data.settings,
      showSettings: true
    })
  },
  saveudid: function () {
    try {
      wx.setStorage({
        key: "udid",
        data: this.data.udid
      })
    } catch (e) {
      console.error("设置本地缓存失败", e)
    }
    wx.cloud.callFunction({
      name: "saveudid",
      data: {
        openid: app.globalData.openid,
        udid: this.data.udid
      },
      success(res) {
        //console.log(res)
      },
    })
  },
  query: function () {
    if (!!!this.data.udid) {
      return
    }
    if (this.data.udid.length != 40) {
      //console.info("无此udid,格式错误")
      Notify({
        message: '未查询到设备',
        duration: 1000,
      });
      this.setData({
        showSettings: false
      })
      return
    }
    util.httpsGet("a9getSettings?udid=" + this.data.udid).then((res) => {
      if (res.data.length > 0) {
        //console.info("获取设置成功",res.data[0])
        this.data.oldSettings = res.data[0].settings
        this.saveSettings(res.data[0].settings.split("|"))
        this.saveudid()
        wx.pageScrollTo({
          scrollTop: 100,
          duration: 300
        })
        Notify({
          message: '查询成功',
          background: '#07C160',
          duration: 1000,
        });
      } else {
        //console.info("未查询到设备")
        Notify({
          message: '未查询到设备',
          duration: 1000,
        });
        this.setData({
          showSettings: false
        })
      }
    }).catch((err) => {
      console.error("获取设置失败", err)
      util.networkError();
    })
  },
  handleInput: function (e) {
    if (e.target.id == "udid")
      this.data.udid = e.detail
    else {
      this.data.settings[this.getkey(this.data.settings, e.target.id)].value = e.detail
    }
  },
  getClipboard: function (e) {
    var that = this
    wx.getClipboardData({
      success(res) {
        //console.log("获取剪切板数据 ",res.data)
        that.setData({
          udid: res.data
        })
      }
    })
  },
  presentSettings: function () {
    var presentSettings = ""
    var i = 0
    for (var key in this.data.settings) {
      if (i++ < 12) {
        presentSettings += this.data.settings[key].options.value[this.data.settings[key].index] + "|"
      } else {
        presentSettings += (this.data.settings[key].value).replace(/\s+/g, "") + "|"
      }
    }
    return presentSettings.replace("||", "|")
  },
  submit: function () {
    var presentSettings = this.presentSettings()
    if (presentSettings == this.data.oldSettings) {
      wx.showModal({
        title: '更新成功',
        content: '脚本会在游戏单局结束或恢复运行时修改其设置',
        showCancel: false,
      })
      return
    }
    var data = {
      udid: this.data.udid,
      settings: presentSettings
    }
    util.httpsPost("a9saveSettings", util.json2Form(data)).then((res) => {
      if (res.statusCode != 200) {
        util.networkError()
      } else {
        wx.showModal({
          title: '更新成功',
          content: '脚本会在游戏单局结束或恢复运行时修改其设置',
          showCancel: false,
        })
      }
    })
  },
  getkey: function (dic, value) {
    for (var key in dic)
      if (dic[key].title == value)
        return key
  },
  onChange: function (e) {
    this.data.settings[this.getkey(this.data.settings, e.target.id)].index = e.detail,
      this.setData({
        settings: this.data.settings,
      });
  },
})