require "TSLib"
local ts = require("ts")
local sz = require("sz")
local json = sz.json
init(1)
apiUrl = "https://yourdomin.cn/a9api/"
gameBid = "com.Aligames.kybc9"
root = userPath() .. "/res/"
stage = -1 --段位
state = 0 --中间变量，声明检测界面后的下一步流程
path = 0 --道路选择
time = -1 --时间戳，记录离开赛事的时间
innerGhost = 0 --有内鬼次数
LoginTimes = 0 --连续登陆次数
PVPTimes, PVETimes = 0, 0 --多人和赛事局数,存文件
width, height = 0, 0 --屏幕分辨率
checkplacetimes = 0 --连续检测界面次数
checkplacetimesout = 35 --连续检测界面超时次数
validateGame = false --是否已知处在正确的赛事位置
runningState = true --脚本运行状态
receive_starting_command = false --如果是true那么检测到账号被顶就不再等待
changecar = false --PVE是否已经换车
PVPchooseCar = true --多人是否选车
model = "" --设备型号
chooseHighStageCarClass = 1 --改成1的话，使用新多人选车方案
watchAds = ""
PVPwithoutPack, packWithoutRestore = 0, 0 --开过最近的一个PVP包后完成PVP局数,连着开了多少个包但是没有补充
accountnum, nowaccount = "", "" --当前运行的账号,当前运行的账号+密码
switchaccountfun = false --是否打开多人刷包切换账号的功能
udid = ts.system.udid()
settings = ""--用户设置
noAds, restartTimes = 0, 0 --连续回油没广告次数，连续重启次数
---前置准备函数---
function prepare()
    unlockedDevice()
    setAutoLockTime(0)
    checkScreenSize()
    networkState()
    starttime = os.time()
    ShowUI()
    period = os.time() - starttime - 2--period>115认为没有点确定，无人为操作，脚本远程启动
    --获取上次的设置(远端设置)，然后对比这次的设置，若改动，就用改过的并在远端保存此次改过的设置，若无改动，就判断是不是period>115脚本远程启动，如果是就使用远端设置，远端设置可以提前获取。
    if period > 115 then
        refreshSettings(getSettings())
    else
        saveSettings()
    end
    initTable()
    startGame()
    savePowerF()
    paraArgu()
end
---程序主函数---
function main()
    prepare()
    :: begin ::
    worker(checkPlace())
    if state ~= -1 then
        checkplacetimes = 0
    end
    if state == -1 then
        checkplacetimes = checkplacetimes + 1
        goto begin
    elseif state == -2 then
        goto stop
    elseif state == -3 then
        goto begin
    elseif state == -4 then
        goto backFromLines
    elseif state == -5 then
        goto autoMobile
    elseif state == -6 then
        goto waitBegin
    end
    state = toCarbarn()--此处的state=-1 0 1 分别对应停止 中断再识别 继续
    if state == 0 then
        goto begin
    elseif state == -1 then
        goto stop
    end
    :: chooseCar ::
    if not chooseCar() then
        goto begin --选车出错了
    end
    :: waitBegin ::
    if waitBegin() == -1 then
        goto begin
    end
    :: autoMobile ::
    autoMobile()
    :: backFromLines ::
    backFromLines()
    if not shouldStop(false) then
        goto begin
    end
    :: stop ::
    after()
end
---结束处理函数---
function after()
    log4l("⏹脚本停止运行")
    closeApp(gameBid) --关闭游戏
    lockDevice()
end
function beforeUserExit()
    ts.httpsGet(apiUrl .. "a9control?udid=" .. udid .. "&command=1", {}, {})
    log4l("⏹脚本被手动终止")
end
---通用处理函数[不区分设备型号]---
function drift(second)
    touchDown(150, 550);
    mSleep(second * 1000);
    touchUp(150, 550);
end
function saveSettings()
    --存储用户本次设置选项
    body_send = { ["udid"] = udid, ["settings"] = settings }
    ts.httpsPost(apiUrl .. "a9saveSettings", {}, body_send)
end
function getSettings()
    --存储用户本次设置选项
    newsettings = settings
    a9getSettings_code, a9getSettingsheader_resp, resp_settings = ts.httpsGet(apiUrl .. "a9getSettings?udid=" .. udid, {}, {})
    if a9getSettings_code == 200 then
        newsettings = resp_settings
    end
    return newsettings
end
function refreshSettings(newsettings)
    if not (settings == newsettings) and not (newsettings == nil) then
        settingsTable = strSplit(settings, "|")
        newsettingsTable = strSplit(newsettings, "|")
        refreshSettingslog = ""
        for key, value in pairs(newsettingsTable) do
            if not (settingsTable[key] == newsettingsTable[key]) then
                if (key == 1) then
                    supermode = value
                    mode = value
                    refreshSettingslog = refreshSettingslog .. "主模式更改为" .. value .. " "
                elseif (key == 2) then
                    switch = value
                    mode = supermode
                    refreshSettingslog = refreshSettingslog .. "没油没票后动作(赛事模式)更改为" .. value .. " "
                elseif (key == 3) then
                    path = value
                    refreshSettingslog = refreshSettingslog .. "路线选择(所有模式)更改为" .. value .. " "
                elseif (key == 4) then
                    gamenum = value
                    validateGame = false
                    refreshSettingslog = refreshSettingslog .. "赛事位置选择更改为" .. value .. " "
                elseif (key == 5) then
                    PVEchooseCar = value
                    refreshSettingslog = refreshSettingslog .. "赛事是否选车更改为" .. value .. " "
                elseif (key == 6) then
                    carplace = value
                    refreshSettingslog = refreshSettingslog .. "赛事用车位置选择(赛事模式)更改为" .. value .. " "
                elseif (key == 7) then
                    backifallstar = value
                    refreshSettingslog = refreshSettingslog .. "赛事选车是否返回一次(被寻车满星时)更改为" .. value .. " "
                elseif (key == 8) then
                    PVPatBest = value
                    refreshSettingslog = refreshSettingslog .. "传奇是否刷多人更改为" .. value .. " "
                elseif (key == 9) then
                    savePower = value
                    refreshSettingslog = refreshSettingslog .. "节能模式更改为" .. value .. " "
                elseif (key == 10) then
                    lowerCar = value
                    refreshSettingslog = refreshSettingslog .. "多人选低一段车辆(白银及以上)更改为" .. value .. " "
                elseif (key == 11) then
                    changeCar = value
                    refreshSettingslog = refreshSettingslog .. "赛事没油是否换车更改为" .. value .. " "
                elseif (key == 12) then
                    watchAds = value
                    refreshSettingslog = refreshSettingslog .. "赛事没油是否看广告更改为" .. value .. " "
                elseif (key == 13) then
                    timeout_backPVE = value
                    refreshSettingslog = refreshSettingslog .. "需要过多久返回赛事模式或寻车模式更改为" .. value .. " "
                elseif (key == 14) then
                    skipcar = value
                    refreshSettingslog = refreshSettingslog .. "多人跳车更改为" .. value .. " "
                elseif (key == 15) then
                    timeout_parallelRead = value
                    refreshSettingslog = refreshSettingslog .. "顶号重连更改为" .. value .. " "
                elseif (key == 16) then
                    email = value
                    refreshSettingslog = refreshSettingslog .. "邮箱更改为" .. value .. "@qq.com"
                end
            end
        end
        log4l(refreshSettingslog)
        paraArgu()
        settings = newsettings
    end
end
function savePowerF()
    if savePower == "开" then
        toast("降低屏幕亮度", 1)
        setBacklightLevel(0) --屏幕亮度调制最暗
    end
end
function checkScreenSize()
    width, height = getScreenSize()
    if width == 640 and height == 1136 then
        model = "SE"
    elseif true or (width == 750 and height == 1334) then
        model = "i68"
    else
        ret = dialogRet("告知\n本脚本不支持您的设备分辨率，是否继续运行此脚本", "是", "否", 0, 0)
        if ret ~= 0 then
            --如果按下"否"按钮
            toast("脚本停止", 1)
            mSleep(700)
            luaExit() --退出脚本
        end
    end
end
function splitStr(str)
    strLen = getStrNum(str)
    restable = {}
    for i = 1, strLen do
        restable[i] = string.sub(str, i, i)
    end
    return restable
end
function paraArgu()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7)) --随机数初始化
    timeout_backPVE = tonumber(timeout_backPVE) --需要过多久返回赛事模式或寻车模式
    timeout_parallelRead = tonumber(timeout_parallelRead) --顶号重连时间
    gamenum = tonumber(gamenum)
    skipcar = tonumber(skipcar)
    if path == "左" then
        path = -1
    elseif path == "中" then
        path = 0
    elseif path == "右" then
        path = 1
    elseif path == "随机" then
        path = 2
    end
    if PVEchooseCar == "是" then
        PVEchooseCar = true
    else
        PVEchooseCar = false
    end
    if PVPchooseCar == "是" then
        PVPchooseCar = true
    else
        PVPchooseCar = false
    end
    if restartAfterAds == "是" then
        restartAfterAds = true
    else
        restartAfterAds = false
    end
    supermode = mode
end
function getHttpsCommand()
    refreshSettings(getSettings())
    :: getCommand ::
    a9getCommandcode, a9getCommandheader_resp, a9getCommandbody_resp = ts.httpsGet(apiUrl .. "a9getCommand?udid=" .. udid, {}, {})
    if a9getCommandcode == 200 then
        a9getCommandbody_resp = tonumber(a9getCommandbody_resp)
        if a9getCommandbody_resp == 0 then
            if runningState == true then
                log4l("⏸接收到暂停指令，脚本暂停运行")
                runningState = false
                toast("接收到暂停指令，脚本暂停运行", 1)
                closeApp(gameBid) --关闭游戏
                savePowerF()
            end
            toast("脚本已暂停运行", 4)
            mSleep(5000)
            toast("5秒后再次发起请求", 4)
            mSleep(5000) --等5秒后再次发起请求
            goto getCommand
        elseif a9getCommandbody_resp == 1 and runningState == false then
            toast("接收到开始指令，脚本开始运行", 1)
            log4l("▶️接收到开始指令，脚本开始运行")
            runningState = true
            receive_starting_command = true
            savePowerF()
        elseif a9getCommandbody_resp == 4 then
            toast("接收到脚本停止指令，脚本停止", 1)
            log4l("接收到脚本停止指令，脚本停止")
        end
        if not (a9getCommandbody_resp == 1 and runningState == false) then
            ts.httpsGet(apiUrl .. "a9control?udid=" .. udid .. "&command=1", {}, {})--将脚本状态置为运行
        end
        return a9getCommandbody_resp
    end
end
function httpsGet(content)
    header_send = {}
    body_send = {}
    ts.setHttpsTimeOut(5) --安卓不支持设置超时时间
    code, header_resp, body_resp = ts.httpsGet(apiUrl .. "a9?content=" .. content .. "&udid=" .. udid, header_send, body_send)
end
function ToStringEx(value)
    if type(value) == "table" then
        return TableToStr(value)
    elseif type(value) == "string" then
        return "" .. value .. ""
    else
        return tostring(value)
    end
end
function TableToStr(t)
    if t == nil then
        return ""
    end
    local retstr = ""
    local i = 1
    for key, value in pairs(t) do
        local signal = "\n"
        if i == 1 then
            signal = ""
        end
        if key == i then
            retstr = retstr .. signal .. ToStringEx(value)
        else
            if type(key) == "number" or type(key) == "string" then
                retstr = retstr .. signal .. "[" .. ToStringEx(key) .. "]=" .. ToStringEx(value)
            else
                if type(key) == "userdata" then
                    retstr = retstr .. signal .. "*s" .. TableToStr(getmetatable(key)) .. "*e" .. "=" .. ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. "=" .. ToStringEx(value)
                end
            end
        end
        i = i + 1
    end
    retstr = retstr .. ""
    return retstr
end
function url_encode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])",
                function(c)
                    return string.format("%%%02X", string.byte(c))
                end)
        str = string.gsub(str, " ", "+")
    end
    return str
end
function makeGameFront()
    if isFrontApp(gameBid) == 0 then
        runApp(gameBid)
        mSleep(10000)
    end
end
function refreshTable()
    table = readFile(root .. "A9Info.txt")
    if table then
        --如果日期不对
        if table[1] ~= os.date("%Y年%m月%d日") then
            writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1)
            PVPTimes = 0
            PVETimes = 0
            writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), PVPTimes, PVETimes }, "w", 1)
        else
            writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), PVPTimes, PVETimes }, "w", 1)
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1)
    end
