<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.sql.*, TeamPrj.DBConnection"%>
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
<title>경매 종료</title>
</head>
<body>

	<h2>:: 경매 종료 ::</h2>

	<form method="post">
		종료할 경매 ID: <input type="number" name="auctionId"><br> <br>
		<button type="submit">종료</button>
	</form>

	<%
	if (request.getMethod().equals("POST")) {

		long auctionId = Long.parseLong(request.getParameter("auctionId"));
		Connection conn = DBConnection.getConnection();
		
		PreparedStatement checkStmt = conn.prepareStatement("SELECT TradeID FROM TRANSACTION WHERE AuctionID = ?");
		checkStmt.setLong(1, auctionId);
		ResultSet checkRs = checkStmt.executeQuery();

		if (checkRs.next()) {
			out.println("<script>alert('이미 종료된 경매(거래 완료)입니다.'); history.back();</script>");
			checkRs.close();
			checkStmt.close();
			conn.close();
			return;
		}
		checkRs.close();
		checkStmt.close();

		// 1️⃣ AuctionID → ItemID 가져오기
		PreparedStatement getItem = conn.prepareStatement("SELECT ItemID, SellerID FROM AUCTION WHERE AuctionID = ?");
		getItem.setLong(1, auctionId);
		ResultSet itemRS = getItem.executeQuery();

		long itemId = -1;
		String sellerId = null;
		if (itemRS.next()) {
			itemId = itemRS.getLong(1);
			sellerId = itemRS.getString(2);
		}

		itemRS.close();
		getItem.close();

		// 2️⃣ 최고 입찰자 찾기
		PreparedStatement ps = conn.prepareStatement("SELECT BidderID, BidAmount FROM ("
		+ "SELECT BidderID, BidAmount FROM BIDDING_RECORD WHERE AuctionID = ? ORDER BY BidAmount DESC"
		+ ") WHERE ROWNUM = 1");
		ps.setLong(1, auctionId);

		ResultSet rs = ps.executeQuery();

		if (rs.next()) {
			String buyer = rs.getString(1);
			long price = rs.getLong(2);
			long commission = (long)(price * 0.1);

			// 3️⃣ TRANSACTION 생성
			PreparedStatement insert = conn.prepareStatement(
			"INSERT INTO TRANSACTION (TradeID, AuctionID, BuyerID, SELLERID, Final_Price, COMMISSION, TRADETIME) " +
			"VALUES (seq_transaction_id.NEXTVAL, ?, ?, ?, ?, ?, SYSDATE)");
			
			insert.setLong(1, auctionId);
			insert.setString(2, buyer);
			insert.setString(3, sellerId);
			insert.setLong(4, price);
			insert.setLong(5, commission);
			insert.executeUpdate();
			insert.close();

			// ⭐ 4️⃣ 인벤토리에 자동 추가
			if (itemId != -1) {
		PreparedStatement addInv = conn
				.prepareStatement("INSERT INTO INVENTORY (UserID, ItemID, Quantity) VALUES (?, ?, 1)");
		addInv.setString(1, buyer);
		addInv.setLong(2, itemId);
		addInv.executeUpdate();
		addInv.close();
			}

			out.println("거래 생성 및 인벤토리 추가 완료!");

		} else {
			out.println("입찰자가 없어 종료 실패!");
		}

		rs.close();
		ps.close();
		conn.close();
	}
	%>

	<br>
	<a href="index.jsp">메인 메뉴</a>

</body>
</html>
