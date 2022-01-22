package com.script.a9script.entity;

import lombok.extern.slf4j.Slf4j;

import java.io.*;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class Config {
    Map<String, User> data;

    public Config() {
        this.data = new HashMap<>();
    }

    public Config(String path) throws ClassNotFoundException {
        try {
            this.data = FromFile(path);
        } catch (IOException c) {
            this.data = new HashMap<>();
        }

        if (this.data == null) {
            this.data = new HashMap<>();
        }

    }

    public boolean Have(String udid) {
        return this.data.containsKey(udid);
    }

    public void SetState(String udid, int state) {
        this.data.get(udid).setState(state);
    }

    public int GetState(String udid) {
        return this.data.get(udid).getState();
    }

    public String GetSetting(String udid) {
        return this.data.get(udid).getSetting();
    }

    public void SetSetting(String udid, String setting) {
        this.data.get(udid).setSetting(setting);
    }

    public void SetConfig(String udid, int state, String setting) {
        User conf = new User(state, setting);
        this.data.put(udid, conf);
    }

    public void Persistence(String path) throws IOException {
        FileOutputStream fileOut = new FileOutputStream(path);
        ObjectOutputStream out = new ObjectOutputStream(fileOut);
        out.writeObject(this.data);
        out.close();
        fileOut.close();
        log.info("Serialized data is saved in " + path);
    }

    public Map<String, User> FromFile(String path) throws IOException, ClassNotFoundException {
        FileInputStream fileIn = new FileInputStream(path);
        ObjectInputStream in = new ObjectInputStream(fileIn);
        Map<String, User> d = (Map<String, User>) in.readObject();
        in.close();
        fileIn.close();
        log.info("Read data from " + path);
        return d;
    }
}

