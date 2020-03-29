require "TSLib"
local ts = require("ts");
init(1);
stage=-1;
state=0;
path=0;
checkLvUp=0;
time=-1;
innerGhost=0;
LoginTimes=0;
PVPTimes=0;--多人局数,存文件
PVETimes=0;--赛事局数,存文件
checkplacetimes=0;--连续检测界面次数
validateGame=false;
function ToStringEx(value)
	if type(value)=='table' then
		return TableToStr(value)
	elseif type(value)=='string' then
		return ""..value..""
	else
		return tostring(value)
	end
end
function TableToStr(t)
	if t == nil then return "" end
	local retstr= ""

	local i = 1
	for key,value in pairs(t) do
		local signal = "\n"
		if i==1 then
			signal = ""
		end

		if key == i then
			retstr = retstr..signal..ToStringEx(value)
		else
			if type(key)=='number' or type(key) == 'string' then
				retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
			else
				if type(key)=='userdata' then
					retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
				else
					retstr = retstr..signal..key.."="..ToStringEx(value)
				end
			end
		end

		i = i+1
	end

	retstr = retstr..""
	return retstr
end
function refreshTable()
	table=readFile(userPath().."/res/A9Info.txt") 
	if table then 
		--如果日期不对
		if table[1]~=os.date("%Y%m%d") then
			writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),0,0},"w",1);
			PVPTimes=0;PVETimes=0;
			writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),PVPTimes,PVETimes},"w",1);
		else
			writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),PVPTimes,PVETimes},"w",1);
		end
	else
		--没有文件就创建文件，初始化内容
		writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),0,0},"w",1);
	end
end
function initTable()
	table=readFile(userPath().."/res/A9Info.txt")
	logtxt=readFile(userPath().."/res/A9log.txt")
	if table then 
		--如果日期不对，数据重写
		if table[1]~=os.date("%Y%m%d") then
			--文件重写
			writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),0,0},"w",1);
			initTable();
		else
			PVPTimes=table[2];
			PVETimes=table[3];
		end
	else
		--没有文件就创建文件，初始化内容
		writeFile(userPath().."/res/A9Info.txt",{os.date("%Y%m%d"),0,0},"w",1);
		mSleep(1000);
		initTable();--每次初始化内容都要再运行initTable()检查
	end
	if logtxt then 
		if logtxt[1]~=os.date("%Y%m%d") then
			--如果日期不对,发邮件，数据重写
			sendEmail(email,"[A9]"..os.date("%m%d%H").."日志"..getDeviceName(),logtxt);
			writeFile(userPath().."/res/A9log.txt",{os.date("%Y%m%d")},"w",1);
			mSleep(1000);
			initTable();--每次初始化内容都要再运行initTable()检查
		else
			--啥都不干
		end
	else
		--没有文件就创建文件，初始化内容
		writeFile(userPath().."/res/A9log.txt",{os.date("%Y%m%d")},"w",1);
		mSleep(1000);
		initTable();--每次初始化内容都要再运行initTable()检查
	end
end
function log4j(content)
	table=readFile(userPath().."/res/A9log.txt")
	if table then 
		--如果日期不对,发邮件，数据重写
		if table[1]~=os.date("%Y%m%d") then
			initTable();
		else
			writeFile(userPath().."/res/A9log.txt",{"["..os.date("%H%M%S").."]"..content},"a",1);
		end
	else
		--没有文件就创建文件，初始化内容,再写入内容
		initTable();
		log4j(content);
	end
end
function sendEmail(reciver,topic,content)
	if reciver=="" then 
		toast("未指定邮箱",1);
		return 0;
	end
	if type(content)=='table' then
		content=TableToStr(content);
	end
	status = ts.smtp(reciver,topic,content,"smtp.qq.com","yourqq@qq.com","授权码");
	if (status) then           
		toast("邮件发送成功",1);
		mSleep(1000);
	else
		toast("邮件发送失败",1);
		mSleep(10000)
	end
end
function ShowUI()
	w,h = getScreenSize()
	UINew(2,"第1页,第2页","确定","取消","uiconfig.dat",1,120,w,h,"255,255,255","255,255,255","","dot",1);
	UILabel(1,"狂野飙车9国服iOS脚本",15,"center","38,38,38");
	UILabel(1,"模式选择",15,"left","38,38,38");
	UIRadio(1,"mode","多人刷积分声望,赛事模式","0");--记录最初设置
	UILabel(1,"没油没票后动作（赛事模式）",15,"left","38,38,38");
	UIRadio(1,"switch","去刷多人,等15分钟,等30分钟","0");
	UILabel(1,"路线选择（所有模式）",15,"left","38,38,38");
	UIRadio(1,"path","左,中,右,随机","0");
	UILabel(1,"赛事位置选择",15,"left","38,38,38");
	UIRadio(1,"gamenum","1,2,3,4,5,6,7,8,9,10,11","0");
	UILabel(1,"赛事是否选车",15,"left","38,38,38");
	UIRadio(1,"chooseCarorNot","是,否","0");
	UILabel(1,"赛事用车位置选择（赛事模式）",15,"left","38,38,38");
	UIRadio(1,"upordown","中间上,中间下","0");
	UILabel(1,"赛事选车是否返回一次（被寻车满星时）",15,"left","38,38,38");
	UIRadio(1,"backifallstar","是,否","0");
	UILabel(1,"传奇是否刷多人",15,"left","38,38,38");
	UIRadio(1,"PVPatBest","是,否","0");
	UILabel(1,"节能模式",15,"left","38,38,38");
	UIRadio(1,"savePower","开,关","0");
	UILabel(1,"多人选低一段车辆（白金及以上）",15,"left","38,38,38");
	UIRadio(1,"lowerCar","开,关","0");
	UILabel(1,"需要过多久返回赛事模式或寻车模式（分钟）",15,"left","38,38,38");
	UIEdit(1,"timeout","内容","60",15,"center","38,38,38","number");
	UILabel(1,"多人跳车（填0不跳）",15,"left","38,38,38");
	UIEdit(1,"skipcar","内容","0",15,"center","38,38,38","number");
	UILabel(1,"顶号重连（分钟）",15,"left","38,38,38");
	UIEdit(1,"timeout2","内容","30",15,"center","38,38,38","number");
	UILabel(1,"接收日志的邮箱",15,"left","38,38,38");
	UIEdit(1,"email","邮箱地址","",15,"left","38,38,38","default");
	UILabel(1,"详细说明请向左滑查看第二页",20,"left","255,30,2");
	UILabel(2,"刷赛事模式需要先用所需车辆手动完成一局再启动脚本。",15,"left","255,30,2")
	UILabel(2,"多人刷积分声望:脚本自动刷多人获得声望。",15,"left","38,38,38")
	UILabel(2,"脚本运行前需手动开启自动驾驶。",15,"left","38,38,38")
	UILabel(2,"没油没票后动作:刷赛事用完油和票之后的动作，选择去刷多人会在指定时间后返回。",15,"left","38,38,38")
	UILabel(2,"赛事位置选择:选择刷第几个赛事。",15,"left","38,38,38")
	UILabel(2,"赛事是否选车:有些赛事为指定车辆，无法从车库选车。",15,"left","38,38,38")
	UILabel(2,"寻车赛事用车位置选择:赛事选车时游戏会自动跳到上局此赛事所用车辆，需要选择上还是下。",15,"left","38,38,38")
	UILabel(2,"多人跳车:避免赛事所需车的燃油在多人中消耗，可以指定跳过车辆。",15,"left","38,38,38")
	UILabel(2,"接收日志的邮箱：每日日志会在次日脚本运行之初发送至此邮箱。",15,"left","38,38,38")
	UILabel(2,"如果有脚本无法识别的界面，请联系QQ群1028746490群主。如果需要购买脚本授权码也请联系上述QQ群群主。",20,"left","38,38,38")
	UIShow();
end
function keypress(key)
	keyDown(key);
	keyUp(key);
end
function restartApp()
	log4j("游戏重启");
	closeApp("com.Aligames.kybc9");--关闭游戏
	mSleep(5000);
	runApp("com.Aligames.kybc9");--打开游戏
	mSleep(5000);
end
function back_SE()
	toast("后退",1)
	tap(30,30)
	mSleep(1500)
