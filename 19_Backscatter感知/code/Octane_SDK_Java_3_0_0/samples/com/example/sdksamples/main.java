package com.example.sdksamples;

import com.impinj.octane.ImpinjReader;

public class main {
    public static void main(String args[]) {
        String hostname = "169.254.1.1";
        SingleTagReader reader = new SingleTagReader(hostname);
        reader.read();
    }
}