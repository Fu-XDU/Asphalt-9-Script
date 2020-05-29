require "TSLib"
local ts = require("ts");
init(1);
stage = -1;--段位
state = 0;--中间件，声明检测界面后的下一步流程
path = 0;--道路选择
time = -1;--时间戳，记录离开赛事的时间
innerGhost = 0;--有内鬼次数
LoginTimes = 0;--连续登陆次数
PVPTimes, PVETimes = 0, 0;--多人和赛事局数,存文件
checkplacetimes = 0;--连续检测界面次数
checkplacetimesout = 35;--连续检测界面超时次数
validateGame = false;
runningState = true;--脚本运行状态
receive_starting_command = false;--如果是true那么检测到账号被顶就不再等待
width, height = "", "";--屏幕尺寸
-------下面是主函数-------main()为程序主流程函数| prepare()为前置准备函数 | after()为脚本结束处理函数
function prepare()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7));--随机数初始化
    checkScreenSize();
    ShowUI();
    savePowerF();
    initTable();
    log4j("Starting_script");
    toast("脚本开始", 5);
    runApp("com.Aligames.kybc9");
    ts.httpsGet("https://yourdomin.cn/api/a9control?udid=" .. ts.system.udid() .. "&command=1", {}, {})--将脚本状态置为运行
    supermode = mode;
    timeout = tonumber(timeout);
    timeout2 = tonumber(timeout2);
    skipcar = tonumber(skipcar);
end
function main()
    prepare();
    if (width == 640 and height == 1136) or not (width == 750 and height == 1334) then
        --iPhone SE,5,5S,iPod touch 5
        :: flag_SE ::
        place = checkPlace_SE();
        if checkplacetimes > 2 then
            mSleep(1000);
        end
        if checkplacetimes > checkplacetimesout then
            checkplacetimes = 0;
            restartApp();
            toast("等待30秒", 1)
            mSleep(30000);
            place = 404;
        end
        worker_SE();
        if state == -1 then
            state = 0;
            checkplacetimes = checkplacetimes + 1;
            goto flag_SE;
        elseif state == -2 then
            state = 0;
            checkplacetimes = 0;
            goto stop_SE;
        elseif state == -3 then
            state = 0;
            back_SE();
            checkplacetimes = 0;
            goto flag_SE;
        elseif state == -4 then
            state = 0;
            checkplacetimes = 0;
            goto backFromLines_SE;
        elseif state == -5 then
            state = 0;
            checkplacetimes = 0;
            goto autoMobile_SE;
        elseif state == -6 then
            state = 0;
            checkplacetimes = 0;
            goto waitBegin_SE;
        end
        checkplacetimes = 0;
        state2 = toCarbarn_SE();
        if state2 == 0 then
            state2 = 0;
            goto flag_SE;
        elseif state2 == -1 then
            state2 = 0;
            goto stop_SE;
        end
        :: chooseCar_SE ::
        chooseCar_SE();
        :: waitBegin_SE ::
        state = waitBegin_SE();
        if state == -1 then
            state = 0;
            goto flag_SE;
        end
        :: autoMobile_SE ::
        autoMobile_SE();
        :: backFromLines_SE ::
        backFromLines_SE();
        getHttpsCommand();--https请求获取运行指令
        goto flag_SE;
        :: stop_SE ::
        log4j("Script_terminated");
    elseif width == 750 and height == 1334 then
        checkplacetimes = 0;
        :: flag_i68 ::
        place = checkPlace_i68();
        if checkplacetimes > 2 then
            mSleep(1000);
        end
        if checkplacetimes > checkplacetimesout then
            checkplacetimes = 0;
            restartApp();
            toast("等待30秒", 1)
            mSleep(30000);
            place = 404;
        end
        worker_i68();
        if state == -1 then
            state = 0;
            checkplacetimes = checkplacetimes + 1;
            goto flag_i68;
        elseif state == -2 then
            state = 0;
            checkplacetimes = 0;
            goto stop_i68;
        elseif state == -3 then
            state = 0;
            back_i68();
            checkplacetimes = 0;
            goto flag_i68;
        elseif state == -4 then
            state = 0;
            checkplacetimes = 0;
            goto backFromLines_i68;
        elseif state == -5 then
            state = 0;
            checkplacetimes = 0;
            goto autoMobile_i68;
        elseif state == -6 then
            state = 0;
            checkplacetimes = 0;
            goto waitBegin_i68;
        end
        checkplacetimes = 0;
        state2 = toCarbarn_i68();
        if state2 == 0 then
            state2 = 0;
            goto flag_i68;
        elseif state2 == -1 then
            state2 = 0;
            goto stop_i68;
        end
        :: chooseCar_i68 ::
        chooseCar_i68();
        :: waitBegin_i68 ::
        state = waitBegin_i68();
        if state == -1 then
            state = 0;
            goto flag_i68;
        end
        :: autoMobile_i68 ::
        autoMobile_i68();
        :: backFromLines_i68 ::
        backFromLines_i68();
        mSleep(5000);
        getHttpsCommand();--https请求获取运行指令
        goto flag_i68;
        :: stop_i68 ::
        log4j("Script_terminated");
    end
    after();
end
function after()
    sendEmail(email, "[A9]脚本自动停止运行" .. getDeviceName(), readFile(userPath() .. "/res/A9log.txt"))
    closeApp("com.Aligames.kybc9");--关闭游戏
    lockDevice();
end
-------下面是通用处理函数-------
function savePowerF()
    if savePower == "开" then
        toast("降低屏幕亮度", 2);
        setBacklightLevel(0);--屏幕亮度调制最暗
    end
end
function checkScreenSize()
    width, height = getScreenSize();
    if not ((width == 640 and height == 1136) or (width == 750 and height == 1334)) then
        ret = dialogRet("告知\n本脚本不支持您的设备分辨率，是否继续运行此脚本", "是", "否", 0, 0);
        if ret ~= 0 then
            --如果按下"否"按钮
            toast("脚本停止", 1);
            mSleep(700);
            luaExit();        --退出脚本
        end
    end
end
function getHttpsCommand()
    :: getCommand ::
    a9getCommandcode, a9getCommandheader_resp, a9getCommandbody_resp = ts.httpsGet("https://yourdomin.cn/api/a9getCommand?udid=" .. ts.system.udid(), {}, {})
    if a9getCommandcode == 200 and a9getCommandbody_resp == "0" then
        if runningState == true then
            log4j("Stopping_command,script_terminated");
            runningState = false;
            toast("接收到暂停指令，脚本暂停运行", 1);
            savePowerF();
        end
        toast("脚本已暂停运行", 4);
        mSleep(5000);
        toast("5秒后再次发起请求", 4);
        mSleep(5000);--等5秒后再次发起请求
        goto getCommand;
    elseif a9getCommandcode == 200 and a9getCommandbody_resp == "1" and runningState == false then
        toast("接收到开始指令，脚本开始运行", 1);
        log4j("Starting_command,script_online");
        runningState = true;
        receive_starting_command = true;
        savePowerF();
    elseif a9getCommandcode == 200 and a9getCommandbody_resp == "2" then
        toast("接收到模式转换指令，停止赛事模式", 1);
        mSleep(1000);
        log4j("Switch_command,PVE_terminated");
        supermode = "多人刷积分声望";
        mode = "多人刷积分声望";
        savePowerF();
        ts.httpsGet("https://yourdomin.cn/api/a9control?udid=" .. ts.system.udid() .. "&command=1", {}, {})--将脚本状态置为运行
    elseif a9getCommandcode == 200 and a9getCommandbody_resp == "3" then
        toast("接收到模式转换指令，开始赛事模式", 1);
        mSleep(1000);
        log4j("Switch_command,PVE_started");
        supermode = "赛事模式";
        mode = "赛事模式";
        savePowerF();
        ts.httpsGet("https://yourdomin.cn/api/a9control?udid=" .. ts.system.udid() .. "&command=1", {}, {})--将脚本状态置为运行
    end
end
function httpsGet(content)
    udid = ts.system.udid()
    header_send = {}
    body_send = {}
    ts.setHttpsTimeOut(5) --安卓不支持设置超时时间
    code, header_resp, body_resp = ts.httpsGet("https://yourdomin.cn/api/a9?content=" .. content .. "&udid=" .. udid, header_send, body_send)
end
function ToStringEx(value)
    if type(value) == 'table' then
        return TableToStr(value)
    elseif type(value) == 'string' then
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
            if type(key) == 'number' or type(key) == 'string' then
                retstr = retstr .. signal .. '[' .. ToStringEx(key) .. "]=" .. ToStringEx(value)
            else
                if type(key) == 'userdata' then
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
function refreshTable()
    table = readFile(userPath() .. "/res/A9Info.txt")
    if table then
        --如果日期不对
        if table[1] ~= os.date("%Y年%m月%d日") then
            writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1);
            PVPTimes = 0;
            PVETimes = 0;
            writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), PVPTimes, PVETimes }, "w", 1);
        else
            writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), PVPTimes, PVETimes }, "w", 1);
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1);
    end
end
function initTable()
    table = readFile(userPath() .. "/res/A9Info.txt")
    logtxt = readFile(userPath() .. "/res/A9log.txt")
    if table then
        --如果日期不对，数据重写
        if table[1] ~= os.date("%Y年%m月%d日") then
            --文件重写
            writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1);
            initTable();
        else
            PVPTimes = table[2];
            PVETimes = table[3];
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(userPath() .. "/res/A9Info.txt", { os.date("%Y年%m月%d日"), 0, 0 }, "w", 1);
        mSleep(1000);
        initTable();--每次初始化内容都要再运行initTable()检查
    end
    if logtxt then
        if logtxt[1] ~= os.date("%Y年%m月%d日") then
            --如果日期不对,发邮件，数据重写
            sendEmail(email, "[A9]" .. os.date("%m%d%H") .. "日志" .. getDeviceName(), logtxt);
            writeFile(userPath() .. "/res/A9log.txt", { os.date("%Y年%m月%d日") }, "w", 1);
            mSleep(1000);
            httpsGet("Delete_log");
            initTable();--每次初始化内容都要再运行initTable()检查
        else
            --啥都不干
        end
    else
        --没有文件就创建文件，初始化内容
        writeFile(userPath() .. "/res/A9log.txt", { os.date("%Y年%m月%d日") }, "w", 1);
        mSleep(1000);
        initTable();--每次初始化内容都要再运行initTable()检查
    end