end
function checkPlace_SE()
	if checkplacetimes > 2 then
		toast("检测界面,"..tostring(checkplacetimes).."/25",1);
	end
	if (isColor( 688,  391, 0xfe8b40, 85) and  isColor( 395,  392, 0xfe8b40, 85) and isColor( 479,  399, 0xfe8b40, 85) and isColor( 494,  371, 0xfe8b40, 85) and isColor( 787,  420, 0xfe8b40, 85) and isColor( 819,  366, 0xfe8b40, 85)) then
		return -2;--在登录界面
	elseif (isColor( 419,  137, 0xffffff, 85) and isColor( 455,  134, 0xffffff, 85) and isColor( 573,  137, 0xffffff, 85) and isColor( 573,  158, 0xffffff, 85) and isColor( 602,  136, 0xffffff, 85) and isColor( 636,  133, 0xffffff, 85) and isColor( 659,  134, 0xffffff, 85) and isColor( 683,  140, 0xffffff, 85) and isColor( 442,  515, 0x000721, 85) and isColor( 190,  518, 0xffffff, 85)) then
		return 20;--俱乐部新人
	end
	if (isColor( 437,  570, 0x9f0942, 85) and isColor( 452,  569, 0x9f0943, 85) and isColor( 451,  584, 0x9f0942, 85) and isColor( 444,  577, 0x9f0942, 85)) then
		return -3;--网络未同步
	end
	if (isColor(  92,  129, 0xf00252, 85) and isColor(  97,  129, 0xf20252, 85) and isColor( 104,  129, 0xf50153, 85) and isColor( 116,  130, 0xea0352, 85) and isColor( 128,  127, 0xf1014b, 85) and isColor( 158,  128, 0xdb0244, 85) and isColor( 761,   96, 0xd9d6d6, 85) and isColor( 827,  101, 0x3887d7, 85) and isColor( 906,  101, 0x4e443b, 85) and isColor( 971,  100, 0x9015fb, 85)) then
		return 3.1;--在多人车库
	end
	if getColor(5, 5) == 0x101f3b then
		return 0;--在大厅
	end
	if multiColor({{100,560,0xffffff},{270,570,0xffffff},{860,560,0xffffff},{1060,560,0xffffff}},90,false) == true then
		return 1;--在多人
	end
	if (isColor( 115,  625, 0xc3fb12, 85) or isColor( 301,  625, 0xc3fb12, 85) or isColor( 469,  625, 0xc3fb12, 85)) then
		return 5;--在赛事
	end
	if (isColor( 216,   96, 0xe6004d, 85) and isColor( 139,   96, 0xfc0053, 85) and isColor(  60,   95, 0xf00251, 85) and isColor( 221,  176, 0xffffff, 85) and isColor(  60,  161, 0xff0054, 85)) then
		return 6;--在赛事开始界面
	end
	if (isColor( 540,  312, 0x01b9e3, 85) and isColor( 635,  307, 0x01b8e3, 85) and isColor( 596,  273, 0x01718b, 85) and isColor( 581,  350, 0x03b9e3, 85) and isColor( 564,  308, 0xffffff, 85) and isColor( 609,  310, 0xffffff, 85) and isColor( 658,  314, 0xffffff, 85) and isColor( 682,  291, 0xdfdfdf, 85)) then
		return 17;--多人匹配中
	end
	if getColor(5, 5) == 0xffffff then
		return -1;--不在大厅，不在多人
	end
	if getColor(115,25) == 0xff0054 then
		return 2;--游戏结算界面
	end
	if getColor(170,100) == 0x14bde9 then
		return 3;--游戏中
	end
	if (isColor(  60,   26, 0xff0052, 85) and isColor( 153,   29, 0xfe0052, 85) and isColor( 209,   59, 0xffffff, 85) and isColor( 282,   57, 0xffffff, 85) and isColor( 355,   65, 0xffffff, 85) and isColor( 454,   63, 0xffffff, 85) and isColor( 515,   61, 0xffffff, 85) and isColor( 629,   45, 0xffffff, 85)) then
		return 4;--来自Gameloft的礼物
	end
	if (isColor( 525,   33, 0xff0054, 85) and isColor( 536,   33, 0xff0054, 85) and isColor( 531,   41, 0xff0054, 85) and isColor( 529,   52, 0xff0054, 85) and isColor( 568,   33, 0xff0054, 85) and isColor( 568,   44, 0xbe064c, 85) and isColor( 567,   53, 0xc6054c, 85) and isColor( 490,   81, 0xdadce0, 85) and isColor( 556,   87, 0xe4e6e8, 85) and isColor( 631,   85, 0xe6e8ea, 85)) then
		return 7;--领奖开包
	elseif (isColor( 211,  328, 0xe77423, 85) and isColor( 366,  321, 0x4299e1, 85) and isColor( 511,  310, 0xd8a200, 85) and isColor( 657,  303, 0x5c17db, 85) and isColor( 825,  289, 0x545454, 85) and isColor( 960,  123, 0xfffeff, 85)) then
		return 8;--多人联赛奖励界面
	elseif (isColor( 597,   52, 0xff0054, 85) and isColor( 596,   63, 0xff0054, 85) and isColor( 523,   55, 0xff0054, 85) and isColor( 535,   55, 0xff0054, 85) and isColor( 567,   54, 0xff0054, 85) and isColor( 557,   70, 0xff0054, 85) and isColor( 254,  552, 0xffffff, 85) and isColor( 522,  557, 0xffffff, 85) and isColor( 250,  592, 0xffffff, 85) and isColor( 526,  591, 0xffffff, 85)) then
		return 9;--赛车解锁或升星
	elseif (isColor( 523,  350, 0xcb0042, 85) and isColor( 610,  350, 0xcc0042, 85) and isColor( 610,  435, 0xcc0042, 85) and isColor( 568,  460, 0xcd0042, 85) and isColor( 525,  436, 0xcc0042, 85) and isColor( 544,  422, 0xd9d9d9, 85) and isColor( 568,  439, 0xcecece, 85) and isColor( 591,  426, 0xd6d6d6, 85) and isColor( 592,  396, 0xececec, 85) and isColor( 592,  371, 0xfafafa, 85)) then
		return 10;--开始的开始
	elseif (isColor(  35,  555, 0xfb1264, 85) and isColor(  35,  602, 0xfb1264, 85) and isColor( 223,  136, 0xfa0153, 85) and isColor( 349,  137, 0xfe0055, 85) and isColor( 938,  569, 0xffffff, 85) and isColor(1070,  569, 0xffffff, 85) and isColor( 935,  602, 0xffffff, 85) and isColor(1076,  601, 0xffffff, 85)) then
		return 11;--段位升级
	elseif (isColor( 222,   50, 0xffffff, 85) and isColor( 301,   53, 0xffffff, 85) and isColor( 196,   85, 0xffffff, 85) and isColor( 277,   84, 0xffffff, 85) and isColor( 333,  298, 0xffffff, 85) and isColor( 392,  297, 0xffffff, 85) and isColor( 456,  300, 0xffffff, 85) and isColor( 394,  212, 0xffffff, 85) and isColor( 293,  237, 0xffffff, 85) and isColor( 494,  235, 0xffffff, 85)) then
		return 12;--声望升级
	elseif (isColor( 184,  218, 0xffffff, 85) and isColor( 218,  229, 0xd8d9dc, 85) and isColor( 245,  224, 0xe6e7e9, 85) and isColor( 266,  225, 0xf9f9f9, 85) and isColor( 342,  225, 0xe9e9e9, 85) and isColor( 408,  221, 0xcfcfcf, 85) and isColor( 935,  228, 0xf2004f, 85) and isColor( 991,  225, 0xff0054, 85) and isColor( 976,  243, 0xfb0052, 85)) then
		return 13;--未能连接到服务器
	elseif (isColor(  26,   24, 0xff0054, 85) and isColor( 234,   20, 0xff0054, 85) and isColor(  29,  212, 0xff0054, 85) and isColor( 195,  120, 0xffffff, 85) and isColor( 441,  127, 0xffffff, 85) and isColor(  15,  103, 0x061724, 85) and isColor( 845,  559, 0xc3fb13, 85) and isColor(1035,  559, 0xc2fb12, 85) and isColor( 945,  603, 0xc3fb13, 85)) then
		return 14;--多人断开连接
	elseif (isColor( 525,  185, 0xffffff, 85) and isColor( 546,  182, 0xffffff, 85) and isColor( 574,  189, 0xffffff, 85) and isColor( 591,  190, 0xffffff, 85) and isColor( 729,  329, 0xeceef1, 85) and isColor( 742,  336, 0xd2d6dd, 85) and isColor( 759,  334, 0xffffff, 85) and isColor( 788,  336, 0xe4e7eb, 85) and isColor( 798,  329, 0xcdd1d9, 85) and isColor( 569,  437, 0xffffff, 85)) then
		return 15;--连接错误
	elseif (isColor( 176,  214, 0xffffff, 85) and isColor( 269,  217, 0xecedee, 85) and isColor( 326,  217, 0x999da4, 85) and isColor( 342,  211, 0xbdc0c4, 85) and isColor( 352,  221, 0xe7e7e7, 85) and isColor( 395,  221, 0xd7d7d7, 85) and isColor( 409,  221, 0xcececf, 85) and isColor( 555,  352, 0xe5eaf0, 85) and isColor( 951,  217, 0xff0054, 85) and isColor( 993,  221, 0xff0054, 85)) then
		return 16;--顶号行为
	elseif (isColor( 495,  147, 0xff0054, 85) and isColor( 525,  149, 0xd4044d, 85) and isColor( 538,  148, 0xfd0054, 85) and isColor( 564,  145, 0xfd0054, 85) and isColor( 585,  150, 0xfd0054, 85) and isColor( 604,  146, 0xfd0054, 85) and isColor( 608,  145, 0xe80250, 85) and isColor( 861,  158, 0xf90052, 85) and isColor( 567,  453, 0xc3fb11, 85)) then
		return 18;--VIP到期
	elseif (isColor(  67,   23, 0x664944, 85) and isColor( 183,   26, 0x7b4542, 85) and isColor( 346,   22, 0x8f7a81, 85) and isColor( 495,   27, 0x587bad, 85) and isColor( 632,   25, 0x90bee2, 85) and isColor( 764,   27, 0x8c7b94, 85) and isColor( 892,   29, 0x9c7d84, 85)) then
		return 19;--登录延时
	elseif (isColor( 506,  152, 0xf3f4f5, 85) and isColor( 542,  162, 0xfbfbfb, 85) and isColor( 560,  162, 0xe8eaec, 85) and isColor( 573,  161, 0xffffff, 85) and isColor( 612,  162, 0xffffff, 85) and isColor( 508,  464, 0xffffff, 85) and isColor( 619,  457, 0xffffff, 85) and isColor( 647,  486, 0x020922, 85)) then
		return 21;--段位降低
	elseif (isColor(  19,   21, 0xff0054, 85) and isColor( 223,   17, 0xff0054, 85) and isColor(  18,  235, 0xff0054, 85) and isColor( 231,  241, 0xff0054, 85) and isColor( 178,  155, 0xffffff, 85) and isColor( 409,  157, 0xffffff, 85) and isColor( 454,  131, 0xffffff, 85) and isColor(1017,  562, 0xc3fb12, 85) and isColor(1074,  593, 0xc3fb11, 85) and isColor(1085,  607, 0x000b1f, 85)) then
		return 22;--失去资格
	end
	mSleep(1000);
end
function backHome_SE()
	tap(1100, 20);--返回大厅
	mSleep(2000);
	place=checkPlace_SE();
	if place ~= 0 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function toPVP_SE()
	toast("进入多人",1); 
	if (isColor( 741,  538, 0xfc0050, 85) and isColor( 742,  541, 0xed0150, 85)) then
		goto PVP;
	end
	for i=1,10,1 do
		moveTo(860,235,225,235,20);--从右往左划
		if (isColor(1116,  539, 0xdc014a, 85) and isColor(1116,  538, 0xda0147, 85)) then
			break;
		end
	end
	for i=1,2,1 do
		moveTo(225,235,860,235,20);--从左往右划
	end
	mSleep(2000);
	--TODO:检查是否在多人入口
	::PVP::checkAndGetPackage_SE();
	tap(660,600);
	mSleep(1500);
	place=checkPlace_SE();
	if place ~= 1 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function getStage_SE()
	color=getColor(328,316);
	if color == 0xf1cb30 then
		stage=2;--黄金段位
		toast("黄金段位",1);
	elseif color == 0x96b2d4 then
		stage=1;--白银段位
		toast("白银段位",1);
	elseif color == 0xd88560 then
		stage=0;--青铜段位
		toast("青铜段位",1);
	elseif color == 0x9365f8 then
		stage=3;--白金段位
		toast("白金段位",1);
	elseif (isColor( 320,  309, 0xf5e2a4, 85) and isColor( 334,  309, 0xf5e2a4, 85) and isColor( 323,  324, 0xf4e1a4, 85) and isColor( 334,  323, 0xf5e2a4, 85) and isColor( 328,  327, 0xf5e2a4, 85)) then
		stage=4;--传奇段位
		toast("传奇段位",1);
	elseif (isColor( 322,  308, 0x00bbe8, 85) and isColor( 335,  308, 0x00bbe8, 85) and isColor( 334,  323, 0x00bbe8, 85) and isColor( 320,  321, 0x00bbe8, 85)) then
		stage=-2;--没有段位
		toast("没有段位",1);
	end
end
function chooseStageCar_SE()
	virtalstage=0;
	if lowerCar == "开" then
		virtalstage=stage - 1;
	else virtalstage=stage;
	end
	if virtalstage <= 0 then
		tap(760,100);
	elseif virtalstage == 1 then
		tap(830,100);
	elseif virtalstage == 2 then
		tap(900,100);
	elseif virtalstage == 3 then
		tap(975,100);
	elseif virtalstage == 4 then
		tap(1050,100);
	end
end
function checkTimeOut_SE()
	if time ~= -1 then 
		if(os.time()-time>=timeout*60) then
			toast("时间到",1)
			mode=supermode;
			backHome_SE();
		else 
			toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
			mSleep(1000);
		end
	end
end
function toCarbarn_SE()
	mSleep(1000);
	getStage_SE();
	mSleep(1000);
	if stage == 4 and PVPatBest == "否" then
		if supermode == "多人刷积分声望" then
			toast("脚本停止",1);
			return -1;
		elseif supermode == "赛事模式" then
			toast("等待"..tostring(timeout-(os.time()-time)/60).."分钟后返回",5);
			for i= 1,timeout*60-(os.time()-time),1 do
				toast(tostring((timeout*60-(os.time()-time)) - ((timeout*60-(os.time()-time))%0.01)).."秒后返回赛事",0.7)
				mSleep(1000);
			end
			mSleep(5*60*1000);
			checkTimeOut_SE();
			return 0;
		end
	end
	tap(500,580);--进入车库
end
function chooseCar_SE()
	mSleep(2500);
	chooseStageCar_SE();
	mSleep(2000);
	if stage == -2 or stage == 0 or stage == -1 then
		for i=800,450,-30 do
			tap(i,270);
		end
	else
		for i=1100,900,-30 do
			tap(i,270);
		end
	end
	mSleep(3000);
	skip=1;
	while getColor(1090,570) == 0xffffff or skip==skipcar or (isColor( 167,  160, 0x797979, 85) and isColor( 172,  161, 0x797979, 85) and isColor( 169,  156, 0x797979, 85)) do
		tap(440,320);
		mSleep(500);
		skip=skip+1;
	end

	--检查自动驾驶
	if (isColor(1058,  508, 0xfc0001, 85) and isColor(1053,  508, 0xef0103, 85) and isColor(1065,  508, 0xef0103, 85) and isColor(1057,  515, 0xff0000, 85) and isColor(1047,  523, 0xf00103, 85) and isColor(1062,  521, 0xe60205, 85)) then
		toast("开启自动驾驶",1);
		tap(1060,510);
		mSleep(1000);
	end
	tap(1090,570);
end
function waitBegin_SE()
	timer=0;
	while (getColor(170,100) ~= 0x14bde9 and timer<45) do
		mSleep(2000);
		timer=timer+1;
		toast("开局中,"..tostring(timer).."/45",0.5);
		if (isColor( 959,  206, 0xfff8fb, 85) and isColor( 980,  228, 0xfffbff, 85) and isColor( 959,  226, 0xffffff, 85) and isColor( 981,  205, 0xfffeff, 85) and isColor( 969,  216, 0xfffeff, 85) and isColor( 938,  213, 0xff0053, 85) and isColor( 993,  207, 0xff0054, 85) and isColor( 981,  238, 0xff0054, 85)) then
			tap(970,220)
			mSleep(2000);
			return -1;
		end
	end
	if timer>=45 then
		if (isColor( 540,  312, 0x01b9e3, 85) and isColor( 635,  307, 0x01b8e3, 85) and isColor( 596,  273, 0x01718b, 85) and isColor( 581,  350, 0x03b9e3, 85) and isColor( 564,  308, 0xffffff, 85) and isColor( 658,  314, 0xffffff, 85) and isColor( 682,  291, 0xdfdfdf, 85) and isColor(  17,   50, 0xffffff, 85) and isColor(  70,   14, 0xffffff, 85)) then
			toast("有内鬼，停止交易",1);
			back_SE();
			return -1;
		else 
			innerGhost=innerGhost+1;
			toast("有内鬼，停止交易",1);
			--如果5次timer计时还在开局并且左上角返回键消失
			if innerGhost >= 5 then
				innerGhost=0;
				restartApp();
			end
			return -1;
		end
	end
end
function autoMobile_SE()
	toast("接管比赛",1);
	while (getColor(170,100) == 0x14bde9) do
		mSleep(500);
		tap(950,400);
		mSleep(500)
		if path == "左" then 
			moveTo(800,235,400,235,20);--从右往左划
			moveTo(800,235,400,235,20);--从右往左划
		elseif path == "右" then 
			moveTo(600,235,800,235,20);--从左往右划
			moveTo(600,235,800,235,20);--从左往右划
		elseif path == "随机" then
			rand=math.random(1,3);--rand==1 2 or 3
			if rand == 1 then
				moveTo(800,235,400,235,20);--从右往左划
				moveTo(800,235,400,235,20);--从右往左划
			elseif rand == 2 then
				moveTo(600,235,800,235,20);--从左往右划
				moveTo(600,235,800,235,20);--从左往右划
			end
		end
		mSleep(500);
		tap(950,400);
	end
	toast("比赛结束",1);
