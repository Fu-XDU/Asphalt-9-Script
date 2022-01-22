package com.script.a9script.controller;

import com.script.a9script.service.Asphalt9Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.sql.SQLException;

@RestController
@RequestMapping("/")
public class Asphalt9Controller {
    private Asphalt9Service a9s;

    @Autowired
    public void setAsphalt9Service(Asphalt9Service asphalt9Service) {
        this.a9s = asphalt9Service;
    }

    @ResponseBody
    @RequestMapping("/a9")
    public String log(String content, String udid) throws IOException {
        return a9s.log(content, udid);
    }

    @ResponseBody
    @RequestMapping("/a9log")
    public String printLog(String udid) {
        return a9s.printlog(udid);
    }

    @ResponseBody
    @RequestMapping("/a9control")
    public String control(String command, String udid) throws SQLException {
        return a9s.control(command, udid);
    }

    @ResponseBody
    @RequestMapping("/a9getCommand")
    public String getCommand(String udid) throws SQLException {
        return a9s.getCommand(udid);
    }

    /*
    @ResponseBody
    @RequestMapping("/a9Unsubscribe")
    public String unsubscribe(String token) {
        return a9s.unsubscribe(token);
    }
    */

    @ResponseBody
    @RequestMapping("/a9Special_UDID")
    public String change_Special_UDID() {
        a9s.Special_UDID = !a9s.Special_UDID;
        return "特殊UDID功能已经" + (a9s.Special_UDID ? "打开" : "关闭");
    }

    /*
    @ResponseBody
    @RequestMapping("/a9switchAccount")
    public String switchAccount(String udid) throws SQLException {
        return a9s.switchAccount(udid);
    }
     */

    /*
    @ResponseBody
    @RequestMapping("/a9accountDone")
    public void accountDone(String udid, String account) {
        a9s.accountDone(udid, account);
    }
    */

    @ResponseBody
    @PostMapping("/a9saveSettings")
    public void saveSettings(@RequestParam("udid") String udid, @RequestParam("settings") String settings) {
        a9s.saveSettings(udid, settings);
    }

    @ResponseBody
    @RequestMapping("/a9getSettings")
    public String getSettings(String udid) {
        return a9s.getSettings(udid);
    }
}
