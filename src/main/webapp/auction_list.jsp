<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>경매 목록</title>
</head>
<body>

<h2>:: 경매 목록 ::</h2>

<table border="1" cellpadding="8">
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
        int auctionId = rs.getInt("AuctionID");
        String itemName = rs.getString("ITEM_NAME");
        int currentPrice = rs.getInt("CurrentHighestPrice");
        Timestamp endTime = rs.getTimestamp("EndTime");
%>

    <tr>
        <td><%= auctionId %></td>
        <td><%= itemName %></td>
        <td><%= currentPrice %></td>
        <td><%= endTime %></td>

        <td>
            <!-- ★★★★★ 중요: POST 방식으로 입찰하기 ★★★★★ -->
            <form action="auction_bid.jsp" method="POST" style="display:inline;">
                <input type="hidden" name="auctionId" value="<%= auctionId %>">
                <input type="number" name="amount" placeholder="금액" min="1" style="width:80px;" required>
                <button type="submit">입찰</button>
            </form>

            <!-- 즐겨찾기 링크 -->
            |
            <a href="add_favorite.jsp?auctionId=<%= auctionId %>">즐겨찾기</a>
        </td>
    </tr>

<%
    }
    rs.close();
    stmt.close();
    conn.close();
%>

</table>

<br>
<a href="index.jsp">메인 메뉴로</a>

</body>
</html>