end
function backFromLines_SE()
	--从赛道回到多人界面
	mSleep(4000);
	color=getColor(115,25);
	while (color == 0xff0054) do
		tap(1000,580);
		mSleep(1500);
		color=getColor(115,25);
	end
	mSleep(2000);
	toast("比赛完成",1);
	if mode == "多人刷积分声望" then
		PVPTimes=PVPTimes+1;
		log4j("完成"..tostring(PVPTimes).."局多人");
	elseif mode == "赛事模式" then
		PVETimes=PVETimes+1;
		log4j("完成"..tostring(PVETimes).."局赛事");
	end
	refreshTable();
	if supermode == "赛事模式" then 
		checkTimeOut_SE();
	end
end
function checkAndGetPackage_SE()
	if (not isColor( 649,  472, 0x091624, 85)) then
		toast("领取多人包",1);
		log4j("领取多人包");
		mSleep(700);
		tap(570,470);
		mSleep(2000);
		tap(500,600);
		mSleep(2000);
		tap(1030,590);
		mSleep(10000);
	end
	if ((isColor( 178,  503, 0xb9e816, 85) and isColor( 173,  500, 0xbae916, 85) and isColor( 175,  506, 0xc3fb12, 85) and isColor( 147,  506, 0xbba7bb, 85) and isColor( 128,  508, 0xe5dde5, 85) and isColor( 127,  500, 0xfdfcfd, 85)) and not(isColor(  80,  453, 0x1d071e, 85) and isColor( 211,  455, 0x241228, 85) and isColor(  84,  473, 0x241128, 85) and isColor( 201,  472, 0x221226, 85) and isColor( 228,  482, 0x676769, 85))) then
		log4j("补充多人包");
		tap(153,462);
		mSleep(1000);
	end
end
function Login_SE()
	if (isColor( 521,  298, 0x333333, 85) and isColor( 502,  298, 0x333333, 85) and isColor( 487,  298, 0x333333, 85) and isColor( 469,  297, 0x333333, 85) and isColor( 452,  298, 0x333333, 85) and isColor( 435,  297, 0x333333, 85) and isColor( 418,  297, 0x333333, 85) and isColor( 399,  296, 0x333333, 85) and isColor( 385,  296, 0x333333, 85)) then
		log4j("登录游戏");
		tap(559,397);
		mSleep(2000)
		return -1;
	else 
		if ts.system.udid() == "yourudid" then
			toast("无密码,自动输入",1);
			log4j("自动输入密码");
			mSleep(1000);
			tap(380,300);
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
			tap(580,257)
			mSleep(20000);
			return -1;
		else
			toast("无密码,脚本退出",1);
			log4j("无密码,脚本退出");
			mSleep(1000);
			return -2;
		end
	end
end
function toDailyGame_SE()
	toast("进入赛事",1); 
	if (isColor( 555,  537, 0xf9004b, 85) and isColor( 556,  540, 0xfe0054, 85)) then
		tap(929,474);
		goto DailyGame;
	end
	for i=1,10,1 do
		moveTo(860,235,225,235,20);--从右往左划
		if (isColor(1116,  539, 0xdc014a, 85) and isColor(1116,  538, 0xda0147, 85)) then
			break;
		end
	end
	for i=1,4,1 do
		moveTo(225,235,860,235,20);--从左往右划
	end
	mSleep(1000);
	--TODO:检查是否在赛事入口
	::DailyGame::tap(469,589);
	mSleep(2000);
	for i=1,4,1 do
		moveTo(100,500,520,500,20);--从左往右划
	end
	mSleep(2000);
	return -1;
end
function chooseGame_SE()
	gamenum=tonumber(gamenum);
	if gamenum<=7 then
		tap(138+160*(gamenum-1),500);
		mSleep(1000);
		tap(138+160*(gamenum-1),500);
		mSleep(2000);
		return -1;
	else 
		for i = 1,gamenum - 7,1 do
			moveTo(610,500,470,500,20)
			mSleep(500)
		end
		tap(138+160*6,500);
		mSleep(1000);
		tap(138+160*6,500);
		mSleep(2000);
		return -1;
	end

end
function gametoCarbarn_SE()
	tap(1065,590);
	mSleep(2000);
	if chooseCarorNot == "是" then
		tap(580,270);
		if backifallstar == "是" then
			mSleep(2000);
			back_SE();
			mSleep(1000);
			if chooseCarorNot == "是" then
				if upordown == "中间上" then
					tap(580,270);
				elseif upordown == "中间下" then
					tap(580,480);
				end
			end
		end
	end
	mSleep(2000);
	::beginAtGame::	if ((((isColor(1041,  557, 0xc7fb24, 85) and isColor( 849,  561, 0xc8fb25, 85) and isColor( 849,  598, 0xc8fb25, 85) and isColor(1074,  601, 0xc7fb23, 85))) or (isColor( 938,  551, 0xc4fb11, 85) and isColor(1093,  555, 0xc2fb12, 85) and isColor(1086,  603, 0xc2fb11, 85) and isColor( 928,  605, 0xc4fb16, 85)))) and not (isColor( 167,  160, 0x797979, 85) and isColor( 172,  161, 0x797979, 85) and isColor( 169,  156, 0x797979, 85)) then
		--检查自动驾驶
		if (isColor(1058,  508, 0xfc0001, 85) and isColor(1053,  508, 0xef0103, 85) and isColor(1065,  508, 0xef0103, 85) and isColor(1057,  515, 0xff0000, 85) and isColor(1047,  523, 0xf00103, 85) and isColor(1062,  521, 0xe60205, 85)) then
			toast("开启自动驾驶",1);
			tap(1060,510);
			mSleep(1000);
		end
		tap(958,574);
		mSleep(2000);
		--检查是不是有票
		if (isColor( 257,  448, 0xc3fb12, 85) and isColor( 508,  453, 0xc3fb12, 85) and isColor( 250,  488, 0xc2fb12, 85) and isColor( 509,  492, 0xc4fb12, 85)) then
			toast("没票",1)
			tap(970,160);
			--去多人or生涯
			time=os.time();--记录当前时间
			if switch == "去刷多人" then
				toast(tostring(timeout).."分钟后返回",1)
				mode="多人刷积分声望"
				backHome_SE();
				return -1;
			elseif switch == "等待15分钟" then
				toast("等待15分钟",1)
				mSleep(15*60*1000);
				toast("15分钟到",1)
				mSleep(1000);
				goto beginAtGame;
			elseif switch == "等待30分钟" then
				toast("等待30分钟",1)
				mSleep(30*60*1000);
				toast("30分钟到",1)
				goto beginAtGame;
			end
		end
	else 
		toast("没油了",1);
		--去多人or生涯
		time=os.time();--记录当前时间
		if switch == "去刷多人" then
			toast(tostring(timeout).."分钟后返回",1)
			mode="多人刷积分声望"
			backHome_SE();
			return -1;
		elseif switch == "等待15分钟" then
			toast("等待15分钟",1)
			mSleep(15*60*1000);
			toast("15分钟到",1)
			mSleep(1000);
			goto beginAtGame;
		elseif switch == "等待30分钟" then
			toast("等待30分钟",1)
			mSleep(30*60*1000);
			toast("30分钟到",1)
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
	sendEmail(email,"领取来自GameLoft的礼物",getDeviceName());
	mSleep(1000);
	tap(1015,582);
	mSleep(5000);
	tap(569,582);
	mSleep(2000);
	tap(1015,582);
	mSleep(2000);
end
function receivePrizeAtGame_SE()
	mSleep(1000);
	tap(550,590);
	mSleep(1000);
	tap(1020,585);
	mSleep(1500);
	return -1;
end
function worker_SE()
	if place == -3 then
		toast("网络未同步",1);
		mSleep(1000);
		state=-1;
	elseif place == 3.1 then
		toast("在多人车库",1)
		mSleep(1000);
		state=-3;
	elseif place == 0 then
		toast("在大厅",1);
		if mode == "多人刷积分声望" then 
			state=toPVP_SE();
		elseif mode == "赛事模式" then
			state=toDailyGame_SE();
		end
	elseif place == 1 then
		toast("在多人",1);
		if mode == "多人刷积分声望" then 
			state=0;
		elseif mode == "赛事模式" then
			back_SE();
			state=toDailyGame_SE();
		end
	elseif place == -1 then
		toast("不在大厅，不在多人，回到大厅",1);
		state=backHome_SE();
		if mode == "多人刷积分声望" then 
			state=toPVP_SE();
		elseif mode == "赛事模式" then
			state=toDailyGame_SE();
		end
	elseif place == 2 then
		toast("在结算",1);
		state=-4;
	elseif place == 3 then
		toast("在游戏",1);
		state=-5;
	elseif place == -2 then
		toast("登录界面",1);
		state=Login_SE();
	elseif place == 4 then
		toast("奖励界面",1);
		receivePrizeFromGL_SE();
		state=-1;
	elseif place == 5 then
		if mode == "赛事模式" then 
			state=chooseGame_SE();
			validateGame=true;
		elseif mode == "多人刷积分声望" then 
			back_SE();
			state=-1;
		end
	elseif place == 6 then
		toast("赛事开始界面",1);
		mSleep(1000);
		if mode == "赛事模式" then 
			if validateGame == false then
				back_SE();
				mSleep(1000)
				state=-1;
			elseif validateGame == true then
				state=gametoCarbarn_SE();
			end
		elseif mode == "多人刷积分声望" then 
			backHome_SE();
			state=-1;
		end
	elseif place == 7 then
		toast("领奖界面",1);
		state=receivePrizeAtGame_SE();
	elseif place == 8 then
		toast("多人联赛介绍界面",1);
		tap(960,120);
		mSleep(1000);
		state=-1;
	elseif place == 9 then
		toast("解锁或升星",1);
		tap(390,570);
		mSleep(2000);
		state=-1;
	elseif place == 10 then
		toast("开始的开始",1);
		tap(566,491);--按下开始
		mSleep(10000);
		state=-1;	
	elseif place == 11 then
		toast("段位升级",1);
		log4j("段位升级");
		tap(1000,580);--继续
		mSleep(2000);
		state=-1;
	elseif place == 12 then
		toast("声望升级",1);
		mSleep(1000)
		tap(570,590);--确定
		mSleep(2000);
		state=-1;
	elseif place == 13 then
		toast("未能连接到服务器",1);
		tap(967,215);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 14 then
		toast("断开连接",1);
		tap(940,570);--继续
		mSleep(2000);
		state=-1;
	elseif place == 15 then
		toast("连接错误",1);
		tap(569,437);--重试
		mSleep(2000);
		state=-1;
	elseif place == 16 then
		sendEmail(email,"账号被顶,等待"..tostring(timeout2).."分钟",getDeviceName());
		toast("账号被顶",1);
		mSleep(1000);
		toast("等待"..tostring(timeout2).."分钟",1)
		--[[
		for i= 1,timeout2*1000*60,1 do
			toast(tostring((timeout2*60-i) - ((timeout2*60-i)%0.01)).."秒后重新登录",0.7)
			mSleep(1000);
		end
		]]--
		mSleep(timeout2*60*1000);
		sendEmail(email,"账号被顶,等待完成",getDeviceName());
		toast("等待完成",1);
		tap(970,215);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 17 then
		toast("匹配中",1);
		state=-6;
	elseif place == 18 then
		toast("VIP会员到期",1);
		tap(883,150);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 19 then
		LoginTimes=LoginTimes+1;
		if LoginTimes >=20 then 
			toast("登录延时",1);
			mSleep(1000);
			restartApp();
			LoginTimes=0;
			state=-1;
		else 
			toast("登陆中",1);
			state=-1;
		end
	elseif place == 20 then
		toast("俱乐部人气很旺",1);
		tap(313,495);--稍后查看
		mSleep(1500);
		state=-1;
	elseif place == 21 then
		toast("段位降级",1);
		log4j("段位降级");
		tap(563,471);--确定
		mSleep(2000);
		state=-1;
	elseif place == 21 then
		toast("失去资格",1);
		tap(945,579);--确定
		mSleep(2000);
		state=-1;
	else
		toast("不知道在哪",1)
		state=-1;
	end
end
function back_Air()
	--完成
	toast("后退",1)
	tap(50,50)
	mSleep(2500)
