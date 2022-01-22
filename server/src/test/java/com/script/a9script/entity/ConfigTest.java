package com.script.a9script.entity;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ConfigTest {

    Config config = new Config();

    @Test
    void have() {
    }

    @Test
    void setState() {
    }

    @Test
    void getSetting() {
        config.SetConfig("1", 1, "before settings");
        System.out.println(config.GetSetting("1"));
        config.SetSetting("1","after settings");
        System.out.println(config.GetSetting("1"));
        System.out.println(config.GetState("1"));
        config.SetState("1",2);
        System.out.println(config.GetState("1"));
    }

    @Test
    void setSetting() {
    }

    @Test
    void setConfig() {
    }
}