<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page language="java" import="java.text.*, java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
/*


    String deleteAuctionId = request.getParameter("delete_auction_id");
    String updateInventoryId = request.getParameter("inventoryid");

    if (deleteAuctionId != null && userId != null && !deleteAuctionId.isEmpty()) {
    	String cntSql = "select count(*) from bidding_record B where auctionid = ? and bidderid = ?";
    	PreparedStatement cntPstmt = conn.prepareStatement(cntSql);
    	cntPstmt.setString(1, deleteAuctionId);
    	cntPstmt.setString(2, userId);
    	ResultSet rs = cntPstmt.executeQuery();
    	if(rs.next()){
    		int cnt = rs.getInt(1);
			if (cnt >= 1){
				out.println("<p>Alreadly start bidding. Cannot delete registered item. </p>");
			}else{
		        String deleteSql = "Update auction set EndTime = ? WHERE auctionid = ? AND sellerid = ?";
		        PreparedStatement delPstmt = conn.prepareStatement(deleteSql);
		        Timestamp now = new Timestamp(System.currentTimeMillis());
		        delPstmt.setTimestamp(1, now);
		        delPstmt.setString(2, deleteAuctionId);
		        delPstmt.setString(3, userId);
		        int deleted = delPstmt.executeUpdate();
		        delPstmt.close();
		        
		        String updateSql = "Update inventory set quantity = quantity + 1 where inventoryid = ? ";
				PreparedStatement updPstmt = conn.prepareStatement(updateSql);
				updPstmt.setString(1, updateInventoryId);
				int updated = updPstmt.executeUpdate();
		        updPstmt.close();
		        
		        conn.commit();
		        out.println("<p>" + deleteAuctionId + "is deleted.</p>");
			}
    	}
		cntPstmt.close(); rs.close();
    }
*/

%>
<%
	Connection conn = DBConnection.getConnection();
	conn.setAutoCommit(false);
	
	request.setCharacterEncoding("UTF-8");
	String sql = "select A.auctionid, I.name, INV.conditions, A.start_price, A.currenthighestprice,  A.starttime, A.endTime, A.registerinventoryid " +
				 "from auction A join inventory INV on A.registerinventoryID = INV.inventoryid join item I on I.itemid = INV.itemid " +
				 "where A.sellerid = ? and A.EndTime > ?";
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, userId);
    Timestamp now2 = new Timestamp(System.currentTimeMillis());
    pstmt.setTimestamp(2, now2);
	ResultSet rs = pstmt.executeQuery();
	out.println("<table border = 1><tr><th>AUCTION_ID</th><th>ITEM_NAME</th><th>CONDITIONS</th><th>START_PRICE</th><th>CURRENT_HIGHEST_PRICE</th><th>START_TIME</th><th>END_TIME</th></tr>");
	boolean hasRow = false;
	while(rs.next()){
		hasRow = true;
        String auctionId = rs.getString(1);
		out.println("<tr>");
		out.println("<td>"+ auctionId + "</td>");
		out.println("<td>"+ rs.getString(2) + "</td>");
		out.println("<td>"+ rs.getString(3) + "</td>");
		out.println("<td>"+ rs.getString(4) + "</td>");
		out.println("<td>"+ rs.getString(5) + "</td>");
		out.println("<td>"+ rs.getString(6).substring(0, 19) + "</td>");
		out.println("<td>"+ rs.getString(7).substring(0, 19) + "</td>");
		/*
		String inventoryid = rs.getString(8);
        out.println("<td>");
        out.println("<form method='POST' action='show_my_registered_item_list_action.jsp' style='margin:0;'>");
        out.println("<input type='hidden' name='delete_auction_id' value='" + auctionId + "'/>");
        out.println("<input type='hidden' name='inventoryid' value = '" + inventoryid + "'/>");
        out.println("<input type='submit' value='Delete'/>");
        out.println("</form>");
        out.println("</td>");
		*/
		out.println("</tr>");
	}
	if (!hasRow) {
	    out.println("<tr><td colspan='5'>No inventory found.</td></tr>");
	}
	out.println("</table>");
	rs.close(); pstmt.close();
%>

</body>
</html>