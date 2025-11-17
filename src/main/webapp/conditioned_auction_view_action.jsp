<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page language = "java" import = "java.text.*, java.sql.*, util.DBconnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>


<%

	Connection conn = DBconnection.getConnection();
	conn.setAutoCommit(false);
	StringBuffer buf = new StringBuffer();
	buf.append("select A.auctionid, I.name, INV.conditions, A.start_price, A.currenthighestprice,  A.starttime, A.endTime ");
	buf.append("from auction A join inventory INV on A.registerinventoryid = INV.inventoryid join item I on I.itemid = INV.itemid ");
	buf.append("where A.endtime > ?");
	
	String item_id_4_2 = request.getParameter("item_id_4_2");	
	String category_id_4_2 = request.getParameter("category_id_4_2");
	String lower_price_4_2 = request.getParameter("lower_price_4_2");
	String higher_price_4_2 = request.getParameter("higher_price_4_2");
	String end_time_order_4_2 = request.getParameter("end_time_order_4_2");
	
	
	if (lower_price_4_2 != null && !lower_price_4_2.isEmpty() &&
		    higher_price_4_2 != null && !higher_price_4_2.isEmpty()) {

		    try {
		        int low = Integer.parseInt(lower_price_4_2);
		        int high = Integer.parseInt(higher_price_4_2);

		        if (low > high) {
		            out.println("<p style='color:red;'>Lower price cannot be greater than higher price.</p>");
		            return;
		        }

		    } catch (NumberFormatException e) {
		        out.println("<p style='color:red;'>Price must be a number.</p>");
		        return;
		    }
		}
	
	

	boolean hasWhere = false;

	// WHERE 절 추가 조건 존재 여부 확인
	boolean hasCondition =
	    (item_id_4_2 != null && !item_id_4_2.isEmpty()) ||
	    (category_id_4_2 != null && !category_id_4_2.isEmpty()) ||
	    (lower_price_4_2 != null && !lower_price_4_2.isEmpty()) ||
	    (higher_price_4_2 != null && !higher_price_4_2.isEmpty());

	
	// 조건 1 — Item ID
	if (item_id_4_2 != null && !item_id_4_2.isEmpty()) {
	    buf.append("I.itemid = ? ");
	    hasWhere = true;
	}

	// 조건 2 — Category ID
	if (category_id_4_2 != null && !category_id_4_2.isEmpty()) {
	    if (hasWhere) buf.append("and ");
	    buf.append("I.categoryid = ? ");
	    hasWhere = true;
	}

	// 조건 3 — Minimum Price
	if (lower_price_4_2 != null && !lower_price_4_2.isEmpty()) {
	    if (hasWhere) buf.append("and ");
	    buf.append("A.start_price >= ? ");
	    hasWhere = true;
	}

	// 조건 4 — Maximum Price
	if (higher_price_4_2 != null && !higher_price_4_2.isEmpty()) {
	    if (hasWhere) buf.append("and ");
	    buf.append("A.start_price <= ? ");
	    hasWhere = true;
	}
	
	if (!end_time_order_4_2.equals("default")){
		if (end_time_order_4_2.equals("ASCEND")){
			buf.append("order by A.endtime asc");
		}else{
			buf.append("order by A.endtime desc");
		}
	}
	
	

	String sql = buf.toString();
	PreparedStatement pstmt = conn.prepareStatement(sql);

	Timestamp now = new Timestamp(System.currentTimeMillis());
	pstmt.setTimestamp(1, now);
	// 파라미터 바인딩
	int idx = 2;

	if (item_id_4_2 != null && !item_id_4_2.isEmpty()) {
	    pstmt.setString(idx++, item_id_4_2);
	}
	if (category_id_4_2 != null && !category_id_4_2.isEmpty()) {
	    pstmt.setString(idx++, category_id_4_2);
	}
	if (lower_price_4_2 != null && !lower_price_4_2.isEmpty()) {
	    pstmt.setString(idx++, lower_price_4_2);
	}
	if (higher_price_4_2 != null && !higher_price_4_2.isEmpty()) {
	    pstmt.setString(idx++, higher_price_4_2);
	}

	ResultSet rs = pstmt.executeQuery();
	
	out.println("<table border = 1><tr><th>AUCTION_ID</th><th>ITEM_NAME</th><th>CONDITIONS</th><th>START_PRICE</th><th>CURRENT_HIGHEST_PRICE</th><th>START_TIME</th><th>END_TIME</th><th>BID</th></tr>");
	boolean hasRow = false;
	while(rs.next()){
		hasRow = true;
		String auction_id = rs.getString(1);
		String current_highest_price = rs.getString(5);
		
		
		out.println("<tr>");
		out.println("<td>"+ auction_id + "</td>");
		out.println("<td>"+ rs.getString(2) + "</td>");
		out.println("<td>"+ rs.getString(3) + "</td>");
		out.println("<td>"+ rs.getString(4) + "</td>");
		out.println("<td>"+ current_highest_price + "</td>");
		out.println("<td>"+ rs.getString(6).substring(0, 19) + "</td>");
		out.println("<td>"+ rs.getString(7).substring(0, 19) + "</td>");
/*
        out.println("<form method='POST' action='conditioned_auction_view_action.jsp' style='margin:0;'>");
		out.println("<input type='hidden' name = 'mode' value='step1'>");
		out.println("<input type='hidden' name = 'current_highest_price' value='" + current_highest_price_2 +"'>");
		out.println("<td><input type='Submit' value='Bid'></td>");
		out.println("</form>");
*/
		out.println("</tr>");
	}
	if (!hasRow) {
	    out.println("<tr><td colspan='5'>No inventory found.</td></tr>");
	}
	out.println("</table>");
	conn.close(); rs.close(); pstmt.close();

%>





</body>
</html>