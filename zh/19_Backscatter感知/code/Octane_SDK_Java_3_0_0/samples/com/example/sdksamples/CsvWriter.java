package com.example.sdksamples;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.text.SimpleDateFormat;

public class CsvWriter {
    BufferedWriter out;
    String folderPath;
    String csvHead;

    public CsvWriter(String folderPath, String csvHead) {
        this.folderPath = folderPath;
        this.csvHead = csvHead;
    }

    public void init(String filePath) {
        File file = new File(filePath);
        FileWriter fileWriter;

        try {
            fileWriter = new FileWriter(file);
            out = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }
        write(csvHead);
    }

    public void init() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
        String date = sdf.format(new Date());
        //String filePath = folderPath + "/" + date + ".csv";
        String filePath = folderPath + "/test" + ".csv";
        init(filePath);
    }

    public void write(String str) {
        try {
            out.write(str);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void close() {
        if (out != null) {
            try {
                out.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
            try {
                out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            out = null;
        }
    }
}
