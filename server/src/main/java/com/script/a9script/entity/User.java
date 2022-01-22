package com.script.a9script.entity;

public class User {
    int state;
    String setting;

    public User(int state, String setting) {
        this.state = state;
        this.setting = setting;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public String getSetting() {
        return setting;
    }

    public void setSetting(String setting) {
        this.setting = setting;
    }
}