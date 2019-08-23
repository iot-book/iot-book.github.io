package com.example.myapplication;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;


public class VoiceProcess {

    private static final int DEFAULT_SOURCE = MediaRecorder.AudioSource.MIC;
    private boolean mRecording = false;
    private  int mMinBufferSize ;
    private AudioRecord mAudioRecord = null;


    public boolean StartRecording(){
        int mMinBufferSize = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT);
        mAudioRecord = new AudioRecord(DEFAULT_SOURCE, 44100, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT, mMinBufferSize);
        mAudioRecord.startRecording();
        mRecording = true;
        Thread recordingThread = new Thread(new AudioRecordingRunable());
        recordingThread.start();
        Log.d("audio", "thread started");
        return true;
    }

    public boolean StopRecording(){
        mRecording = false;
        return true;
    }

    private class AudioRecordingRunable implements Runnable{
        @Override
        public void run(){
            while(mRecording){
                byte[] buffer = new byte[mMinBufferSize];
                int ret = mAudioRecord.read(buffer, 0, mMinBufferSize);
                if(ret == AudioRecord.SUCCESS){
                    Log.d("audio", "recording " + ret + " bytes");
                }
            }
        }
    }

}