end
function initTable()
    table = readFile(root .. "A9Info.txt")
    logtxt = readFile(root .. "A9log.txt")
    if table then
        --如果日期不对，数据重写
        if table[1] ~= os.date("%Y年%m月%d日") then
            --文件重写
            writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1)
            initTable()
        else
            PVPTimes = table[2]
            PVETimes = table[3]
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(root .. "A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1)
        mSleep(1000)
        initTable() --每次初始化内容都要再运行initTable()检查
    end
    if logtxt then
        if logtxt[1] ~= os.date("%Y年%m月%d日") then
            --如果日期不对,发邮件，数据重写
            sendEmail(email, "[A9]" .. os.date("%m%d%H") .. "日志" .. getDeviceName(), logtxt)
            writeFile(root .. "A9log.txt", { os.date("%Y年%m月%d日") }, "w", 1)
            mSleep(1000)
            httpsGet("Delete_log")
            initTable() --每次初始化内容都要再运行initTable()检查
        else
            --啥都不干
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(root .. "A9log.txt", { os.date("%Y年%m月%d日") }, "w", 1)
        mSleep(1000)
        initTable() --每次初始化内容都要再运行initTable()检查
    end
end
function log4l(content)
    if content ~= "游戏重启" then
        restartTimes = 0
    end
    t = batteryStatus()
    charging = ""
    if t.charging == 1 then
        charging = "⚡"
    end
    content = content .. "      🔋:️" .. charging .. tostring(t.level) .. "%"
    urlcontent = url_encode(content)
    table = readFile(root .. "A9log.txt")
    if table then
        --如果日期不对,发邮件，数据重写
        if table[1] ~= os.date("%Y年%m月%d日") then
            initTable()
            httpsGet("Delete_log")
        else
            writeFile(root .. "A9log.txt", { "[" .. os.date("%H:%M:%S") .. "]" .. content }, "a", 1)
            httpsGet(urlcontent)
        end
    else
        --没有文件就创建文件，初始化内容,再写入内容
        initTable()
        log4l(content)
    end
end
function sendEmail(reciver, topic, content)
    if reciver == "" then
        toast("未指定邮箱", 1)
        return 0
    else
        reciver = reciver .. "@qq.com"
    end
    if type(content) == "table" then
        content = TableToStr(content)
    end
    status = ts.smtp(reciver, topic, content, "smtp.qq.com", "yourqq@qq.com", "授权码")
    if status then
        toast("邮件发送成功", 1)
    else
        toast("邮件发送失败", 1)
    end
    mSleep(1000)
end
function networkState()
    if getNetTime() == 0 then
        ret = dialogRet("无网络连接\n目前设备无网络连接，是否继续运行脚本", "是", "否", 0, 0)
        if ret ~= 0 then
            --如果按下"否"按钮
            toast("脚本停止", 1)
            mSleep(700)
            luaExit() --退出脚本
        end
    end
    --dialog(networkState() == true and "网络良好" or "无网络")
end
function ShowUI()
    w, h = getScreenSize()
    UINew(2, "第1页,第2页", "确定", "取消", "uiconfig.dat", 1, 120, w, h, "255,255,255", "255,255,255", "", "dot", 1)
    UILabel(1, "狂野飙车9国服iOS脚本", 15, "center", "38,38,38")
    UILabel(1, "详细说明，远程控制和远程日志查看请向左滑查看第二页", 20, "left", "255,30,2")
    UILabel(1, "购买脚本授权码请联系QQ群1028746490群主", 20, "left", "255,30,2")
    UILabel(1, "模式选择", 15, "left", "38,38,38")
    UIRadio(1, "mode", "多人刷声望,赛事模式", "0") --记录最初设置 | 特殊赛事保留
    UILabel(1, "没油没票后动作（赛事模式）", 15, "left", "38,38,38")
    UIRadio(1, "switch", "多人刷声望,等30分钟,等60分钟", "0")
    UILabel(1, "路线选择（所有模式）", 15, "left", "38,38,38")
    UIRadio(1, "path", "左,中,右,随机", "0")
    UILabel(1, "赛事位置选择", 15, "left", "38,38,38")
    UIRadio(1, "gamenum", "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22", "0")
    UILabel(1, "赛事是否选车", 15, "left", "38,38,38")
    UIRadio(1, "PVEchooseCar", "是,否", "0")
    UILabel(1, "赛事用车位置选择（赛事模式）", 15, "left", "38,38,38")
    UIRadio(1, "carplace", "中间上,中间下,左上,左下,右上（被寻车满星时）", "0")
    UILabel(1, "赛事选车是否返回一次（被寻车满星时）", 15, "left", "38,38,38")
    UIRadio(1, "backifallstar", "是,否", "0")
    UILabel(1, "多人是否选车", 15, "left", "38,38,38")
    UIRadio(1, "PVPchooseCar", "是,否", "0")
    UILabel(1, "多人类型（如果有）", 15, "left", "38,38,38")
    UIRadio(1, "PVPtype", "上,下", "0")
    UILabel(1, "传奇是否刷多人", 15, "left", "38,38,38")
    UIRadio(1, "PVPatBest", "是,否", "0")
    UILabel(1, "节能模式", 15, "left", "38,38,38")
    UIRadio(1, "savePower", "开,关", "0")
    UILabel(1, "多人选低一段车辆（白银及以上）", 15, "left", "38,38,38")
    UIRadio(1, "lowerCar", "开,关", "1")
    UILabel(1, "赛事没油是否换车", 15, "left", "38,38,38")
    UIRadio(1, "changeCar", "开,关", "0")
    UILabel(1, "赛事没油是否看广告(建议配合插件VideoAdsSpeed开20倍使用)", 15, "left", "38,38,38")
    UIRadio(1, "watchAds", "开(有20倍广告加速),关,开(没有广告加速)", "0")
    UILabel(1, "广告后是否重启游戏", 15, "left", "38,38,38")
    UIRadio(1, "restartAfterAds", "是,否", "1")
    UILabel(1, "需要过多久返回赛事模式或寻车模式（分钟）", 15, "left", "38,38,38")
    UIEdit(1, "timeout_backPVE", "内容", "60", 15, "center", "38,38,38", "number")
    UILabel(1, "多人跳车（填0不跳）", 15, "left", "38,38,38")
    UIEdit(1, "skipcar", "内容", "0", 15, "center", "38,38,38", "number")
    UILabel(1, "顶号重连（分钟）", 15, "left", "38,38,38")
    UIEdit(1, "timeout_parallelRead", "内容", "30", 15, "center", "38,38,38", "number")
    UILabel(1, "接收日志的QQ邮箱的QQ号", 15, "left", "38,38,38")
    UIEdit(1, "email", "邮箱地址（选填）", "", 15, "left", "38,38,38", "default")
    UILabel(1, "详细说明请向左滑查看第二页", 20, "left", "255,30,2")
    UILabel(2, "本脚本目前适用设备为iPhone 5S/SE/6/6s/7/8/iPod Touch5G(6G)，iPad与Plus设备均不支持。", 15, "left", "38,38,38")
    UILabel(2, "刷赛事模式需要先用所需车辆手动完成一局再启动脚本。", 15, "left", "255,30,2")
    UILabel(2, "多人刷声望:脚本自动刷多人获得声望。", 15, "left", "38,38,38")
    --UILabel(2, "多人刷包:脚本自动刷多人包，确保开始时有包可刷。当连续完成12局PVP且12局中未开包时认为刷完，刷完脚本自动停止。", 15, "left", "38,38,38")
    UILabel(2, "脚本运行前需手动开启自动驾驶。", 15, "left", "38,38,38")
    UILabel(2, "没油没票后动作:刷赛事用完油和票之后的动作，选择去刷多人会在指定时间后返回。", 15, "left", "38,38,38")
    UILabel(2, "赛事位置选择:选择刷第几个赛事。", 15, "left", "38,38,38")
    UILabel(2, "赛事是否选车:有些赛事为指定车辆，无法从车库选车。", 15, "left", "38,38,38")
    UILabel(2, "寻车赛事用车位置选择:赛事选车时游戏会自动跳到上局此赛事所用车辆，需要选择上还是下。", 15, "left", "38,38,38")
    UILabel(2, "多人跳车:避免赛事所需车的燃油在多人中消耗，可以指定跳过车辆。", 15, "left", "38,38,38")
    UILabel(2, "赛事没油看广告:建议配合插件VideoAdsSpeed开20倍使用。", 15, "left", "38,38,38")
    UILabel(2, "接收日志的邮箱：每日日志会在次日脚本运行之初发送至此邮箱。", 15, "left", "38,38,38")
    UILabel(2, "远程控制功能，可以访问网址https://yourdomin.cn/api/a9control?command=XXX&udid=" .. ts.system.udid() .. "来远程控制脚本的运行。XXX需要更改为如下几种选项之一：", 15, "left", "38,38,38")
    UILabel(2, "XXX=0 暂停脚本运行，与XXX=1配合使用", 15, "left", "38,38,38")
    UILabel(2, "XXX=1 恢复脚本运行，与XXX=0配合使用", 15, "left", "38,38,38")
    UILabel(2, "XXX=2 停止赛事模式，将主模式更改为多人刷声望，与XXX=3配合使用", 15, "left", "38,38,38")
    UILabel(2, "XXX=3 开始赛事模式，将主模式更改为赛事模式，与XXX=2配合使用", 15, "left", "38,38,38")
    UILabel(2, "XXX=4 终止脚本运行，此操作不可逆", 15, "left", "38,38,38")
    UILabel(2, "XXX=5 赛事没油没票后改为等待60分钟", 15, "left", "38,38,38")
    UILabel(2, "XXX=6 赛事没油没票后改为多人刷声望", 15, "left", "38,38,38")
    UILabel(2, "远程日志功能，可以访问网址https://yourdomin.cn/api/a9log?udid=" .. ts.system.udid() .. "查看本日脚本日志。", 15, "left", "38,38,38")
    UILabel(2, "如果有脚本无法识别的界面，请联系QQ群1028746490群主。如果需要购买脚本授权码也请联系上述QQ群群主。", 20, "left", "38,38,38")
    UIShow()
    settings = mode .. "|" .. switch .. "|" .. path .. "|" .. gamenum .. "|" .. PVEchooseCar .. "|" .. carplace .. "|" .. backifallstar .. "|" .. PVPatBest .. "|" .. savePower .. "|" .. lowerCar .. "|" .. changeCar .. "|" .. watchAds .. "|" .. timeout_backPVE .. "|" .. skipcar .. "|" .. timeout_parallelRead .. "|" .. email
end
function startGame()
    log4l("脚本开始")
    toast("脚本开始", 3)
    makeGameFront()
    ts.httpsGet(apiUrl .. "a9control?udid=" .. ts.system.udid() .. "&command=1", {}, {})
    --将脚本状态置为运行
end
function snap()
    --截图被存在了userPath().."/res/"下
    if width == 0 and height == 0 then
        checkScreenSize()
    end
    pngname = os.date("%Y%m%d%H%M%S_") .. tostring(width) .. "x" .. tostring(height) .. ".png"
    snapshot(pngname, 0, 0, height - 1, width - 1)
    return pngname
end
function upload(filename)
    status = ts.ftp.connect("yourip", "asphalt9", "asphalt9123")
    if status then
        --上传本地 res 文件夹下的 filename 文件到服务器
        upStatus = ts.ftp.upload(root .. filename, "/home/ftp1/" .. tostring(width) .. "x" .. tostring(height) .. "/" .. filename, 0)
    else
        --toast("连接失败", 0)
    end
    ts.ftp.close()  --操作完成后，断开 FTP 服务器连接
end
function keypress(key)
    keyDown(key)
    keyUp(key)
end
function uploadSnap()
    filename = snap()
    upload(filename)
    delFile(root .. filename)
end
function restartApp()
    uploadSnap()
    log4l("游戏重启")
    closeApp(gameBid) --关闭游戏
    mSleep(5000)
    runApp(gameBid) --打开游戏
    mSleep(5000)
    restartTimes = restartTimes + 1
    noAds = 0
end
function wait_when_Parallel_read_detected()
    if receive_starting_command == false then
        log4l("账号被顶，等待" .. tostring(timeout_parallelRead) .. "分钟")
        toast("账号被顶", 1)
        mSleep(1000)
        toast("等待" .. tostring(timeout_parallelRead) .. "分钟", 1)
        stop = wait_time(timeout_parallelRead) --stop==-2停止 stop==-1正常
        toast("等待完成", 1)
        return stop
    end
    return -1
end
function wait_time(minutes)
    if minutes >= 5 then
        closeApp(gameBid)
    end
    --minutes是数字型
    log4l("等" .. tostring(minutes) .. "分钟", 1)
    --循环minutes * 6次，每次等10秒，共minutes * 60秒也就是minutes分钟
    for _ = 1, minutes * 6 do
        mSleep(10 * 1000) --等10秒
    end
    --https请求获取运行指令
    if getHttpsCommand() == 4 then
        return -2
    else
        log4l(tostring(minutes) .. "分钟到", 1)
        makeGameFront()
        return -1
    end

end
function back()
    --[[
    if model == "SE" then
        tap(30, 30)
    elseif model == "i68" then
        tap(30, 30)
    end
    ]]--
    tap(30, 30)
    mSleep(2000)
end
function checkTimeOut()
    if time ~= -1 then
        if (os.time() - time >= timeout_backPVE * 60) then
            toast("时间到", 1)
            mode = supermode
            backHome()
        else
            --toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
            --mSleep(1000);
        end
    end
end
function recordPVPnPVE()
    if mode == "多人刷声望" or mode == "多人刷包" then
        PVPwithoutPack = PVPwithoutPack + 1
        PVPTimes = PVPTimes + 1
        log4l("完成" .. tostring(PVPTimes) .. "局多人")
    elseif mode == "赛事模式" then
        PVETimes = PVETimes + 1
        log4l("🚗 完成" .. tostring(PVETimes) .. "局赛事")
    end
end
function actAfterNoFuelNTicket()
    time = os.time() --记录当前时间
    if switch == "多人刷声望" or switch == "多人刷包" then
        toast(tostring(timeout_backPVE) .. "分钟后返回", 1)
        mode = switch
        mSleep(200)
        backHome()
        return -1
    elseif switch == "等30分钟" or switch == "等60分钟" then
        changecar = false
        if switch == "等30分钟" then
            return wait_time(30)
        elseif switch == "等60分钟" then
            return wait_time(60)
        end
        return -1
    end
end
function watchAd()
    beginGame()
    mSleep(2000)
    if model == "SE" then
        tap(731, 427)
    elseif model == "i68" then
        tap(862, 509)
    end
    mSleep(3000)
    haveAds = checkPlace()
    if haveAds == 34 then
        worker(haveAds)
        noAds = noAds + 1
        return -2
    end
    noAds = 0
    if watchAds == "开(有20倍广告加速)" then
        mSleep(10000)
    elseif watchAds == "开(没有广告加速)" then
        mSleep(35000)
    end
    return -1
end
---通用处理函数[区分设备型号]---
function backHome()
    if model == "SE" then
        if (isColor(1110, 14, 0xf8f9fb, 85) and isColor(1096, 22, 0xe7ebef, 85) and isColor(1122, 22, 0xe7eaf0, 85) and isColor(1097, 34, 0xc7d1dc, 85) and isColor(1120, 37, 0xc2cbd7, 85) and isColor(1110, 36, 0x13243e, 85)) then
            tap(1100, 20) --返回大厅
        else
            back()
        end
    elseif model == "i68" then
        tap(1300, 30) --返回大厅
    end
    mSleep(3000)
    if checkPlace() ~= 0 then
        toast("有内鬼，停止交易", 1)
        return -1
    end
    return 0
end
function getStage()
    if model == "SE" then
        SE_X, SE_Y = 355, 305
        if isColor(SE_X, SE_Y, 0xf1cb30, 85) then
            stage = 2 --黄金段位
        elseif isColor(SE_X, SE_Y, 0x96b2d4, 85) then
            stage = 1 --白银段位
        elseif isColor(SE_X, SE_Y, 0xd88560, 85) then
            stage = 0 --青铜段位
        elseif isColor(SE_X, SE_Y, 0x9365f8, 85) then
            stage = 3 --白金段位
        elseif isColor(SE_X, SE_Y, 0xf5e2a4, 85) then
            stage = 4 --传奇段位
        else
            stage = -2 --没有段位
        end
    elseif model == "i68" then
        --Undone
        i86_X, i86_Y = 430, 355
        if isColor(i86_X, i86_Y, 0xf1cb30, 85) then
            stage = 2 --黄金段位
        elseif isColor(i86_X, i86_Y, 0x96b3d3, 85) then
            stage = 1 --白银段位
        elseif isColor(i86_X, i86_Y, 0xd88560, 85) then
            stage = 0 --青铜段位
        elseif isColor(i86_X, i86_Y, 0x9365f8, 85) then
            stage = 3 --白金段位
        elseif isColor(i86_X, i86_Y, 0xf5e2a4, 85) then
            stage = 4 --传奇段位
        else
            stage = -2 --没有段位
        end
    end
end
function chooseCarStage()
    virtalStage = 0
    if lowerCar == "开" then
        virtalStage = stage - 1
    else
        virtalStage = stage
    end
    baseList = { SE = { 760, 830, 900, 975, 975 }, i68 = { 900, 980, 1060, 1140, 1140 } }
    offset = { SE = 70, i68 = 80 }
    if virtalStage <= 0 then
        virtalStage = 1
    end
    --TODO:如果是传奇段位，就选三菱
    tap(baseList[model][virtalStage + 1] + chooseHighStageCarClass * offset[model], 100)
end
function lowPower()
    t = batteryStatus()
    --没在充电 电量少于20 停止脚本
    return t.charging == 0 and tonumber(t.level) <= 20
end
function toCarbarn()
    if PVPchooseCar == true then
        getStage()
        if stage == 4 and PVPatBest == "否" then
            if supermode == "多人刷声望" then
                log4l("传奇段位不跑多人")
                toast("脚本停止", 1)
                return -1
                --传奇段位且不在传奇刷多人并且主模式是赛事模式时
            elseif supermode == "赛事模式" then
                log4l("传奇段位不跑多人，脚本改为赛事模式，等30分钟")
                mode = "赛事模式" --将现在的模式改为赛事模式
                switch = "等30分钟" --赛事没油改为等30分钟
                return 0
            end
        end
    end
    if model == "SE" then
        tap(720, 570) --进入车库
    elseif model == "i68" then
        tap(845, 670) --进入车库
    end
    return 1 --可以进入车库选车并开始PVP
end
function chooseGame()
    if model == "SE" then
        if gamenum <= 7 then
            tap(145 + 165 * (gamenum - 1), 500)
            mSleep(1000)
            tap(145 + 165 * (gamenum - 1), 500)
        else
            for _ = 1, gamenum - 7, 1 do
                moveTo(610, 500, 483, 500, 20)
                mSleep(500)
            end
            tap(145 + 165 * 6, 500)
            mSleep(1000)
            tap(145 + 165 * 6, 500)
        end
    elseif model == "i68" then
        if gamenum == 1 then
            tap(170, 570)
            mSleep(1000)
            tap(170, 590)
        end
        if gamenum > 1 and gamenum <= 6 then
            tap(372 + 194 * (gamenum - 2), 570)
            mSleep(1000)
            tap(372 + 194 * (gamenum - 2), 570)
        else
            for _ = 0, gamenum - 7, 1 do
                moveTo(1250, 500, 1095, 500, 20)
                mSleep(500)
            end
            tap(1300, 570)
            mSleep(1000)
            tap(1300, 570)
        end
    end
    mSleep(2000)
    return -1
end
function checkAndGetPackage()
    nomorepack = false
    if model == "SE" then
        if (isColor(531, 99, 0xfdfff6, 90) and isColor(567, 108, 0xfcfff4, 90) and isColor(615, 109, 0xfcfff5, 90) and isColor(736, 539, 0xff0054, 90)) then
            toast("领取多人包", 1)
            log4l("🎁 开多人包")
            mSleep(700)
            tap(570, 470)
            mSleep(2000)
            tap(500, 600)
            mSleep(2000)
            tap(1030, 590)
            mSleep(10000)
            packWithoutRestore = packWithoutRestore + 1
            PVPwithoutPack = 0
        end
        --VIP用户多人包可补充界面为灰色
        VIPrestoreButtonDisabled = (isColor(86, 452, 0x010f17, 90) and isColor(134, 452, 0x05121a, 90) and isColor(175, 454, 0x09161e, 90) and isColor(205, 450, 0x06121b, 90) and isColor(199, 467, 0x051219, 90) and isColor(157, 467, 0x010f15, 90) and isColor(123, 466, 0x07141c, 90) and isColor(92, 466, 0x011018, 90) and isColor(96, 478, 0x021019, 90) and isColor(220, 479, 0x09161f, 90))
        VIPcanRestore = (isColor(113, 498, 0xdce1e4, 90) and isColor(113, 504, 0xa9b7be, 90) and isColor(105, 504, 0xebeef0, 90) and isColor(105, 501, 0xf7f9f9, 90) and isColor(124, 498, 0xd0d7dc, 90) and isColor(124, 503, 0xd0d7dc, 90) and isColor(134, 503, 0xfefefe, 90) and isColor(137, 503, 0xfafbfb, 90) and isColor(137, 507, 0xebeef0, 90)) and not VIPrestoreButtonDisabled
        poorrestoreButtonDisabled = true --TODO:普通用户多人包可补充界面为灰色
        poorcanRestore = (isColor(120, 500, 0xfcfdfd, 90) and isColor(123, 500, 0xfcfdfd, 90) and isColor(128, 500, 0xffffff, 90) and isColor(128, 506, 0xdce2e5, 90) and isColor(125, 506, 0xafbdc3, 90) and isColor(143, 506, 0xf2f4f5, 90) and isColor(147, 505, 0xedf0f2, 90) and isColor(151, 500, 0xe9edee, 90) and isColor(154, 511, 0xfafbfa, 90)) and not poorrestoreButtonDisabled
        canRestore = VIPcanRestore or poorcanRestore
        if canRestore then
            if tonumber(os.date("%H")) ~= 7 then
                log4l("补充多人包")
                packWithoutRestore = 0
                tap(153, 462)
                mSleep(1000)
            else
                log4l("可补充多人包，早7点不补充")
            end
            return 1
        end
        --[[if VIPrestoreButtonDisabled or poorrestoreButtonDisabled then
            nomorepack = true
        end]]--
        if tonumber(os.date("%H")) ~= 7 then
            tap(153, 462) --尝试补充多人包
        end
    elseif model == "i68" then
        tap(668, 576)
        mSleep(2000)
        place = checkPlace()
        if place == 7 then
            log4l("🎁 开多人包")
            receivePrizeAtGame()
            PVPwithoutPack = 0
            mSleep(10000)
        elseif place == 1 then
            back()
        end
        if tonumber(os.date("%H")) ~= 7 then
            tap(176, 545) --尝试补充多人包
        end
    end
    --现在位于大厅，页面在多人界面
    if shouldStop(nomorepack) then
        return -2
    else
        return 1
    end
end
function unlockedDevice()
    flag = deviceIsLock()
    if flag == 1 then
        unlockDevice();
    end
end
function checkShouldSwitchAccount()
    a9getCommandcode, a9getCommandheader_resp, a9getCommandbody_resp = ts.httpsGet(apiUrl .. "a9switchAccount?udid=" .. ts.system.udid(), {}, {})
    if a9getCommandcode == 200 then
        return a9getCommandbody_resp
    else
        return "null"
    end
end
function switchAccount(account, passwd)
    accountnum = account
    account = splitStr(account) --拿到账号
    passwd = splitStr(passwd) --拿到密码
    backHome()
    tap(1100, 20) --按下设置
    mSleep(2000)
    tap(655, 300)--按下退出
    mSleep(2000)
    tap(390, 425)--按下确定
    mSleep(5000)
    tap(570, 520)--按下开始
    mSleep(4000)
    for _ = 1, 10 do
        tap(1030, 40)--按右上角切换账号
        mSleep(500)
    end
    tap(540, 205)--按下账号输入框弹出键盘
    mSleep(2000)
    tap(723, 63)--按下删除清清除当前账号密码
    mSleep(2000)
    --输入账号
    keypress('1')--第一次keypress会失效
    mSleep(500)
    for i = 1, #account do
        keypress(account[i])
    end
    mSleep(1000)
    tap(381, 157) --按下密码输入框
    mSleep(1000)
    --输入密码
    for i = 1, #passwd do
        keypress(passwd[i])
    end
    tap(580, 257) --点击登陆
    log4l("登陆账号" .. accountnum)
    mSleep(10000)
end
function shouldStop(nomorepack)
    --开完最后一个包可能不会立刻停止，因为12个奖杯只需要少于12局即可完成，代码中写12是为稳定起见 //针对SE：连续开4个包但没补充应该停止
    if (mode == "多人刷包" and PVPwithoutPack >= 12) or (model == "SE" and mode == "多人刷包" and (packWithoutRestore >= 4 or nomorepack or PVPwithoutPack >= 12)) then
        log4l("🈚 " .. accountnum .. "没有多人包可刷")
        --将账号accountnum在数据库中状态改为刷包关闭
        ts.httpsGet(apiUrl .. "a9accountDone?udid=" .. ts.system.udid() .. "&account=" .. nowaccount, {}, {})
        if supermode == "赛事模式" and switch == "多人刷包" then
            log4l("赛事没油没票改为等30分钟")
            switch = "等30分钟"
            mode = supermode
            return false
        end
        if switchaccountfun then
            --查看是否有需要刷包的账号
            nowaccount = checkShouldSwitchAccount()
            if nowaccount ~= "null" then
                -- 拿到账号密码
                data = strSplit(nowaccount, '_', 1)
                switchAccount(data[1], data[2]) --切换账号
                PVPwithoutPack, packWithoutRestore = 0, 0 --初始化刷包数据
                return false
            end
        end
        --没有账号可以切换，脚本应该停止
        return true
    elseif savePower == "开" and lowPower() then
        log4l("电量低，脚本停止")
        return true
    elseif getHttpsCommand() == 4 then
        return true
    end
    return false
end
function receivePrizeFromGL()
    log4l("🎁 领取来自gameloft的礼物")
    if model == "SE" then
        tap(1015, 582)
        mSleep(5000)
        tap(569, 582)
        mSleep(2000)
        tap(1015, 582)
    elseif model == "i68" then
        tap(1015, 582)
        mSleep(5000)
        tap(569, 582)
        mSleep(2000)
        tap(1015, 582)
    end
    mSleep(2000)
end
function chooseCar()
    mSleep(2500)
    if PVPchooseCar then
        chooseCarStage()
        mSleep(1500)
        chooseClassCar()
        mSleep(3000)
        if not switchToSuitableCar() then
            return false
        end
    end
    if PVPchooseCar == false then
        if carCanUse() == false and watchAds ~= "关" then
            if watchAd() == -1 then
                if model == "SE" then
                    tap(1077, 83) --关闭广告
                elseif model == "i68" then
                    tap(1276, 83) --关闭广告
                end
                mSleep(2000)
                if restartAfterAds then
                    closeApp(gameBid) --关闭游戏
                    mSleep(5000)
                    runApp(gameBid) --打开游戏
                    mSleep(5000)
                end
            end
        end
    end
    beginGame()
    return true
end
function receivePrizeAtGame()
    if model == "SE" then
        tap(550, 590)
        mSleep(1000)
        tap(1020, 585)
    elseif model == "i68" then
        tap(670, 700)
        mSleep(1000)
        tap(1200, 680)
    end
    mSleep(1500)
    return -1
end
function beginGame()
    checkAutoMobileBeforeBegin()
    if model == "SE" then
        tap(1090, 570)
    elseif model == "i68" then
        tap(1280, 700)
    end
end
function slideToPVP()
    if model == "SE" then
        for _ = 1, 10, 1 do
            moveTo(860, 235, 225, 235, 20) --从右往左划
            if (isColor(1116, 539, 0xdc014a, 85) and isColor(1116, 538, 0xda0147, 85)) then
                break
            end
        end
        for _ = 1, 2, 1 do
            moveTo(225, 235, 860, 235, 20) --从左往右划
        end
    elseif model == "i68" then
        for _ = 1, 10, 1 do
            moveTo(860, 235, 225, 235, 20) --从右往左划
        end
        for _ = 1, 3, 1 do
            moveTo(225, 235, 860, 235, 20) --从左往右划
        end
    end
    mSleep(2000)
end
function selectCarAtGame()
    if model == "SE" then
        if PVEchooseCar then
            if backifallstar == "是" then
                tap(580, 270)
                mSleep(2000)
                back()
                mSleep(1000)
            end
            if carplace == "中间上" then
                tap(580, 270)
            elseif carplace == "中间下" then
                tap(580, 420)
            elseif carplace == "右上（被寻车满星时）" then
                for i = 800, 1050, 30 do
                    tap(i, 320)
                end
            elseif carplace == "左上" then
                tap(286, 268)
            elseif carplace == "左下" then
                tap(219, 496)
            end
        end
    elseif model == "i68" then
        if PVEchooseCar then
            if backifallstar == "是" then
                tap(660, 320)
                mSleep(2500)
                back()
                mSleep(1000)
            end
            if PVEchooseCar then
                if carplace == "中间上" then
                    tap(660, 320)
                elseif carplace == "中间下" then
                    tap(660, 462)
                elseif carplace == "右上（被寻车满星时）" then
                    for i = 1000, 1325, 30 do
                        tap(i, 320)
                    end
                elseif carplace == "左上" then
                    tap(280, 330)
                elseif carplace == "左下" then
                    tap(260, 600)
                end
            end
        end
        mSleep(2500)
    end
end
function carCanUse()
    if model == "SE" then
        unlocked = isColor(160, 85, 0xffe833, 85) --已解锁为true
        has_fuel = isColor(1090, 590, 0xc3fc11, 85) --有油为true
    elseif model == "i68" then
        unlocked = isColor(185, 100, 0xffd313, 85) --已解锁为true
        has_fuel = isColor(1255, 675, 0xc3fb12, 85) --有油为true
    end
    return unlocked and has_fuel
end
function checkAutoMobile()
    if model == "SE" then
        if (isColor(188, 94, 0xbf0408, 90) and isColor(196, 94, 0xe90203, 90) and isColor(191, 97, 0xf30101, 90) and isColor(186, 103, 0xc40303, 90) and isColor(196, 102, 0xca0302, 90) and isColor(186, 107, 0xe70203, 90) and isColor(193, 107, 0xd30405, 90)) then
            --toast("开启自动驾驶",1);
            tap(128, 100)
        end
    elseif model == "i68" then
        if (isColor(220, 114, 0xcb1319, 90) and isColor(225, 114, 0xbf191f, 90) and isColor(223, 121, 0xfb0101, 90) and isColor(230, 120, 0xd50e0d, 90)) then
            --toast("开启自动驾驶",1);
            tap(230, 120)
        end
    end
end
function checkAutoMobileBeforeBegin()
    if model == "SE" then
        if (isColor(801, 587, 0xc3fb12, 90) and isColor(838, 588, 0xc3fb12, 90) and isColor(840, 608, 0xc3fb12, 90) and isColor(795, 607, 0xc3fb12, 90)) then
            --toast("开启自动驾驶",1);
            tap(760, 600)
        end
    elseif model == "i68" then
        if (isColor(985, 700, 0xc3fb12, 85)) then
            --toast("开启自动驾驶",1);
            tap(890, 700)
        end
    end
    mSleep(1500)
end
function switchToSuitableCar()
    skip = 1
    --当车没油、没解锁（不能买），需跳过，没解锁能买时，总是找下一辆车
    should_skip = skip == skipcar
    while (not carCanUse()) or should_skip do
        if model == "SE" then
            tap(440, 320) --向左选车
        elseif model == "i68" then
            tap(510, 380)
        end
        mSleep(500)
        skip = skip + 1
        should_skip = skip == skipcar
        --如果连续三十次没车 估计是不在选车界面
        if skip > 30 then
            return false
        end
    end
    return true
end
function chooseClassCar()
    if model == "SE" then
        --旧多人选车方案
        if chooseHighStageCarClass == 0 then
            -- 没有段位 青铜段位 未知段位
            if stage == -2 or stage == 0 or stage == -1 then
                for i = 800, 450, -30 do
                    tap(i, 270)
                end
            else
                for i = 1100, 900, -30 do
                    tap(i, 270)
                end
            end
        elseif chooseHighStageCarClass == 1 then
            --新多人选车方案
            --如果不是传奇
            if stage < 4 or (stage == 4 and lowerCar == "开") then
                tap(294, 282)
            elseif lowerCar == "关" then
                --当是传奇段位且未开启选低一段车辆时
                for i = 1100, 900, -30 do
                    tap(i, 270)
                end
            end
        end
    elseif model == "i68" then
        --旧多人选车方案
        if chooseHighStageCarClass == 0 then
            -- 没有段位 青铜段位 未知段位
            if stage == -2 or stage == 0 or stage == -1 then
                for i = 600, 300, -30 do
                    tap(i, 270)
                end
            else
                for i = 1325, 1025, -30 do
                    tap(i, 270)
                end
            end
        elseif chooseHighStageCarClass == 1 then
            --新多人选车方案
            --如果不是传奇
            if stage < 4 or (stage == 4 and lowerCar == "开") then
                tap(348, 329)
            elseif lowerCar == "关" then
                --当是传奇段位且未开启选低一段车辆时，使用旧多人选车方案
                for i = 1325, 1025, -30 do
                    tap(i, 270)
                end
            end
        end
    end
end
---iPhone 5S/SE 设备处理函数---
function checkPlace_SE()
    if (isColor(53, 64, 0xfb1264, 85) and isColor(151, 65, 0xfb1264, 85) and isColor(55, 102, 0xfb1264, 85) and isColor(153, 102, 0xfb1264, 85) and isColor(47, 225, 0xef1363, 85) and isColor(72, 225, 0xf91264, 85) and isColor(107, 225, 0xfa1264, 85) and isColor(145, 225, 0xf21364, 85) and isColor(85, 540, 0xffffff, 85) and isColor(1052, 552, 0xffffff, 85)) then
        checkplacetimes = 0
        return 26 --游戏公告栏，左上角显示为"最新动态"四个字
    elseif (isColor(688, 391, 0xfe8b40, 85) and isColor(395, 392, 0xfe8b40, 85) and isColor(479, 399, 0xfe8b40, 85) and isColor(494, 371, 0xfe8b40, 85) and isColor(787, 420, 0xfe8b40, 85) and isColor(819, 366, 0xfe8b40, 85)) then
        checkplacetimes = 0
        return -2 --在登录界面
    elseif (isColor(419, 137, 0xffffff, 85) and isColor(455, 134, 0xffffff, 85) and isColor(573, 137, 0xffffff, 85) and isColor(573, 158, 0xffffff, 85) and isColor(602, 136, 0xffffff, 85) and isColor(636, 133, 0xffffff, 85) and isColor(659, 134, 0xffffff, 85) and isColor(683, 140, 0xffffff, 85) and isColor(442, 515, 0x000721, 85) and isColor(190, 518, 0xffffff, 85)) then
        checkplacetimes = 0
        return 20 --俱乐部新人
    elseif (isColor(437, 570, 0x9f0942, 85) and isColor(452, 569, 0x9f0943, 85) and isColor(451, 584, 0x9f0942, 85) and isColor(444, 577, 0x9f0942, 85)) then
        return -3 --网络未同步
    elseif (isColor(92, 129, 0xf00252, 85) and isColor(97, 129, 0xf20252, 85) and isColor(104, 129, 0xf50153, 85) and isColor(116, 130, 0xea0352, 85) and isColor(128, 127, 0xf1014b, 85) and isColor(158, 128, 0xdb0244, 85) and isColor(761, 96, 0xd9d6d6, 85) and isColor(827, 101, 0x3887d7, 85) and isColor(906, 101, 0x4e443b, 85) and isColor(971, 100, 0x9015fb, 85)) then
        checkplacetimes = 0
        return 3.1 --在多人车库
    elseif (isColor(1069, 75, 0xffffff, 85) and isColor(1087, 74, 0xffffff, 85) and isColor(1077, 83, 0xffffff, 85) and isColor(1068, 93, 0xffffff, 85) and isColor(1087, 93, 0xffffff, 85)) or (isColor(575, 76, 0xffffff, 90) and isColor(588, 77, 0xffffff, 90) and isColor(582, 83, 0xffffff, 90) and isColor(574, 90, 0xffffff, 90) and isColor(589, 91, 0xffffff, 90) and isColor(568, 82, 0x848484, 90) and isColor(602, 84, 0x848484, 90) and isColor(582, 70, 0x848484, 90) and isColor(582, 100, 0x848484, 90)) then
        checkplacetimes = 0
        return 25 --广告播放完成,后面的or是广告错位了
    elseif getColor(5, 5) == 0x101f3b then
        checkplacetimes = 0
        return 0 --在大厅
    elseif (isColor(240, 426, 0xffffff, 90) and isColor(406, 432, 0xffffff, 90) and isColor(247, 456, 0xffffff, 90) and isColor(412, 457, 0xffffff, 90) and isColor(306, 550, 0xffffff, 90) and isColor(525, 554, 0xffffff, 90) and isColor(735, 430, 0xffffff, 90) and isColor(880, 434, 0xffffff, 90) and isColor(294, 599, 0xffffff, 90) and isColor(887, 458, 0xffffff, 90)) then
        checkplacetimes = 0
        return 1 --在多人
    elseif (isColor(115, 625, 0xc3fb12, 85) or isColor(301, 625, 0xc3fb12, 85) or isColor(469, 625, 0xc3fb12, 85)) then
        checkplacetimes = 0
        return 5 --在赛事
    elseif (isColor(216, 96, 0xe6004d, 85) and isColor(139, 96, 0xfc0053, 85) and isColor(60, 95, 0xf00251, 85) and isColor(221, 176, 0xffffff, 85) and isColor(60, 161, 0xff0054, 85)) then
        checkplacetimes = 0
        return 6 --在赛事开始界面
    elseif (isColor(540, 312, 0x01b9e3, 85) and isColor(635, 307, 0x01b8e3, 85) and isColor(596, 273, 0x01718b, 85) and isColor(581, 350, 0x03b9e3, 85) and isColor(564, 308, 0xffffff, 85) and isColor(609, 310, 0xffffff, 85) and isColor(658, 314, 0xffffff, 85) and isColor(682, 291, 0xdfdfdf, 85)) then
        checkplacetimes = 0
        return 17 --多人匹配中
    elseif getColor(115, 25) == 0xff0054 then
        checkplacetimes = 0
        return 2 --游戏结算界面
    elseif (isColor(37, 94, 0xfefefe, 90) and isColor(36, 103, 0xfefefe, 90) and isColor(46, 99, 0xffffff, 90) and isColor(54, 100, 0xffffff, 90) and isColor(60, 100, 0xffffff, 90) and isColor(68, 99, 0xffffff, 90) and isColor(74, 99, 0xffffff, 90) and isColor(104, 99, 0x3daaef, 90) and isColor(112, 99, 0x3ca8ec, 90) and isColor(153, 100, 0x3daaee, 90)) then
        checkplacetimes = 0
        return 3 --游戏中
    elseif (isColor(60, 26, 0xff0052, 85) and isColor(153, 29, 0xfe0052, 85) and isColor(209, 59, 0xffffff, 85) and isColor(282, 57, 0xffffff, 85) and isColor(355, 65, 0xffffff, 85) and isColor(454, 63, 0xffffff, 85) and isColor(515, 61, 0xffffff, 85) and isColor(629, 45, 0xffffff, 85)) then
        checkplacetimes = 0
        return 4 --来自Gameloft的礼物
    elseif (isColor(525, 33, 0xff0054, 85) and isColor(536, 33, 0xff0054, 85) and isColor(531, 41, 0xff0054, 85) and isColor(529, 52, 0xff0054, 85) and isColor(568, 33, 0xff0054, 85) and isColor(568, 44, 0xbe064c, 85) and isColor(567, 53, 0xc6054c, 85) and isColor(490, 81, 0xdadce0, 85) and isColor(556, 87, 0xe4e6e8, 85) and isColor(631, 85, 0xe6e8ea, 85)) then
        checkplacetimes = 0
        return 7 --领奖开包
    elseif (isColor(248, 391, 0xd88560, 90) and isColor(397, 387, 0x96b2d4, 90) and isColor(545, 374, 0xf1cb30, 90) and isColor(692, 359, 0x9365f8, 90) and isColor(866, 353, 0xf5e2a4, 90)) then
        checkplacetimes = 0
        return 8 --多人联赛介绍界面
    elseif (isColor(597, 52, 0xff0054, 85) and isColor(596, 63, 0xff0054, 85) and isColor(523, 55, 0xff0054, 85) and isColor(535, 55, 0xff0054, 85) and isColor(567, 54, 0xff0054, 85) and isColor(557, 70, 0xff0054, 85) and isColor(254, 552, 0xffffff, 85) and isColor(522, 557, 0xffffff, 85) and isColor(250, 592, 0xffffff, 85) and isColor(526, 591, 0xffffff, 85)) or (isColor(522, 99, 0xffffff, 85) and isColor(439, 114, 0xffffff, 85) and isColor(560, 99, 0xffffff, 85) and isColor(621, 108, 0xffffff, 85) and isColor(634, 116, 0xffffff, 85) and isColor(678, 105, 0xffffff, 85) and isColor(687, 105, 0xffffff, 85) and isColor(269, 559, 0xffffff, 85) and isColor(505, 572, 0xffffff, 85)) then
        checkplacetimes = 0
        return 9 --赛车解锁或升星
    elseif (isColor(523, 350, 0xcb0042, 85) and isColor(610, 350, 0xcc0042, 85) and isColor(610, 435, 0xcc0042, 85) and isColor(568, 460, 0xcd0042, 85) and isColor(525, 436, 0xcc0042, 85) and isColor(544, 422, 0xd9d9d9, 85) and isColor(568, 439, 0xcecece, 85) and isColor(591, 426, 0xd6d6d6, 85) and isColor(592, 396, 0xececec, 85) and isColor(592, 371, 0xfafafa, 85)) then
        checkplacetimes = 0
        return 10 --开始的开始
    elseif (isColor(35, 555, 0xfb1264, 85) and isColor(35, 602, 0xfb1264, 85) and isColor(223, 136, 0xfa0153, 85) and isColor(349, 137, 0xfe0055, 85) and isColor(938, 569, 0xffffff, 85) and isColor(1070, 569, 0xffffff, 85) and isColor(935, 602, 0xffffff, 85) and isColor(1076, 601, 0xffffff, 85)) then
        checkplacetimes = 0
        return 11 --段位升级
    elseif (isColor(222, 50, 0xffffff, 85) and isColor(301, 53, 0xffffff, 85) and isColor(196, 85, 0xffffff, 85) and isColor(277, 84, 0xffffff, 85) and isColor(333, 298, 0xffffff, 85) and isColor(392, 297, 0xffffff, 85) and isColor(456, 300, 0xffffff, 85) and isColor(394, 212, 0xffffff, 85) and isColor(293, 237, 0xffffff, 85) and isColor(494, 235, 0xffffff, 85)) then
        checkplacetimes = 0
        return 12 --声望升级
    elseif (isColor(184, 218, 0xffffff, 85) and isColor(218, 229, 0xd8d9dc, 85) and isColor(245, 224, 0xe6e7e9, 85) and isColor(266, 225, 0xf9f9f9, 85) and isColor(342, 225, 0xe9e9e9, 85) and isColor(408, 221, 0xcfcfcf, 85) and isColor(935, 228, 0xf2004f, 85) and isColor(991, 225, 0xff0054, 85) and isColor(976, 243, 0xfb0052, 85)) then
        checkplacetimes = 0
        return 13 --未能连接到服务器
    elseif (isColor(26, 24, 0xff0054, 85) and isColor(234, 20, 0xff0054, 85) and isColor(29, 212, 0xff0054, 85) and isColor(195, 120, 0xffffff, 85) and isColor(441, 127, 0xffffff, 85) and isColor(15, 103, 0x061724, 85) and isColor(845, 559, 0xc3fb13, 85) and isColor(1035, 559, 0xc2fb12, 85) and isColor(945, 603, 0xc3fb13, 85)) then
        checkplacetimes = 0
        return 14 --多人断开连接
    elseif (isColor(525, 185, 0xffffff, 85) and isColor(546, 182, 0xffffff, 85) and isColor(574, 189, 0xffffff, 85) and isColor(591, 190, 0xffffff, 85) and isColor(729, 329, 0xeceef1, 85) and isColor(742, 336, 0xd2d6dd, 85) and isColor(759, 334, 0xffffff, 85) and isColor(788, 336, 0xe4e7eb, 85) and isColor(798, 329, 0xcdd1d9, 85) and isColor(569, 437, 0xffffff, 85)) then
        checkplacetimes = 0
        return 15 --连接错误
    elseif (isColor(176, 214, 0xffffff, 85) and isColor(269, 217, 0xecedee, 85) and isColor(326, 217, 0x999da4, 85) and isColor(342, 211, 0xbdc0c4, 85) and isColor(352, 221, 0xe7e7e7, 85) and isColor(395, 221, 0xd7d7d7, 85) and isColor(409, 221, 0xcececf, 85) and isColor(555, 352, 0xe5eaf0, 85) and isColor(951, 217, 0xff0054, 85) and isColor(993, 221, 0xff0054, 85)) then
        checkplacetimes = 0
        return 16 --顶号行为
    elseif (isColor(495, 147, 0xff0054, 85) and isColor(525, 149, 0xd4044d, 85) and isColor(538, 148, 0xfd0054, 85) and isColor(564, 145, 0xfd0054, 85) and isColor(585, 150, 0xfd0054, 85) and isColor(604, 146, 0xfd0054, 85) and isColor(608, 145, 0xe80250, 85) and isColor(861, 158, 0xf90052, 85) and isColor(567, 453, 0xc3fb11, 85)) then
        checkplacetimes = 0
        return 18 --VIP到期
    elseif (isColor(67, 23, 0x664944, 85) and isColor(183, 26, 0x7b4542, 85) and isColor(346, 22, 0x8f7a81, 85) and isColor(495, 27, 0x587bad, 85) and isColor(632, 25, 0x90bee2, 85) and isColor(764, 27, 0x8c7b94, 85) and isColor(892, 29, 0x9c7d84, 85)) then
        checkplacetimes = 0
        return 19 --登录延时
    elseif (isColor(506, 152, 0xf3f4f5, 85) and isColor(542, 162, 0xfbfbfb, 85) and isColor(560, 162, 0xe8eaec, 85) and isColor(573, 161, 0xffffff, 85) and isColor(612, 162, 0xffffff, 85) and isColor(508, 464, 0xffffff, 85) and isColor(619, 457, 0xffffff, 85) and isColor(647, 486, 0x020922, 85)) then
        checkplacetimes = 0
        return 21 --段位降低
    elseif (isColor(19, 21, 0xff0054, 85) and isColor(223, 17, 0xff0054, 85) and isColor(18, 235, 0xff0054, 85) and isColor(231, 241, 0xff0054, 85) and isColor(178, 155, 0xffffff, 85) and isColor(409, 157, 0xffffff, 85) and isColor(454, 131, 0xffffff, 85) and isColor(1017, 562, 0xc3fb12, 85) and isColor(1074, 593, 0xc3fb11, 85) and isColor(1085, 607, 0x000b1f, 85)) then
        checkplacetimes = 0
        return 22 --失去资格
    elseif (isColor(950, 91, 0xff0056, 90) and isColor(955, 96, 0xff0056, 90) and isColor(961, 102, 0xfd0255, 90) and isColor(968, 96, 0xff0054, 90) and isColor(973, 91, 0xff0055, 90) and isColor(952, 112, 0xff0054, 90) and isColor(957, 107, 0xfe0053, 90) and isColor(967, 107, 0xfa0054, 90) and isColor(970, 111, 0xfd0056, 90)) or (isColor(962, 97, 0xffffff, 90) and isColor(957, 92, 0xfcfdfa, 90) and isColor(954, 89, 0xfefefc, 90) and isColor(952, 106, 0xfcfdfa, 90) and isColor(971, 106, 0xfdfcfa, 90)) or (isColor(961, 101, 0xfdfdfd, 90) and isColor(969, 93, 0xfcfdfa, 90) and isColor(952, 92, 0xfefcfe, 90) and isColor(951, 111, 0xfdfcfd, 90) and isColor(970, 110, 0xfffbfe, 90)) or (isColor(954, 89, 0xfa0154, 90) and isColor(961, 97, 0xff0054, 90) and isColor(970, 88, 0xfd0155, 90) and isColor(951, 107, 0xfb0255, 90) and isColor(972, 107, 0xfb0253, 90)) then
        checkplacetimes = 0
        return 23 --弹窗广告，右上角有叉号的那种
    elseif (isColor(77, 52, 0xee0048, 90) and isColor(77, 66, 0xf40152, 90) and isColor(93, 53, 0xf10253, 90) and isColor(94, 58, 0xee0252, 90) and isColor(104, 60, 0xe80352, 90) and isColor(104, 69, 0xf50254, 90) and isColor(123, 58, 0xfe0054, 90) and isColor(123, 66, 0xec0353, 90) and isColor(128, 58, 0xf70153, 90) and isColor(123, 53, 0xf60153, 90)) then
        checkplacetimes = 0
        return 24 --获得了新红币界面
    elseif (isColor(365, 82, 0xffffff, 85) and isColor(410, 100, 0xffffff, 85) and isColor(464, 98, 0xffffff, 85) and isColor(508, 98, 0xffffff, 85) and isColor(553, 99, 0xffffff, 85) and isColor(584, 55, 0xffffff, 85) and isColor(665, 55, 0xffffff, 85) and isColor(723, 57, 0xffffff, 85) and isColor(743, 61, 0xffffff, 85) and isColor(745, 95, 0xffffff, 85)) then
        --账号刚登录时的欢迎来到俱乐部界面
        checkplacetimes = 0
        return 27
    elseif (isColor(672, 368, 0xfaf9f9, 85) and isColor(684, 367, 0xf5b500, 85) and isColor(682, 377, 0xf8b800, 85) and isColor(688, 376, 0xd39502, 85) and isColor(693, 379, 0xf5b500, 85) and isColor(710, 369, 0xffbf00, 85) and isColor(734, 369, 0xfabb00, 85) and isColor(760, 363, 0xcb9401, 85)) then
        --刚登录时的神兽车联会
        checkplacetimes = 0
        return 28
    elseif (isColor(539, 107, 0xffffff, 85) and isColor(461, 94, 0xffffff, 85) and isColor(488, 76, 0xffffff, 85) and isColor(576, 73, 0xffffff, 85) and isColor(639, 76, 0xffffff, 85) and isColor(616, 111, 0xffffff, 85) and isColor(616, 122, 0xffffff, 85) and isColor(299, 514, 0xffffff, 85) and isColor(397, 522, 0x1a2e4a, 85) and isColor(344, 557, 0xffffff, 85)) then
        --俱乐部达成新里程碑
        checkplacetimes = 0
        return 29
    elseif (isColor(165, 288, 0xf6f7f8, 90) and isColor(165, 297, 0xeaecf0, 90) and isColor(347, 332, 0xffffff, 90) and isColor(709, 462, 0x000822, 90) and isColor(705, 441, 0xffffff, 90) and isColor(889, 330, 0xf5f6f8, 90) and isColor(986, 404, 0x0a1e3a, 90) and isColor(990, 177, 0x0d182b, 90)) then
        --服务器维护中，脚本停止
        checkplacetimes = 0
        return 30
    elseif (isColor(340, 102, 0xfc0050, 90) and isColor(426, 102, 0xfb004f, 90) and isColor(949, 576, 0xffd800, 90) and isColor(1092, 607, 0x010921, 90) and isColor(1091, 566, 0xffd800, 90)) then
        --多人赛季奖励
        checkplacetimes = 0
        return 31
    elseif (isColor(367, 217, 0xffffff, 90) and isColor(767, 224, 0x474747, 90) and isColor(1075, 60, 0x333333, 90) and isColor(735, 407, 0xff7026, 90) and isColor(390, 414, 0xff7026, 90)) then
        --防沉迷，22-8点禁止登陆
        checkplacetimes = 0
        return 32
    elseif (isColor(367, 239, 0xffffff, 90) and isColor(370, 274, 0xffffff, 90) and isColor(363, 275, 0x474747, 90) and isColor(487, 274, 0x474747, 90) and isColor(515, 280, 0xffffff, 90) and isColor(503, 280, 0xffffff, 90) and isColor(620, 296, 0x474747, 90) and isColor(469, 432, 0xff7026, 90) and isColor(642, 446, 0xff7026, 90) and isColor(751, 443, 0xff7026, 90)) then
        --防沉迷，今天游戏时长已到
        checkplacetimes = 0
        return 32
    elseif (isColor(84, 169, 0xffffff, 90) and isColor(77, 175, 0xffffff, 90) and isColor(105, 173, 0xffffff, 90) and isColor(109, 193, 0xffffff, 90) and isColor(154, 180, 0xffffff, 90) and isColor(182, 185, 0xffffff, 90) and isColor(140, 152, 0xf11262, 90) and isColor(66, 152, 0xf11363, 90)) then
        --每日任务，够6个领15蓝币那个
        checkplacetimes = 0
        return 33
    elseif (isColor(707, 427, 0xe60656, 90) and isColor(713, 427, 0xc50c57, 90) and isColor(725, 427, 0xb90f57, 90) and isColor(735, 428, 0xdb0856, 90) and isColor(746, 428, 0xf50255, 90) and isColor(747, 434, 0xe10655, 90) and isColor(764, 424, 0xf70255, 90) and isColor(781, 424, 0xf20355, 90) and isColor(747, 449, 0xf9fafb, 90) and isColor(756, 448, 0xe1e4e9, 90)) then
        --赛车回油目前无广告
        checkplacetimes = 0
        return 34
    elseif (isColor(850, 128, 0x000000, 90) and isColor(897, 116, 0x000000, 90) and isColor(927, 162, 0x000000, 90) and isColor(996, 176, 0x000000, 90) and isColor(1019, 117, 0x000a10, 90) and isColor(975, 108, 0xff0054, 90) and isColor(1006, 112, 0xff0054, 90) and isColor(973, 134, 0xff0054, 90) and isColor(989, 126, 0xffffff, 90) and isColor(998, 135, 0xfef8fa, 90)) then
        --可以领取赛季通行证奖励
        checkplacetimes = 0
        return 35
    elseif (isColor(585, 203, 0xffffff, 90) and isColor(626, 208, 0xffffff, 90) and isColor(666, 196, 0xffffff, 90) and isColor(786, 205, 0xffffff, 90) and isColor(835, 201, 0xf90154, 90) and isColor(865, 203, 0xfc0155, 90) and isColor(896, 208, 0xf70154, 90) and isColor(736, 279, 0xfb1264, 90) and isColor(756, 278, 0xfb1264, 90) and isColor(721, 468, 0xffffff, 90)) then
        --你已经满足所有奖励条件
        checkplacetimes = 0
        return 36
    elseif getColor(5, 5) == 0xffffff then
        return -1 --不在大厅，不在多人
    else
        return 404 --不知道在哪
    end
end
function toPVP_SE()
    toast("进入多人", 1)
    --检查是不是已经在多人那一栏了
    atPVP = isColor(741, 538, 0xfc0050, 85) and isColor(742, 541, 0xed0150, 85)
    if not atPVP then
        slideToPVP()
    end
    --TODO:检查是否在多人入口
    --检查多人包
    --[[if checkAndGetPackage() == -2 then
        return -2
    end]]--
    if PVPtype == "上" then
        tap(871, 277)--进入多人
    elseif PVPtype == "下" then
        tap(866, 321)--进入多人
    end
    mSleep(1500)
    place = checkPlace() --检查不是是在多人内部
    if place ~= 1 then
        toast("有内鬼，停止交易", 1)
        return -1
    end
    return 0
end
function waitBegin_SE()
    mSleep(5000)
    timer = 0
    --当检测界面不在游戏且检测次数少于35
    while (checkPlace_SE() ~= 3 and timer < 35) do
        mSleep(2000)
        timer = timer + 1
        toast("开局中," .. tostring(timer) .. "/35", 0.5)
        if timer % 5 == 0 and isFrontApp(gameBid) == 0 then
            timer = 35
        end
        --网络不好没匹配到人被提示
        if (isColor(959, 206, 0xfff8fb, 85) and isColor(980, 228, 0xfffbff, 85) and isColor(959, 226, 0xffffff, 85) and isColor(981, 205, 0xfffeff, 85) and isColor(969, 216, 0xfffeff, 85) and isColor(938, 213, 0xff0053, 85) and isColor(993, 207, 0xff0054, 85) and isColor(981, 238, 0xff0054, 85)) then
            tap(970, 220)
            mSleep(2000)
            return -1
        end
    end
    if timer >= 35 then
        toast("开局异常", 1)
        --如果还在匹配界面且左上有返回
        if (isColor(540, 312, 0x01b9e3, 85) and isColor(635, 307, 0x01b8e3, 85) and isColor(596, 273, 0x01718b, 85) and isColor(581, 350, 0x03b9e3, 85) and isColor(564, 308, 0xffffff, 85) and isColor(658, 314, 0xffffff, 85) and isColor(682, 291, 0xdfdfdf, 85) and isColor(17, 50, 0xffffff, 85) and isColor(70, 14, 0xffffff, 85)) then
            back()
            return -1
        else
            innerGhost = innerGhost + 1
            --如果5次timer计时还在开局并且左上角返回键消失
            if innerGhost >= 5 then
                innerGhost = 0
                restartApp()
            end
            return -1
        end
    end
end
function autoMobile_SE()
    toast("接管比赛", 1)
    --_time = os.time()
    checkAutoMobile()
    --检测界面在游戏
    while checkPlace_SE() == 3 do
        mSleep(500)
        tap(950, 400)
        mSleep(500)
        if path == -1 or path == 1 then
            -- -1从右往左划 1从左往右划
            moveTo(700 + path * (-100), 235, 600 + path * 200, 235, 20)
            moveTo(700 + path * (-100), 235, 600 + path * 200, 235, 20)
        elseif path == 2 then
            rand = math.random(1, 2) --rand==1 or 2
            --1从右往左划 2从左往右划
            moveTo(1000 + rand * (-200), 235, 800 + rand * (-400), 235, 20)
            moveTo(1000 + rand * (-200), 235, 800 + rand * (-400), 235, 20)
        end
        mSleep(500)
        tap(950, 400)
    end
    --toast("比赛结束",1);
    recordPVPnPVE()
    refreshTable()
    mSleep(2000)
end
function backFromLines_SE()
    --从赛道回到多人界面
    --mSleep(1000);
    color = getColor(115, 25)
    while (color == 0xff0054) do
        tap(1000, 580)
        mSleep(1000)
        color = getColor(115, 25)
    end
    mSleep(5000)
    --toast("比赛完成",1);
    if supermode == "赛事模式" and (mode == "多人刷声望" or mode == "特殊赛事" or mode == "多人刷包") then
        checkTimeOut()
    end
end
function Login_SE()
    if (isColor(521, 298, 0x333333, 85) and isColor(502, 298, 0x333333, 85) and isColor(487, 298, 0x333333, 85) and isColor(469, 297, 0x333333, 85) and isColor(452, 298, 0x333333, 85) and isColor(435, 297, 0x333333, 85) and isColor(418, 297, 0x333333, 85) and isColor(399, 296, 0x333333, 85) and isColor(385, 296, 0x333333, 85)) then
        log4l("登录")
        tap(559, 397)
        mSleep(2000)
        return -1
    else
        if ts.system.udid() == "yourudid" then
            toast("无密码,自动输入", 1)
            log4l("自动输入密码")
            mSleep(1000)
            tap(380, 300)
            mSleep(1000)
            passcode = splitStr("passwd")
            for i = 1, #passcode do
                keypress(passcode[i])
            end
            tap(580, 257)
            mSleep(20000)
            return -1
        else
            toast("无密码,脚本退出", 1)
            log4l("无密码,脚本终止")
            mSleep(1000)
            return -2
        end
    end
end
function slideToPVE()
    if model == "SE" then
        for _ = 1, 20, 1 do
            moveTo(860, 235, 225, 235, 20) --从右往左划
            if (isColor(1116, 539, 0xdc014a, 85) and isColor(1116, 538, 0xda0147, 85)) then
                break
            end
        end
        for _ = 1, 4, 1 do
            moveTo(225, 235, 860, 235, 20) --从左往右划
        end
    elseif model == "i68" then
        for _ = 1, 10, 1 do
            moveTo(860, 235, 225, 235, 20) --从左往右划
        end
        for _ = 1, 4, 1 do
            moveTo(225, 235, 950, 235, 20) --从右往左划，需要改
        end
    end
    mSleep(1000)
end
function toDailyGame_SE()
    toast("进入赛事", 1)
    atPVE = isColor(555, 537, 0xf9004b, 85) and isColor(556, 540, 0xfe0054, 85)
    if not atPVE then
        slideToPVE()
    end
    --TODO:检查是否在赛事入口
    tap(929, 474) --点击右侧赛事标签
    --tap(469, 589) --点击下方赛事标签
    mSleep(3000)
    --检查是不是有奖励能领
    if (isColor(345, 352, 0xfb004f, 90) and isColor(343, 388, 0xfe0054, 90) and isColor(792, 351, 0xfb004f, 90) and isColor(791, 389, 0xfc0053, 90) and isColor(500, 364, 0xffffff, 90) and isColor(716, 368, 0xffffff, 90) and isColor(559, 625, 0xc3fb12, 90) and isColor(634, 627, 0xc3fb12, 90) and isColor(556, 369, 0x000000, 90)) then
        --领奖励
        tap(570, 505)
        mSleep(2000)
        tap(570, 505)
        mSleep(3000)
        if (isColor(75, 576, 0xffffff, 90) and isColor(260, 571, 0xffffff, 90) and isColor(79, 613, 0xffffff, 90) and isColor(254, 613, 0xffffff, 90) and isColor(272, 617, 0x010924, 90) and isColor(273, 611, 0x000321, 90)) then
            tap(1075, 590) --是巅峰赛奖励
        else
            tap(368, 496) --俱乐部奖励
        end
        mSleep(3000)
        return -1
    end
    for _ = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20) --从左往右划
    end
    mSleep(2000)
    return -1
