<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%
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
<title>카테고리</title>
</head>
<body>

	<h2>:: 카테고리 선택 ::</h2>

	<%
	Connection conn = DBConnection.getConnection();
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT CategoryID, Name FROM CATEGORY");
	while (rs.next()) {
		int cid = rs.getInt(1);
		String cname = rs.getString(2);
	%>

	<a href="category_items.jsp?cid=<%=cid%>"><%=cname%></a>
	<br>
	<br>

	<%
	}
	rs.close();
	stmt.close();
	conn.close();
	%>

	<a href="index.jsp">메인</a>

</body>
</html>
