<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String idParam = request.getParameter("auctionId");
    if (idParam == null || idParam.trim().isEmpty()) {
        out.print("-1");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        String sql = "SELECT Start_Price, CurrentHighestPrice FROM AUCTION WHERE AuctionID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(idParam));
        rs = pstmt.executeQuery();

        if (rs.next()) {
            long startPrice = rs.getLong("Start_Price");
            long currentPrice = rs.getLong("CurrentHighestPrice");

            long minBid = (currentPrice > 0) ? currentPrice + 1 : startPrice;
            
            out.print(minBid);
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