end
function toSpecialEvent_SE()
    toast("进入特殊赛事", 1)
    --[[if (isColor( 555,  537, 0xf9004b, 85) and isColor( 556,  540, 0xfe0054, 85)) then
        tap(929,474);--在赛事就直接进入
        goto DailyGame;
    end]]
    for _ = 1, 20, 1 do
        moveTo(360, 235, 600, 235, 20) --从左往右划
        if (isColor(19, 537, 0xfc0051, 85) and isColor(19, 540, 0xff0054, 85) and isColor(19, 539, 0xff0054, 85)) then
            break
        end
    end
    moveTo(600, 235, 360, 235, 20) --从右往左划一次
    mSleep(1000)
    --TODO:检查是否在特殊赛事入口
    :: DailyGame ::
    tap(207, 621)
    mSleep(2000)
    for _ = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20) --从左往右划
    end
    mSleep(2000)
    return -1
end
function gametoCarbarn_SE()
    upwithoutoil, downwithoutoil, changecar, ads = false, false, false, false
    tap(1065, 590)
    mSleep(2000)
    selectCarAtGame()
    :: beginAtGame ::
    mSleep(4000)
    if ads or carCanUse() then
        beginGame()
        mSleep(2000)
        --检查是不是有票
        if (isColor(462, 154, 0xffffff, 90) and isColor(465, 164, 0xffffff, 90) and isColor(478, 163, 0xffffff, 90) and isColor(509, 163, 0xffffff, 90) and isColor(543, 160, 0xffffff, 90) and isColor(572, 160, 0xffffff, 90) and isColor(585, 168, 0xfafafb, 90)) then
            toast("没票", 1)
            tap(1030, 160)
            --去多人or生涯
            return actAfterNoFuelNTicket()
        end
    else
        if changeCar == "开" and not changecar then
            if carplace == "中间下" then
                downwithoutoil = true
            else
                upwithoutoil = true
            end
            if not (upwithoutoil and downwithoutoil) then
                if carplace == "中间下" then
                    tap(440, 320) --向左选车
                else
                    tap(1070, 320) --向右选车
                end
                changecar = true
                goto beginAtGame --此行只能运行一次
            end
        end
        if watchAds ~= "关" then
            if watchAd() == -1 then
                tap(1077, 83)--关闭广告
                mSleep(2000)
                ads = true
                if restartAfterAds then
                    closeApp(gameBid) --关闭游戏
                    mSleep(5000)
                    runApp(gameBid) --打开游戏
                    mSleep(15000)
                    return -1
                end
            end
            goto beginAtGame
        end
        --去多人or生涯
        return actAfterNoFuelNTicket()
    end
    mSleep(3000)
    --如果提示已经满足所有奖励条件
    if checkPlace() == 36 then
        worker(36)
        return -2
    end
    --如果等待失败
    if waitBegin() == -1 then
        return -1
    end
    autoMobile() --接管比赛
    return -1
