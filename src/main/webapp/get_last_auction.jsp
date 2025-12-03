<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = DBConnection.getConnection();
        
        String sql = "SELECT AuctionID FROM AUCTION ORDER BY STARTTIME DESC, AuctionID DESC";
        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            out.print(rs.getInt(1));
        } else {
            out.print("-1");
        }
    } catch (Exception e) {
        out.print("-1");
    } finally {
        if(rs!=null) rs.close();
        if(pstmt!=null) pstmt.close();
        if(conn!=null) conn.close();
    }
%>