end
function log4j(content)
    table = readFile(userPath() .. "/res/A9log.txt")
    if table then
        --如果日期不对,发邮件，数据重写
        if table[1] ~= os.date("%Y年%m月%d日") then
            initTable();
            httpsGet("Delete_log");
        else
            writeFile(userPath() .. "/res/A9log.txt", { "[" .. os.date("%H:%M:%S") .. "]" .. content }, "a", 1);
            httpsGet(content);
        end
    else
        --没有文件就创建文件，初始化内容,再写入内容
        initTable();
        log4j(content);
    end
end
function sendEmail(reciver, topic, content)
    if reciver == "" then
        toast("未指定邮箱", 1);
        return 0;
    end
    if type(content) == 'table' then
        content = TableToStr(content);
    end
    status = ts.smtp(reciver, topic, content, "smtp.qq.com", "yourqq@qq.com", "授权码");
    if (status) then
        toast("邮件发送成功", 1);
        mSleep(1000);
    else
        toast("邮件发送失败", 1);
        mSleep(10000)
    end
end
function ShowUI()
    w, h = getScreenSize()
    UINew(2, "第1页,第2页", "确定", "取消", "uiconfig.dat", 1, 120, w, h, "255,255,255", "255,255,255", "", "dot", 1);
    UILabel(1, "狂野飙车9国服iOS脚本", 15, "center", "38,38,38");
    UILabel(1, "模式选择", 15, "left", "38,38,38");
    UIRadio(1, "mode", "多人刷积分声望,赛事模式", "0");--记录最初设置 | 特殊赛事保留
    UILabel(1, "没油没票后动作（赛事模式）", 15, "left", "38,38,38");
    UIRadio(1, "switch", "去刷多人,等15分钟,等30分钟", "0");
    UILabel(1, "路线选择（所有模式）", 15, "left", "38,38,38");
    UIRadio(1, "path", "左,中,右,随机", "0");
    UILabel(1, "赛事位置选择", 15, "left", "38,38,38");
    UIRadio(1, "gamenum", "1,2,3,4,5,6,7,8,9,10,11", "0");
    UILabel(1, "赛事是否选车", 15, "left", "38,38,38");
    UIRadio(1, "chooseCarorNot", "是,否", "0");
    UILabel(1, "赛事用车位置选择（赛事模式）", 15, "left", "38,38,38");
    UIRadio(1, "upordown", "中间上,中间下,右上（被寻车满星时）", "0");
    UILabel(1, "赛事选车是否返回一次（被寻车满星时）", 15, "left", "38,38,38");
    UIRadio(1, "backifallstar", "是,否", "0");
    UILabel(1, "传奇是否刷多人", 15, "left", "38,38,38");
    UIRadio(1, "PVPatBest", "是,否", "0");
    UILabel(1, "节能模式", 15, "left", "38,38,38");
    UIRadio(1, "savePower", "开,关", "0");
    UILabel(1, "多人选低一段车辆（白金及以上）", 15, "left", "38,38,38");
    UIRadio(1, "lowerCar", "开,关", "0");
    UILabel(1, "赛事没油是否向左选车", 15, "left", "38,38,38");
    UIRadio(1, "changeCar", "开,关", "0");
    UILabel(1, "需要过多久返回赛事模式或寻车模式（分钟）", 15, "left", "38,38,38");
    UIEdit(1, "timeout", "内容", "60", 15, "center", "38,38,38", "number");
    UILabel(1, "多人跳车（填0不跳）", 15, "left", "38,38,38");
    UIEdit(1, "skipcar", "内容", "0", 15, "center", "38,38,38", "number");
    UILabel(1, "顶号重连（分钟）", 15, "left", "38,38,38");
    UIEdit(1, "timeout2", "内容", "30", 15, "center", "38,38,38", "number");
    UILabel(1, "接收日志的邮箱", 15, "left", "38,38,38");
    UIEdit(1, "email", "邮箱地址", "", 15, "left", "38,38,38", "default");
    UILabel(1, "详细说明请向左滑查看第二页", 20, "left", "255,30,2");
    UILabel(2, "刷赛事模式需要先用所需车辆手动完成一局再启动脚本。", 15, "left", "255,30,2")
    UILabel(2, "多人刷积分声望:脚本自动刷多人获得声望。", 15, "left", "38,38,38")
    UILabel(2, "脚本运行前需手动开启自动驾驶。", 15, "left", "38,38,38")
    UILabel(2, "没油没票后动作:刷赛事用完油和票之后的动作，选择去刷多人会在指定时间后返回。", 15, "left", "38,38,38")
    UILabel(2, "赛事位置选择:选择刷第几个赛事。", 15, "left", "38,38,38")
    UILabel(2, "赛事是否选车:有些赛事为指定车辆，无法从车库选车。", 15, "left", "38,38,38")
    UILabel(2, "寻车赛事用车位置选择:赛事选车时游戏会自动跳到上局此赛事所用车辆，需要选择上还是下。", 15, "left", "38,38,38")
    UILabel(2, "多人跳车:避免赛事所需车的燃油在多人中消耗，可以指定跳过车辆。", 15, "left", "38,38,38")
    UILabel(2, "接收日志的邮箱：每日日志会在次日脚本运行之初发送至此邮箱。", 15, "left", "38,38,38")
    UILabel(2, "如果有脚本无法识别的界面，请联系QQ群1028746490群主。如果需要购买脚本授权码也请联系上述QQ群群主。", 20, "left", "38,38,38")
    UIShow();
end
function keypress(key)
    keyDown(key);
    keyUp(key);
end
function restartApp()
    log4j("Asphalt9_restarted");
    closeApp("com.Aligames.kybc9");--关闭游戏
    mSleep(5000);
    runApp("com.Aligames.kybc9");--打开游戏
    mSleep(5000);
end
-------下面是iPhone SE 设备处理函数-------
function back_SE()
    toast("后退", 1)
    tap(30, 30)
    mSleep(1500)
