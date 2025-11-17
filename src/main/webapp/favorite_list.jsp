<%@ page import="java.sql.*, TeamPrj.DBConnection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String userId = (String) session.getAttribute("userId");
if (userId == null) {
	response.sendRedirect("login.html");
	return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>즐겨찾기 목록</title>
</head>
<body>

	<h2>:: 즐겨찾기 목록 ::</h2>

	<table border="1">
		<tr>
			<th>경매ID</th>
			<th>아이템명</th>
			<th>현재 가격</th>
			<th>종료 시간</th>
			<th>삭제</th>
		</tr>

		<%
		Connection conn = DBConnection.getConnection();

		PreparedStatement ps = conn.prepareStatement("SELECT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime "
				+ "FROM FAVORITE f " + "JOIN AUCTION a ON f.AuctionID = a.AuctionID " + "JOIN ITEM i ON a.ItemID = i.ItemID "
				+ "WHERE f.UserID = ? " + "ORDER BY f.AddedTime DESC");

		ps.setString(1, userId);
		ResultSet rs = ps.executeQuery();

		while (rs.next()) {
		%>

		<tr>
			<td><%=rs.getInt(1)%></td>
			<td><%=rs.getString(2)%></td>
			<td><%=rs.getInt(3)%></td>
			<td><%=rs.getTimestamp(4)%></td>
			<td><a href="delete_favorite.jsp?auctionId=<%=rs.getInt(1)%>">삭제</a></td>
		</tr>

		<%
		}

		rs.close();
		ps.close();
		conn.close();
		%>

	</table>

	<br>
	<a href="index.jsp">메인으로</a>

</body>
</html>
