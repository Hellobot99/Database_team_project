<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>경매 목록</title></head>
<body>

<h2>:: 경매 목록 ::</h2>

<table border="1">
    <tr>
        <th>ID</th>
        <th>상품명</th>
        <th>현재가</th>
        <th>종료시간</th>
        <th>입찰</th>
    </tr>

<%
    Connection conn = DBConnection.getConnection();
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(
    	    "SELECT a.AuctionID, i.Name AS ITEM_NAME, a.CurrentHighestPrice, a.EndTime " +
    	    "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID"
    );




    while(rs.next()) {
%>

<tr>
    <td><%=rs.getInt(1)%></td>
    <td><%=rs.getString(2)%></td>
    <td><%=rs.getInt(3)%></td>
    <td><%=rs.getTimestamp(4)%></td>
    <td>
        <a href="auction_bid.jsp?auctionId=<%=rs.getInt(1)%>">입찰</a> |
        <a href="add_favorite.jsp?auctionId=<%=rs.getInt(1)%>">즐겨찾기</a>
    </td>
</tr>


<%
    }
    rs.close();
    stmt.close();
    conn.close();
%>

</table>

<br><a href="index.jsp">메인 메뉴로</a>

</body>
</html>
