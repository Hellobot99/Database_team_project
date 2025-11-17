<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>내가 참여한 경매</title></head>
<body>

<h2>:: 내가 참여한 경매 ::</h2>

<table border="1">
<tr>
    <th>경매ID</th>
    <th>아이템명</th>
    <th>현재 가격</th>
    <th>종료 시간</th>
</tr>

<%
    Connection conn = DBConnection.getConnection();

PreparedStatement ps = conn.prepareStatement(
	    "SELECT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime " +
	    "FROM BIDDING_RECORD b " +
	    "JOIN AUCTION a ON b.AuctionID = a.AuctionID " +
	    "JOIN ITEM i ON a.ItemID = i.ItemID " +
	    "WHERE b.BidderID = ? " +   // ★ 수정됨
	    "ORDER BY a.EndTime DESC"
	);


    ps.setString(1, userId);
    ResultSet rs = ps.executeQuery();

    while(rs.next()){
%>

<tr>
    <td><%=rs.getInt(1)%></td>
    <td><%=rs.getString(2)%></td>
    <td><%=rs.getInt(3)%></td>
    <td><%=rs.getTimestamp(4)%></td>
</tr>

<%
    }

    rs.close();
    ps.close();
    conn.close();
%>
</table>

<br><a href="index.jsp">메인 메뉴</a>

</body>
</html>