end
function worker_SE(place)
    if checkplacetimes > 2 then
        mSleep(1000)
    end
    if checkplacetimes > checkplacetimesout then
        checkplacetimes = 0
        restartApp()
        toast("等待30秒", 1)
        mSleep(30000)
        place = 404
    end
    if place == -3 then
        toast("网络未同步", 1)
        state = -1
    elseif place == -2 then
        toast("登录界面", 1)
        state = Login()
    elseif place == -1 then
        toast("不在大厅，不在多人，回到大厅", 1)
        back()
        state = backHome()
        if state == -1 then
            return 0
        end
        if mode == "多人刷声望" or mode == "多人刷包" then
            state = toPVP()
        elseif mode == "赛事模式" then
            state = toDailyGame()
        elseif mode == "特殊赛事" then
            state = toSpecialEvent_SE()
        end
    elseif place == 0 then
        toast("在大厅", 1)
        if mode == "多人刷声望" or mode == "多人刷包" then
            state = toPVP()
        elseif mode == "赛事模式" then
            state = toDailyGame()
        elseif mode == "特殊赛事" then
            state = toSpecialEvent_SE()
        end
    elseif place == 1 then
        toast("在多人", 1)
        if mode == "多人刷声望" then
            state = 0
        elseif mode == "多人刷包" then
            back() --back一下是因为懒得写新逻辑了，直接toPVP()好了
            state = toPVP()
        elseif mode == "赛事模式" then
            back()
            state = toDailyGame()
        elseif mode == "特殊赛事" then
            back()
            state = toSpecialEvent_SE()
        end
    elseif place == 2 then
        --toast("在结算",1);
        state = -4
    elseif place == 3 then
        --toast("在游戏",1);
        state = -5
    elseif place == 3.1 then
        toast("在多人车库", 1)
        back()
        state = -3
    elseif place == 4 then
        toast("奖励界面", 1)
        receivePrizeFromGL()
        state = -1
    elseif place == 5 then
        --在赛事
        if mode == "赛事模式" then
            state = chooseGame()
            validateGame = true
        elseif mode == "多人刷声望" or mode == "特殊赛事" or mode == "多人刷包" then
            back()
            state = -1
        end
    elseif place == 6 then
        toast("赛事开始界面", 1)
        if mode == "赛事模式" then
            if validateGame == false then
                back()
                state = -1
            elseif validateGame == true then
                state = gametoCarbarn()
            end
        elseif mode == "多人刷声望" or mode == "特殊赛事" or mode == "多人刷包" then
            backHome()
            state = -1
        end
    elseif place == 7 then
        toast("领奖界面", 1)
        state = receivePrizeAtGame()
    elseif place == 8 then
        toast("多人联赛介绍界面", 1)
        tap(960, 120)
        mSleep(1000)
        state = -1
    elseif place == 9 then
        toast("解锁或升星", 1)
        log4l("🔓 🌟车辆解锁或升星")
        tap(390, 570)
        mSleep(2000)
        state = -1
    elseif place == 10 then
        toast("开始的开始", 1)
        tap(566, 491) --按下开始
        mSleep(10000)
        state = -1
    elseif place == 11 then
        toast("段位升级", 1)
        log4l("⬆️段位升级")
        tap(1000, 580) --继续
        mSleep(2000)
        state = -1
    elseif place == 12 then
        toast("声望升级", 1)
        log4l("⬆️声望升级")
        mSleep(1000)
        tap(570, 590) --确定
        mSleep(2000)
        state = -1
    elseif place == 13 then
        toast("未能连接到服务器", 1)
        tap(967, 215) --关闭
        mSleep(2000)
        state = -1
    elseif place == 14 then
        toast("断开连接", 1)
        tap(940, 570) --继续
        mSleep(2000)
        state = -1
    elseif place == 15 then
        toast("连接错误", 1)
        tap(569, 437) --重试
        mSleep(2000)
        state = -1
    elseif place == 16 then
        state = wait_when_Parallel_read_detected()
        tap(970, 215) --关闭
        mSleep(2000)
    elseif place == 17 then
        toast("匹配中", 1)
        state = -6
    elseif place == 18 then
        toast("VIP会员到期", 1)
        tap(883, 150) --关闭
        mSleep(2000)
        state = -1
    elseif place == 19 then
        LoginTimes = LoginTimes + 1
        if LoginTimes >= 20 then
            toast("登录延时", 1)
            mSleep(1000)
            restartApp()
            LoginTimes = 0
            state = -1
        else
            toast("登陆中", 1)
            mSleep(2000)
            state = -1
        end
    elseif place == 20 then
        toast("俱乐部人气很旺", 1)
        tap(313, 495) --稍后查看
        mSleep(1500)
        state = -1
    elseif place == 21 then
        toast("段位降级", 1)
        log4l("⬇️段位降级")
        tap(563, 471) --确定
        mSleep(2000)
        state = -1
    elseif place == 22 then
        toast("失去资格", 1)
        tap(945, 579) --确定
        mSleep(2000)
        state = -1
    elseif place == 23 then
        tap(960, 100) --关闭右上角有叉的弹窗广告
        mSleep(500)
        state = -1
    elseif place == 24 then
        --获得了新红币界面
        tap(65, 585) --不再提示
        mSleep(500)
        tap(980, 580) --确定
        state = -1
    elseif place == 25 then
        --广告播放完成界面
        tap(1077, 83)
        mSleep(2000)
        state = -1
    elseif place == 26 then
        --公告
        tap(986, 554)
        mSleep(500)
        state = -1
    elseif place == 27 then
        --账号刚登录时的欢迎来到俱乐部界面
        mSleep(500)
        tap(975, 560)
        mSleep(500)
        state = -1
    elseif place == 28 then
        --账号刚登录时的欢迎来到俱乐部界面
        mSleep(500)
        tap(565, 545)
        mSleep(5000)
        state = -1
    elseif place == 29 then
        --俱乐部达成新里程杯
        mSleep(500)
        tap(370, 530)
        mSleep(500)
        state = -1
    elseif place == 30 then
        --服务器维护中，脚本停止
        log4l("🔧服务器维护中")
        state = -2
    elseif place == 31 then
        --多人赛季奖励
        toast("多人赛季奖励", 1)
        tap(1000, 570)
        state = -1
    elseif place == 32 then
        --防沉迷
        state = antiAddiction()
    elseif place == 33 then
        --每日任务，够6个领15蓝币那个
        toast("每日任务", 1)
        tap(1075, 100)
        state = -1
    elseif place == 34 then
        --赛车回油目前无广告
        toast("目前无广告", 1)
        tap(887, 190)
        state = -1
    elseif place == 35 then
        --可以领取赛季通行证奖励
        log4l("🎁可以领取赛季通行证奖励")
        tap(990, 127)
        state = -1
    elseif place == 36 then
        --你已经满足所有奖励条件
        log4l("🈚️赛事已刷完")
        tap(874, 477)
        if switch == "多人刷包" then
            supermode, mode = "多人刷包", "多人刷包"
            log4l("主模式改为多人刷包")
            state = -1
        else
            state = -2
        end
    elseif place == 404 then
        toast("不知道在哪", 1)
        mSleep(1000)
        state = -1
    end
    receive_starting_command = false