end
function checkPlace_Air()
	if checkplacetimes > 2 then
		toast("检测界面,"..tostring(checkplacetimes).."/25",1);
	end
	if (isColor( 688,  391, 0xfe8b40, 85) and  isColor( 395,  392, 0xfe8b40, 85) and isColor( 479,  399, 0xfe8b40, 85) and isColor( 494,  371, 0xfe8b40, 85) and isColor( 787,  420, 0xfe8b40, 85) and isColor( 819,  366, 0xfe8b40, 85)) then
		mSleep(1000);
		return -2;--在登录界面
	elseif (isColor( 798, 1422, 0xe13056, 85) and isColor( 812, 1410, 0xdf3055, 85) and isColor( 912, 1394, 0xffffff, 85) and isColor( 946, 1400, 0xf4f4f5, 85) and isColor(1090, 1486, 0xe63666, 85) and isColor(1154, 1484, 0xe63666, 85) and isColor(1260, 1488, 0xe63666, 85) and isColor( 888, 1448, 0xc1294f, 85) and isColor( 954, 1440, 0xd92f55, 85) and isColor(1308, 1414, 0xd12d52, 85)) then
		mSleep(1000);
		return -3;--网络未同步 done
	elseif (isColor(1368,  180, 0xc37c53, 85) and isColor(1520,  180, 0x4b65b8, 85) and isColor(1756,  176, 0xd3c5e3, 85) and isColor(1884,  182, 0xc6b989, 85) and isColor(1416,  230, 0xffffff, 85) and isColor(1546,  226, 0xffffff, 85) and isColor(1676,  228, 0xffffff, 85) and isColor(1806,  232, 0xffffff, 85) and isColor(1936,  230, 0xffffff, 85)) then	mSleep(1000);
		return 3.1;--在多人车库 done
	elseif (isColor(  32,   22, 0x14213d, 85) and isColor(  26,   62, 0x162c52, 85) and isColor(1986,   48, 0xfefefe, 85) and isColor(2006,   46, 0x162339, 85) and isColor(2006,   72, 0x777e8d, 85)) then
		mSleep(1000);
		return 0;--在大厅 done
	elseif (isColor( 168, 1312, 0xffffff, 85) and isColor( 506, 1326, 0xffffff, 85) and isColor( 172, 1432, 0xffffff, 85) and isColor( 504, 1428, 0xffffff, 85) and isColor( 554, 1440, 0x01071f, 85) and isColor(1528, 1314, 0xffffff, 85) and isColor(1884, 1312, 0xffffff, 85) and isColor(1502, 1440, 0xffffff, 85) and isColor(1898, 1432, 0xffffff, 85) and isColor(1930, 1446, 0x01071f, 85)) then
		mSleep(1000);
		return 1;--在多人 done
	elseif (isColor( 124, 1500, 0xcef952, 85) and isColor( 200, 1498, 0xcef952, 85) and isColor( 234, 1502, 0xcef952, 85) and isColor( 270, 1502, 0xcef952, 85) and isColor( 306, 1504, 0xcef952, 85) and isColor( 364, 1502, 0xcef952, 85) and isColor( 412, 1502, 0xcef952, 85) and isColor( 440, 1444, 0xcef952, 85) and isColor( 212, 1414, 0xcff952, 85) and isColor( 444, 1416, 0xcef952, 85) or (isColor( 536, 1386, 0xcef952, 85) and isColor( 616, 1388, 0xcef952, 85) and isColor( 764, 1386, 0xcef952, 85) and isColor( 874, 1388, 0xcef952, 85) and isColor( 548, 1436, 0xcef952, 85) and isColor( 872, 1444, 0xcdf751, 85) and isColor( 900, 1450, 0x020b1f, 85) and isColor( 564, 1504, 0xcef952, 85) and isColor( 736, 1502, 0xcef952, 85) and isColor( 892, 1500, 0xcef952, 85))) then
		return 5;--在赛事 done 
	elseif (isColor( 216,   96, 0xe6004d, 85) and isColor( 139,   96, 0xfc0053, 85) and isColor(  60,   95, 0xf00251, 85) and isColor( 221,  176, 0xffffff, 85) and isColor(  60,  161, 0xff0054, 85)) then
		return 6;--在赛事开始界面
	end
	if (isColor(1074,  690, 0x51b2d9, 85) and isColor(1168,  690, 0x4fafd5, 85) and isColor(1206,  685, 0x4ca8cd, 85) and isColor(1225,  728, 0xffffff, 85) and isColor(1158,  754, 0x53b6de, 85) and isColor( 983,  776, 0x53b7df, 85) and isColor(1037,  841, 0x53b7df, 85) and isColor(1174,  782, 0xffffff, 85) and isColor( 940,  768, 0xd1e6f0, 85) and isColor(1039,  767, 0xffffff, 85)) then
		return 17;--多人匹配中 done
	elseif getColor(34,31) == 0xffffff then
		mSleep(1000);
		return -1;--不在大厅，不在多人 done
	elseif (isColor( 212,   39, 0xea3358, 85) and isColor( 220,   32, 0xea3358, 85) and isColor( 227,   23, 0xea3358, 85) and isColor( 239,   14, 0xea3358, 85) and isColor( 243,    6, 0xea3358, 85) and isColor(  66,  187, 0xea3358, 85) and isColor(  56,  193, 0xea3358, 85) and isColor(  41,  209, 0xea3358, 85) and isColor(  30,  216, 0xea3358, 85) and isColor(  32,  222, 0xea3358, 85)) then
		return 2;--游戏结算界面 done
	elseif (isColor( 313,  181, 0x57bae4, 85) and isColor( 347,  181, 0x57bae4, 85) and isColor( 362,  183, 0x57bae4, 85) and isColor( 361,  191, 0x57bae4, 85) and isColor( 360,  211, 0x57bae4, 85) and isColor( 334,  223, 0x57bae4, 85) and isColor( 334,  223, 0x57bae4, 85) and isColor( 311,  221, 0x57bae4, 85) and isColor( 307,  210, 0x57bae4, 85) and isColor( 308,  196, 0x57bae4, 85)) then
		return 3;--游戏中 done
	elseif (isColor(  60,   26, 0xff0052, 85) and isColor( 153,   29, 0xfe0052, 85) and isColor( 209,   59, 0xffffff, 85) and isColor( 282,   57, 0xffffff, 85) and isColor( 355,   65, 0xffffff, 85) and isColor( 454,   63, 0xffffff, 85) and isColor( 515,   61, 0xffffff, 85) and isColor( 629,   45, 0xffffff, 85)) then
		mSleep(1000);
		return 4;--来自Gameloft的礼物
	end
	if (isColor( 906,   66, 0xea3358, 85) and isColor( 920,   64, 0xea3358, 85) and isColor(1182,  164, 0xdfe0e4, 85) and isColor( 920,   88, 0xea3358, 85) and isColor( 908,  116, 0xe43157, 85) and isColor(1228,  172, 0xfafafa, 85) and isColor(1046,   94, 0xe83257, 85) and isColor(1038,  104, 0xea3358, 85) and isColor(1206,  188, 0xdfe0e4, 85) and isColor(1088,  120, 0xea3358, 85)) then
		return 7;--领奖开包 done
	elseif (isColor( 960,  376, 0xffffff, 85) and isColor( 969,  376, 0xffffff, 85) and isColor( 955,  395, 0xfefefe, 85) and isColor( 414,  940, 0xcc8967, 85) and isColor( 978,  919, 0xebcc52, 85) and isColor(1263,  887, 0x8c67f0, 85) and isColor(1597,  875, 0xf2e3ab, 85) and isColor(1780,  350, 0xea3358, 85) and isColor(1813,  387, 0xea3358, 85)) then
		return 8;--多人联赛奖励界面 done
	elseif (isColor( 945,   97, 0xea3358, 85) and isColor(1022,   92, 0xea3358, 85) and isColor(1077,   97, 0xea3358, 85) and isColor(1177,  184, 0xffffff, 85) and isColor(1178,  197, 0xe4e5e8, 85) and isColor(1182,  213, 0xc9ccd1, 85) and isColor(1230,  180, 0x969ba5, 85) and isColor(1261,  181, 0xffffff, 85) and isColor(1302,  189, 0xeeeff1, 85) and isColor(1300,  210, 0xffffff, 85)) then
		return 9;--赛车解锁或升星 done
	elseif (isColor( 926,  867, 0xb82645, 85) and isColor( 920,  900, 0xba2645, 85) and isColor( 921,  942, 0xba2645, 85) and isColor( 976,  971, 0xebebec, 85) and isColor(1079, 1012, 0xdfdfdf, 85) and isColor(1060, 1055, 0xd4d4d3, 85) and isColor(1002, 1067, 0xd0d0d0, 85) and isColor( 971, 1054, 0xd2d2d4, 85) and isColor( 956, 1034, 0xd9d9da, 85)) then
		return 10;--开始的开始 done
	elseif (isColor(  35,  555, 0xfb1264, 85) and isColor(  35,  602, 0xfb1264, 85) and isColor( 223,  136, 0xfa0153, 85) and isColor( 349,  137, 0xfe0055, 85) and isColor( 938,  569, 0xffffff, 85) and isColor(1070,  569, 0xffffff, 85) and isColor( 935,  602, 0xffffff, 85) and isColor(1076,  601, 0xffffff, 85)) then
		mSleep(1000)
		return 11;--段位升级
	elseif (isColor( 222,   50, 0xffffff, 85) and isColor( 301,   53, 0xffffff, 85) and isColor( 196,   85, 0xffffff, 85) and isColor( 277,   84, 0xffffff, 85) and isColor( 333,  298, 0xffffff, 85) and isColor( 392,  297, 0xffffff, 85) and isColor( 456,  300, 0xffffff, 85) and isColor( 394,  212, 0xffffff, 85) and isColor( 293,  237, 0xffffff, 85) and isColor( 494,  235, 0xffffff, 85)) then
		mSleep(1000);
		return 12;--声望升级
	elseif (isColor( 184,  218, 0xffffff, 85) and isColor( 218,  229, 0xd8d9dc, 85) and isColor( 245,  224, 0xe6e7e9, 85) and isColor( 266,  225, 0xf9f9f9, 85) and isColor( 342,  225, 0xe9e9e9, 85) and isColor( 408,  221, 0xcfcfcf, 85) and isColor( 935,  228, 0xf2004f, 85) and isColor( 991,  225, 0xff0054, 85) and isColor( 976,  243, 0xfb0052, 85)) then
		mSleep(1000);
		return 13;--未能连接到服务器
	elseif (isColor(  26,   24, 0xff0054, 85) and isColor( 234,   20, 0xff0054, 85) and isColor(  29,  212, 0xff0054, 85) and isColor( 195,  120, 0xffffff, 85) and isColor( 441,  127, 0xffffff, 85) and isColor(  15,  103, 0x061724, 85) and isColor( 845,  559, 0xc3fb13, 85) and isColor(1035,  559, 0xc2fb12, 85) and isColor( 945,  603, 0xc3fb13, 85)) then
		mSleep(1000);
		return 14;--多人断开连接
	elseif (isColor( 525,  185, 0xffffff, 85) and isColor( 546,  182, 0xffffff, 85) and isColor( 574,  189, 0xffffff, 85) and isColor( 591,  190, 0xffffff, 85) and isColor( 729,  329, 0xeceef1, 85) and isColor( 742,  336, 0xd2d6dd, 85) and isColor( 759,  334, 0xffffff, 85) and isColor( 788,  336, 0xe4e7eb, 85) and isColor( 798,  329, 0xcdd1d9, 85) and isColor( 569,  437, 0xffffff, 85)) then
		mSleep(1000);
		return 15;--连接错误
	elseif (isColor( 176,  214, 0xffffff, 85) and isColor( 269,  217, 0xecedee, 85) and isColor( 326,  217, 0x999da4, 85) and isColor( 342,  211, 0xbdc0c4, 85) and isColor( 352,  221, 0xe7e7e7, 85) and isColor( 395,  221, 0xd7d7d7, 85) and isColor( 409,  221, 0xcececf, 85) and isColor( 555,  352, 0xe5eaf0, 85) and isColor( 951,  217, 0xff0054, 85) and isColor( 993,  221, 0xff0054, 85)) then
		mSleep(1000);
		return 16;--顶号行为
	elseif (isColor( 495,  147, 0xff0054, 85) and isColor( 525,  149, 0xd4044d, 85) and isColor( 538,  148, 0xfd0054, 85) and isColor( 564,  145, 0xfd0054, 85) and isColor( 585,  150, 0xfd0054, 85) and isColor( 604,  146, 0xfd0054, 85) and isColor( 608,  145, 0xe80250, 85) and isColor( 861,  158, 0xf90052, 85) and isColor( 567,  453, 0xc3fb11, 85)) then
		mSleep(1000);
		return 18;--VIP到期
	elseif (isColor(  67,   23, 0x664944, 85) and isColor( 183,   26, 0x7b4542, 85) and isColor( 346,   22, 0x8f7a81, 85) and isColor( 495,   27, 0x587bad, 85) and isColor( 632,   25, 0x90bee2, 85) and isColor( 764,   27, 0x8c7b94, 85) and isColor( 892,   29, 0x9c7d84, 85)) then
		mSleep(1000);
		return 19;--登录延时
	end
	mSleep(2000);
end
function backHome_Air()
	--完成
	tap(1994,38);--返回大厅
	mSleep(2000);
	place=checkPlace_Air();
	if place ~= 0 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function toPVP_Air()
	toast("进入多人",1); 
	mSleep(4000);
	for i=1,10,1 do
		moveTo(882,500,1742,500,20);--从右往左划
		mSleep(500);
	end
	mSleep(2000);
	tap(1194,1458);
	mSleep(2000);
	--TODO:检查是否在多人入口
	checkAndGetPackage_Air();
	tap(1194,1458);
	mSleep(2000);
	place=checkPlace_Air();
	if place ~= 1 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function getStage_Air()
	--完成
	if (isColor( 582,  758, 0xebcc52, 85)) then
		stage=2;--黄金段位
		toast("黄金段位",1);
	elseif (isColor( 582,  758, 0x9bb1d1, 85)) then
		stage=1;--白银段位
		toast("白银段位",1);
	elseif (isColor( 582,  758, 0xcc8967, 85)) then
		stage=0;--青铜段位
		toast("青铜段位",1);
	elseif (isColor( 582,  758, 0x8c67f0, 85)) then
		stage=3;--白金段位
		toast("白金段位",1);
	elseif (isColor( 582,  758, 0xf2e3ab, 85)) then
		stage=4;--传奇段位
		toast("传奇段位",1);
	else
		stage=-2;--没有段位
		toast("没有段位",1);
	end
end
function chooseStageCar_Air()
	--完成
	virtalstage=0;
	if lowerCar == "开" then
		virtalstage=stage - 1;
	else virtalstage=stage;
	end
	if virtalstage <= 0 then
		tap(1374,180);
	elseif virtalstage == 1 then
		tap(1498,180);
	elseif virtalstage == 2 then
		tap(1638,180);
	elseif virtalstage == 3 then
		tap(1750,180);
	elseif virtalstage == 4 then
		tap(1894,180);
	end
