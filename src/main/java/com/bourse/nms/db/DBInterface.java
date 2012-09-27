package com.bourse.nms.db;

import org.apache.commons.lang.time.FastDateFormat;
import org.apache.log4j.Logger;

import javax.sql.DataSource;
import java.sql.*;

/**
 * Created by IntelliJ IDEA.
 * User: araz
 * Date: 8/5/12
 * Time: 8:50 PM
 */
public class DBInterface {

    private static final Logger log = Logger.getLogger(DBInterface.class);
    public static final FastDateFormat MYSQL_DATE_FORMAT = FastDateFormat.getInstance("yyyy-MM-dd HH:mm:ss");

    private final DataSource ds;

    protected DBInterface(final DataSource ds) {
        this.ds = ds;
    }
    protected Connection getConnection() throws SQLException {
        return ds.getConnection();
    }

    public void insertSessionData(long startTime, long stopTime, int preOpeningLength, int tradingLength, int buyOrderCount, int sellOrderCount, int totalGeneratedOrdersCount, int preOpeningPercent, int matchPercent, int meanPutOrder, int minPutOrder, int maxPutOrder, int meanTrade, int minTrade, int maxTrade, long totalTradeCost, String preOpeningLogPath, String tradingLogPath) throws SQLException {
        Connection c = null;
        PreparedStatement ps = null;
        try{
            c = getConnection();
            ps = c.prepareStatement("INSERT INTO sessions (`start_timestamp`, `stop_timestamp`, `pre_opening_time`, " +
                    "`trading_time`, `buy_order_count`, `sell_order_count`, `generated_orders_count`, `preopening_percent`, " +
                    "`match_percent`, `mean_put_order`, `min_put_order`, `max_put_order`, " +
                    "`mean_trade`, `min_trade`, `max_trade`, `total_trade_cost`, `pre_opening_log_file_path`, `trading_log_file_path`) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
            ps.setTimestamp(1, new Timestamp(startTime));
            ps.setTimestamp(2, new Timestamp(stopTime));
            ps.setInt(3, preOpeningLength);
            ps.setInt(4, tradingLength);
            ps.setInt(5, buyOrderCount);
            ps.setInt(6, sellOrderCount);
            ps.setInt(7, totalGeneratedOrdersCount);
            ps.setInt(8, preOpeningPercent);
            ps.setInt(9, matchPercent);
            ps.setInt(10, meanPutOrder);
            ps.setInt(11, minPutOrder);
            ps.setInt(12, maxPutOrder);
            ps.setInt(13, meanTrade);
            ps.setInt(14, minTrade);
            ps.setInt(15, maxTrade);
            ps.setLong(16, totalTradeCost);
            ps.setString(17, preOpeningLogPath);
            ps.setString(18, tradingLogPath);
            ps.executeUpdate();
        }finally {
            attemptClose(ps);
            attemptClose(c);
        }
    }

    public static Statement createStatement(Connection connection) throws Exception {
        if (connection == null) {
            throw new Exception("Connection is null. call createStatement after getConnection");
        }

        if (connection.isClosed()) {
            throw new Exception("Cannot createStatement since Connection is closed.");
        }

        return connection.createStatement();
    }

    public static void attemptClose(Statement s) {
        if (s != null)
            try {
                if (!s.isClosed())
                    s.close();
            } catch (SQLException e) {
                log.warn("SQLException in attemptClose statement", e);
            }
    }

    public static void attemptClose(Connection c) {
        if (c != null)
            try {
                if (!c.isClosed())
                    c.close();
            } catch (SQLException e) {
                log.warn("SQLException in attemptClose connection", e);
            }
    }

    public static void attemptClose(ResultSet r) {
        if (r != null)
            try {
                r.close();
            } catch (SQLException e) {
                log.warn("SQLException in attemptClose ResultSet", e);
            }
    }

    public static void makeAutoCommit(Connection c) {
        if (c != null)
            try {
                if (!c.isClosed() && !c.getAutoCommit())
                    c.setAutoCommit(true);
            } catch (SQLException e) {
                log.warn("SQLException in makeAutoCommit connect", e);
            }
    }


}