end
function antiAddiction()
    hour = tonumber(os.date("%H"))
    if hour < 8 then
        log4l("防沉迷时间，等待今日8点")
        wait_time(math.ceil((os.time({ year = tonumber(os.date("%Y")), month = tonumber(os.date("%m")), day = tonumber(os.date("%d")), hour = 8, min = 00, sec = 00 }) - os.time()) / 60))
    else
        log4l("防沉迷时间，等待明日8点")
        wait_time(math.ceil((os.time({ year = tonumber(os.date("%Y")), month = tonumber(os.date("%m")), day = tonumber(os.date("%d")), hour = 23, min = 59, sec = 59 }) - os.time()) / 60) + 8 * 60)
    end
    return -1
end
---iPhone 6/6S/7/8 设备处理函数---
function checkPlace_i68()
    if (isColor(1266, 74, 0xffffff, 85) and isColor(1285, 74, 0xffffff, 85) and isColor(1275, 83, 0xffffff, 85) and isColor(1267, 92, 0xffffff, 85) and isColor(1285, 92, 0xffffff, 85)) then
        checkplacetimes = 0
        return 25 --广告播放完毕
    elseif ((isColor(1305, 14, 0xfcffff, 85) and isColor(1312, 22, 0xfefefe, 85) and isColor(1314, 37, 0xcdd3db, 85) and isColor(1293, 32, 0xfefeff, 85) and isColor(1294, 21, 0xffffff, 85) and isColor(1304, 17, 0xfeffff, 85)) and
            not (isColor(12, 16, 0xffffff, 85) and isColor(10, 45, 0xffffff, 85))) or
            (isColor(1111, 11, 0xfbffff, 85) and isColor(1120, 16, 0xf8faf9, 85) and isColor(1126, 26, 0xe2e4e8, 85) and isColor(1095, 26, 0xfdfdfd, 85)) then
        checkplacetimes = 0
        return 0 --在大厅
    elseif (isColor(513, 668, 0xff0054, 85) and isColor(521, 676, 0xff0054, 85) and isColor(529, 685, 0xff0054, 85) and isColor(530, 668, 0xfc0053, 85) and isColor(513, 684, 0xfe0054, 85) and isColor(587, 665, 0xe4e5e8, 85) and isColor(588, 717, 0xfb1264, 85) and isColor(615, 717, 0xfb1264, 85) and isColor(640, 717, 0xfb1264, 85) and isColor(660, 717, 0xfb1264, 85)) then
        checkplacetimes = 0
        return -3 --网络未同步
    elseif (isColor(498, 429, 0xfe8b40, 85) and isColor(500, 472, 0xfe8b40, 85) and isColor(845, 434, 0xfe8b40, 85) and isColor(846, 467, 0xfe8b40, 85)) then
        checkplacetimes = 0
        return -2 --在登录界面
    elseif (isColor(419, 137, 0xffffff, 85) and isColor(455, 134, 0xffffff, 85) and isColor(573, 137, 0xffffff, 85) and isColor(573, 158, 0xffffff, 85) and isColor(602, 136, 0xffffff, 85) and isColor(636, 133, 0xffffff, 85) and isColor(659, 134, 0xffffff, 85) and isColor(683, 140, 0xffffff, 85) and isColor(442, 515, 0x000721, 85) and isColor(190, 518, 0xffffff, 85)) then
        checkplacetimes = 0
        return 20 --俱乐部新人,undone
    elseif (isColor(896, 112, 0xce7345, 85) and isColor(985, 113, 0x6c7889, 85) and isColor(1059, 119, 0xbd9158, 85) and isColor(1144, 118, 0xbcb3d5, 85) and isColor(1230, 116, 0x6d6c63, 85)) then
        checkplacetimes = 0
        return 3.1 --在多人车库
    elseif (isColor(285, 501, 0xffffff, 85) and isColor(473, 501, 0xffffff, 85) and isColor(297, 537, 0xffffff, 85) and isColor(470, 529, 0xffffff, 85) and isColor(362, 661, 0xffffff, 85) and isColor(612, 654, 0xffffff, 85) and isColor(475, 700, 0xffffff, 85) and isColor(880, 505, 0xffffff, 85) and isColor(1029, 505, 0xffffff, 85) and isColor(944, 537, 0xffffff, 85)) then
        checkplacetimes = 0
        return 1 --在多人
    elseif (isColor(89, 679, 0xc5fb12, 85) and isColor(246, 680, 0xc3fb12, 85) and isColor(81, 703, 0xc2fb0f, 85) and isColor(253, 700, 0xc3fa12, 85)) then
        checkplacetimes = 0
        return 5 --在赛事
    elseif (isColor(70, 112, 0xfa0152, 85) and isColor(82, 112, 0xfa0052, 85) and isColor(101, 112, 0xfb0052, 85) and isColor(143, 113, 0xfd0053, 85) and isColor(189, 113, 0xfe0053, 85) and isColor(228, 113, 0xfd0053, 85) and isColor(258, 113, 0xf60051, 85)) then
        checkplacetimes = 0
        return 6 --在赛事开始界面
    elseif (isColor(628, 370, 0x03b9e4, 85) and isColor(660, 353, 0xfefefe, 85) and isColor(682, 360, 0xffffff, 85) and isColor(712, 364, 0xffffff, 85) and isColor(738, 389, 0xffffff, 85) and isColor(678, 423, 0x02b9e2, 85) and isColor(621, 385, 0x00b9e2, 85)) then
        checkplacetimes = 0
        return 17 --多人匹配中
    elseif getColor(5, 5) == 0xffffff then
        return -1 --不在大厅，不在多人
    elseif (isColor(160, 4, 0xff0054, 85) and isColor(147, 18, 0xff0054, 85)) then
        checkplacetimes = 0
        return 2 --游戏结算界面
    elseif (isColor(44, 110, 0xffffff, 90) and isColor(44, 115, 0xffffff, 90) and isColor(55, 126, 0xffffff, 90) and isColor(104, 119, 0xffffff, 90) and isColor(113, 118, 0xffffff, 90) and isColor(121, 117, 0x419fdb, 90) and isColor(143, 120, 0x3daaee, 90) and isColor(164, 120, 0x3ca6e9, 90) and isColor(186, 118, 0x3da8ec, 90) and isColor(180, 114, 0x3da6e8, 90)) then
        checkplacetimes = 0
        return 3 --游戏中
    elseif (isColor(60, 26, 0xff0052, 85) and isColor(153, 29, 0xfe0052, 85) and isColor(209, 59, 0xffffff, 85) and isColor(282, 57, 0xffffff, 85) and isColor(355, 65, 0xffffff, 85) and isColor(454, 63, 0xffffff, 85) and isColor(515, 61, 0xffffff, 85) and isColor(629, 45, 0xffffff, 85)) then
        checkplacetimes = 0
        return 4 --来自Gameloft的礼物,undone
    elseif (isColor(617, 34, 0xea3358, 85) and isColor(699, 39, 0xea3358, 85) and isColor(701, 66, 0xe83258, 85) and isColor(1291, 716, 0x01061f, 85) and isColor(1264, 702, 0xffffff, 85)) then
        checkplacetimes = 0
        return 7 --领奖开包
    elseif (isColor(295, 458, 0xd88560, 85) and isColor(465, 455, 0x96b2d4, 85) and isColor(639, 437, 0xf1cb30, 85) and isColor(812, 421, 0x9365f8, 85) and isColor(1013, 424, 0xf5e2a4, 85)) then
        checkplacetimes = 0
        return 8 --多人联赛介绍界面
    elseif (isColor(616, 208, 0xfbde23, 85) and isColor(625, 224, 0xfec002, 85) and isColor(643, 226, 0xfee53d, 85) and isColor(629, 204, 0xfffef5, 85)) then
        checkplacetimes = 0
        return 9 --赛车解锁或升星
    elseif (isColor(584, 582, 0xc3fb12, 85) and isColor(774, 587, 0xc3fb11, 85) and isColor(547, 638, 0xc3fb13, 85) and isColor(785, 638, 0xc5fb12, 85) and isColor(806, 650, 0x000b21, 85)) then
        checkplacetimes = 0
        return 10 --开始的开始
    elseif (isColor(252, 161, 0xfd0055, 85) and isColor(290, 159, 0xfa0051, 85) and isColor(316, 161, 0xfe0055, 85) and isColor(375, 162, 0xf60154, 85) and isColor(414, 161, 0xfc0156, 85) and isColor(42, 652, 0xfb1264, 85) and isColor(43, 696, 0xf91263, 85) and isColor(1111, 663, 0xffffff, 85) and isColor(1260, 668, 0xffffff, 85) and isColor(1284, 712, 0x000521, 85)) then
        checkplacetimes = 0
        return 11 --段位升级
    elseif (isColor(265, 59, 0xfffefd, 85) and isColor(287, 59, 0xfffffd, 85) and isColor(347, 68, 0xffffff, 85) and isColor(334, 88, 0xffffff, 85) and isColor(337, 268, 0xfefffd, 85) and isColor(459, 245, 0xffffff, 85) and isColor(462, 178, 0xf4feff, 85) and isColor(323, 540, 0xfcffff, 85) and isColor(591, 644, 0xffffff, 85) and isColor(820, 687, 0x030625, 85)) then
        checkplacetimes = 0
        return 12 --声望升级
    elseif (isColor(184, 218, 0xffffff, 85) and isColor(218, 229, 0xd8d9dc, 85) and isColor(245, 224, 0xe6e7e9, 85) and isColor(266, 225, 0xf9f9f9, 85) and isColor(342, 225, 0xe9e9e9, 85) and isColor(408, 221, 0xcfcfcf, 85) and isColor(935, 228, 0xf2004f, 85) and isColor(991, 225, 0xff0054, 85) and isColor(976, 243, 0xfb0052, 85)) then
        checkplacetimes = 0
        return 13 --未能连接到服务器,undone
    elseif (isColor(36, 45, 0xff0054, 85) and isColor(26, 260, 0xff0054, 85) and isColor(148, 139, 0xff0054, 85) and isColor(243, 37, 0xff0054, 85) and isColor(269, 272, 0xff0054, 85) and isColor(521, 140, 0xffffff, 85) and isColor(992, 650, 0xc3fb12, 85) and isColor(1114, 705, 0xc2fb13, 85) and isColor(1221, 658, 0xc3fb13, 85) and isColor(1272, 713, 0x000a21, 85)) then
        checkplacetimes = 0
        return 14 --多人断开连接
    elseif (isColor(525, 185, 0xffffff, 85) and isColor(546, 182, 0xffffff, 85) and isColor(574, 189, 0xffffff, 85) and isColor(591, 190, 0xffffff, 85) and isColor(729, 329, 0xeceef1, 85) and isColor(742, 336, 0xd2d6dd, 85) and isColor(759, 334, 0xffffff, 85) and isColor(788, 336, 0xe4e7eb, 85) and isColor(798, 329, 0xcdd1d9, 85) and isColor(569, 437, 0xffffff, 85)) then
        checkplacetimes = 0
        return 15 --连接错误,undone
    elseif (isColor(207, 250, 0xffffff, 85) and isColor(222, 250, 0xf3f3f4, 85) and isColor(243, 250, 0xeeeff0, 85) and isColor(252, 250, 0xbbc0c5, 85) and isColor(261, 254, 0xb2b6bc, 85) and isColor(274, 255, 0xe8e9ea, 85) and isColor(291, 255, 0xf3f3f4, 85) and isColor(317, 257, 0xf9f9f9, 85) and isColor(1136, 253, 0xfffafd, 85) and isColor(1138, 253, 0xffffff, 85)) then
        checkplacetimes = 0
        return 16 --顶号行为
    elseif (isColor(495, 147, 0xff0054, 85) and isColor(525, 149, 0xd4044d, 85) and isColor(538, 148, 0xfd0054, 85) and isColor(564, 145, 0xfd0054, 85) and isColor(585, 150, 0xfd0054, 85) and isColor(604, 146, 0xfd0054, 85) and isColor(608, 145, 0xe80250, 85) and isColor(861, 158, 0xf90052, 85) and isColor(567, 453, 0xc3fb11, 85)) then
        checkplacetimes = 0
        return 18 --VIP到期,undone
    elseif (isColor(67, 23, 0x664944, 85) and isColor(183, 26, 0x7b4542, 85) and isColor(346, 22, 0x8f7a81, 85) and isColor(495, 27, 0x587bad, 85) and isColor(632, 25, 0x90bee2, 85) and isColor(764, 27, 0x8c7b94, 85) and isColor(892, 29, 0x9c7d84, 85)) then
        return 19 --登录延时,undone
    elseif (isColor(591, 187, 0xfcfcfc, 85) and isColor(605, 187, 0xdfe0e3, 85) and isColor(623, 190, 0xffffff, 85) and isColor(632, 190, 0xfafafb, 85) and isColor(641, 191, 0xffffff, 85) and isColor(651, 191, 0xf5f6f6, 85) and isColor(707, 191, 0xe6e7e9, 85) and isColor(730, 552, 0xffffff, 85) and isColor(761, 569, 0x010722, 85)) then
        checkplacetimes = 0
        return 21 --段位降级
    elseif (isColor(62, 83, 0xfb1264, 90) and isColor(181, 80, 0xfb1264, 90) and isColor(66, 118, 0xfb1264, 90) and isColor(178, 121, 0xfb1264, 90) and isColor(268, 634, 0xffffff, 90) and isColor(87, 633, 0xffffff, 90) and isColor(253, 672, 0xffffff, 90) and isColor(1088, 644, 0xffffff, 90) and isColor(1270, 674, 0xffffff, 90) and isColor(1271, 635, 0xffffff, 90)) then
        checkplacetimes = 0
        return 22 --游戏公告栏，左上角显示为"最新动态"四个字
    elseif (isColor(1118, 110, 0xff0054, 90) and isColor(1127, 119, 0xff0054, 90) and isColor(1136, 110, 0xff0054, 90) and isColor(1119, 126, 0xfd0053, 90) and isColor(1134, 126, 0xff0054, 90) and isColor(1114, 132, 0xff0054, 90) and isColor(1140, 132, 0xff0054, 90) and isColor(1114, 106, 0xff0054, 90)) or (isColor(1115, 107, 0xfbfbfb, 90) and isColor(1124, 116, 0xfefefe, 90) and isColor(1127, 119, 0xfefefe, 90) and isColor(1138, 108, 0xfafbfb, 90) and isColor(1115, 131, 0xfefefe, 90) and isColor(1137, 129, 0xfefefe, 90)) then
        checkplacetimes = 0
        return 23 --弹窗广告，右上角有叉号的那种
    end
    return 404
