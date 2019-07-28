package com.example.accelerometerdetector;

import java.util.Date;

public class Record {
    public Date date;
    public float x;
    public float y;
    public float z;

    public Record(Date date, float x, float y, float z) {
        this.date = date;
        this.x = x;
        this.y = y;
        this.z = z;
    }
}