end
function checkTimeOut_Air()
	--完成
	if time ~= -1 then 
		if(os.time()-time>=timeout*60) then
			toast("时间到",1)
			mode=supermode;
			backHome_Air();
		else 
			toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
			mSleep(1000);
		end
	end
end
function toCarbarn_Air()
	--完成
	mSleep(1000);
	getStage_Air();
	mSleep(1000);
	if stage == 4 and PVPatBest == "否" then
		if supermode == "多人刷积分声望" then
			toast("脚本停止",1);
			return -1;
		elseif supermode == "赛事模式" then
			toast("等待"..tostring(timeout-(os.time()-time)/60).."分钟后返回",5);
			for i= 1,timeout*60-(os.time()-time),1 do
				toast(tostring((timeout*60-(os.time()-time)) - ((timeout*60-(os.time()-time))%0.01)).."秒后返回赛事",0.7)
				mSleep(1000);
			end
			mSleep(5*60*1000);
			checkTimeOut_Air();
			return 0;
		end
	end
	tap(1014,1366);--进入车库
end
function chooseCar_Air()
	--完成
	mSleep(2500);
	chooseStageCar_Air();
	mSleep(2000);
	if stage == -2 or stage == 0 or stage == -1 then
		for i=1120,450,-30 do
			tap(i,640);
		end
	else
		for i=2000,900,-30 do
			tap(i,640);
		end
	end
	mSleep(3000);
	skip=1;
	while (getColor(1932,1376) == 0xffffff or skip==skipcar) do
		tap(774,766);
		mSleep(500);
		skip=skip+1;
	end
	--检查自动驾驶
	if not (isColor(1902, 1308, 0xcbf551, 85) and isColor(1918, 1308, 0xcbf551, 85) and isColor(1912, 1292, 0xc2eb4e, 85) and isColor(1926, 1292, 0xc2eb4e, 85) and isColor(1894, 1292, 0xc2eb4e, 85) and isColor(1890, 1324, 0xcdf851, 85)) then
		toast("开启自动驾驶",1);
		tap(1902,1308);
		mSleep(1000);
	end
	tap(1734,1432);--开始匹配
end
function waitBegin_Air()
	--TODO:基本完成，存在未完成
	timer=0;
	while (getColor(311,184) ~= 0x57bae4 and timer<45) do
		mSleep(2000);
		timer=timer+1;
		toast("开局中",0.5);
		if (isColor(1074,  690, 0x51b2d9, 85) and isColor(1168,  690, 0x4fafd5, 85) and isColor(1206,  685, 0x4ca8cd, 85) and isColor(1225,  728, 0xffffff, 85) and isColor(1158,  754, 0x53b6de, 85) and isColor( 983,  776, 0x53b7df, 85) and isColor(1037,  841, 0x53b7df, 85) and isColor(1174,  782, 0xffffff, 85) and isColor( 940,  768, 0xd1e6f0, 85) and isColor(1039,  767, 0xffffff, 85)) then
			tap(970,220);--匹配失败可能弹出的窗口，未修改
			mSleep(2000);
			return -1;
		end
	end
	if timer>=45 then
		if (isColor( 946,  800, 0x53b6de, 85) and isColor( 980,  800, 0x52b5de, 85) and isColor(1014,  822, 0x53b6de, 85) and isColor(1050,  838, 0x53b6de, 85) and isColor(1118,  778, 0x54b8e0, 85) and isColor(1142,  716, 0x53b6df, 85) and isColor(1076,  684, 0x4faed5, 85) and isColor(1174,  778, 0xffffff, 85) and isColor(1236,  716, 0xffffff, 85) and isColor(  34,   38, 0xffffff, 85)) then
			toast("有内鬼，停止交易",1);
			back_Air();
			return -1;
		else 
			innerGhost=innerGhost+1;
			toast("有内鬼，停止交易",1);
			--如果5次timer计时还在开局并且左上角返回键消失
			if innerGhost >= 5 then
				innerGhost=0;
				restartApp();
			end
			return -1;
		end
	end
end
function autoMobile_Air()
	--完成
	toast("接管比赛",1);
	while (getColor(311,183) == 0x57bae4) do
		mSleep(500);
		tap(1740,1180);--加速
		mSleep(500)
		if path == "左" then 
			moveTo(1406,740,1180,740,20);--从右往左划
			moveTo(1406,740,1180,740,20);--从右往左划
		elseif path == "右" then 
			moveTo(1280,740,1406,740,20);--从左往右划
			moveTo(1280,740,1406,740,20);--从左往右划
		elseif path == "随机" then
			rand=math.random(1,3);--rand==1 2 or 3
			if rand == 1 then
				moveTo(1406,740,1180,740,20);--从右往左划
				moveTo(1406,740,1180,740,20);--从右往左划
			elseif rand == 2 then
				moveTo(1280,740,1406,740,20);--从左往右划
				moveTo(1280,740,1406,740,20);--从左往右划
			end
		end
		mSleep(500);
		tap(1740,1180);--加速
	end
	toast("比赛结束",1);
end
function backFromLines_Air()
	--从赛道回到多人界面，完成
	mSleep(4000);
	color=getColor(208,45);
	while (color == 0xea3358) do
		tap(1692,1424);
		mSleep(100);
		color=getColor(208,45);
	end
	mSleep(2000);
	toast("比赛完成",1);
	if mode == "多人刷积分声望" then
		PVPTimes=PVPTimes+1;
		log4j("完成"..tostring(PVPTimes).."局多人");
	elseif mode == "赛事模式" then
		PVETimes=PVETimes+1;
		log4j("完成"..tostring(PVETimes).."局赛事");
	end
	refreshTable();
	if supermode == "赛事模式" then 
		checkTimeOut_Air();
	end
end
function checkAndGetPackage_Air()
	--完成
	toast("检查多人包",1);
	if (isColor( 900,  220, 0xfdfff7, 85) and isColor( 918,  258, 0xfcfff5, 85) and isColor( 914,  296, 0xfcfff4, 85) and isColor(1022,  222, 0xfdfff6, 85) and isColor( 992,  300, 0xfcfff2, 85) and isColor(1066,  308, 0xfcfff2, 85) and isColor(1134,  276, 0xfcfff4, 85) and isColor(1184,  258, 0xfcfff6, 85) and isColor(1176,  312, 0xfcfff3, 85)) then
		toast("领取多人包",1);
		log4j("领取多人包");
		tap(1006,1176);
		mSleep(2000);
		tap(1016,1472);
		mSleep(2000);
		tap(1846,1430);
		mSleep(10000);
	else
		toast("没有多人包",1);
	end
	tap(284,1104);--补充可能的多人包
end
function Login_Air()
	--完成
	if (isColor( 838,  745, 0x333333, 85) and isColor( 856,  746, 0x333333, 85) and isColor( 877,  746, 0x333333, 85) and isColor( 809,  822, 0xef9151, 85) and isColor(1169,  836, 0xef9151, 85) and isColor( 816,  865, 0xef9151, 85) and isColor(1249,  865, 0xef9151, 85)) then
		log4j("登录游戏");
		tap(1037,845);
		mSleep(2000)
		return -1;
	else 
		if ts.system.udid() == "yourudid" then
			toast("无密码,自动输入",1);
			log4j("自动输入密码");
			mSleep(1000);
			tap(380,300);
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
			tap(580,257)
			mSleep(20000);
			return -1;
		else
			toast("无密码,脚本退出",1);
			log4j("无密码,脚本退出");
			mSleep(1000);
			return -2;
		end
	end
end
function toDailyGame_Air()
	toast("进入赛事",1); 
	for i=1,10,1 do
		moveTo(882,500,1742,500,20);--从右往左划
		mSleep(500);
	end
	mSleep(2000);
	tap(834,1406)
	mSleep(2000);
	--TODO:检查是否在赛事入口
	tap(834,1406);
	mSleep(2000);
	for i=1,4,1 do
		moveTo(246,1230,1152,1244,20);--从左往右划
	end
	mSleep(2000);
	return -1;
end
function chooseGame_Air()
	gamenum=tonumber(gamenum);
	if gamenum<=7 then
		tap(138+160*(gamenum-1),1200);
		mSleep(1000);
		tap(138+160*(gamenum-1),1200);
		mSleep(2000);
		return -1;
	else 
		for i = 1,gamenum - 7,1 do
			moveTo(610,1200,470,1200,20)
			mSleep(500)
		end
		tap(138+160*6,1200);
		mSleep(1000);
		tap(138+160*6,1200);
		mSleep(2000);
		return -1;
	end

end
function gametoCarbarn_Air()
	tap(1065,590);
	mSleep(2000);
	if chooseCarorNot == "是" then
		tap(580,270);
		if backifallstar == "是" then
			mSleep(2000);
			back_Air();
			mSleep(1000);
			if chooseCarorNot == "是" then
				if upordown == "中间上" then
					tap(580,270);
				elseif upordown == "中间下" then
					tap(580,480);
				end
			end
		end
	end
	mSleep(2000);
	::beginAtGame::	if ((((isColor(1041,  557, 0xc7fb24, 85) and isColor( 849,  561, 0xc8fb25, 85) and isColor( 849,  598, 0xc8fb25, 85) and isColor(1074,  601, 0xc7fb23, 85))) or (isColor( 938,  551, 0xc4fb11, 85) and isColor(1093,  555, 0xc2fb12, 85) and isColor(1086,  603, 0xc2fb11, 85) and isColor( 928,  605, 0xc4fb16, 85)))) then
		--检查自动驾驶
		if (isColor(1058,  508, 0xfc0001, 85) and isColor(1053,  508, 0xef0103, 85) and isColor(1065,  508, 0xef0103, 85) and isColor(1057,  515, 0xff0000, 85) and isColor(1047,  523, 0xf00103, 85) and isColor(1062,  521, 0xe60205, 85)) then
			toast("开启自动驾驶",1);
			tap(1060,510);
			mSleep(1000);
		end
		tap(958,574);
		mSleep(2000);
		--检查是不是有票
		if (isColor( 257,  448, 0xc3fb12, 85) and isColor( 508,  453, 0xc3fb12, 85) and isColor( 250,  488, 0xc2fb12, 85) and isColor( 509,  492, 0xc4fb12, 85)) then
			toast("没票",1)
			tap(970,160);
			--去多人or生涯
			time=os.time();--记录当前时间
			if switch == "去刷多人" then
				toast(tostring(timeout).."分钟后返回",1)
				mode="多人刷积分声望"
				backHome_Air();
				return -1;
			elseif switch == "等待15分钟" then
				toast("等待15分钟",1)
				mSleep(15*60*1000);
				toast("15分钟到",1)
				mSleep(1000);
				goto beginAtGame;
			elseif switch == "等待30分钟" then
				toast("等待30分钟",1)
				mSleep(30*60*1000);
				toast("30分钟到",1)
				goto beginAtGame;
			end
		end
	else 
		toast("没油了",1);
		--去多人or生涯
		time=os.time();--记录当前时间
		if switch == "去刷多人" then
			toast(tostring(timeout).."分钟后返回",1)
			mode="多人刷积分声望"
			backHome_Air();
			return -1;
		elseif switch == "等待15分钟" then
			toast("等待15分钟",1)
			mSleep(15*60*1000);
			toast("15分钟到",1)
			mSleep(1000);
			goto beginAtGame;
		elseif switch == "等待30分钟" then
			toast("等待30分钟",1)
			mSleep(30*60*1000);
			toast("30分钟到",1)
			goto beginAtGame;
		end
	end
	mSleep(3000)
	if waitBegin_Air() == -1 then
		return -1;
	end
	autoMobile_Air();--接管比赛
	mSleep(2000);
	return -1;
end
function receivePrizeFromGL_Air()
	sendEmail(email,"领取来自GameLoft的礼物",getDeviceName());
	mSleep(1000);
	tap(1015,582);
	mSleep(5000);
	tap(569,582);
	mSleep(2000);
	tap(1015,582);
	mSleep(2000);
end
function receivePrizeAtGame_Air()
	--完成
	mSleep(1000);
	tap(1030,1482);
	mSleep(1000);
	tap(1806,1438);
	mSleep(1500);
	return -1;
