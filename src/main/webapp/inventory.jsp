<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
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
<title>내 인벤토리</title>
<style>
table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 20px;
}

th, td {
	border: 1px solid #ddd;
	padding: 12px;
	text-align: center;
}

h2 {
	text-align: center;
}
</style>
</head>
<body>

	<h2>:: 내 인벤토리 ::</h2>

	<table>
		<tr>
			<th>아이템명</th>
			<th>설명</th>
			<th>수량</th>
		</tr>

		<%
		Connection conn = DBConnection.getConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT i.Name, i.Description, inv.Quantity " + "FROM INVENTORY inv "
				+ "JOIN ITEM i ON inv.ItemID = i.ItemID " + "WHERE inv.UserID = ?");
		ps.setString(1, userId);
		ResultSet rs = ps.executeQuery();

		while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getString(1)%></td>
			<td><%=rs.getString(2)%></td>
			<td><%=rs.getInt(3)%></td>
		</tr>
		<%
		}
		rs.close();
		ps.close();
		conn.close();
		%>
	</table>

	<a href="index.jsp">메인 메뉴</a>
</body>
</html>