end
function toPVP_i68()
    toast("进入多人", 1)
    mSleep(4000)
    slideToPVP()
    --TODO:检查是否在多人入口
    --检查多人包
    --[[if checkAndGetPackage() == -2 then
        return -2
    end]]--
    if PVPtype == "上" then
        tap(1205, 315)--进入多人
    elseif PVPtype == "下" then
        tap(1210, 375)--进入多人
    end
    mSleep(2000)
    place = checkPlace()
    if place ~= 1 then
        toast("有内鬼，停止交易", 1)
        return -1
    end
    return 0
end
function waitBegin_i68()
    mSleep(5000)
    timer = 0
    --当检测界面不在游戏且检测次数少于35
    while (checkPlace_i68() ~= 3 and timer < 35) do
        mSleep(2000)
        timer = timer + 1
        toast("开局中," .. tostring(timer) .. "/35", 0.5)
        if timer % 5 == 0 and isFrontApp(gameBid) == 0 then
            timer = 35 --开局不在游戏，直接开局失败
        end
        --网络不好没匹配到人被提示，undone
        if (isColor(959, 206, 0xfff8fb, 85) and isColor(980, 228, 0xfffbff, 85) and isColor(959, 226, 0xffffff, 85) and isColor(981, 205, 0xfffeff, 85) and isColor(969, 216, 0xfffeff, 85) and isColor(938, 213, 0xff0053, 85) and isColor(993, 207, 0xff0054, 85) and isColor(981, 238, 0xff0054, 85)) then
            tap(970, 220)
            mSleep(2000)
            return -1
        end
    end
    if timer >= 35 then
        --如果还在匹配界面且左上有返回
        toast("开局异常", 1)
        if (isColor(632, 383, 0x02b9e3, 85) and isColor(663, 366, 0xffffff, 85) and isColor(678, 367, 0xfeffff, 85) and isColor(699, 360, 0xffffff, 85) and isColor(722, 374, 0xffffff, 85) and isColor(23, 47, 0xffffff, 85) and isColor(87, 15, 0xffffff, 85)) then
            back()
            return -1
        else
            innerGhost = innerGhost + 1
            --如果5次timer计时还在开局并且左上角返回键消失
            if innerGhost >= 5 then
                innerGhost = 0
                restartApp()
            end
            return -1
        end
    end