end
function worker_Air()
	if place == -3 then
		toast("网络未同步",1);
		mSleep(1000);
		state=-1;
	elseif place == 3.1 then
		toast("在多人车库",1)
		mSleep(1000);
		state=-3;
	elseif place == 0 then
		toast("在大厅",1);
		mSleep(1000);
		if mode == "多人刷积分声望" then 
			state=toPVP_Air();
		elseif mode == "赛事模式" then
			state=toDailyGame_Air();
		end
	elseif place == 1 then
		toast("在多人",1);
		mSleep(1000);
		if mode == "多人刷积分声望" then 
			state=0;
		elseif mode == "赛事模式" then
			back_Air();
			state=toDailyGame_Air();
		end
	elseif place == -1 then
		toast("不在大厅，不在多人",1);
		mSleep(1000)
		toast("回到大厅",1);
		state=backHome_Air();
		if mode == "多人刷积分声望" then 
			state=toPVP_Air();
		elseif mode == "赛事模式" then
			state=toDailyGame_Air();
		end
	elseif place == 2 then
		toast("在结算",1);
		mSleep(1000);
		state=-4;
	elseif place == 3 then
		toast("在游戏",1);
		mSleep(1000);
		state=-5;
	elseif place == -2 then
		toast("登录界面",1);
		mSleep(1000);
		state=Login_Air();
	elseif place == 4 then
		toast("奖励界面",1);
		mSleep(1000);
		receivePrizeFromGL_Air();
		state=-1;
	elseif place == 5 then
		toast("在赛事",1);
		mSleep(1000);
		if mode == "赛事模式" then 
			state=chooseGame_Air();
			validateGame=true;
		elseif mode == "多人刷积分声望" then 
			back_Air();
			state=-1;
		end
	elseif place == 6 then
		toast("赛事开始界面",1);
		mSleep(1000);
		if mode == "赛事模式" then 
			if validateGame == false then
				back_Air();
				state=-1;
			elseif validateGame == true then
				state=gametoCarbarn_Air();
			end
		elseif mode == "多人刷积分声望" then 
			backHome_Air();
			state=-1;
		end
	elseif place == 7 then
		toast("领奖界面",1);
		mSleep(1000);
		state=receivePrizeAtGame_Air();
	elseif place == 8 then
		toast("多人联赛介绍界面",1);
		mSleep(1000);
		tap(960,120);
		mSleep(1000);
		state=-1;
	elseif place == 9 then
		toast("解锁或升星",1);
		mSleep(1000);
		tap(390,570);
		mSleep(2000);
		state=-1;
	elseif place == 10 then
		toast("开始的开始",1);
		mSleep(1000);
		tap(566,491);--按下开始
		mSleep(10000);
		state=-1;	
	elseif place == 11 then
		toast("段位升级",1);
		log4j("段位升级");
		tap(1000,580);--继续
		mSleep(2000);
		state=-1;
	elseif place == 12 then
		toast("声望升级",1);
		mSleep(1200)
		tap(570,590);--确定
		mSleep(2000);
		state=-1;
	elseif place == 13 then
		toast("未能连接到服务器",1);
		tap(967,215);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 14 then
		toast("断开连接",1);
		tap(940,570);--继续
		mSleep(2000);
		state=-1;
	elseif place == 15 then
		toast("连接错误",1);
		tap(569,437);--重试
		mSleep(2000);
		state=-1;
	elseif place == 16 then
		sendEmail(email,"账号被顶,等待"..tostring(timeout2).."分钟",getDeviceName());
		toast("账号被顶",1);
		mSleep(1000);
		toast("等待"..tostring(timeout2).."分钟",1)
		for i= 1,timeout2*1000*60,1 do
			toast(tostring((timeout2*60-i) - ((timeout2*60-i)%0.01)).."秒后重新登录",0.7)
			mSleep(1000);
		end
		sendEmail(email,"账号被顶,等待完成",getDeviceName());
		toast("等待完成",1);
		mSleep(1000);
		tap(970,215);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 17 then
		toast("匹配中",1);
		state=-6;
	elseif place == 18 then
		toast("VIP会员到期",1);
		tap(883,150);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 19 then
		LoginTimes=LoginTimes+1;
		if LoginTimes >=20 then 
			toast("登录延时",1);
			mSleep(1000);
			restartApp();
			LoginTimes=0;
			state=-1;
		else 
			toast("登陆中",1);
			state=-1;
		end
	else
		toast("不知道在哪",1)
		state=-1;
	end
end
function back_i68()
	--Done
	toast("后退",1)
	tap(30,30)
	mSleep(2500)
end
function checkPlace_i68()
	if checkplacetimes > 2 then
		toast("检测界面,"..tostring(checkplacetimes).."/25",1);
	end
	if (((isColor(1305,   14, 0xfcffff, 85) and isColor(1312,   22, 0xfefefe, 85) and isColor(1314,   37, 0xcdd3db, 85) and isColor(1293,   32, 0xfefeff, 85) and isColor(1294,   21, 0xffffff, 85) and isColor(1304,   17, 0xfeffff, 85)) and not (isColor(  12,   16, 0xffffff, 85) and 
				isColor(  10,   45, 0xffffff, 85)))) or ((isColor(1111,   11, 0xfbffff, 85) and isColor(1120,   16, 0xf8faf9, 85) and isColor(1126,   26, 0xe2e4e8, 85) and isColor(1095,   26, 0xfdfdfd, 85))) then
		return 0;--在大厅
	elseif (isColor( 513,  668, 0xff0054, 85) and isColor( 521,  676, 0xff0054, 85) and isColor( 529,  685, 0xff0054, 85) and isColor( 530,  668, 0xfc0053, 85) and isColor( 513,  684, 0xfe0054, 85) and isColor( 587,  665, 0xe4e5e8, 85) and isColor( 588,  717, 0xfb1264, 85) and isColor( 615,  717, 0xfb1264, 85) and isColor( 640,  717, 0xfb1264, 85) and isColor( 660,  717, 0xfb1264, 85)) then
		return -3;--网络未同步
	elseif (isColor( 498,  429, 0xfe8b40, 85) and isColor( 500,  472, 0xfe8b40, 85) and isColor( 845,  434, 0xfe8b40, 85) and isColor( 846,  467, 0xfe8b40, 85)) then
		return -2;--在登录界面
	elseif (isColor( 419,  137, 0xffffff, 85) and isColor( 455,  134, 0xffffff, 85) and isColor( 573,  137, 0xffffff, 85) and isColor( 573,  158, 0xffffff, 85) and isColor( 602,  136, 0xffffff, 85) and isColor( 636,  133, 0xffffff, 85) and isColor( 659,  134, 0xffffff, 85) and isColor( 683,  140, 0xffffff, 85) and isColor( 442,  515, 0x000721, 85) and isColor( 190,  518, 0xffffff, 85)) then
		return 20;--俱乐部新人,undone
	elseif (isColor( 896,  112, 0xce7345, 85) and isColor( 985,  113, 0x6c7889, 85) and isColor(1059,  119, 0xbd9158, 85) and isColor(1144,  118, 0xbcb3d5, 85) and isColor(1230,  116, 0x6d6c63, 85)) then
		return 3.1;--在多人车库
	elseif (isColor(  89,  643, 0xffffff, 85) and isColor( 335,  645, 0xffffff, 85) and isColor( 362,  708, 0x000822, 85) and isColor(1021,  648, 0xffffff, 85) and isColor(1234,  646, 0xffffff, 85) and isColor(1260,  704, 0x000821, 85)) then
		return 1;--在多人
	elseif (isColor(  89,  679, 0xc5fb12, 85) and isColor( 246,  680, 0xc3fb12, 85) and isColor(  81,  703, 0xc2fb0f, 85) and isColor( 253,  700, 0xc3fa12, 85)) then
		return 5;--在赛事
	elseif (isColor(  70,  112, 0xfa0152, 85) and isColor(  82,  112, 0xfa0052, 85) and isColor( 101,  112, 0xfb0052, 85) and isColor( 143,  113, 0xfd0053, 85) and isColor( 189,  113, 0xfe0053, 85) and isColor( 228,  113, 0xfd0053, 85) and isColor( 258,  113, 0xf60051, 85)) then
		return 6;--在赛事开始界面
	elseif (isColor( 628,  370, 0x03b9e4, 85) and isColor( 660,  353, 0xfefefe, 85) and isColor( 682,  360, 0xffffff, 85) and isColor( 712,  364, 0xffffff, 85) and isColor( 738,  389, 0xffffff, 85) and isColor( 678,  423, 0x02b9e2, 85) and isColor( 621,  385, 0x00b9e2, 85)) then		
		return 17;--多人匹配中
	elseif getColor(5, 5) == 0xffffff then
		return -1;--不在大厅，不在多人
	elseif (isColor(160,4, 0xff0054, 85) and isColor(147,18, 0xff0054, 85)) then
		return 2;--游戏结算界面
	elseif (isColor(204,120,0x14bde9, 85)) then
		return 3;--游戏中
	elseif (isColor(  60,   26, 0xff0052, 85) and isColor( 153,   29, 0xfe0052, 85) and isColor( 209,   59, 0xffffff, 85) and isColor( 282,   57, 0xffffff, 85) and isColor( 355,   65, 0xffffff, 85) and isColor( 454,   63, 0xffffff, 85) and isColor( 515,   61, 0xffffff, 85) and isColor( 629,   45, 0xffffff, 85)) then
		return 4;--来自Gameloft的礼物,undone
	elseif (isColor( 614,   38, 0xf00252, 85) and isColor( 636,   39, 0xfa0053, 85) and isColor( 682,   36, 0xe30351, 85) and isColor( 667,   36, 0xff0054, 85) and isColor( 667,   42, 0xff0054, 85) and isColor( 698,   41, 0xff0054, 85) and isColor( 698,   66, 0xff0054, 85)) then
		return 7;--领奖开包
	elseif (isColor(1101,  119, 0xff0053, 85) and isColor(1123,  117, 0xff0053, 85) and isColor(1147,  147, 0xff0053, 85) and isColor(1160,  166, 0xff0054, 85) and isColor(1129,  170, 0xfa0052, 85) and isColor(1127,  143, 0xfffeff, 85)) then
		return 8;--多人联赛奖励界面
	elseif (isColor( 616,  208, 0xfbde23, 85) and isColor( 625,  224, 0xfec002, 85) and isColor( 643,  226, 0xfee53d, 85) and isColor( 629,  204, 0xfffef5, 85)) then
		return 9;--赛车解锁或升星
	elseif (isColor( 584,  582, 0xc3fb12, 85) and isColor( 774,  587, 0xc3fb11, 85) and isColor( 547,  638, 0xc3fb13, 85) and isColor( 785,  638, 0xc5fb12, 85) and isColor( 806,  650, 0x000b21, 85)) then
		return 10;--开始的开始
	elseif (isColor( 252,  161, 0xfd0055, 85) and isColor( 290,  159, 0xfa0051, 85) and isColor( 316,  161, 0xfe0055, 85) and isColor( 375,  162, 0xf60154, 85) and isColor( 414,  161, 0xfc0156, 85) and isColor(  42,  652, 0xfb1264, 85) and isColor(  43,  696, 0xf91263, 85) and isColor(1111,  663, 0xffffff, 85) and isColor(1260,  668, 0xffffff, 85) and isColor(1284,  712, 0x000521, 85)) then
		return 11;--段位升级
	elseif (isColor( 265,   59, 0xfffefd, 85) and isColor( 287,   59, 0xfffffd, 85) and isColor( 347,   68, 0xffffff, 85) and isColor( 334,   88, 0xffffff, 85) and isColor( 337,  268, 0xfefffd, 85) and isColor( 459,  245, 0xffffff, 85) and isColor( 462,  178, 0xf4feff, 85) and isColor( 323,  540, 0xfcffff, 85) and isColor( 591,  644, 0xffffff, 85) and isColor( 820,  687, 0x030625, 85)) then
		return 12;--声望升级
	elseif (isColor( 184,  218, 0xffffff, 85) and isColor( 218,  229, 0xd8d9dc, 85) and isColor( 245,  224, 0xe6e7e9, 85) and isColor( 266,  225, 0xf9f9f9, 85) and isColor( 342,  225, 0xe9e9e9, 85) and isColor( 408,  221, 0xcfcfcf, 85) and isColor( 935,  228, 0xf2004f, 85) and isColor( 991,  225, 0xff0054, 85) and isColor( 976,  243, 0xfb0052, 85)) then
		return 13;--未能连接到服务器,undone
	elseif (isColor(  36,   45, 0xff0054, 85) and isColor(  26,  260, 0xff0054, 85) and isColor( 148,  139, 0xff0054, 85) and isColor( 243,   37, 0xff0054, 85) and isColor( 269,  272, 0xff0054, 85) and isColor( 521,  140, 0xffffff, 85) and isColor( 992,  650, 0xc3fb12, 85) and isColor(1114,  705, 0xc2fb13, 85) and isColor(1221,  658, 0xc3fb13, 85) and isColor(1272,  713, 0x000a21, 85)) then
		return 14;--多人断开连接
	elseif (isColor( 525,  185, 0xffffff, 85) and isColor( 546,  182, 0xffffff, 85) and isColor( 574,  189, 0xffffff, 85) and isColor( 591,  190, 0xffffff, 85) and isColor( 729,  329, 0xeceef1, 85) and isColor( 742,  336, 0xd2d6dd, 85) and isColor( 759,  334, 0xffffff, 85) and isColor( 788,  336, 0xe4e7eb, 85) and isColor( 798,  329, 0xcdd1d9, 85) and isColor( 569,  437, 0xffffff, 85)) then
		return 15;--连接错误,undone
	elseif (isColor( 207,  250, 0xffffff, 85) and isColor( 222,  250, 0xf3f3f4, 85) and isColor( 243,  250, 0xeeeff0, 85) and isColor( 252,  250, 0xbbc0c5, 85) and isColor( 261,  254, 0xb2b6bc, 85) and isColor( 274,  255, 0xe8e9ea, 85) and isColor( 291,  255, 0xf3f3f4, 85) and isColor( 317,  257, 0xf9f9f9, 85) and isColor(1136,  253, 0xfffafd, 85) and isColor(1138,  253, 0xffffff, 85)) then		
		return 16;--顶号行为
	elseif (isColor( 495,  147, 0xff0054, 85) and isColor( 525,  149, 0xd4044d, 85) and isColor( 538,  148, 0xfd0054, 85) and isColor( 564,  145, 0xfd0054, 85) and isColor( 585,  150, 0xfd0054, 85) and isColor( 604,  146, 0xfd0054, 85) and isColor( 608,  145, 0xe80250, 85) and isColor( 861,  158, 0xf90052, 85) and isColor( 567,  453, 0xc3fb11, 85)) then
		return 18;--VIP到期,undone
	elseif (isColor(  67,   23, 0x664944, 85) and isColor( 183,   26, 0x7b4542, 85) and isColor( 346,   22, 0x8f7a81, 85) and isColor( 495,   27, 0x587bad, 85) and isColor( 632,   25, 0x90bee2, 85) and isColor( 764,   27, 0x8c7b94, 85) and isColor( 892,   29, 0x9c7d84, 85)) then
		return 19;--登录延时,undone
	elseif (isColor( 591,  187, 0xfcfcfc, 85) and isColor( 605,  187, 0xdfe0e3, 85) and isColor( 623,  190, 0xffffff, 85) and isColor( 632,  190, 0xfafafb, 85) and isColor( 641,  191, 0xffffff, 85) and isColor( 651,  191, 0xf5f6f6, 85) and isColor( 707,  191, 0xe6e7e9, 85) and isColor( 730,  552, 0xffffff, 85) and isColor( 761,  569, 0x010722, 85)) then
		return 21;--段位降级
	end
	mSleep(1000);
