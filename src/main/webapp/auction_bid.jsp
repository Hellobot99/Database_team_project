<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
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

    Connection conn = DBConnection.getConnection();
    
    PreparedStatement ps1 = conn.prepareStatement(
        "SELECT CurrentHighestPrice, SellerID FROM AUCTION WHERE AuctionID = ?"
    );
    ps1.setLong(1, auctionId);
    ResultSet rs = ps1.executeQuery();

    long currentPrice = 0;
    String sellerId = "";
    
    if (rs.next()) {
        currentPrice = rs.getLong(1);
        sellerId = rs.getString(2);
    }
    rs.close();
    ps1.close();

    if (userId.equals(sellerId)) {
        out.println("<script>");
        out.println("alert('본인이 등록한 물품에는 입찰할 수 없습니다.');");
        out.println("history.back();");
        out.println("</script>");
        conn.close();
        return;
    }

    if (amount <= currentPrice) {
        out.println("<script>");
        out.println("alert('입찰 실패: 현재 최고가보다 높은 금액만 입찰할 수 있습니다.');");
        out.println("history.back();");
        out.println("</script>");
        conn.close();
        return;
    }

    PreparedStatement ps2 = conn.prepareStatement(
        "INSERT INTO BIDDING_RECORD (AuctionID, BidderID, BidAmount, BidTime) " +
        "VALUES (?, ?, ?, SYSDATE)"
    );
    ps2.setLong(1, auctionId);
    ps2.setString(2, userId);
    ps2.setLong(3, amount);
    ps2.executeUpdate();
    ps2.close();

    PreparedStatement ps3 = conn.prepareStatement(
        "UPDATE AUCTION SET CurrentHighestPrice = ? WHERE AuctionID = ?"
    );
    ps3.setLong(1, amount);
    ps3.setLong(2, auctionId);
    ps3.executeUpdate();
    ps3.close();

    conn.close();

    out.println("<script>");
    out.println("alert('입찰 성공!');");
    out.println("location.href='auction_list.jsp';");
    out.println("</script>");

} catch (Exception e) {
    out.println("<h2>오류 발생</h2>");
    e.printStackTrace();
}
%>