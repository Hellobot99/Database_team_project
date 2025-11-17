<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>입찰</title></head>
<body>

<h2>:: 입찰하기 ::</h2>

<form action="auction_bid.jsp" method="post">
    <input type="hidden" name="auctionId" value="<%= request.getParameter("auctionId") %>">
    입찰 금액: <input type="number" name="amount"><br><br>
    <button type="submit">입찰</button>
</form>

<%
if(request.getMethod().equals("POST")) {
    long auctionId = Long.parseLong(request.getParameter("auctionId"));
    long amount = Long.parseLong(request.getParameter("amount"));

    Connection conn = DBConnection.getConnection();

    PreparedStatement ps = conn.prepareStatement("INSERT INTO BIDDING_RECORD (AUCTION_ID, USER_ID, BID_AMOUNT, BID_TIME) VALUES (?, ?, ?, SYSDATE)");

    ps.setLong(1, auctionId);
    ps.setString(2, userId);
    ps.setLong(3, amount);

    int ok = ps.executeUpdate();

    out.println(ok > 0 ? "입찰 성공!" : "입찰 실패!");

    ps.close();
    conn.close();
}
%>

<br><br>
<a href="auction_list.jsp">경매목록</a>

</body>
</html>
