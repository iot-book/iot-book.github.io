package com.example.sdksamples;
import com.impinj.octane.*;

import java.io.BufferedWriter;
import java.util.List;
import java.lang.Thread;
import java.util.Scanner;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.io.OutputStreamWriter;

public class SingleTagReader implements TagReportListener {
    private ImpinjReader reader;
    private String hostname;
    private static CsvWriter csvW = new CsvWriter("C:\\Users\\wisys\\Documents\\RfidLoc&Track\\Data",
                                                             "time,antenna,rssi,phase\n");
    //"time,antenna,rssi,phase,channelNum,epc,doppler,tid,model,pcbits

    private ServerSocket serv;
    private Socket curSkt;
    private BufferedWriter sktWriter;
    private final static int portNum = 20000;


    private final static int maxReadCnt = 1000000;
    private final static int antennaNum = 1;
    private boolean saveFile = false; //save data to file or send data via TCP

    private int readCnt;

    public SingleTagReader(String hstName) {
        this.hostname = hstName;
        this.reader = new ImpinjReader();
        readCnt = 0;

        if(!saveFile) {
            try {
                serv = new ServerSocket(portNum, 100, InetAddress.getByName("localhost"));
                System.out.println("Waiting for connection...");
                curSkt = serv.accept();
                System.out.println("Connection set up.");
                sktWriter = new BufferedWriter(new OutputStreamWriter(curSkt.getOutputStream()));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


    }

    private void configureReader() {
        try {
            Settings settings = reader.queryDefaultSettings();
            ReportConfig report = settings.getReport();
            report.setIncludeAntennaPortNumber(true);
            report.setIncludePhaseAngle(true);
            report.setIncludePeakRssi(true);
            report.setIncludeChannel(true);
            report.setIncludeDopplerFrequency(true);
            report.setIncludeLastSeenTime(true);
            report.setIncludeFastId(true);
            report.setIncludePcBits(true);

            AntennaConfigGroup antennas = settings.getAntennas();
            antennas.disableAll();

            AntennaConfig[] antennaAry = new AntennaConfig[antennaNum];
            for(int i = 0; i < antennaNum; i++) {
                antennaAry[i] = antennas.getAntenna(i + 1);
                antennaAry[i].setEnabled(true);
                antennaAry[i].setIsMaxTxPower(false);
                antennaAry[i].setTxPowerinDbm(32.5);
            }

            settings.setReaderMode(ReaderMode.MaxThroughput);
            settings.setSearchMode(SearchMode.DualTarget);
            settings.setSession(0);
            settings.setTagPopulationEstimate(1);

            reader.applySettings(settings);
        } catch (OctaneSdkException e) {
            System.out.println(e.getMessage());
        }
    }

    public void read() {
        try {
            reader.connect(hostname);
            reader.setTagReportListener(this);
            configureReader();

            csvW.init();
            reader.start();

            Scanner s = new Scanner(System.in);
            s.nextLine();

//            while(readCnt <= maxReadCnt)
//                Thread.sleep(1000);

            reader.stop();
            csvW.close();
            if(!saveFile)
                curSkt.close();

            reader.disconnect();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    @Override
    public void onTagReported(ImpinjReader reader, TagReport report) {
        List<Tag> tags = report.getTags();
        for(Tag tag : tags) {
            long time = tag.getLastSeenTime().getLocalDateTime().getTime();
            int antenna = tag.getAntennaPortNumber() - 1;
            double rssi =  tag.getPeakRssiInDbm();
            double phase = 2 * Math.PI - tag.getPhaseAngleInRadians();
            int channelNum = (int) Math.round((tag.getChannelInMhz() - 920.625) / 0.25);
            String epc = tag.getEpc().toHexString();
            double doppler = tag.getRfDopplerFrequency();
            String tid = tag.getTid().toHexString();
            String model = tag.getModelDetails().getModelName().toString();
            short pcbits = tag.getPcBits();

            String sendStr = time + "," +
                    antenna + "," +
                    rssi  + "," +
                    phase  + /*"," +
                    channelNum  + "," +
                    epc  + "," +
                    doppler + "," +
                    tid  + "," +
                    model  + "," +
                    pcbits +*/ "\n";

            if(saveFile) {
                csvW.write(sendStr);
            } else {
                try {
                    sktWriter.write(sendStr);
                    sktWriter.flush();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            readCnt++;
            if(readCnt % 100 == 0) {
                System.out.println("Read #" + readCnt + "\n");
            }

            if(readCnt >= maxReadCnt) {
                try {
                    reader.stop();
                    csvW.close();
                    if(!saveFile)
                        curSkt.close();
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                }
                return;
            }
        }
    }
}