end
function autoMobile_i68()
    toast("接管比赛", 1)
    checkAutoMobile()
    --检测界面在游戏
    while checkPlace_i68() == 3 do
        mSleep(500)
        tap(1130, 600)
        mSleep(500)
        if path == -1 or path == 1 then
            -- -1从右往左划 1从左往右划
            moveTo(1200 + path * (-100), 235, 1200 + path * 100, 235, 20) --从右往左划
            moveTo(1200 + path * (-100), 235, 1200 + path * 100, 235, 20) --从右往左划
        elseif path == 2 then
            rand = math.random(1, 2) --rand==1 or 2
            moveTo(1500 + rand * (-200), 235, 900 + rand * 200, 235, 20) --从右往左划
            moveTo(1500 + rand * (-200), 235, 900 + rand * 200, 235, 20) --从右往左划
        end
        mSleep(500)
        tap(1130, 600)
    end
    recordPVPnPVE()
    refreshTable()
    mSleep(2000)
end
function backFromLines_i68()
    --从赛道回到多人界面
    color = getColor(140, 20)
    while (color == 0xff0054) do
        tap(1100, 680)
        mSleep(1000)
        color = getColor(115, 25)
    end
    mSleep(5000)
    --toast("比赛完成",1);
    if supermode == "赛事模式" and (mode == "多人刷声望" or mode == "特殊赛事" or mode == "多人刷包") then
        checkTimeOut()
    end
