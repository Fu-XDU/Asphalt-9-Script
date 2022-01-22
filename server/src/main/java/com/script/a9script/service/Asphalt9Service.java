package com.script.a9script.service;

import com.script.a9script.entity.Config;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Slf4j
@Service
public class Asphalt9Service {
    private static final String logPath = "/app/A9log/";
    private static final String configPath = logPath + "settings.ser";
    public boolean Special_UDID = true;

    private final Config config = new Config(configPath);

    @Autowired
    public Asphalt9Service() throws IOException, ClassNotFoundException {
        // 添加hook thread，重写其run方法
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try {
                config.Persistence(configPath);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }));
    }

    public String log(String content, String udid) throws IOException {
        if (udid.length() != 40) return "UDID格式错误，请检查链接中是否有%20，如果有请删除后重试。";
        //先删除昨日日志
        File file = new File(logPath + udid);
        if (content.equals("Delete_log")) {
            if (file.exists() && !file.delete()) return "Log delete error";
            return "Success";
        }
        content = getTime("HH:mm:ss") + ": " + content + "\r\n";
        //将内容写入文件头作为第一行
        RandomAccessFile src = new RandomAccessFile(logPath + udid, "rw");
        int srcLength = (int) src.length();
        byte[] buff = new byte[srcLength];
        src.read(buff, 0, srcLength);
        src.seek(0);
        src.write(content.getBytes());
        src.seek(content.getBytes().length);
        src.write(buff);
        src.close();
        return "Success";
    }

    public String printlog(String udid) {
        String special_UDID = udid;
        if (Special_UDID && udid.equals("2")) udid = "yourudid";
        if (udid.length() != 40) return "UDID格式错误，请检查链接中是否有%20，如果有请删除后重试。";
        File logfile = new File(logPath + udid);
        if (!logfile.exists())
            return "<h>未找到设备" + special_UDID + "相关日志</h>";
        StringBuilder result = new StringBuilder();
        try {
            BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(logfile), StandardCharsets.UTF_8));//构造一个BufferedReader类来读取文件
            String s;
            while ((s = br.readLine()) != null) {
                //使用readLine方法，一次读一行
                s = "<p>" + System.lineSeparator() + s + "</p>";
                result.append(s);
            }
            br.close();
        } catch (Exception e) {
            log.error(String.valueOf(e));
        }
        return result.toString();
    }

    public String control(String command, String udid) throws SQLException {
        if (!"01234567".contains(command)) return "指令错误";
        if (Special_UDID && udid.equals("2")) udid = "yourudid";
        if (udid.length() != 40) return "UDID格式错误";
        if (!config.Have(udid)) return "从未运行过脚本";
        int c = Integer.parseInt(command);
        if ("014".contains(command)) {
            config.SetState(udid, c);
        } else {
            String settings = config.GetSetting(udid);
            String[] settingsList = settings.split("\\|");
            switch (command) {
                case "2":
                    settingsList[0] = "多人刷声望";
                    break;
                case "3":
                    settingsList[0] = "赛事模式";
                    break;
                case "5":
                    settingsList[1] = "等60分钟";
                    break;
                case "6":
                    settingsList[1] = "去刷多人";
                    break;
                case "7":
                    settingsList[1] = "多人刷包";
                    break;
            }
            String newSettings = "";
            for (String setting : settingsList)
                newSettings += setting + "|";
            newSettings = newSettings.substring(0, newSettings.length() - 1);
            if (settingsList.length == 15)
                newSettings += "|";
            config.SetSetting(udid, newSettings);
        }
        switch (c) {
            case 0:
                return "暂停指令发送成功，脚本会在赛道外自动暂停";
            case 1:
                return "开始指令发送成功，脚本会在10秒内恢复运行";
            case 2:
                return "转换指令发送成功，已将脚本模式转换为多人刷声望";
            case 3:
                return "转换指令发送成功，已将脚本模式转换为赛事模式";
            case 4:
                return "停止指令发送成功，脚本会在赛道外自动停止，此过程不可逆";
            case 5:
                return "转换指令发送成功，已将赛事没油没票后改为等待60分钟";
            case 6:
                return "转换指令发送成功，已将赛事没油没票后改为去刷多人";
            case 7:
                return "多人刷包功能已取消";
            //return "转换指令发送成功，已将脚本模式转换为多人刷包";
        }
        return "未知指令，解析失败";
    }

    public String getCommand(String udid) {
        return this.config.Have(udid) ? this.config.GetSetting(udid) : "1";
    }

    /*
        public String unsubscribe(String token) {
            String regex = "^[A-Fa-f0-9]+$";
            if (token.matches(regex)) {
                DbService dbService = newDb();
                String email = Integer.parseInt(token, 16) - 93847293 + "" + "@qq.com";//将16进制的token转为10进制，token前无0x,组装成邮箱格式
                if (dbService.handleSql("delete from Emails where email=\"" + email + "\"").equals("1"))
                    return "邮件退订成功！";
                logger.info("a9Unsubscribe,email:" + email);
            }
            return "邮件退订失败！";
        }

        public String switchAccount(String udid) throws SQLException {
            String res;
            if (!udid.equals("yourudid")) {
                res = "null";
            } else {
                String sql = "select account from Accounts where state=1";
                ResultSet result = newDb().selectReturnSet(sql);
                if (result.next())
                    res = result.getString("account");
                else
                    res = "null";
            }
            return res;
        }

        public void accountDone(String udid, String account) {
            if (udid.equals("yourudid")) {
                newDb().handleSql("UPDATE Accounts SET state=0 where account='" + account + "'");
            }
        }
    */
    public void saveSettings(String udid, String settings) {
        config.SetConfig(udid, 1, settings);
    }

    public String getSettings(String udid) {
        return config.GetSetting(udid);
    }

    public String getTime(String fmt) {
        SimpleDateFormat sdf = new SimpleDateFormat(fmt);
        return sdf.format(new Date());
    }
}
