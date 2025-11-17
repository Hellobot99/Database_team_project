package util;

import java.sql.*;

public class DBconnection {
    
    private static final String SERVER_IP = "localhost";
    private static final String STR_SID = "orcl";
    private static final String PORT_NUM = "1521";
    
    private static final String USER = "DBA_PROJECT"; 
    private static final String PASS = "1234";
    
    private static final String URL = "jdbc:oracle:thin:@" + SERVER_IP + ":" + PORT_NUM + ":" + STR_SID;

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}