end
function Login_i68()
    if (isColor(482, 353, 0x333333, 85) and isColor(498, 353, 0x333333, 85) and isColor(517, 353, 0x333333, 85) and isColor(535, 353, 0x333333, 85) and isColor(550, 353, 0x333333, 85) and isColor(568, 352, 0x333333, 85) and isColor(584, 354, 0x333333, 85) and isColor(515, 444, 0xfe8b40, 85) and isColor(769, 444, 0xfe8b40, 85) and isColor(874, 444, 0xfe8b40, 85)) then
        log4l("登录")
        tap(660, 450)
        mSleep(5000)
        return -1
    else
        if ts.system.udid() == "udid" then
            toast("无密码,自动输入", 1)
            log4l("无密码,自动输入")
            mSleep(1000)
            tap(490, 350)
            mSleep(1000)
            passcode = splitStr("passcode")
            for i = 1, #passcode do
                keypress(passcode[i])
            end
            tap(656, 307)
            mSleep(20000)
            return -1
        else
            toast("无密码,脚本退出", 1)
            log4l("无密码,脚本退出")
            mSleep(1000)
            return -2
        end
    end
end
function toDailyGame_i68()
    --done partly
    toast("进入赛事", 1)
    slideToPVE()
    --TODO:检查是否在赛事入口
    tap(547, 686)
    mSleep(2000)
    for _ = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20) --从左往右划
    end
    mSleep(2000)
    return -1
end
function gametoCarbarn_i68()
    upwithoutoil, downwithoutoil, changecar, ads = false, false, false, false
    tap(1260, 690)
    mSleep(2000)
    selectCarAtGame()
    :: beginAtGame ::
    if ads or carCanUse() then
        beginGame()
        mSleep(2000)
        --检查是不是有票
        if (isColor(545, 174, 0xffffff, 90) and isColor(561, 186, 0xffffff, 90) and isColor(607, 190, 0xffffff, 90) and isColor(633, 192, 0xffffff, 90) and isColor(668, 187, 0xffffff, 90) and isColor(693, 187, 0xffffff, 90) and isColor(685, 208, 0xffffff, 90) and isColor(638, 207, 0xffffff, 90)) then
            toast("没票", 1)
            tap(1140, 180)
            --去多人or生涯
            return actAfterNoFuelNTicket()
        end
    else
        if changeCar == "开" and not changecar then
            if carplace == "中间下" then
                downwithoutoil = true
            else
                upwithoutoil = true
            end
            if not (upwithoutoil and downwithoutoil) then
                if carplace == "中间下" then
                    tap(510, 380) --向左选车
                else
                    tap(1250, 380) --向右选车
                end
                changecar = true
                goto beginAtGame --此行只能运行一次
            end
        end
        toast("没油了", 1)
        if watchAds ~= "关" then
            if watchAd() == -1 then
                tap(1276, 83) --关闭广告
                mSleep(2000)
                ads = true
                if restartAfterAds then
                    closeApp(gameBid) --关闭游戏
                    mSleep(5000)
                    runApp(gameBid) --打开游戏
                    mSleep(15000)
                    return -1
                end
            end
            goto beginAtGame
        end
        --去多人or生涯
        return actAfterNoFuelNTicket()
    end
    mSleep(3000)
    if waitBegin() == -1 then
        return -1
    end
    autoMobile() --接管比赛
    return -1
end
function toSpecialEvent_i68()
    return 0
end
function worker_i68(place)
    if checkplacetimes > 2 then
        mSleep(1000)
    end
    if checkplacetimes > checkplacetimesout then
        checkplacetimes = 0
        restartApp()
        toast("等待30秒", 1)
        mSleep(30000)
        place = 404
    end
    if place == -3 then
        toast("网络未同步", 1)
        state = -1
    elseif place == -2 then
        toast("登录界面", 1)
        state = Login()
    elseif place == -1 then
        toast("不在大厅,不在多人,回到大厅", 1)
        state = backHome()
        if mode == "多人刷声望" or mode == "多人刷包" then
            state = toPVP()
        elseif mode == "赛事模式" then
            state = toDailyGame()
        end

    elseif place == 0 then
        toast("在大厅", 1)
        if mode == "多人刷声望" or mode == "多人刷包" then
            state = toPVP()
        elseif mode == "赛事模式" then
            state = toDailyGame()
        end
    elseif place == 1 then
        toast("在多人", 1)
        if mode == "多人刷声望" or mode == "多人刷包" then
            state = 0
        elseif mode == "赛事模式" then
            back()
            state = toDailyGame()
        end

    elseif place == 2 then
        toast("在结算", 1)
        state = -4
    elseif place == 3 then
        toast("在游戏", 1)
        state = -5
    elseif place == 3.1 then
        toast("在多人车库", 1)
        state = -3
    elseif place == 4 then
        toast("奖励界面", 1)
        receivePrizeFromGL()
        state = -1
    elseif place == 5 then
        toast("在赛事", 1)
        if mode == "赛事模式" then
            state = chooseGame()
            validateGame = true
        elseif mode == "多人刷声望" or mode == "多人刷包" then
            back()
            state = -1
        end
    elseif place == 6 then
        toast("赛事开始界面", 1)
        if mode == "赛事模式" then
            if validateGame == false then
                back()
                state = -1
            elseif validateGame == true then
                state = gametoCarbarn()
            end
        elseif mode == "多人刷声望" or mode == "多人刷包" then
            backHome()
            state = -1
        end
    elseif place == 7 then
        toast("领奖界面", 1)
        state = receivePrizeAtGame()
    elseif place == 8 then
        toast("多人联赛介绍界面", 1)
        tap(1120, 140)
        mSleep(1000)
        state = -1
    elseif place == 9 then
        toast("解锁或升星", 1)
        tap(460, 675)
        mSleep(2000)
        state = -1
    elseif place == 10 then
        toast("开始的开始", 1)
        tap(660, 600) --按下开始
        mSleep(10000)
        state = -1
    elseif place == 11 then
        toast("段位升级", 1)
        log4l("⬆️段位升级")
        tap(1175, 680) --继续
        mSleep(2000)
        state = -1
    elseif place == 12 then
        toast("声望升级", 1)
        log4l("⬆️声望升级")
        tap(660, 660) --确定
        mSleep(2000)
        state = -1
    elseif place == 13 then
        --undone
        toast("未能连接到服务器", 1)
        tap(967, 215) --关闭
        mSleep(2000)
        state = -1
    elseif place == 14 then
        toast("断开连接", 1)
        tap(1100, 670) --继续
        mSleep(2000)
        state = -1
    elseif place == 15 then
        --undone
        toast("连接错误", 1)
        tap(569, 437) --重试
        mSleep(2000)
        state = -1
    elseif place == 16 then
        state = wait_when_Parallel_read_detected()
        tap(1140, 252) --关闭
        mSleep(2000)
    elseif place == 17 then
        toast("匹配中", 1)
        state = -6
    elseif place == 18 then
        --undone
        toast("VIP会员到期", 1)
        tap(883, 150) --关闭
        mSleep(2000)
        state = -1
    elseif place == 19 then
        LoginTimes = LoginTimes + 1
        --undone
        if LoginTimes >= 20 then
            toast("登录延时", 1)
            mSleep(1000)
            restartApp()
            LoginTimes = 0
            state = -1
        else
            toast("登陆中", 1)
            mSleep(2000)
            state = -1
        end
    elseif place == 20 then
        --undone
        toast("俱乐部人气很旺", 1)
        tap(313, 495) --稍后查看
        mSleep(2000)
        state = -1
    elseif place == 21 then
        toast("段位降级", 1)
        log4l("⬇️段位降级")
        tap(660, 550) --稍后查看
        mSleep(1000)
        state = -1
    elseif place == 22 then
        tap(1165, 652)
        mSleep(500)
        state = -1
    elseif place == 23 then
        tap(1127, 119) --关闭右上角有叉的弹窗广告
        mSleep(500)
        state = -1
    elseif place == 25 then
        --广告播放完成
        tap(1276, 83)
        mSleep(2000)
        state = -1
    elseif place == 404 then
        toast("不知道在哪", 1)
        tap(1199, 685)
        mSleep(1000)
        state = -1
    end
    receive_starting_command = false
end
---统一命名函数---
function worker(place)
    if model == "SE" then
        worker_SE(place)
    elseif model == "i68" then
        worker_i68(place)
    end
    if noAds >= 20 then
        log4l("连续20次回油无广告，不再看广告")
        watchAds = "关"
        noAds = 0
    end
    if restartTimes >= 5 then
        log4l("游戏连续重启5次，可能有无法识别界面")
        state = -2
        restartTimes = 0
    end
end
function checkPlace()
    makeGameFront()
    if checkplacetimes > 2 then
        toast("检测界面," .. tostring(checkplacetimes) .. "/" .. tostring(checkplacetimesout), 1)
    end
    if model == "SE" then
        return checkPlace_SE()
    elseif model == "i68" then
        return checkPlace_i68()
    end
end
function waitBegin()
    if model == "SE" then
        return waitBegin_SE()
    elseif model == "i68" then
        return waitBegin_i68()
    end
end
function autoMobile()
    if model == "SE" then
        autoMobile_SE()
    elseif model == "i68" then
        autoMobile_i68()
    end
end
function backFromLines()
    if model == "SE" then
        backFromLines_SE()
    elseif model == "i68" then
        backFromLines_i68()
    end
end
function gametoCarbarn()
    if model == "SE" then
        return gametoCarbarn_SE()
    elseif model == "i68" then
        return gametoCarbarn_i68()
    end
end
function toDailyGame()
    if model == "SE" then
        return toDailyGame_SE()
    elseif model == "i68" then
        return toDailyGame_i68()
    end
end
function Login()
    if model == "SE" then
        return Login_SE()
    elseif model == "i68" then
        return Login_i68()
    end
end
function toPVP()
    if model == "SE" then
        return toPVP_SE()
    elseif model == "i68" then
        return toPVP_i68()
    end
end
function toSpecialEvent()
    if model == "SE" then
        return toSpecialEvent_SE()
    elseif model == "i68" then
        return toSpecialEvent_i68()
    end
end
main()