end
function backHome_i68()
	--Done
	tap(1300,30);--返回大厅
	mSleep(2000);
	place=checkPlace_i68();
	if place ~= 0 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function toPVP_i68()
	toast("进入多人",1); 
	mSleep(4000);
	for i=1,10,1 do
		moveTo(860,235,225,235,20);--从右往左划
	end
	for i=1,3,1 do
		moveTo(225,235,860,235,20);--从左往右划
	end
	mSleep(2000);
	--TODO:检查是否在多人入口
	checkAndGetPackage_i68();
	tap(758,688);
	mSleep(2000);
	place=checkPlace_i68();
	if place ~= 1 then
		toast("有内鬼，停止交易",1)
		return -1;
	end
	return 0;
end
function getStage_i68()
	color=getColor(379,362);
	--Undone
	if color == 0xf1cb30 then
		stage=2;--黄金段位
		toast("黄金段位",1);
	elseif color == 0x96b2d4 then
		stage=1;--白银段位
		toast("白银段位",1);
	elseif color == 0xd88560 then
		stage=0;--青铜段位
		toast("青铜段位",1);
	elseif color == 0x9365f8 then
		stage=3;--白金段位
		toast("白金段位",1);
	elseif (isColor( 320,  309, 0xf5e2a4, 85) and isColor( 334,  309, 0xf5e2a4, 85) and isColor( 323,  324, 0xf4e1a4, 85) and isColor( 334,  323, 0xf5e2a4, 85) and isColor( 328,  327, 0xf5e2a4, 85)) then
		stage=4;--传奇段位
		toast("传奇段位",1);
	elseif (isColor( 322,  308, 0x00bbe8, 85) and isColor( 335,  308, 0x00bbe8, 85) and isColor( 334,  323, 0x00bbe8, 85) and isColor( 320,  321, 0x00bbe8, 85)) then
		stage=-2;--没有段位
		toast("没有段位",1);
	end
end
function chooseStageCar_i68()
	--done
	virtalstage=0;
	if lowerCar == "开" then
		virtalstage=stage - 1;
	else virtalstage=stage;
	end
	if virtalstage <= 0 then
		tap(900,100);
	elseif stage == 1 then
		tap(980,100);
	elseif virtalstage == 2 then
		tap(1060,100);
	elseif virtalstage == 3 then
		tap(1140,100);
	elseif virtalstage == 4 then
		tap(1240,100);
	end
end
function checkTimeOut_i68()
	--done
	if time ~= -1 then 
		if(os.time()-time>=timeout*60) then
			toast("时间到",1)
			mode=supermode;
			backHome_i68();
		else 
			toast(tostring(timeout-(os.time()-time)/60 -((timeout-(os.time()-time)/60)%0.01)).."分钟后返回",1);
			mSleep(1000);
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
			toast("脚本停止",1);
			return -1;
		elseif supermode == "赛事模式" then
			toast("等待"..tostring(timeout-(os.time()-time)/60).."分钟后返回",5);
			for i= 1,timeout*60-(os.time()-time),1 do
				toast(tostring((timeout*60-(os.time()-time)) - ((timeout*60-(os.time()-time))%0.01)).."秒后返回赛事",0.7)
				mSleep(1000);
			end
			mSleep(5*60*1000);
			checkTimeOut_i68();
			return 0;
		end
	end
	tap(883,691);--进入车库
end
function chooseCar_i68()
	--done
	mSleep(2500);
	chooseStageCar_i68();
	mSleep(2000);
	if stage == -2 or stage == 0 or stage == -1 then
		for i=600,300,-30 do
			tap(i,270);
		end
	else
		for i=1325,1025,-30 do
			tap(i,270);
		end
	end
	mSleep(3000);
	skip=1;
	--当车没油、没解锁（不能买），需跳过，没解锁能买时，总是找下一辆车
	while not ((not isColor( 1207,  687, 0xffffff, 85)) and (isColor( 199,  189, 0xffea3f, 85) or isColor( 193,  175, 0xf80555, 85))) or skip==skipcar do
		tap(510,380);
		mSleep(500);
		skip=skip+1;
	end
	--检查自动驾驶
	--[[if not ((isColor(1251,  604, 0xa7d056, 85) or isColor(1239,  592, 0xbff613, 85))) then
		toast("开启自动驾驶",1);
		tap(1240,600);
		mSleep(1000);
	end]]--
tap(1280,700);
end
function waitBegin_i68()
	--done
	timer=0;
	while (getColor(204,122) ~= 0x14bde9 and timer<45) do
		mSleep(2000);
		timer=timer+1;
		toast("开局中",0.5);
		--网络不好没匹配到人被提示，undone
		if (isColor( 959,  206, 0xfff8fb, 85) and isColor( 980,  228, 0xfffbff, 85) and isColor( 959,  226, 0xffffff, 85) and isColor( 981,  205, 0xfffeff, 85) and isColor( 969,  216, 0xfffeff, 85) and isColor( 938,  213, 0xff0053, 85) and isColor( 993,  207, 0xff0054, 85) and isColor( 981,  238, 0xff0054, 85)) then
			tap(970,220)
			mSleep(2000);
			return -1;
		end
	end
	if timer>=45 then
		--如果还在匹配界面且左上有返回
		if (isColor( 632,  383, 0x02b9e3, 85) and isColor( 663,  366, 0xffffff, 85) and isColor( 678,  367, 0xfeffff, 85) and isColor( 699,  360, 0xffffff, 85) and isColor( 722,  374, 0xffffff, 85) and isColor(  23,   47, 0xffffff, 85) and isColor(  87,   15, 0xffffff, 85)) then
			toast("有内鬼，停止交易",1);
			back_i68();
			return -1;
		else 
			innerGhost=innerGhost+1;
			toast("有内鬼，停止交易",1);
			--如果5次timer计时还在开局并且左上角返回键消失
			if innerGhost >= 5 then
				innerGhost=0;
				restartApp();
			end
			return -1;
		end
	end
end
function autoMobile_i68()
	--done
	toast("接管比赛",1);
	while (getColor(200,120) == 0x14bde9) do
		mSleep(500);
		tap(1130,600);
		mSleep(500)
		if path == "左" then 
			moveTo(800,235,400,235,20);--从右往左划
			moveTo(800,235,400,235,20);--从右往左划
		elseif path == "右" then 
			moveTo(400,235,800,235,20);--从左往右划
			moveTo(400,235,800,235,20);--从左往右划
		elseif path == "随机" then
			rand=math.random(1,3);--rand==1 2 or 3
			if rand == 1 then
				moveTo(800,235,400,235,20);--从右往左划
				moveTo(800,235,400,235,20);--从右往左划
			elseif rand == 2 then
				moveTo(600,235,800,235,20);--从左往右划
				moveTo(600,235,800,235,20);--从左往右划
			end
		end
		mSleep(500);
		tap(1130,600);
	end
	toast("比赛结束",1);
end
function backFromLines_i68()
	--done
	--从赛道回到多人界面
	mSleep(4000);
	color=getColor(140,20);
	while (color == 0xff0054) do
		tap(1100,680);
		mSleep(1500);
		color=getColor(115,25);
	end
	mSleep(2000);
	toast("比赛完成",1);
	if mode == "多人刷积分声望" then
		PVPTimes=PVPTimes+1;
		log4j("完成"..tostring(PVPTimes).."局多人");
	elseif mode == "赛事模式" then
		PVETimes=PVETimes+1;
		log4j("完成"..tostring(PVETimes).."局赛事");
	end
	refreshTable();
	if supermode == "赛事模式" then 
		checkTimeOut_i68();
	end
end
function checkAndGetPackage_i68()
	--done
	if (isColor( 608,  113, 0xf8fbf2, 85) and isColor( 623,  118, 0xfcfff4, 85) and isColor( 666,  118, 0xfcfff4, 85) and isColor( 660,  142, 0xfaffef, 85) and isColor( 679,  148, 0xf9feed, 85) and isColor( 714,  141, 0xfbfff1, 85) and isColor( 736,  157, 0xfaffef, 85)) then
		toast("领取多人包",1);
		log4j("领取多人包");
		mSleep(700);
		tap(670,560);
		receivePrizeAtGame_i68();
		mSleep(10000);
	else
		toast("没有多人包",1);
	end
	tap(176,545);--尝试补充多人包
end
function Login_i68()
	--done
	if (isColor( 482,  353, 0x333333, 85) and isColor( 498,  353, 0x333333, 85) and isColor( 517,  353, 0x333333, 85) and isColor( 535,  353, 0x333333, 85) and isColor( 550,  353, 0x333333, 85) and isColor( 568,  352, 0x333333, 85) and isColor( 584,  354, 0x333333, 85) and isColor( 515,  444, 0xfe8b40, 85) and isColor( 769,  444, 0xfe8b40, 85) and isColor( 874,  444, 0xfe8b40, 85)) then
		log4j("登录游戏");
		tap(660,450);
		mSleep(5000)
		return -1;
	else 
		if ts.system.udid() == "649a76c95b6e2f89f0eebbb0d5f5621e" then
			dialog(string, time)
			toast("无密码,自动输入",1);
			log4j("自动输入密码");
			mSleep(1000);
			tap(490,350);
			mSleep(1000);
			keypress('1');
			keypress('9');
			keypress('9');
			keypress('7');
			keypress('2');
			keypress('1');
			keypress('7');
			tap(656,307)
			mSleep(20000);
			return -1;
		else
			toast("无密码,脚本退出",1);
			log4j("无密码,脚本退出");
			mSleep(1000);
			return -2;
		end
	end
end
function toDailyGame_i68()
	--done partly
	toast("进入赛事",1); 
	for i=1,10,1 do
		moveTo(860,235,225,235,20);--从左往右划
	end
	for i=1,4,1 do
		moveTo(225,235,950,235,20);--从右往左划，需要改
	end
	mSleep(2000);
	--TODO:检查是否在赛事入口
	tap(547,686);
	mSleep(2000);
	for i=1,4,1 do
		moveTo(100,500,520,500,20);--从左往右划
	end
	mSleep(2000);
	return -1;
end
function chooseGame_i68()
	--done
	gamenum=tonumber(gamenum);
	if gamenum<=7 then
		tap(170+200*(gamenum-1),500);
		mSleep(1000);
		tap(170+200*(gamenum-1),500);
		mSleep(2000);
		return -1;
	else 
		for i = 1,gamenum - 7,1 do
			moveTo(1250,500,1095,500,20)
			mSleep(500)
		end
		tap(170+200*6,500);
		mSleep(1000);
		tap(170+200*6,500);
		mSleep(2000);
		return -1;
	end

end
function gametoCarbarn_i68()
	--done
	tap(1260,690);
	mSleep(2000);
	if chooseCarorNot == "是" then
		tap(660,320);
		if backifallstar == "是" then
			mSleep(2500);
			back_i68();
			mSleep(1000);
			if chooseCarorNot == "是" then
				if upordown == "中间上" then
					tap(660,320);
				elseif upordown == "中间下" then
					tap(660,575);
				end
			end
		end
	end
	mSleep(2500);
	::beginAtGame::	if (not isColor( 1207,  687, 0xffffff, 85)) and (isColor( 199,  189, 0xffea3f, 85) or isColor( 193,  175, 0xf80555, 85))then
		--检查自动驾驶
		--[[if not ((isColor(1251,  604, 0xa7d056, 85) or isColor(1239,  592, 0xbff613, 85))) then
			toast("开启自动驾驶",1);
			tap(1240,600);
			mSleep(1000);
		end]]--
	tap(1280,700);
	mSleep(2000);
	--检查是不是有票
	if (isColor( 546,  169, 0xf4f5f6, 85) and isColor( 561,  180, 0xffffff, 85) and isColor( 561,  192, 0xffffff, 85) and isColor( 601,  189, 0xffffff, 85) and isColor( 669,  169, 0xfcfcfc, 85) and isColor(1112,  187, 0xff0053, 85) and isColor(1168,  186, 0xff0054, 85) and isColor(1139,  160, 0xff0054, 85) and isColor(1139,  206, 0xfe0054, 85) and isColor(1139,  183, 0xffffff, 85)) then
		toast("没票",1)
		tap(1140,180);
		--去多人or生涯
		time=os.time();--记录当前时间
		if switch == "去刷多人" then
			toast(tostring(timeout).."分钟后返回",1)
			mode="多人刷积分声望"
			backHome_i68();
			return -1;
		elseif switch == "等待15分钟" then
			toast("等待15分钟",1)
			mSleep(15*60*1000);
			toast("15分钟到",1)
			mSleep(1000);
			goto beginAtGame;
		elseif switch == "等待30分钟" then
			toast("等待30分钟",1)
			mSleep(30*60*1000);
			toast("30分钟到",1)
			goto beginAtGame;
		end
	end