end
function checkPlace_SE()
    if checkplacetimes > 2 then
        toast("检测界面," .. tostring(checkplacetimes) .. "/" .. tostring(checkplacetimesout), 1);
    end
    if (isColor(688, 391, 0xfe8b40, 85) and isColor(395, 392, 0xfe8b40, 85) and isColor(479, 399, 0xfe8b40, 85) and isColor(494, 371, 0xfe8b40, 85) and isColor(787, 420, 0xfe8b40, 85) and isColor(819, 366, 0xfe8b40, 85)) then
        checkplacetimes = 0;
        return -2;--在登录界面
    elseif (isColor(419, 137, 0xffffff, 85) and isColor(455, 134, 0xffffff, 85) and isColor(573, 137, 0xffffff, 85) and isColor(573, 158, 0xffffff, 85) and isColor(602, 136, 0xffffff, 85) and isColor(636, 133, 0xffffff, 85) and isColor(659, 134, 0xffffff, 85) and isColor(683, 140, 0xffffff, 85) and isColor(442, 515, 0x000721, 85) and isColor(190, 518, 0xffffff, 85)) then
        return 20;--俱乐部新人
    end
    if (isColor(437, 570, 0x9f0942, 85) and isColor(452, 569, 0x9f0943, 85) and isColor(451, 584, 0x9f0942, 85) and isColor(444, 577, 0x9f0942, 85)) then
        return -3;--网络未同步
    end
    if (isColor(92, 129, 0xf00252, 85) and isColor(97, 129, 0xf20252, 85) and isColor(104, 129, 0xf50153, 85) and isColor(116, 130, 0xea0352, 85) and isColor(128, 127, 0xf1014b, 85) and isColor(158, 128, 0xdb0244, 85) and isColor(761, 96, 0xd9d6d6, 85) and isColor(827, 101, 0x3887d7, 85) and isColor(906, 101, 0x4e443b, 85) and isColor(971, 100, 0x9015fb, 85)) then
        return 3.1;--在多人车库
    end
    if getColor(5, 5) == 0x101f3b then
        checkplacetimes = 0;
        return 0;--在大厅
    end
    if multiColor({ { 100, 560, 0xffffff }, { 270, 570, 0xffffff }, { 860, 560, 0xffffff }, { 1060, 560, 0xffffff } }, 90, false) == true then
        checkplacetimes = 0;
        return 1;--在多人
    end
    if (isColor(115, 625, 0xc3fb12, 85) or isColor(301, 625, 0xc3fb12, 85) or isColor(469, 625, 0xc3fb12, 85)) then
        checkplacetimes = 0;
        return 5;--在赛事
    end
    if (isColor(216, 96, 0xe6004d, 85) and isColor(139, 96, 0xfc0053, 85) and isColor(60, 95, 0xf00251, 85) and isColor(221, 176, 0xffffff, 85) and isColor(60, 161, 0xff0054, 85)) then
        checkplacetimes = 0;
        return 6;--在赛事开始界面
    end
    if (isColor(540, 312, 0x01b9e3, 85) and isColor(635, 307, 0x01b8e3, 85) and isColor(596, 273, 0x01718b, 85) and isColor(581, 350, 0x03b9e3, 85) and isColor(564, 308, 0xffffff, 85) and isColor(609, 310, 0xffffff, 85) and isColor(658, 314, 0xffffff, 85) and isColor(682, 291, 0xdfdfdf, 85)) then
        checkplacetimes = 0;
        return 17;--多人匹配中
    end
    if getColor(5, 5) == 0xffffff then
        return -1;--不在大厅，不在多人
    end
    if getColor(115, 25) == 0xff0054 then
        checkplacetimes = 0;
        return 2;--游戏结算界面
    end
    if getColor(170, 100) == 0x14bde9 then
        checkplacetimes = 0;
        return 3;--游戏中
    end
    if (isColor(60, 26, 0xff0052, 85) and isColor(153, 29, 0xfe0052, 85) and isColor(209, 59, 0xffffff, 85) and isColor(282, 57, 0xffffff, 85) and isColor(355, 65, 0xffffff, 85) and isColor(454, 63, 0xffffff, 85) and isColor(515, 61, 0xffffff, 85) and isColor(629, 45, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 4;--来自Gameloft的礼物
    end
    if (isColor(525, 33, 0xff0054, 85) and isColor(536, 33, 0xff0054, 85) and isColor(531, 41, 0xff0054, 85) and isColor(529, 52, 0xff0054, 85) and isColor(568, 33, 0xff0054, 85) and isColor(568, 44, 0xbe064c, 85) and isColor(567, 53, 0xc6054c, 85) and isColor(490, 81, 0xdadce0, 85) and isColor(556, 87, 0xe4e6e8, 85) and isColor(631, 85, 0xe6e8ea, 85)) then
        checkplacetimes = 0;
        return 7;--领奖开包
    elseif (isColor(211, 328, 0xe77423, 85) and isColor(366, 321, 0x4299e1, 85) and isColor(511, 310, 0xd8a200, 85) and isColor(657, 303, 0x5c17db, 85) and isColor(825, 289, 0x545454, 85) and isColor(960, 123, 0xfffeff, 85)) then
        checkplacetimes = 0;
        return 8;--多人联赛奖励界面
    elseif (isColor(597, 52, 0xff0054, 85) and isColor(596, 63, 0xff0054, 85) and isColor(523, 55, 0xff0054, 85) and isColor(535, 55, 0xff0054, 85) and isColor(567, 54, 0xff0054, 85) and isColor(557, 70, 0xff0054, 85) and isColor(254, 552, 0xffffff, 85) and isColor(522, 557, 0xffffff, 85) and isColor(250, 592, 0xffffff, 85) and isColor(526, 591, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 9;--赛车解锁或升星
    elseif (isColor(523, 350, 0xcb0042, 85) and isColor(610, 350, 0xcc0042, 85) and isColor(610, 435, 0xcc0042, 85) and isColor(568, 460, 0xcd0042, 85) and isColor(525, 436, 0xcc0042, 85) and isColor(544, 422, 0xd9d9d9, 85) and isColor(568, 439, 0xcecece, 85) and isColor(591, 426, 0xd6d6d6, 85) and isColor(592, 396, 0xececec, 85) and isColor(592, 371, 0xfafafa, 85)) then
        checkplacetimes = 0;
        return 10;--开始的开始
    elseif (isColor(35, 555, 0xfb1264, 85) and isColor(35, 602, 0xfb1264, 85) and isColor(223, 136, 0xfa0153, 85) and isColor(349, 137, 0xfe0055, 85) and isColor(938, 569, 0xffffff, 85) and isColor(1070, 569, 0xffffff, 85) and isColor(935, 602, 0xffffff, 85) and isColor(1076, 601, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 11;--段位升级
    elseif (isColor(222, 50, 0xffffff, 85) and isColor(301, 53, 0xffffff, 85) and isColor(196, 85, 0xffffff, 85) and isColor(277, 84, 0xffffff, 85) and isColor(333, 298, 0xffffff, 85) and isColor(392, 297, 0xffffff, 85) and isColor(456, 300, 0xffffff, 85) and isColor(394, 212, 0xffffff, 85) and isColor(293, 237, 0xffffff, 85) and isColor(494, 235, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 12;--声望升级
    elseif (isColor(184, 218, 0xffffff, 85) and isColor(218, 229, 0xd8d9dc, 85) and isColor(245, 224, 0xe6e7e9, 85) and isColor(266, 225, 0xf9f9f9, 85) and isColor(342, 225, 0xe9e9e9, 85) and isColor(408, 221, 0xcfcfcf, 85) and isColor(935, 228, 0xf2004f, 85) and isColor(991, 225, 0xff0054, 85) and isColor(976, 243, 0xfb0052, 85)) then
        checkplacetimes = 0;
        return 13;--未能连接到服务器
    elseif (isColor(26, 24, 0xff0054, 85) and isColor(234, 20, 0xff0054, 85) and isColor(29, 212, 0xff0054, 85) and isColor(195, 120, 0xffffff, 85) and isColor(441, 127, 0xffffff, 85) and isColor(15, 103, 0x061724, 85) and isColor(845, 559, 0xc3fb13, 85) and isColor(1035, 559, 0xc2fb12, 85) and isColor(945, 603, 0xc3fb13, 85)) then
        checkplacetimes = 0;
        return 14;--多人断开连接
    elseif (isColor(525, 185, 0xffffff, 85) and isColor(546, 182, 0xffffff, 85) and isColor(574, 189, 0xffffff, 85) and isColor(591, 190, 0xffffff, 85) and isColor(729, 329, 0xeceef1, 85) and isColor(742, 336, 0xd2d6dd, 85) and isColor(759, 334, 0xffffff, 85) and isColor(788, 336, 0xe4e7eb, 85) and isColor(798, 329, 0xcdd1d9, 85) and isColor(569, 437, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 15;--连接错误
    elseif (isColor(176, 214, 0xffffff, 85) and isColor(269, 217, 0xecedee, 85) and isColor(326, 217, 0x999da4, 85) and isColor(342, 211, 0xbdc0c4, 85) and isColor(352, 221, 0xe7e7e7, 85) and isColor(395, 221, 0xd7d7d7, 85) and isColor(409, 221, 0xcececf, 85) and isColor(555, 352, 0xe5eaf0, 85) and isColor(951, 217, 0xff0054, 85) and isColor(993, 221, 0xff0054, 85)) then
        checkplacetimes = 0;
        return 16;--顶号行为
    elseif (isColor(495, 147, 0xff0054, 85) and isColor(525, 149, 0xd4044d, 85) and isColor(538, 148, 0xfd0054, 85) and isColor(564, 145, 0xfd0054, 85) and isColor(585, 150, 0xfd0054, 85) and isColor(604, 146, 0xfd0054, 85) and isColor(608, 145, 0xe80250, 85) and isColor(861, 158, 0xf90052, 85) and isColor(567, 453, 0xc3fb11, 85)) then
        checkplacetimes = 0;
        return 18;--VIP到期
    elseif (isColor(67, 23, 0x664944, 85) and isColor(183, 26, 0x7b4542, 85) and isColor(346, 22, 0x8f7a81, 85) and isColor(495, 27, 0x587bad, 85) and isColor(632, 25, 0x90bee2, 85) and isColor(764, 27, 0x8c7b94, 85) and isColor(892, 29, 0x9c7d84, 85)) then
        checkplacetimes = 0;
        return 19;--登录延时
    elseif (isColor(506, 152, 0xf3f4f5, 85) and isColor(542, 162, 0xfbfbfb, 85) and isColor(560, 162, 0xe8eaec, 85) and isColor(573, 161, 0xffffff, 85) and isColor(612, 162, 0xffffff, 85) and isColor(508, 464, 0xffffff, 85) and isColor(619, 457, 0xffffff, 85) and isColor(647, 486, 0x020922, 85)) then
        checkplacetimes = 0;
        return 21;--段位降低
    elseif (isColor(19, 21, 0xff0054, 85) and isColor(223, 17, 0xff0054, 85) and isColor(18, 235, 0xff0054, 85) and isColor(231, 241, 0xff0054, 85) and isColor(178, 155, 0xffffff, 85) and isColor(409, 157, 0xffffff, 85) and isColor(454, 131, 0xffffff, 85) and isColor(1017, 562, 0xc3fb12, 85) and isColor(1074, 593, 0xc3fb11, 85) and isColor(1085, 607, 0x000b1f, 85)) then
        checkplacetimes = 0;
        return 22;--失去资格
    elseif (isColor(961, 97, 0xff0054, 85) and isColor(967, 91, 0xfd0054, 85) and isColor(955, 89, 0xf60252, 85) and isColor(955, 103, 0xfd0155, 85) and isColor(971, 105, 0xf80151, 85) and isColor(961, 97, 0xff0054, 85)) then
        checkplacetimes = 0;
        return 23;--弹窗广告
    end
    mSleep(1000);
end
function backHome_SE()
    tap(1100, 20);--返回大厅
    mSleep(2000);
    place = checkPlace_SE();
    if place ~= 0 then
        toast("有内鬼，停止交易", 1)
        return -1;
    end
    return 0;
end
function toPVP_SE()
    toast("进入多人", 1);
    if (isColor(741, 538, 0xfc0050, 85) and isColor(742, 541, 0xed0150, 85)) then
        goto PVP;
    end
    for i = 1, 10, 1 do
        moveTo(860, 235, 225, 235, 20);--从右往左划
        if (isColor(1116, 539, 0xdc014a, 85) and isColor(1116, 538, 0xda0147, 85)) then
            break ;
        end
    end
    for i = 1, 2, 1 do
        moveTo(225, 235, 860, 235, 20);--从左往右划
    end
    mSleep(2000);
    --TODO:检查是否在多人入口
    :: PVP ::
    checkAndGetPackage_SE();
    tap(660, 600);
    mSleep(1500);
    place = checkPlace_SE();
    if place ~= 1 then
        toast("有内鬼，停止交易", 1)
        return -1;
    end
    return 0;
end
function getStage_SE()
    if isColor(328, 328, 0xf1cb30, 85) then
        stage = 2;--黄金段位
        --toast("黄金段位",1);
    elseif isColor(328, 328, 0x96b2d4, 85) then
        stage = 1;--白银段位
        --toast("白银段位",1);
    elseif isColor(328, 328, 0xd88560, 85) then
        stage = 0;--青铜段位
        --toast("青铜段位",1);
    elseif isColor(328, 328, 0x9365f8, 85) then
        stage = 3;--白金段位
        --toast("白金段位",1);
    elseif (isColor(320, 309, 0xf5e2a4, 85) and isColor(334, 309, 0xf5e2a4, 85) and isColor(323, 324, 0xf4e1a4, 85) and isColor(334, 323, 0xf5e2a4, 85) and isColor(328, 327, 0xf5e2a4, 85)) then
        stage = 4;--传奇段位
        --toast("传奇段位",1);
    elseif (isColor(322, 308, 0x00bbe8, 85) and isColor(335, 308, 0x00bbe8, 85) and isColor(334, 323, 0x00bbe8, 85) and isColor(320, 321, 0x00bbe8, 85)) then
        stage = -2;--没有段位
        --toast("没有段位",1);
    end
end
function chooseStageCar_SE()
    virtalstage = 0;
    if lowerCar == "开" then
        virtalstage = stage - 1;
    else
        virtalstage = stage;
    end
    if virtalstage <= 0 then
        tap(760, 100);
    elseif virtalstage == 1 then
        tap(830, 100);
    elseif virtalstage == 2 then
        tap(900, 100);
    elseif virtalstage == 3 then
        tap(975, 100);
    elseif virtalstage == 4 then
        tap(1050, 100);
    end
end
function checkTimeOut_SE()
    if time ~= -1 then
        if (os.time() - time >= timeout * 60) then
            toast("时间到", 1)
            mode = supermode;
            backHome_SE();
        else
            --toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
            --mSleep(1000);
        end
    end
end
function toCarbarn_SE()
    --mSleep(1000);
    getStage_SE();
    if stage == 4 and PVPatBest == "否" then
        if supermode == "多人刷积分声望" then
            toast("脚本停止", 1);
            return -1;
        elseif supermode == "赛事模式" then
            toast("等待" .. tostring(timeout - (os.time() - time) / 60) .. "分钟后返回", 5);
            for i = 1, timeout * 60 - (os.time() - time), 1 do
                toast(tostring((timeout * 60 - (os.time() - time)) - ((timeout * 60 - (os.time() - time)) % 0.01)) .. "秒后返回赛事", 0.7)
                mSleep(1000);
            end
            mSleep(5 * 60 * 1000);
            checkTimeOut_SE();
            return 0;
        end
    end
    tap(500, 580);--进入车库
end
function chooseCar_SE()
    mSleep(2500);
    chooseStageCar_SE();
    mSleep(1500);
    if stage == -2 or stage == 0 or stage == -1 then
        for i = 800, 450, -30 do
            tap(i, 270);
        end
    else
        for i = 1100, 900, -30 do
            tap(i, 270);
        end
    end
    mSleep(3000);
    skip = 1;
    while getColor(1090, 570) == 0xffffff or skip == skipcar or (isColor(167, 160, 0x797979, 85) and isColor(172, 161, 0x797979, 85) and isColor(169, 156, 0x797979, 85)) do
        tap(440, 320);--向左选车
        mSleep(500);
        skip = skip + 1;
    end

    --检查自动驾驶
    if (isColor(1058, 508, 0xfc0001, 85) and isColor(1053, 508, 0xef0103, 85) and isColor(1065, 508, 0xef0103, 85) and isColor(1057, 515, 0xff0000, 85) and isColor(1047, 523, 0xf00103, 85) and isColor(1062, 521, 0xe60205, 85)) then
        --toast("开启自动驾驶",1);
        tap(1060, 510);
        mSleep(500);
    end
    tap(1090, 570);
end
function waitBegin_SE()
    timer = 0;
    while (getColor(170, 100) ~= 0x14bde9 and timer < 35) do
        mSleep(2000);
        timer = timer + 1;
        toast("开局中," .. tostring(timer) .. "/35", 0.5);
        if (isColor(959, 206, 0xfff8fb, 85) and isColor(980, 228, 0xfffbff, 85) and isColor(959, 226, 0xffffff, 85) and isColor(981, 205, 0xfffeff, 85) and isColor(969, 216, 0xfffeff, 85) and isColor(938, 213, 0xff0053, 85) and isColor(993, 207, 0xff0054, 85) and isColor(981, 238, 0xff0054, 85)) then
            tap(970, 220)
            mSleep(2000);
            return -1;
        end
    end
    if timer >= 45 then
        toast("开局异常", 1);
        if (isColor(540, 312, 0x01b9e3, 85) and isColor(635, 307, 0x01b8e3, 85) and isColor(596, 273, 0x01718b, 85) and isColor(581, 350, 0x03b9e3, 85) and isColor(564, 308, 0xffffff, 85) and isColor(658, 314, 0xffffff, 85) and isColor(682, 291, 0xdfdfdf, 85) and isColor(17, 50, 0xffffff, 85) and isColor(70, 14, 0xffffff, 85)) then
            back_SE();
            return -1;
        else
            innerGhost = innerGhost + 1;
            --如果5次timer计时还在开局并且左上角返回键消失
            if innerGhost >= 5 then
                innerGhost = 0;
                restartApp();
            end
            return -1;
        end
    end
end
function autoMobile_SE()
    toast("接管比赛", 1);
    while (getColor(170, 100) == 0x14bde9) do
        mSleep(500);
        tap(950, 400);
        mSleep(500)
        if path == "左" then
            moveTo(800, 235, 400, 235, 20);--从右往左划
            moveTo(800, 235, 400, 235, 20);--从右往左划
        elseif path == "右" then
            moveTo(600, 235, 800, 235, 20);--从左往右划
            moveTo(600, 235, 800, 235, 20);--从左往右划
        elseif path == "随机" then
            rand = math.random(1, 3);--rand==1 2 or 3
            if rand == 1 then
                moveTo(800, 235, 400, 235, 20);--从右往左划
                moveTo(800, 235, 400, 235, 20);--从右往左划
            elseif rand == 2 then
                moveTo(600, 235, 800, 235, 20);--从左往右划
                moveTo(600, 235, 800, 235, 20);--从左往右划
            end
        end
        mSleep(500);
        tap(950, 400);
    end
    --toast("比赛结束",1);
    if mode == "多人刷积分声望" then
        PVPTimes = PVPTimes + 1;
        log4j(tostring(PVPTimes) .. "_PVP_done");
    elseif mode == "赛事模式" or mode == "特殊赛事" then
        PVETimes = PVETimes + 1;
        log4j(tostring(PVETimes) .. "_PVE_done");
    end
    refreshTable();
end
function backFromLines_SE()
    --从赛道回到多人界面
    --mSleep(1000);
    color = getColor(115, 25);
    while (color == 0xff0054) do
        tap(1000, 580);
        mSleep(1000);
        color = getColor(115, 25);
    end
    mSleep(5000);
    --toast("比赛完成",1);
    if supermode == "赛事模式" and (mode == "多人刷积分声望" or mode == "特殊赛事") then
        checkTimeOut_SE();
    end
end
function checkAndGetPackage_SE()
    if (not isColor(649, 472, 0x091624, 85)) then
        toast("领取多人包", 1);
        log4j("Open_multiplayer_pack");
        mSleep(700);
        tap(570, 470);
        mSleep(2000);
        tap(500, 600);
        mSleep(2000);
        tap(1030, 590);
        mSleep(10000);
    end
    if ((isColor(178, 503, 0xb9e816, 85) and isColor(173, 500, 0xbae916, 85) and isColor(175, 506, 0xc3fb12, 85) and isColor(147, 506, 0xbba7bb, 85) and isColor(128, 508, 0xe5dde5, 85) and isColor(127, 500, 0xfdfcfd, 85)) and not (isColor(80, 453, 0x1d071e, 85) and isColor(211, 455, 0x241228, 85) and isColor(84, 473, 0x241128, 85) and isColor(201, 472, 0x221226, 85) and isColor(228, 482, 0x676769, 85))) then
        log4j("Restocks_multiplayer_pack");
        tap(153, 462);
        mSleep(1000);
    end
end
function Login_SE()
    if (isColor(521, 298, 0x333333, 85) and isColor(502, 298, 0x333333, 85) and isColor(487, 298, 0x333333, 85) and isColor(469, 297, 0x333333, 85) and isColor(452, 298, 0x333333, 85) and isColor(435, 297, 0x333333, 85) and isColor(418, 297, 0x333333, 85) and isColor(399, 296, 0x333333, 85) and isColor(385, 296, 0x333333, 85)) then
        log4j("Login");
        tap(559, 397);
        mSleep(2000)
        return -1;
    else
        if ts.system.udid() == "yourudid" then
            toast("无密码,自动输入", 1);
            log4j("Input_passcode_automatically");
            mSleep(1000);
            tap(380, 300);
            mSleep(1000);
            keypress('q');
            keypress('w');
            keypress('e');
            keypress('a');
            keypress('s');
            keypress('d');
            keypress('1');
            keypress('1');
            keypress('3');
            tap(580, 257)
            mSleep(20000);
            return -1;
        else
            toast("无密码,脚本退出", 1);
            log4j("Passcode_not_found,script_terminated");
            mSleep(1000);
            return -2;
        end
    end
end
function toDailyGame_SE()
    toast("进入赛事", 1);
    if (isColor(555, 537, 0xf9004b, 85) and isColor(556, 540, 0xfe0054, 85)) then
        tap(929, 474);
        goto DailyGame;
    end
    for i = 1, 20, 1 do
        moveTo(860, 235, 225, 235, 20);--从右往左划
        if (isColor(1116, 539, 0xdc014a, 85) and isColor(1116, 538, 0xda0147, 85)) then
            break ;
        end
    end
    for i = 1, 4, 1 do
        moveTo(225, 235, 860, 235, 20);--从左往右划
    end
    mSleep(1000);
    --TODO:检查是否在赛事入口
    :: DailyGame ::
    tap(469, 589);
    mSleep(2000);
    for i = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20);--从左往右划
    end
    mSleep(2000);
    return -1;
end
function toSpecialEvent_SE()
    toast("进入特殊赛事", 1);
    --[[if (isColor( 555,  537, 0xf9004b, 85) and isColor( 556,  540, 0xfe0054, 85)) then
		tap(929,474);--在赛事就直接进入
		goto DailyGame;
	end]]--
    for i = 1, 20, 1 do
        moveTo(360, 235, 600, 235, 20);--从左往右划
        if (isColor(19, 537, 0xfc0051, 85) and isColor(19, 540, 0xff0054, 85) and isColor(19, 539, 0xff0054, 85)) then
            break ;
        end
    end
    moveTo(600, 235, 360, 235, 20);--从右往左划一次
    mSleep(1000);
    --TODO:检查是否在特殊赛事入口
    :: DailyGame ::
    tap(207, 621);
    mSleep(2000);
    for i = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20);--从左往右划
    end
    mSleep(2000);
    return -1;
end
function chooseGame_SE()
    gamenum = tonumber(gamenum);
    if gamenum <= 7 then
        tap(138 + 160 * (gamenum - 1), 500);
        mSleep(1000);
        tap(138 + 160 * (gamenum - 1), 500);
        mSleep(2000);
        return -1;
    else
        for i = 1, gamenum - 7, 1 do
            moveTo(610, 500, 470, 500, 20)
            mSleep(500)
        end
        tap(138 + 160 * 6, 500);
        mSleep(1000);
        tap(138 + 160 * 6, 500);
        mSleep(2000);
        return -1;
    end

end
function gametoCarbarn_SE()
    tap(1065, 590);
    mSleep(2000);
    if chooseCarorNot == "是" then
        if backifallstar == "是" then
            tap(580, 270);
            mSleep(2000);
            back_SE();
            mSleep(1000);
        end
        if upordown == "中间上" then
            tap(580, 270);
        elseif upordown == "中间下" then
            tap(580, 420);
        elseif upordown == "右上（被寻车满星时）" then
            tap(900, 270);
        end
    end
    :: beginAtGame ::
    mSleep(4000);
    if (((((isColor(1041, 557, 0xc7fb24, 85) and isColor(849, 561, 0xc8fb25, 85) and isColor(849, 598, 0xc8fb25, 85) and isColor(1074, 601, 0xc7fb23, 85))) or (isColor(938, 551, 0xc4fb11, 85) and isColor(1093, 555, 0xc2fb12, 85) and isColor(1086, 603, 0xc2fb11, 85) and isColor(928, 605, 0xc4fb16, 85)))) and not (isColor(167, 160, 0x797979, 85) and isColor(172, 161, 0x797979, 85) and isColor(169, 156, 0x797979, 85))) or ((isColor(1097, 553, 0xc3fb12, 85) and
            isColor(1097, 569, 0xc3fb11, 85))) then
        --检查自动驾驶
        if (isColor(1058, 508, 0xfc0001, 85) and isColor(1053, 508, 0xef0103, 85) and isColor(1065, 508, 0xef0103, 85) and isColor(1057, 515, 0xff0000, 85) and isColor(1047, 523, 0xf00103, 85) and isColor(1062, 521, 0xe60205, 85)) then
            toast("开启自动驾驶", 1);
            tap(1060, 510);
            mSleep(1000);
        end
        tap(1095, 548);
        mSleep(2000);
        --检查是不是有票
        if (isColor(257, 448, 0xc3fb12, 85) and isColor(508, 453, 0xc3fb12, 85) and isColor(250, 488, 0xc2fb12, 85) and isColor(509, 492, 0xc4fb12, 85)) then
            toast("没票", 1)
            tap(970, 160);
            --去多人or生涯
            time = os.time();--记录当前时间
            if switch == "去刷多人" then
                toast(tostring(timeout) .. "分钟后返回", 1)
                mode = "多人刷积分声望"
                mSleep(200);
                backHome_SE();
                return -1;
            elseif switch == "等15分钟" then
                toast("等15分钟", 1)
                mSleep(15 * 60 * 1000);
                toast("15分钟到", 1)
                mSleep(1000);
                goto beginAtGame;
            elseif switch == "等30分钟" then
                toast("等30分钟", 1)
                mSleep(30 * 60 * 1000);
                toast("30分钟到", 1)
                goto beginAtGame;
            end
        end
    else
        toast("没油了", 1);
        if changeCar == "开" then
            tap(440, 320);--向左选车
            goto beginAtGame;
        end
        --去多人or生涯
        time = os.time();--记录当前时间
        if switch == "去刷多人" then
            toast(tostring(timeout) .. "分钟后返回", 1)
            mode = "多人刷积分声望"
            backHome_SE();
            return -1;
        elseif switch == "等待15分钟" then
            toast("等待15分钟", 1)
            mSleep(15 * 60 * 1000);
            toast("15分钟到", 1)
            mSleep(1000);
            goto beginAtGame;
        elseif switch == "等待30分钟" then
            toast("等待30分钟", 1)
            mSleep(30 * 60 * 1000);
            toast("30分钟到", 1)
            goto beginAtGame;
        end
    end
    mSleep(3000)
    if waitBegin_SE() == -1 then
        return -1;
    end
    autoMobile_SE();--接管比赛
    mSleep(2000);
    return -1;
end
function receivePrizeFromGL_SE()
    log4j("Receive_packets_from_GL");
    mSleep(1000);
    tap(1015, 582);
    mSleep(5000);
    tap(569, 582);
    mSleep(2000);
    tap(1015, 582);
    mSleep(2000);
end
function receivePrizeAtGame_SE()
    mSleep(1000);
    tap(550, 590);
    mSleep(1000);
    tap(1020, 585);
    mSleep(1500);
    return -1;
end
function worker_SE()
    if place == -3 then
        toast("网络未同步", 1);
        state = -1;
    elseif place == 3.1 then
        toast("在多人车库", 1)
        state = -3;
    elseif place == 0 then
        toast("在大厅", 1);
        if mode == "多人刷积分声望" then
            state = toPVP_SE();
        elseif mode == "赛事模式" then
            state = toDailyGame_SE();
        elseif mode == "特殊赛事" then
            state = toSpecialEvent_SE();
        end
    elseif place == 1 then
        toast("在多人", 1);
        if mode == "多人刷积分声望" then
            state = 0;
        elseif mode == "赛事模式" then
            back_SE();
            state = toDailyGame_SE();
        elseif mode == "特殊赛事" then
            back_SE();
            state = toSpecialEvent_SE();
        end
    elseif place == -1 then
        toast("不在大厅，不在多人，回到大厅", 1);
        state = backHome_SE();
        if mode == "多人刷积分声望" then
            state = toPVP_SE();
        elseif mode == "赛事模式" then
            state = toDailyGame_SE();
        elseif mode == "特殊赛事" then
            state = toSpecialEvent_SE();
        end
    elseif place == 2 then
        --toast("在结算",1);
        state = -4;
    elseif place == 3 then
        --toast("在游戏",1);
        state = -5;
    elseif place == -2 then
        toast("登录界面", 1);
        state = Login_SE();
    elseif place == 4 then
        toast("奖励界面", 1);
        receivePrizeFromGL_SE();
        state = -1;
    elseif place == 5 then
        if mode == "赛事模式" then
            state = chooseGame_SE();
            validateGame = true;
        elseif mode == "多人刷积分声望" or mode == "特殊赛事" then
            back_SE();
            state = -1;
        end
    elseif place == 6 then
        toast("赛事开始界面", 1);
        if mode == "赛事模式" then
            if validateGame == false then
                back_SE();
                state = -1;
            elseif validateGame == true then
                state = gametoCarbarn_SE();
            end
        elseif mode == "多人刷积分声望" or mode == "特殊赛事" then
            backHome_SE();
            state = -1;
        end
    elseif place == 7 then
        toast("领奖界面", 1);
        state = receivePrizeAtGame_SE();
    elseif place == 8 then
        toast("多人联赛介绍界面", 1);
        tap(960, 120);
        mSleep(1000);
        state = -1;
    elseif place == 9 then
        toast("解锁或升星", 1);
        tap(390, 570);
        mSleep(2000);
        state = -1;
    elseif place == 10 then
        toast("开始的开始", 1);
        tap(566, 491);--按下开始
        mSleep(10000);
        state = -1;
    elseif place == 11 then
        toast("段位升级", 1);
        log4j("League_up");
        tap(1000, 580);--继续
        mSleep(2000);
        state = -1;
    elseif place == 12 then
        toast("声望升级", 1);
        mSleep(1000)
        tap(570, 590);--确定
        mSleep(2000);
        state = -1;
    elseif place == 13 then
        toast("未能连接到服务器", 1);
        tap(967, 215);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 14 then
        toast("断开连接", 1);
        tap(940, 570);--继续
        mSleep(2000);
        state = -1;
    elseif place == 15 then
        toast("连接错误", 1);
        tap(569, 437);--重试
        mSleep(2000);
        state = -1;
    elseif place == 16 then
        if receive_starting_command == false then
            --sendEmail(email,"账号被顶,等待"..tostring(timeout2).."分钟",getDeviceName());
            log4j("Parallel_read_detected,waiting " .. tostring(timeout2) .. " minutes");
            toast("账号被顶", 1);
            mSleep(1000);
            toast("等待" .. tostring(timeout2) .. "分钟", 1)
            mSleep(timeout2 * 60 * 1000);
            --sendEmail(email,"账号被顶,等待完成",getDeviceName());
            log4j("Waiting time over");
            toast("等待完成", 1);
        end
        tap(970, 215);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 17 then
        toast("匹配中", 1);
        state = -6;
    elseif place == 18 then
        toast("VIP会员到期", 1);
        tap(883, 150);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 19 then
        LoginTimes = LoginTimes + 1;
        if LoginTimes >= 20 then
            toast("登录延时", 1);
            mSleep(1000);
            restartApp();
            LoginTimes = 0;
            state = -1;
        else
            toast("登陆中", 1);
            state = -1;
        end
    elseif place == 20 then
        toast("俱乐部人气很旺", 1);
        tap(313, 495);--稍后查看
        mSleep(1500);
        state = -1;
    elseif place == 21 then
        toast("段位降级", 1);
        log4j("League_down");
        tap(563, 471);--确定
        mSleep(2000);
        state = -1;
    elseif place == 22 then
        toast("失去资格", 1);
        tap(945, 579);--确定
        mSleep(2000);
        state = -1;
    elseif place == 23 then
        tap(963, 97);--关闭弹窗广告
        mSleep(500);
        state = -1;
    else
        toast("不知道在哪", 1)
        state = -1;
    end
    receive_starting_command = false;
end
-------下面是iPhone 6 - iPhone 8 设备处理函数-------
function back_i68()
    --Done
    toast("后退", 1)
    tap(30, 30)
    mSleep(2500)
end
function checkPlace_i68()
    if checkplacetimes > 2 then
        toast("检测界面," .. tostring(checkplacetimes) .. "/" .. tostring(checkplacetimesout), 1);
    end
    if (((isColor(1305, 14, 0xfcffff, 85) and isColor(1312, 22, 0xfefefe, 85) and isColor(1314, 37, 0xcdd3db, 85) and isColor(1293, 32, 0xfefeff, 85) and isColor(1294, 21, 0xffffff, 85) and isColor(1304, 17, 0xfeffff, 85)) and not (isColor(12, 16, 0xffffff, 85) and
            isColor(10, 45, 0xffffff, 85)))) or ((isColor(1111, 11, 0xfbffff, 85) and isColor(1120, 16, 0xf8faf9, 85) and isColor(1126, 26, 0xe2e4e8, 85) and isColor(1095, 26, 0xfdfdfd, 85))) then
        checkplacetimes = 0;
        return 0;--在大厅
    elseif (isColor(513, 668, 0xff0054, 85) and isColor(521, 676, 0xff0054, 85) and isColor(529, 685, 0xff0054, 85) and isColor(530, 668, 0xfc0053, 85) and isColor(513, 684, 0xfe0054, 85) and isColor(587, 665, 0xe4e5e8, 85) and isColor(588, 717, 0xfb1264, 85) and isColor(615, 717, 0xfb1264, 85) and isColor(640, 717, 0xfb1264, 85) and isColor(660, 717, 0xfb1264, 85)) then
        checkplacetimes = 0;
        return -3;--网络未同步
    elseif (isColor(498, 429, 0xfe8b40, 85) and isColor(500, 472, 0xfe8b40, 85) and isColor(845, 434, 0xfe8b40, 85) and isColor(846, 467, 0xfe8b40, 85)) then
        checkplacetimes = 0;
        return -2;--在登录界面
    elseif (isColor(419, 137, 0xffffff, 85) and isColor(455, 134, 0xffffff, 85) and isColor(573, 137, 0xffffff, 85) and isColor(573, 158, 0xffffff, 85) and isColor(602, 136, 0xffffff, 85) and isColor(636, 133, 0xffffff, 85) and isColor(659, 134, 0xffffff, 85) and isColor(683, 140, 0xffffff, 85) and isColor(442, 515, 0x000721, 85) and isColor(190, 518, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 20;--俱乐部新人,undone
    elseif (isColor(896, 112, 0xce7345, 85) and isColor(985, 113, 0x6c7889, 85) and isColor(1059, 119, 0xbd9158, 85) and isColor(1144, 118, 0xbcb3d5, 85) and isColor(1230, 116, 0x6d6c63, 85)) then
        checkplacetimes = 0;
        return 3.1;--在多人车库
    elseif (isColor(89, 643, 0xffffff, 85) and isColor(335, 645, 0xffffff, 85) and isColor(362, 708, 0x000822, 85) and isColor(1021, 648, 0xffffff, 85) and isColor(1234, 646, 0xffffff, 85) and isColor(1260, 704, 0x000821, 85)) then
        checkplacetimes = 0;
        return 1;--在多人
    elseif (isColor(89, 679, 0xc5fb12, 85) and isColor(246, 680, 0xc3fb12, 85) and isColor(81, 703, 0xc2fb0f, 85) and isColor(253, 700, 0xc3fa12, 85)) then
        checkplacetimes = 0;
        return 5;--在赛事
    elseif (isColor(70, 112, 0xfa0152, 85) and isColor(82, 112, 0xfa0052, 85) and isColor(101, 112, 0xfb0052, 85) and isColor(143, 113, 0xfd0053, 85) and isColor(189, 113, 0xfe0053, 85) and isColor(228, 113, 0xfd0053, 85) and isColor(258, 113, 0xf60051, 85)) then
        checkplacetimes = 0;
        return 6;--在赛事开始界面
    elseif (isColor(628, 370, 0x03b9e4, 85) and isColor(660, 353, 0xfefefe, 85) and isColor(682, 360, 0xffffff, 85) and isColor(712, 364, 0xffffff, 85) and isColor(738, 389, 0xffffff, 85) and isColor(678, 423, 0x02b9e2, 85) and isColor(621, 385, 0x00b9e2, 85)) then
        checkplacetimes = 0;
        return 17;--多人匹配中
    elseif getColor(5, 5) == 0xffffff then
        return -1;--不在大厅，不在多人
    elseif (isColor(160, 4, 0xff0054, 85) and isColor(147, 18, 0xff0054, 85)) then
        checkplacetimes = 0;
        return 2;--游戏结算界面
    elseif (isColor(204, 120, 0x14bde9, 85)) then
        checkplacetimes = 0;
        return 3;--游戏中
    elseif (isColor(60, 26, 0xff0052, 85) and isColor(153, 29, 0xfe0052, 85) and isColor(209, 59, 0xffffff, 85) and isColor(282, 57, 0xffffff, 85) and isColor(355, 65, 0xffffff, 85) and isColor(454, 63, 0xffffff, 85) and isColor(515, 61, 0xffffff, 85) and isColor(629, 45, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 4;--来自Gameloft的礼物,undone
    elseif (isColor(614, 38, 0xf00252, 85) and isColor(636, 39, 0xfa0053, 85) and isColor(682, 36, 0xe30351, 85) and isColor(667, 36, 0xff0054, 85) and isColor(667, 42, 0xff0054, 85) and isColor(698, 41, 0xff0054, 85) and isColor(698, 66, 0xff0054, 85)) then
        checkplacetimes = 0;
        return 7;--领奖开包
    elseif (isColor(1101, 119, 0xff0053, 85) and isColor(1123, 117, 0xff0053, 85) and isColor(1147, 147, 0xff0053, 85) and isColor(1160, 166, 0xff0054, 85) and isColor(1129, 170, 0xfa0052, 85) and isColor(1127, 143, 0xfffeff, 85)) then
        checkplacetimes = 0;
        return 8;--多人联赛奖励界面
    elseif (isColor(616, 208, 0xfbde23, 85) and isColor(625, 224, 0xfec002, 85) and isColor(643, 226, 0xfee53d, 85) and isColor(629, 204, 0xfffef5, 85)) then
        checkplacetimes = 0;
        return 9;--赛车解锁或升星
    elseif (isColor(584, 582, 0xc3fb12, 85) and isColor(774, 587, 0xc3fb11, 85) and isColor(547, 638, 0xc3fb13, 85) and isColor(785, 638, 0xc5fb12, 85) and isColor(806, 650, 0x000b21, 85)) then
        checkplacetimes = 0;
        return 10;--开始的开始
    elseif (isColor(252, 161, 0xfd0055, 85) and isColor(290, 159, 0xfa0051, 85) and isColor(316, 161, 0xfe0055, 85) and isColor(375, 162, 0xf60154, 85) and isColor(414, 161, 0xfc0156, 85) and isColor(42, 652, 0xfb1264, 85) and isColor(43, 696, 0xf91263, 85) and isColor(1111, 663, 0xffffff, 85) and isColor(1260, 668, 0xffffff, 85) and isColor(1284, 712, 0x000521, 85)) then
        checkplacetimes = 0;
        return 11;--段位升级
    elseif (isColor(265, 59, 0xfffefd, 85) and isColor(287, 59, 0xfffffd, 85) and isColor(347, 68, 0xffffff, 85) and isColor(334, 88, 0xffffff, 85) and isColor(337, 268, 0xfefffd, 85) and isColor(459, 245, 0xffffff, 85) and isColor(462, 178, 0xf4feff, 85) and isColor(323, 540, 0xfcffff, 85) and isColor(591, 644, 0xffffff, 85) and isColor(820, 687, 0x030625, 85)) then
        checkplacetimes = 0;
        return 12;--声望升级
    elseif (isColor(184, 218, 0xffffff, 85) and isColor(218, 229, 0xd8d9dc, 85) and isColor(245, 224, 0xe6e7e9, 85) and isColor(266, 225, 0xf9f9f9, 85) and isColor(342, 225, 0xe9e9e9, 85) and isColor(408, 221, 0xcfcfcf, 85) and isColor(935, 228, 0xf2004f, 85) and isColor(991, 225, 0xff0054, 85) and isColor(976, 243, 0xfb0052, 85)) then
        checkplacetimes = 0;
        return 13;--未能连接到服务器,undone
    elseif (isColor(36, 45, 0xff0054, 85) and isColor(26, 260, 0xff0054, 85) and isColor(148, 139, 0xff0054, 85) and isColor(243, 37, 0xff0054, 85) and isColor(269, 272, 0xff0054, 85) and isColor(521, 140, 0xffffff, 85) and isColor(992, 650, 0xc3fb12, 85) and isColor(1114, 705, 0xc2fb13, 85) and isColor(1221, 658, 0xc3fb13, 85) and isColor(1272, 713, 0x000a21, 85)) then
        checkplacetimes = 0;
        return 14;--多人断开连接
    elseif (isColor(525, 185, 0xffffff, 85) and isColor(546, 182, 0xffffff, 85) and isColor(574, 189, 0xffffff, 85) and isColor(591, 190, 0xffffff, 85) and isColor(729, 329, 0xeceef1, 85) and isColor(742, 336, 0xd2d6dd, 85) and isColor(759, 334, 0xffffff, 85) and isColor(788, 336, 0xe4e7eb, 85) and isColor(798, 329, 0xcdd1d9, 85) and isColor(569, 437, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 15;--连接错误,undone
    elseif (isColor(207, 250, 0xffffff, 85) and isColor(222, 250, 0xf3f3f4, 85) and isColor(243, 250, 0xeeeff0, 85) and isColor(252, 250, 0xbbc0c5, 85) and isColor(261, 254, 0xb2b6bc, 85) and isColor(274, 255, 0xe8e9ea, 85) and isColor(291, 255, 0xf3f3f4, 85) and isColor(317, 257, 0xf9f9f9, 85) and isColor(1136, 253, 0xfffafd, 85) and isColor(1138, 253, 0xffffff, 85)) then
        checkplacetimes = 0;
        return 16;--顶号行为
    elseif (isColor(495, 147, 0xff0054, 85) and isColor(525, 149, 0xd4044d, 85) and isColor(538, 148, 0xfd0054, 85) and isColor(564, 145, 0xfd0054, 85) and isColor(585, 150, 0xfd0054, 85) and isColor(604, 146, 0xfd0054, 85) and isColor(608, 145, 0xe80250, 85) and isColor(861, 158, 0xf90052, 85) and isColor(567, 453, 0xc3fb11, 85)) then
        checkplacetimes = 0;
        return 18;--VIP到期,undone
    elseif (isColor(67, 23, 0x664944, 85) and isColor(183, 26, 0x7b4542, 85) and isColor(346, 22, 0x8f7a81, 85) and isColor(495, 27, 0x587bad, 85) and isColor(632, 25, 0x90bee2, 85) and isColor(764, 27, 0x8c7b94, 85) and isColor(892, 29, 0x9c7d84, 85)) then
        return 19;--登录延时,undone
    elseif (isColor(591, 187, 0xfcfcfc, 85) and isColor(605, 187, 0xdfe0e3, 85) and isColor(623, 190, 0xffffff, 85) and isColor(632, 190, 0xfafafb, 85) and isColor(641, 191, 0xffffff, 85) and isColor(651, 191, 0xf5f6f6, 85) and isColor(707, 191, 0xe6e7e9, 85) and isColor(730, 552, 0xffffff, 85) and isColor(761, 569, 0x010722, 85)) then
        checkplacetimes = 0;
        return 21;--段位降级
    elseif (isColor(1117, 103, 0xf0075a, 85) and isColor(1127, 113, 0xfb004c, 85) and isColor(1137, 103, 0xed0457, 85) and isColor(1119, 121, 0xf3005a, 85)) then
        checkplacetimes = 0;
        return 22;--广告弹窗
    end
    mSleep(1000);
end
function backHome_i68()
    --Done
    tap(1300, 30);--返回大厅
    mSleep(2000);
    place = checkPlace_i68();
    if place ~= 0 then
        toast("有内鬼，停止交易", 1)
        return -1;
    end
    return 0;
end
function toPVP_i68()
    toast("进入多人", 1);
    mSleep(4000);
    for i = 1, 10, 1 do
        moveTo(860, 235, 225, 235, 20);--从右往左划
    end
    for i = 1, 3, 1 do
        moveTo(225, 235, 860, 235, 20);--从左往右划
    end
    mSleep(2000);
    --TODO:检查是否在多人入口
    checkAndGetPackage_i68();
    tap(758, 688);
    mSleep(2000);
    place = checkPlace_i68();
    if place ~= 1 then
        toast("有内鬼，停止交易", 1)
        return -1;
    end
    return 0;
end
function getStage_i68()
    --Undone
    if isColor(385, 379, 0xf1cb30, 85) then
        stage = 2;--黄金段位
        --toast("黄金段位",1);
    elseif isColor(385, 379, 0x96b3d3, 85) then
        stage = 1;--白银段位
        --toast("白银段位",1);
    elseif isColor(385, 379, 0xd88560, 85) then
        stage = 0;--青铜段位
        --toast("青铜段位",1);
    elseif isColor(385, 379, 0x9365f8, 85) then
        stage = 3;--白金段位
        --toast("白金段位",1);
    elseif (isColor(320, 309, 0xf5e2a4, 85) and isColor(334, 309, 0xf5e2a4, 85) and isColor(323, 324, 0xf4e1a4, 85) and isColor(334, 323, 0xf5e2a4, 85) and isColor(328, 327, 0xf5e2a4, 85)) then
        stage = 4;--传奇段位
        --toast("传奇段位",1);
    elseif (isColor(322, 308, 0x00bbe8, 85) and isColor(335, 308, 0x00bbe8, 85) and isColor(334, 323, 0x00bbe8, 85) and isColor(320, 321, 0x00bbe8, 85)) then
        stage = -2;--没有段位
        --toast("没有段位",1);
    end
end
function chooseStageCar_i68()
    --done
    virtalstage = 0;
    if lowerCar == "开" then
        virtalstage = stage - 1;
    else
        virtalstage = stage;
    end
    if virtalstage <= 0 then
        tap(900, 100);
    elseif virtalstage == 1 then
        tap(980, 100);
    elseif virtalstage == 2 then
        tap(1060, 100);
    elseif virtalstage == 3 then
        tap(1140, 100);
    elseif virtalstage == 4 then
        tap(1240, 100);
    end
end
function checkTimeOut_i68()
    --done
    if time ~= -1 then
        if (os.time() - time >= timeout * 60) then
            toast("时间到", 1)
            mode = supermode;
            backHome_i68();
        else
            --toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
            --mSleep(1000);
        end
    end
end
function toCarbarn_i68()
    --done
    mSleep(1000);
    getStage_i68();
    mSleep(1000);
    if stage == 4 and PVPatBest == "否" then
        if supermode == "多人刷积分声望" then
            toast("脚本停止", 1);
            return -1;
        elseif supermode == "赛事模式" then
            toast("等待" .. tostring(timeout - (os.time() - time) / 60) .. "分钟后返回", 5);
            for i = 1, timeout * 60 - (os.time() - time), 1 do
                toast(tostring((timeout * 60 - (os.time() - time)) - ((timeout * 60 - (os.time() - time)) % 0.01)) .. "秒后返回赛事", 0.7)
                mSleep(1000);
            end
            mSleep(5 * 60 * 1000);
            checkTimeOut_i68();
            return 0;
        end
    end
    tap(883, 691);--进入车库
end
function chooseCar_i68()
    --done
    mSleep(2500);
    chooseStageCar_i68();
    mSleep(1500);
    if stage == -2 or stage == 0 or stage == -1 then
        for i = 600, 300, -30 do
            tap(i, 270);
        end
    else
        for i = 1325, 1025, -30 do
            tap(i, 270);
        end
    end
    mSleep(3000);
    skip = 1;
    --当车没油、没解锁（不能买），需跳过，没解锁能买时，总是找下一辆车
    while not ((not isColor(1207, 687, 0xffffff, 85)) and (isColor(199, 189, 0xffea3f, 85) or isColor(193, 175, 0xf80555, 85))) or skip == skipcar do
        tap(510, 380);
        mSleep(500);
        skip = skip + 1;
    end
    --检查自动驾驶
    --[[if not ((isColor(1251,  604, 0xa7d056, 85) or isColor(1239,  592, 0xbff613, 85))) then
		toast("开启自动驾驶",1);
		tap(1240,600);
		mSleep(1000);
	end]]--
    tap(1280, 700);
end
function waitBegin_i68()
    --done
    timer = 0;
    while (getColor(204, 122) ~= 0x14bde9 and timer < 35) do
        mSleep(2000);
        timer = timer + 1;
        toast("开局中," .. tostring(timer) .. "/35", 0.5);
        --网络不好没匹配到人被提示，undone
        if (isColor(959, 206, 0xfff8fb, 85) and isColor(980, 228, 0xfffbff, 85) and isColor(959, 226, 0xffffff, 85) and isColor(981, 205, 0xfffeff, 85) and isColor(969, 216, 0xfffeff, 85) and isColor(938, 213, 0xff0053, 85) and isColor(993, 207, 0xff0054, 85) and isColor(981, 238, 0xff0054, 85)) then
            tap(970, 220)
            mSleep(2000);
            return -1;
        end
    end
    if timer >= 45 then
        --如果还在匹配界面且左上有返回
        toast("开局异常", 1);
        if (isColor(632, 383, 0x02b9e3, 85) and isColor(663, 366, 0xffffff, 85) and isColor(678, 367, 0xfeffff, 85) and isColor(699, 360, 0xffffff, 85) and isColor(722, 374, 0xffffff, 85) and isColor(23, 47, 0xffffff, 85) and isColor(87, 15, 0xffffff, 85)) then
            back_i68();
            return -1;
        else
            innerGhost = innerGhost + 1;
            --如果5次timer计时还在开局并且左上角返回键消失
            if innerGhost >= 5 then
                innerGhost = 0;
                restartApp();
            end
            return -1;
        end
    end
end
function autoMobile_i68()
    --done
    toast("接管比赛", 1);
    while (getColor(200, 120) == 0x14bde9) do
        mSleep(500);
        tap(1130, 600);
        mSleep(500)
        if path == "左" then
            moveTo(1300, 235, 1100, 235, 20);--从右往左划
            moveTo(1300, 235, 1100, 235, 20);--从右往左划
        elseif path == "右" then
            moveTo(1100, 235, 1300, 235, 20);--从左往右划
            moveTo(1100, 235, 1300, 235, 20);--从左往右划
        elseif path == "随机" then
            rand = math.random(1, 3);--rand==1 2 or 3
            if rand == 1 then
                moveTo(1300, 235, 1100, 235, 20);--从右往左划
                moveTo(1300, 235, 1100, 235, 20);--从右往左划
            elseif rand == 2 then
                moveTo(1100, 235, 1300, 235, 20);--从左往右划
                moveTo(1100, 235, 1300, 235, 20);--从左往右划
            end
        end
        mSleep(500);
        tap(1130, 600);
    end
    --toast("比赛结束",1);
    if mode == "多人刷积分声望" then
        PVPTimes = PVPTimes + 1;
        log4j(tostring(PVPTimes) .. "_PVP_done");
    elseif mode == "赛事模式" then
        PVETimes = PVETimes + 1;
        log4j(tostring(PVETimes) .. "_PVE_done");
    end
    refreshTable();
end
function backFromLines_i68()
    --done
    --从赛道回到多人界面
    --mSleep(1000);
    color = getColor(140, 20);
    while (color == 0xff0054) do
        tap(1100, 680);
        mSleep(1000);
        color = getColor(115, 25);
    end
    mSleep(5000);
    --toast("比赛完成",1);
    if supermode == "赛事模式" and mode == "多人刷积分声望" then
        checkTimeOut_i68();
    end
end
function checkAndGetPackage_i68()
    --done
    if (isColor(608, 113, 0xf8fbf2, 85) and isColor(623, 118, 0xfcfff4, 85) and isColor(666, 118, 0xfcfff4, 85) and isColor(660, 142, 0xfaffef, 85) and isColor(679, 148, 0xf9feed, 85) and isColor(714, 141, 0xfbfff1, 85) and isColor(736, 157, 0xfaffef, 85)) then
        toast("领取多人包", 1);
        log4j("Open_PVP_pack");
        mSleep(700);
        tap(670, 560);
        receivePrizeAtGame_i68();
        mSleep(10000);
    else
        toast("没有多人包", 1);
    end
    tap(176, 545);--尝试补充多人包
end
function Login_i68()
    --done
    if (isColor(482, 353, 0x333333, 85) and isColor(498, 353, 0x333333, 85) and isColor(517, 353, 0x333333, 85) and isColor(535, 353, 0x333333, 85) and isColor(550, 353, 0x333333, 85) and isColor(568, 352, 0x333333, 85) and isColor(584, 354, 0x333333, 85) and isColor(515, 444, 0xfe8b40, 85) and isColor(769, 444, 0xfe8b40, 85) and isColor(874, 444, 0xfe8b40, 85)) then
        log4j("Login");
        tap(660, 450);
        mSleep(5000)
        return -1;
    else
        if ts.system.udid() == "649a76c95b6e2f89f0eebbb0d5f5621e" then
            dialog(string, time)
            toast("无密码,自动输入", 1);
            log4j("Input_passcode_automatically");
            mSleep(1000);
            tap(490, 350);
            mSleep(1000);
            keypress('1');
            keypress('9');
            keypress('9');
            keypress('7');
            keypress('2');
            keypress('1');
            keypress('7');
            tap(656, 307)
            mSleep(20000);
            return -1;
        else
            toast("无密码,脚本退出", 1);
            log4j("Passcode_not_found,script_terminated");
            mSleep(1000);
            return -2;
        end
    end
end
function toDailyGame_i68()
    --done partly
    toast("进入赛事", 1);
    for i = 1, 10, 1 do
        moveTo(860, 235, 225, 235, 20);--从左往右划
    end
    for i = 1, 4, 1 do
        moveTo(225, 235, 950, 235, 20);--从右往左划，需要改
    end
    mSleep(2000);
    --TODO:检查是否在赛事入口
    tap(547, 686);
    mSleep(2000);
    for i = 1, 4, 1 do
        moveTo(100, 500, 520, 500, 20);--从左往右划
    end
    mSleep(2000);
    return -1;
end
function chooseGame_i68()
    --done
    gamenum = tonumber(gamenum);
    if gamenum <= 7 then
        tap(170 + 200 * (gamenum - 1), 500);
        mSleep(1000);
        tap(170 + 200 * (gamenum - 1), 500);
        mSleep(2000);
        return -1;
    else
        for i = 1, gamenum - 7, 1 do
            moveTo(1250, 500, 1095, 500, 20)
            mSleep(500)
        end
        tap(170 + 200 * 6, 500);
        mSleep(1000);
        tap(170 + 200 * 6, 500);
        mSleep(2000);
        return -1;
    end

end
function gametoCarbarn_i68()
    --done
    tap(1260, 690);
    mSleep(2000);
    if chooseCarorNot == "是" then
        if backifallstar == "是" then
            tap(660, 320);
            mSleep(2500);
            back_i68();
            mSleep(1000);
        end
        if chooseCarorNot == "是" then
            if upordown == "中间上" then
                tap(660, 320);
            elseif upordown == "中间下" then
                tap(660, 462);
            elseif upordown == "右上（被寻车满星时）" then
                for i = 1325, 1000, -30 do
                    tap(i, 320);
                end
            end
        end
    end
    mSleep(2500);
    :: beginAtGame ::
    if (not isColor(1207, 687, 0xffffff, 85)) and (isColor(199, 189, 0xffea3f, 85) or isColor(193, 175, 0xf80555, 85)) then
        --检查自动驾驶
        --[[if not ((isColor(1251,  604, 0xa7d056, 85) or isColor(1239,  592, 0xbff613, 85))) then
			toast("开启自动驾驶",1);
			tap(1240,600);
			mSleep(1000);
		end]]--
        tap(1280, 700);
        mSleep(2000);
        --检查是不是有票
        if (isColor(546, 169, 0xf4f5f6, 85) and isColor(561, 180, 0xffffff, 85) and isColor(561, 192, 0xffffff, 85) and isColor(601, 189, 0xffffff, 85) and isColor(669, 169, 0xfcfcfc, 85) and isColor(1112, 187, 0xff0053, 85) and isColor(1168, 186, 0xff0054, 85) and isColor(1139, 160, 0xff0054, 85) and isColor(1139, 206, 0xfe0054, 85) and isColor(1139, 183, 0xffffff, 85)) then
            toast("没票", 1)
            tap(1140, 180);
            --去多人or生涯
            time = os.time();--记录当前时间
            if switch == "去刷多人" then
                toast(tostring(timeout) .. "分钟后返回", 1)
                mode = "多人刷积分声望"
                backHome_i68();
                return -1;
            elseif switch == "等15分钟" then
                toast("等15分钟", 1)
                mSleep(15 * 60 * 1000);
                toast("15分钟到", 1)
                mSleep(1000);
                goto beginAtGame;
            elseif switch == "等30分钟" then
                toast("等30分钟", 1)
                mSleep(30 * 60 * 1000);
                toast("30分钟到", 1)
                goto beginAtGame;
            end
        end
    else
        if changeCar == "开" then
            tap(510, 380);--向左选车
            goto beginAtGame;
        end
        toast("没油了", 1);
        --去多人or生涯
        time = os.time();--记录当前时间
        if switch == "去刷多人" then
            toast(tostring(timeout) .. "分钟后返回", 1)
            mode = "多人刷积分声望"
            backHome_i68();
            return -1;
        elseif switch == "等待15分钟" then
            toast("等待15分钟", 1)
            mSleep(15 * 60 * 1000);
            toast("15分钟到", 1)
            mSleep(1000);
            goto beginAtGame;
        elseif switch == "等待30分钟" then
            toast("等待30分钟", 1)
            mSleep(30 * 60 * 1000);
            toast("30分钟到", 1)
            goto beginAtGame;
        end
    end
    mSleep(3000)
    if waitBegin_i68() == -1 then
        return -1;
    end
    autoMobile_i68();--接管比赛
    mSleep(2000);
    return -1;
end
function receivePrizeFromGL_i68()
    log4j("Receive_packets_from_GL");
    mSleep(1000);
    tap(1015, 582);
    mSleep(5000);
    tap(569, 582);
    mSleep(2000);
    tap(1015, 582);
    mSleep(2000);
end
function receivePrizeAtGame_i68()
    --done
    mSleep(1000);
    tap(670, 700);
    mSleep(1000);
    tap(1200, 680);
    mSleep(1500);
    return -1;
end
function worker_i68()
    if place == -3 then
        toast("网络未同步", 1);
        state = -1;
    elseif place == 3.1 then
        toast("在多人车库", 1)
        state = -3;
    elseif place == 0 then
        toast("在大厅", 1);
        if mode == "多人刷积分声望" then
            state = toPVP_i68();
        elseif mode == "赛事模式" then
            state = toDailyGame_i68();
        end
    elseif place == 1 then
        toast("在多人", 1);
        if mode == "多人刷积分声望" then
            state = 0;
        elseif mode == "赛事模式" then
            back_i68();
            state = toDailyGame_i68();
        end
    elseif place == -1 then
        toast("不在大厅，不在多人,回到大厅", 1);
        state = backHome_i68();
        if mode == "多人刷积分声望" then
            state = toPVP_i68();
        elseif mode == "赛事模式" then
            state = toDailyGame_i68();
        end
    elseif place == 2 then
        toast("在结算", 1);
        state = -4;
    elseif place == 3 then
        toast("在游戏", 1);
        state = -5;
    elseif place == -2 then
        toast("登录界面", 1);
        state = Login_i68();
    elseif place == 4 then
        toast("奖励界面", 1);
        receivePrizeFromGL_i68();
        state = -1;
    elseif place == 5 then
        toast("在赛事", 1);
        if mode == "赛事模式" then
            state = chooseGame_i68();
            validateGame = true;
        elseif mode == "多人刷积分声望" then
            back_i68();
            state = -1;
        end
    elseif place == 6 then
        toast("赛事开始界面", 1);
        if mode == "赛事模式" then
            if validateGame == false then
                back_i68();
                state = -1;
            elseif validateGame == true then
                state = gametoCarbarn_i68();
            end
        elseif mode == "多人刷积分声望" then
            backHome_i68();
            state = -1;
        end
    elseif place == 7 then
        toast("领奖界面", 1);
        state = receivePrizeAtGame_i68();
    elseif place == 8 then
        toast("多人联赛介绍界面", 1);
        tap(1120, 140);
        mSleep(1000);
        state = -1;
    elseif place == 9 then
        toast("解锁或升星", 1);
        tap(460, 675);
        mSleep(2000);
        state = -1;
    elseif place == 10 then
        toast("开始的开始", 1);
        tap(660, 600);--按下开始
        mSleep(10000);
        state = -1;
    elseif place == 11 then
        toast("段位升级", 1);
        log4j("League_up");
        tap(1175, 680);--继续
        mSleep(2000);
        state = -1;
    elseif place == 12 then
        toast("声望升级", 1);
        log4j("Level_up");
        tap(660, 660);--确定
        mSleep(2000);
        state = -1;
    elseif place == 13 then
        --undone
        toast("未能连接到服务器", 1);
        tap(967, 215);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 14 then
        toast("断开连接", 1);
        tap(1100, 670);--继续
        mSleep(2000);
        state = -1;
    elseif place == 15 then
        --undone
        toast("连接错误", 1);
        tap(569, 437);--重试
        mSleep(2000);
        state = -1;
    elseif place == 16 then
        if receive_starting_command == false then
            --sendEmail(email,"账号被顶,等待"..tostring(timeout2).."分钟",getDeviceName());
            log4j("Parallel_read_detected,waiting " .. tostring(timeout2) .. " minutes");
            toast("账号被顶", 1);
            mSleep(1000);
            toast("等待" .. tostring(timeout2) .. "分钟", 1)
            --[[
		for i= 1,timeout2*1000*60,1 do
			toast(tostring((timeout2*60-i) - ((timeout2*60-i)%0.01)).."秒后重新登录",0.7)
			mSleep(1000);
		end
		]]--
            mSleep(timeout2 * 60 * 1000);
            --sendEmail(email,"账号被顶,等待完成",getDeviceName());
            log4j("Waiting time over");
            toast("等待完成", 1);
        end
        tap(1140, 252);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 17 then
        toast("匹配中", 1);
        state = -6;
    elseif place == 18 then
        --undone
        toast("VIP会员到期", 1);
        tap(883, 150);--关闭
        mSleep(2000);
        state = -1;
    elseif place == 19 then
        LoginTimes = LoginTimes + 1;
        --undone
        if LoginTimes >= 20 then
            toast("登录延时", 1);
            mSleep(1000);
            restartApp();
            LoginTimes = 0;
            state = -1;
        else
            toast("登陆中", 1);
            state = -1;
        end
    elseif place == 20 then
        --undone
        toast("俱乐部人气很旺", 1);
        tap(313, 495);--稍后查看
        mSleep(2000);
        state = -1;
    elseif place == 21 then
        toast("段位降级", 1);
        log4j("League_down");
        tap(660, 550);--稍后查看
        mSleep(1000);
        state = -1;
    elseif place == 22 then
        tap(1127, 113);
        mSleep(500);
        state = -1;
    else
        toast("不知道在哪", 1)
        state = -1;
    end
    receive_starting_command = false;
end
main();