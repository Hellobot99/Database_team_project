<%@ page import="java.sql.*, TeamPrj.DBConnection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String userId = (String) session.getAttribute("userId");
if (userId == null) {
	response.sendRedirect("login.html");
	return;
}

int cid = Integer.parseInt(request.getParameter("cid"));
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>카테고리 아이템</title>
</head>
<body>

	<h2>:: 카테고리 아이템 ::</h2>

	<table border="1">
		<tr>
			<th>아이템명</th>
			<th>설명</th>
			<th>가격</th>
		</tr>

		<%
		Connection conn = DBConnection.getConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT Name, Description, BasePrice FROM ITEM WHERE CategoryID = ?");
		ps.setInt(1, cid);
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
		%>

	</table>

	<a href="category_list.jsp">카테고리 목록</a>
	<br>
	<a href="index.jsp">메인</a>

</body>
</html>
