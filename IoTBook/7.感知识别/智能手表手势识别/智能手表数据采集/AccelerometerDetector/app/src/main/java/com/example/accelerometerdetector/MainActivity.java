package com.example.accelerometerdetector;

import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.support.wearable.activity.WearableActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MainActivity extends WearableActivity {
    private static final DecimalFormat DataFormatter = new DecimalFormat("000.0000");
    private Button toggle;
    private String outputPath;

    private Sensor accSensor;
    private Sensor gyroSensor;

    private SensorManager sensorManager;
    private SensorEventListener listener;
    private long startTime;
    private List<Record> accData = new ArrayList<>();
    private List<Record> gyroData = new ArrayList<>();
    private boolean isActive = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);

        accSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        gyroSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
        listener = new SensorDataListener();

        outputPath = Environment.getExternalStorageDirectory().getPath() + "/111.data";
        toggle = findViewById(R.id.main_button_toggle);
        toggle.setOnClickListener(this::toggle_button_click);
    }

    @Override
    protected void onResume() {
        if (isActive)
            sensorManager.registerListener(listener, accSensor, SensorManager.SENSOR_DELAY_FASTEST);
            sensorManager.registerListener(listener, gyroSensor, SensorManager.SENSOR_DELAY_FASTEST);
        super.onResume();
    }

    @Override
    protected void onPause() {
        if (isActive)
            sensorManager.unregisterListener(listener);
        super.onPause();
    }

    private void toggle_button_click(View v) {
        if (checkSelfPermission("android.permission.WRITE_EXTERNAL_STORAGE") != PackageManager.PERMISSION_GRANTED) {
            Log.e("i", "Storage Failed");
            return;
        }

        if (toggle.getText() == getString(R.string.main_button_stop)) {
            toggle.setText(R.string.main_button_save);
            toggle.setBackgroundColor(Color.parseColor("#FF0000"));
            sensorManager.unregisterListener(listener);
            WriteDataTask task = new WriteDataTask();
            task.execute((Void) null);
            isActive = false;
        } else {
            sensorManager.registerListener(listener, accSensor, SensorManager.SENSOR_DELAY_FASTEST);
            sensorManager.registerListener(listener, gyroSensor, SensorManager.SENSOR_DELAY_FASTEST);
            startTime = new Date().getTime();
            toggle.setText(R.string.main_button_stop);
            toggle.setBackgroundColor(Color.parseColor("#FFFFFF"));
            isActive = true;
        }
    }

    private class SensorDataListener implements SensorEventListener {
        @Override
        public void onSensorChanged(SensorEvent event) {
            if(!isActive) return;
            switch(event.sensor.getType()) {
                case Sensor.TYPE_ACCELEROMETER:
                    accData.add(new Record(new Date(), event.values[0], event.values[1], event.values[2]));
                    break;
                case Sensor.TYPE_GYROSCOPE:
                    gyroData.add(new Record(new Date(), event.values[0], event.values[1], event.values[2]));
                    break;
            }

        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }
    }

    private class WriteDataTask extends AsyncTask<Void, Void, Void> {
        private long stopTime;

        @Override
        protected void onPreExecute() {

        }

        @Override
        protected void onPostExecute(Void aVoid) {
            toggle.setText(getString(R.string.message_time_usage, Long.toString(stopTime - startTime)));
            Log.e("i","计时：start:"+Long.toString(+startTime)+" stop:"+Long.toString(stopTime)+" -:"+Long.toString(stopTime-startTime) );
        }

        @Override
        protected Void doInBackground(Void... params) {
            stopTime = new Date().getTime();
            try {
                File file = new File(outputPath);
                if (file.exists())
                    file.delete();
                BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(outputPath, true));

                int size = Math.min(accData.size(), gyroData.size());
                Log.e("i", Long.toString(accData.size()) + " " + Long.toString(gyroData.size()));
                Long first, last;

                first = accData.get(0).date.getTime();
                last = accData.get(size - 1).date.getTime();
                Log.e("i", "加速度：first:" + Long.toString(first) + " last:" + Long.toString(last) + " -:" + Long.toString(last - first));
                first = gyroData.get(0).date.getTime();
                last = gyroData.get(size - 1).date.getTime();
                Log.e("i", "陀螺仪：first:" + Long.toString(first) + " last:" + Long.toString(last) + " -:" + Long.toString(last - first));


                for (int i = 0; i < size; ++i) {
                    Record record1 = accData.get(i), record2 = gyroData.get(i);
                    bufferedWriter.write(record1.date.getTime() + " " +
                            DataFormatter.format(record1.x) + " " + DataFormatter.format(record1.y) + " " + DataFormatter.format(record1.z) + " " +
                            DataFormatter.format(record2.x) + " " + DataFormatter.format(record2.y) + " " + DataFormatter.format(record2.z) + " "
                    );
                    bufferedWriter.write("\n");
                }
                accData.clear();
                gyroData.clear();

                bufferedWriter.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }
    }
}
