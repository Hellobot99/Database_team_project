<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page language="java"
	import="java.text.*, java.sql.*, TeamPrj.DBConnection"%>
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
<title>Inventory List</title>
</head>
<body>



	<%
	request.setCharacterEncoding("UTF-8");

	String mode = request.getParameter("mode");
	String inventoryId = request.getParameter("inventory_id");
	String invQuantity = request.getParameter("inv_quantity");
	String itemId = request.getParameter("item_id");

	if (invQuantity != null && Integer.parseInt(invQuantity) == 0) {
	%>
	<script>
		alert("현재 수량이 0이라 경매 등록이 불가능합니다.");
		history.back(); // 이전 페이지로 돌아가기
	</script>
	<%
	} else {
	if ("step1".equals(mode)) {
		out.println("<h3>Register Auction</h3>");
		out.println("Inventory ID: " + inventoryId);
		out.println("Item ID: " + itemId);
		out.println("Current Quantity: " + invQuantity);
	%>
	<form method="POST" action="my_inventory_list_action.jsp">
		<input type="hidden" name="mode" value="step2"> <input
			type="hidden" name="inventory_id" value="<%=inventoryId%>">
		<input type="hidden" name="item_id" value="<%=itemId%>"> <input
			type="hidden" name="user_id" value="<%=userId%>"> Start
		Price: <input type="text" name="start_price"><br> End
		Time : After 7 days<br> <input type="submit"
			value="Confirm Register">
	</form>
	<%
	}
	}
	%>

	<%
	if ("step2".equals(mode)) {
		String startPrice = request.getParameter("start_price");
		Connection conn = DBConnection.getConnection();
		conn.setAutoCommit(false);
		PreparedStatement pstmt = null;

		try {

			String selectAuctionId = "select auctionID from Auction where rownum = 1 order by auctionid desc";
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(selectAuctionId);
			int auctionid = 0;
			if (rs.next())
		auctionid = rs.getInt(1);
			rs.close();
			stmt.close();

			String insertAuctionSql = "insert into auction (auctionid, start_price, StartTime, EndTime, CurrentHighestPrice, ItemID, SellerID, REGISTERINVENTORYID) "
			+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
			Timestamp now2 = new Timestamp(System.currentTimeMillis());
			pstmt = conn.prepareStatement(insertAuctionSql);
			pstmt.setInt(1, auctionid + 1);
			pstmt.setString(2, startPrice);
			pstmt.setTimestamp(3, now2);
			Timestamp endTime = new Timestamp(now2.getTime() + 7L * 24 * 60 * 60 * 1000);
			pstmt.setTimestamp(4, endTime);
			pstmt.setString(5, startPrice);
			pstmt.setInt(6, Integer.parseInt(itemId));
			pstmt.setString(7, userId);
			pstmt.setInt(8, Integer.parseInt(inventoryId));
			int inserted = pstmt.executeUpdate();
			pstmt.close();

			String updateInvSql = "UPDATE INVENTORY SET quantity = quantity - 1 WHERE inventoryid = ?";
			pstmt = conn.prepareStatement(updateInvSql);
			pstmt.setInt(1, Integer.parseInt(inventoryId));
			int updated = pstmt.executeUpdate();
			pstmt.close();

			conn.commit();

			out.println("<p>Auction registered successfully.</p>");
			out.println("<p><a href='my_inventory_list_action.jsp?user_id_4_1=" + userId + "'>Back to Inventory</a></p>");

		} catch (Exception e) {
			if (conn != null)
		conn.rollback();
			out.println("<p>Error: " + e.getMessage() + "</p>");
		} finally {
			if (pstmt != null)
		try {
			pstmt.close();
		} catch (Exception e) {
		}
			if (conn != null)
		try {
			conn.close();
		} catch (Exception e) {
		}
		}
	}
	%>
	<%
	Connection conn = DBConnection.getConnection();
	conn.setAutoCommit(false);
	String sql = "select INV.inventoryid, IT.name, INV.quantity, INV.conditions, INV.acquired_date, INV.itemid, INV.userid "
			+ "from inventory INV join item IT on INV.itemid = IT.itemid " + "where INV.userid = ?";
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, userId);
	ResultSet rs = pstmt.executeQuery();
	out.println(
			"<table border='1'><tr><th>INVENTORY_ID</th><th>ITEM_NAME</th><th>QUANTITY</th><th>CONDITION</th><th>ACQUIRED_DATE</th><th>REGISTER</th></tr>");

	boolean hasRow = false;
	while (rs.next()) {
		hasRow = true;
		String update_inv_id = rs.getString("inventoryid");
		out.println("<tr>");
		out.println("<td>" + update_inv_id + "</td>");
		out.println("<td>" + rs.getString("name") + "</td>");
		out.println("<td>" + rs.getInt("quantity") + "</td>");
		out.println("<td>" + rs.getString("conditions") + "</td>");
		out.println("<td>" + rs.getTimestamp("acquired_date") + "</td>");

		out.println("<td>");
		out.println("<form method='POST' action='my_inventory_list_action.jsp' style='margin:0;'>");
		out.println("<input type='hidden' name='mode' value='step1'>");
		out.println("<input type='hidden' name='inventory_id' value='" + update_inv_id + "'>");
		out.println("<input type='hidden' name='inv_quantity' value='" + rs.getString("quantity") + "'>");
		out.println("<input type='hidden' name='item_id' value='" + rs.getString("itemid") + "'>");
		out.println("<input type='hidden' name='user_id' value='" + rs.getString("userid") + "'>");
		out.println("<input type='submit' value='Register'>");
		out.println("</form>");
		out.println("</td>");

	}
	rs.close();
	pstmt.close();
	conn.close();
	if (!hasRow) {
		out.println("<tr><td>No inventory found.</td></tr>");
	}
	out.println("</table>");
	%>





</body>
</html>