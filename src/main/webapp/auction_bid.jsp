<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
Connection conn = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
ResultSet rs = null;

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

    ps2 = conn.prepareStatement(
        "UPDATE AUCTION SET CurrentHighestPrice = ? WHERE AuctionID = ? and CurrentHighestPrice < ?"
    );
    ps2.setLong(1, amount);
    ps2.setLong(2, auctionId);
    ps2.setLong(3, amount);
    int updated = ps2.executeUpdate();

    if (updated == 0) {
        // 이미 더 높은 입찰이 있거나, 내가 넣은 금액이 현재가 이하인 경우
        conn.rollback();
        out.println("<script>");
        out.println("alert('입찰 실패: 현재 최고가보다 높은 금액만 입찰할 수 있습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }


    ps3 = conn.prepareStatement(
        "INSERT INTO BIDDING_RECORD (AuctionID, BidderID, BidAmount, BidTime) " +
        "VALUES (?, ?, ?, SYSDATE)"
    );
    ps3.setLong(1, auctionId);
    ps3.setString(2, userId);
    ps3.setLong(3, amount);
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
    try { if (rs  != null) rs.close();  } catch (Exception ignore) {}
    try { if (ps1 != null) ps1.close(); } catch (Exception ignore) {}
    try { if (ps2 != null) ps2.close(); } catch (Exception ignore) {}
    try { if (ps3 != null) ps3.close(); } catch (Exception ignore) {}
    try {
        if (conn != null) {
            conn.setAutoCommit(true);
            conn.close();
        }
    } catch (Exception ignore) {}
}
%>