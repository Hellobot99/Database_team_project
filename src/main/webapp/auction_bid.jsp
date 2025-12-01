<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
Connection conn = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
PreparedStatement psCheckTop = null;
PreparedStatement psDeduct = null;
PreparedStatement psRefund = null;

ResultSet rs = null;
ResultSet rsTop = null;

try {
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    if (!request.getMethod().equalsIgnoreCase("POST")) {
        out.println("잘못된 접근입니다.");
        return;
    }

    long auctionId = Long.parseLong(request.getParameter("auctionId"));
    long amount    = Long.parseLong(request.getParameter("amount"));

    conn = DBConnection.getConnection();
    conn.setAutoCommit(false);
    
    ps1 = conn.prepareStatement(
        "SELECT SellerID FROM AUCTION WHERE AuctionID = ? FOR UPDATE"
    );
    ps1.setLong(1, auctionId);
    rs = ps1.executeQuery();

    String sellerId = "";
    
    if (rs.next()) {
        sellerId = rs.getString(1);
    } else {
        conn.rollback();
        out.println("<script>");
        out.println("alert('존재하지 않는 경매입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    if (userId.equals(sellerId)) {
        out.println("<script>");
        out.println("alert('본인이 등록한 물품에는 입찰할 수 없습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String prevBidderId = null;
    long prevBidAmount = 0;

    String sqlCheckTop = "SELECT BidderID, BidAmount FROM BIDDING_RECORD " + 
                         "WHERE AuctionID = ? ORDER BY BidAmount DESC, BidTime ASC FETCH FIRST 1 ROWS ONLY";
    psCheckTop = conn.prepareStatement(sqlCheckTop);
    psCheckTop.setLong(1, auctionId);
    rsTop = psCheckTop.executeQuery();
    
    if (rsTop.next()) {
        prevBidderId = rsTop.getString("BidderID");
        prevBidAmount = rsTop.getLong("BidAmount");
    }

    java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
    ps2 = conn.prepareStatement(
        "UPDATE AUCTION SET CurrentHighestPrice = ? WHERE AuctionID = ? and CurrentHighestPrice < ? " +
        "and EXISTS (select 1 from USERS where UserId = ? and Balance >=  ?) " +
        "and Endtime > ?"
    );
    ps2.setLong(1, amount);
    ps2.setLong(2, auctionId);
    ps2.setLong(3, amount);
    ps2.setString(4, userId);
    ps2.setLong(5, amount);
    ps2.setTimestamp(6, now);
    int updated = ps2.executeUpdate();

    if (updated == 0) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('입찰 실패: 이미 마감되었거나, 가진 금액이 부족하거나, 현재 최고가보다 높은 금액만 입찰할 수 있습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String sqlDeduct = "UPDATE USERS SET Balance = Balance - ? WHERE UserID = ?";
    psDeduct = conn.prepareStatement(sqlDeduct);
    psDeduct.setLong(1, amount);
    psDeduct.setString(2, userId);
    psDeduct.executeUpdate();


    if (prevBidderId != null) {
        String sqlRefund = "UPDATE USERS SET Balance = Balance + ? WHERE UserID = ?";
        psRefund = conn.prepareStatement(sqlRefund);
        psRefund.setLong(1, prevBidAmount);
        psRefund.setString(2, prevBidderId);
        psRefund.executeUpdate();
    }

    ps3 = conn.prepareStatement(
        "INSERT INTO BIDDING_RECORD (AuctionID, BidderID, BidAmount, BidTime) " +
        "VALUES (?, ?, ?, ?)"
    );
    ps3.setLong(1, auctionId);
    ps3.setString(2, userId);
    ps3.setLong(3, amount);
    ps3.setTimestamp(4, now);
    ps3.executeUpdate();
 

    conn.commit();

    out.println("<script>");
    out.println("alert('입찰 성공!');");
    out.println("location.href='auction_list.jsp';");
    out.println("</script>");

} catch (Exception e) {
    if (conn != null) {
        try { conn.rollback(); } catch (Exception ignore) {}
    }
    out.println("<h2>오류 발생</h2>");
    e.printStackTrace();
} finally{
    try { if (rsTop != null) rsTop.close(); } catch (Exception ignore) {}
    try { if (rs  != null) rs.close();  } catch (Exception ignore) {}
    
    try { if (ps1 != null) ps1.close(); } catch (Exception ignore) {}
    try { if (ps2 != null) ps2.close(); } catch (Exception ignore) {}
    try { if (ps3 != null) ps3.close(); } catch (Exception ignore) {}
    try { if (psCheckTop != null) psCheckTop.close(); } catch (Exception ignore) {}
    try { if (psDeduct != null) psDeduct.close(); } catch (Exception ignore) {}
    try { if (psRefund != null) psRefund.close(); } catch (Exception ignore) {}

    try {
        if (conn != null) {
            conn.setAutoCommit(true);
            conn.close();
        }
    } catch (Exception ignore) {}
}
%>