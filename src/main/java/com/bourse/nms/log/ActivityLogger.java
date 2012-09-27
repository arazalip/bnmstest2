package com.bourse.nms.log;

import com.bourse.nms.entity.Settings;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;


/**
 * logs orders and trades
 */
public class ActivityLogger {

    private final BlockingQueue<String> preOpeningQueue;
    private final BlockingQueue<String> tradingQueue;
    private final String logPath;
    private static final Logger log = Logger.getLogger(ActivityLogger.class);
    volatile boolean working = true;
    private Thread preOpeningWriterThread;
    private Thread tradingWriterThread;
    @Autowired
    private Settings settings;

    public enum LogType {
        PRE_OPENING, TRADING
    }

    public ActivityLogger(int activityLoggerQueueSize, String logPath) {
        preOpeningQueue = new ArrayBlockingQueue<>(activityLoggerQueueSize);
        tradingQueue = new ArrayBlockingQueue<>(activityLoggerQueueSize);
        this.logPath = logPath;
    }

    /**
     * initializes activity logger with a file that will be creates in log path
     *
     * @param fileName file name
     * @throws IOException
     */
    public void init(String fileName) throws IOException {
        working = true;
        final long systemTime = System.currentTimeMillis();
        final String tradingLogPath = logPath + File.separator + fileName + "_trading." + systemTime + ".log";
        final String preOpeningLogPath = logPath + File.separator + fileName + "_preopening." + systemTime + ".log";
        final BufferedWriter preOpeningWriter = new BufferedWriter(new FileWriter(preOpeningLogPath));
        final BufferedWriter tradingWriter = new BufferedWriter(new FileWriter(tradingLogPath));
        settings.setTradingLogPath(tradingLogPath);
        settings.setPreOpeningLogPath(preOpeningLogPath);

        preOpeningWriterThread = new Thread() {
            public void run() {
                try {
                    while (working) {
                        if (preOpeningQueue != null) {
                            final String line = preOpeningQueue.take();
                            preOpeningWriter.write(line + "\n");
                            if (preOpeningQueue.isEmpty()) {
                                preOpeningWriter.flush();
                            }
                        }
                    }
                    preOpeningWriter.close();
                } catch (InterruptedException | IOException e) {
                    log.warn("exception on writing activity log", e);
                }
            }
        };
        preOpeningWriterThread.start();
        tradingWriterThread = new Thread() {
            public void run() {
                try {
                    while (working) {
                        if (tradingQueue != null) {
                            final String line = tradingQueue.take();
                            tradingWriter.write(line + "\n");
                            if (tradingQueue.isEmpty()) {
                                tradingWriter.flush();
                            }
                        }
                    }
                    tradingWriter.close();
                } catch (InterruptedException | IOException e) {
                    log.warn("exception on writing activity log", e);
                }
            }
        };
        tradingWriterThread.start();
    }

    public void closeWriters() {
        while (!preOpeningQueue.isEmpty() || !tradingQueue.isEmpty()){
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                log.warn("exception on waiting for activity log queues get empty", e);
            }
        }
        preOpeningWriterThread.interrupt();
        tradingWriterThread.interrupt();
        working = false;
    }


    public void log(String msg) {
        if (!working) {
            log.warn("got message to log when working is false: " + msg);
        }
        switch (settings.getStatus()) {
            case PRE_OPENING:
                preOpeningQueue.add(msg);
                break;
            case TRADING:
                tradingQueue.add(msg);
                break;

        }
    }

}