else 
	toast("没油了",1);
	--去多人or生涯
	time=os.time();--记录当前时间
	if switch == "去刷多人" then
		toast(tostring(timeout).."分钟后返回",1)
		mode="多人刷积分声望"
		backHome_i68();
		return -1;
	elseif switch == "等待15分钟" then
		toast("等待15分钟",1)
		mSleep(15*60*1000);
		toast("15分钟到",1)
		mSleep(1000);
		goto beginAtGame;
	elseif switch == "等待30分钟" then
		toast("等待30分钟",1)
		mSleep(30*60*1000);
		toast("30分钟到",1)
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
	sendEmail(email,"领取来自GameLoft的礼物",getDeviceName());
	mSleep(1000);
	tap(1015,582);
	mSleep(5000);
	tap(569,582);
	mSleep(2000);
	tap(1015,582);
	mSleep(2000);
end
function receivePrizeAtGame_i68()
	--done
	mSleep(1000);
	tap(670,700);
	mSleep(1000);
	tap(1200,680);
	mSleep(1500);
	return -1;
end
function worker_i68()
	if place == -3 then
		toast("网络未同步",1);
		mSleep(1000);
		state=-1;
	elseif place == 3.1 then
		toast("在多人车库",1)
		state=-3;
	elseif place == 0 then
		toast("在大厅",1);
		if mode == "多人刷积分声望" then 
			state=toPVP_i68();
		elseif mode == "赛事模式" then
			state=toDailyGame_i68();
		end
	elseif place == 1 then
		toast("在多人",1);
		if mode == "多人刷积分声望" then 
			state=0;
		elseif mode == "赛事模式" then
			back_i68();
			state=toDailyGame_i68();
		end
	elseif place == -1 then
		toast("不在大厅，不在多人,回到大厅",1);
		state=backHome_i68();
		if mode == "多人刷积分声望" then 
			state=toPVP_i68();
		elseif mode == "赛事模式" then
			state=toDailyGame_i68();
		end
	elseif place == 2 then
		toast("在结算",1);
		state=-4;
	elseif place == 3 then
		toast("在游戏",1);
		state=-5;
	elseif place == -2 then
		toast("登录界面",1);
		state=Login_i68();
	elseif place == 4 then
		toast("奖励界面",1);
		receivePrizeFromGL_i68();
		state=-1;
	elseif place == 5 then
		toast("在赛事",1);
		if mode == "赛事模式" then 
			state=chooseGame_i68();
			validateGame=true;
		elseif mode == "多人刷积分声望" then 
			back_i68();
			state=-1;
		end
	elseif place == 6 then
		toast("赛事开始界面",1);
		if mode == "赛事模式" then 
			if validateGame == false then
				back_i68();
				state = -1;
			elseif validateGame == true then
				state=gametoCarbarn_i68();
			end
		elseif mode == "多人刷积分声望" then 
			backHome_i68();
			state=-1;
		end
	elseif place == 7 then
		toast("领奖界面",1);
		state=receivePrizeAtGame_i68();
	elseif place == 8 then
		toast("多人联赛介绍界面",1);
		tap(1120,140);
		mSleep(1000);
		state=-1;
	elseif place == 9 then
		toast("解锁或升星",1);
		tap(460,675);
		mSleep(2000);
		state=-1;
	elseif place == 10 then
		toast("开始的开始",1);
		tap(660,600);--按下开始
		mSleep(10000);
		state=-1;	
	elseif place == 11 then
		toast("段位升级",1);
		log4j("段位升级");
		tap(1175,680);--继续
		mSleep(2000);
		state=-1;
	elseif place == 12 then
		toast("声望升级",1);
		log4j("声望升级");
		tap(660,660);--确定
		mSleep(2000);
		state=-1;
	elseif place == 13 then
		--undone
		toast("未能连接到服务器",1);
		tap(967,215);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 14 then
		toast("断开连接",1);
		tap(1100,670);--继续
		mSleep(2000);
		state=-1;
	elseif place == 15 then
		--undone
		toast("连接错误",1);
		tap(569,437);--重试
		mSleep(2000);
		state=-1;
	elseif place == 16 then
		sendEmail(email,"账号被顶,等待"..tostring(timeout2).."分钟",getDeviceName());
		toast("账号被顶",1);
		mSleep(1000);
		toast("等待"..tostring(timeout2).."分钟",1)
		--[[
		for i= 1,timeout2*1000*60,1 do
			toast(tostring((timeout2*60-i) - ((timeout2*60-i)%0.01)).."秒后重新登录",0.7)
			mSleep(1000);
		end
		]]--
		mSleep(timeout2*60*1000);
		sendEmail(email,"账号被顶,等待完成",getDeviceName());
		toast("等待完成",1);
		tap(1140,252);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 17 then
		toast("匹配中",1);
		state=-6;
	elseif place == 18 then
		--undone
		toast("VIP会员到期",1);
		tap(883,150);--关闭
		mSleep(2000);
		state=-1;
	elseif place == 19 then
		LoginTimes=LoginTimes+1;
		--undone
		if LoginTimes >=20 then 
			toast("登录延时",1);
			mSleep(1000);
			restartApp();
			LoginTimes=0;
			state=-1;
		else 
			toast("登陆中",1);
			state=-1;
		end
	elseif place == 20 then
		--undone
		toast("俱乐部人气很旺",1);
		tap(313,495);--稍后查看
		mSleep(2000);
		state=-1;
	elseif place == 21 then
		toast("段位降级",1);
		log4j("段位降级");
		tap(660,550);--稍后查看
		mSleep(1000);
		state=-1;
	else
		toast("不知道在哪",1)
		state=-1;
	end
end
math.randomseed(tostring(os.time()):reverse():sub(1, 7));--随机数初始化
width,height = getScreenSize();
if width == 1536 and height == 2048 then         
	ret = dialogRet("告知\n本脚本不支持完全您的设备分辨率，脚本可能出错，是否继续运行此脚本","是","否",0,0);
	if ret ~= 0 then    --如果按下"否"按钮
		toast("脚本停止",1);
		mSleep(700);
		luaExit();        --退出脚本
	end
end
if not ((width == 640 and height == 1136) or (width == 750 and height == 1334) or(width == 1536 and height == 2048)) then         
	ret = dialogRet("告知\n本脚本不支持您的设备分辨率，是否继续运行此脚本","是","否",0,0);
	if ret ~= 0 then    --如果按下"否"按钮
		toast("脚本停止",1);
		mSleep(700);
		luaExit();        --退出脚本
	end
end
ShowUI();
if savePower == "开" then
	toast("降低屏幕亮度",2);
	setBacklightLevel(0);--屏幕亮度调制最暗
end
initTable();
log4j("脚本开始");
toast("脚本开始",10);
runApp("com.Aligames.kybc9");
supermode=mode;
timeout=tonumber(timeout);
timeout2=tonumber(timeout2);
skipcar=tonumber(skipcar);
if width == 640 and height == 1136 then --iPhone SE,5,5S,iPod touch 5
	::flag_SE::place=checkPlace_SE();
	if checkplacetimes > 2 then
		mSleep(1000);
	end
	if checkplacetimes>=25 then
		checkplacetimes=0;
		restartApp();
		toast("等待30秒",1)
		mSleep(30000);
		place=404;
	end
	worker_SE();
	if state == -1 then state=0; checkplacetimes=checkplacetimes+1; goto flag_SE;
	elseif state == -2 then state=0; checkplacetimes=0; goto stop_SE;
	elseif state == -3 then state=0; back_SE(); checkplacetimes=0; goto flag_SE; 
	elseif state == -4 then state=0; checkplacetimes=0; goto backFromLines_SE;
	elseif state == -5 then state=0; checkplacetimes=0; goto autoMobile_SE;
	elseif state == -6 then state=0; checkplacetimes=0; goto waitBegin_SE;
	end
	checkplacetimes=0; 
	state2=toCarbarn_SE();
	if state2 == 0 then state2=0; goto flag_SE; 
	elseif state2 == -1 then state2=0; goto stop_SE;
	end
	::chooseCar_SE::chooseCar_SE();
	::waitBegin_SE::state=waitBegin_SE();
	if state == -1 then state=0; goto flag_SE; end 
	::autoMobile_SE::autoMobile_SE();
	::backFromLines_SE::backFromLines_SE();
	mSleep(5000);
	goto flag_SE;
	::stop_SE::log4j("脚本停止");
elseif width == 1536 and height == 2048 then --TheNewiPad/iPad 4/Air/Air2/Pro 9.7
	checkplacetimes=0;
	::flag_Air::place=checkPlace_Air();
	if checkplacetimes > 2 then
		mSleep(1000);
	end
	if checkplacetimes>=25 then
		checkplacetimes=0;
		restartApp();
		toast("等待30秒",1)
		mSleep(30000);
		place=404;
	end
	worker_Air();
	if state == -1 then state=0; checkplacetimes=checkplacetimes+1; goto flag_Air;
	elseif state == -2 then state=0; checkplacetimes=0; goto stop_Air;
	elseif state == -3 then state=0; back_SE(); checkplacetimes=0; goto flag_Air; 
	elseif state == -4 then state=0; checkplacetimes=0; goto backFromLines_Air;
	elseif state == -5 then state=0; checkplacetimes=0; goto autoMobile_Air;
	elseif state == -6 then state=0; checkplacetimes=0; goto waitBegin_Air;
	end
	checkplacetimes=0; 
	state2=toCarbarn_Air();
	if state2 == 0 then state2=0; goto flag_Air; 
	elseif state2 == -1 then state2=0; goto stop_Air;
	end
	::chooseCar_Air::chooseCar_Air();
	::waitBegin_Air::state=waitBegin_Air();
	if state == -1 then state=0; goto flag_Air; end 
	::autoMobile_Air::autoMobile_Air();
	::backFromLines_Air::backFromLines_Air();
	checkplacetimes=0;
	mSleep(5000);
	goto flag_Air;
	::stop_Air::log4j("脚本停止");
elseif width == 750 and height == 1334 then
	checkplacetimes=0;
	::flag_i68::place=checkPlace_i68();
	if checkplacetimes > 2 then
		mSleep(1000);
	end
	if checkplacetimes>=25 then
		checkplacetimes=0;
		restartApp();
		toast("等待30秒",1)
		mSleep(30000);
		place=404;
	end
	worker_i68();
	if state == -1 then state=0; checkplacetimes=checkplacetimes+1; goto flag_i68;
	elseif state == -2 then state=0; checkplacetimes=0; goto stop_i68;
	elseif state == -3 then state=0; back_i68(); checkplacetimes=0; goto flag_i68; 
	elseif state == -4 then state=0; checkplacetimes=0; goto backFromLines_i68;
	elseif state == -5 then state=0; checkplacetimes=0; goto autoMobile_i68;
	elseif state == -6 then state=0; checkplacetimes=0; goto waitBegin_i68;
	end
	checkplacetimes=0; 
	state2=toCarbarn_i68();
	if state2 == 0 then state2=0; goto flag_i68; 
	elseif state2 == -1 then state2=0; goto stop_i68;
	end
	::chooseCar_i68::chooseCar_i68();
	::waitBegin_i68::state=waitBegin_i68();
	if state == -1 then state=0; goto flag_i68; end 
	::autoMobile_i68::autoMobile_i68();
	::backFromLines_i68::backFromLines_i68();
	mSleep(5000);
	goto flag_i68;
	::stop_i68::log4j("脚本停止");
else
	::flag_SE::place=checkPlace_SE();
	if checkplacetimes > 2 then
		mSleep(1000);
	end
	if checkplacetimes>=25 then
		checkplacetimes=0;
		restartApp();
		toast("等待30秒",1)
		mSleep(30000);
		place=404;
	end
	worker_SE();
	if state == -1 then state=0; checkplacetimes=checkplacetimes+1; goto flag_SE;
	elseif state == -2 then state=0; checkplacetimes=0; goto stop_SE;
	elseif state == -3 then state=0; back_SE(); checkplacetimes=0; goto flag_SE; 
	elseif state == -4 then state=0; checkplacetimes=0; goto backFromLines_SE;
	elseif state == -5 then state=0; checkplacetimes=0; goto autoMobile_SE;
	elseif state == -6 then state=0; checkplacetimes=0; goto waitBegin_SE;
	end
	checkplacetimes=0; 
	state2=toCarbarn_SE();
	if state2 == 0 then state2=0; goto flag_SE; 
	elseif state2 == -1 then state2=0; goto stop_SE;
	end
	::chooseCar_SE::chooseCar_SE();
	::waitBegin_SE::state=waitBegin_SE();
	if state == -1 then state=0; goto flag_SE; end 
	::autoMobile_SE::autoMobile_SE();
	::backFromLines_SE::backFromLines_SE();
	mSleep(5000);
	goto flag_SE;
	::stop_SE::log4j("脚本停止");
end
sendEmail(email,"[A9]脚本停止"..getDeviceName(),readFile(userPath().."/res/A9log.txt"))
closeApp("com.Aligames.kybc9");--关闭游戏
lockDevice();
--return 0;