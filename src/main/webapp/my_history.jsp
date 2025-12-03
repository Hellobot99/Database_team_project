<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection, java.text.DecimalFormat" %>

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    DecimalFormat df = new DecimalFormat("#,###");
%>

<html>
<head>
<meta charset="UTF-8">
<title>나의 거래 내역</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background: #121212; color: #fff; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    .main-wrapper { padding: 40px; }
    .container { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; }
    .box { background: #1e1e1e; padding: 20px; border-radius: 10px; border: 1px solid #333; }
    h2 { margin-top: 0; border-bottom: 2px solid #555; padding-bottom: 10px; font-size: 1.2rem; }
    .item-row { display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #333; }
    .item-info { flex: 1; }
    .item-name { font-weight: bold; font-size: 1rem; margin-bottom: 4px; }
    .date { font-size: 0.8em; color: #666; }
    .status-area { text-align: right; min-width: 90px; }
    .plus { color: #28a745; font-weight: bold; display: block; margin-bottom: 5px; }
    .minus { color: #ff4444; font-weight: bold; display: block; margin-bottom: 5px; }
    .btn-receive { background: #ffcc00; color: #000; border: none; padding: 5px 10px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 0.8rem; }
    .btn-get-item { background: #007bff; color: #fff; border: none; padding: 5px 10px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 0.8rem; }
    .btn-get-item:hover { background: #0056b3; }
    .btn-retrieve { background: #6c757d; color: #fff; border: none; padding: 5px 10px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 0.8rem; }
    .text-complete { color: #666; font-size: 0.85rem; font-weight: bold; border: 1px solid #444; padding: 3px 8px; border-radius: 4px; }
    .home-btn { display: block; width: 150px; margin: 40px auto; text-align: center; padding: 12px; background: #444; color: white; text-decoration: none; border-radius: 30px; }
</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <h1 style="text-align:center; margin-bottom:40px;">📜 나의 거래 내역</h1>

    <div class="container">

        <div class="box">
            <h2 style="color:#ffcc00;">💰 판매 완료 (낙찰됨)</h2>

            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DBConnection.getConnection();
                String sqlSell =
                    "SELECT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime, m.TradeTime " +
                    "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID " +
                    "LEFT JOIN MARKET_HISTORY m ON a.AuctionID = m.AuctionID " +
                    "WHERE a.SellerID = ? AND a.EndTime < SYSDATE " +
                    "AND EXISTS (SELECT 1 FROM BIDDING_RECORD br WHERE br.AuctionID = a.AuctionID) " +
                    "ORDER BY a.EndTime DESC";

                pstmt = conn.prepareStatement(sqlSell);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();

                while(rs.next()) {
                    boolean isSettled = (rs.getTimestamp("TradeTime") != null);
            %>

                <div class="item-row">
                    <div class="item-info">
                        <div class="item-name"><%= rs.getString("Name") %></div>
                        <span class="date"><%= rs.getTimestamp("EndTime") %></span>
                    </div>

                    <div class="status-area">
                        <span class="plus">+ <%= df.format(rs.getInt("CurrentHighestPrice")) %> G</span>

                        <% if (!isSettled) { %>
                            <button onclick="location.href='settlement_action.jsp?auctionId=<%= rs.getInt("AuctionID") %>'" class="btn-receive">💰 정산 받기</button>
                        <% } else { %>
                            <span class="text-complete">정산 완료</span>
                        <% } %>
                    </div>
                </div>

            <% }
                rs.close(); pstmt.close(); %>
        </div>


        <div class="box">
            <h2 style="color:#dc3545;">🚫 유찰 (입찰자 없음)</h2>

            <%
            String sqlFail =
                "SELECT a.AuctionID, i.Name, a.EndTime " +
                "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID " +
                "WHERE a.SellerID = ? AND a.EndTime < SYSDATE " +
                "AND NOT EXISTS (SELECT 1 FROM BIDDING_RECORD br WHERE br.AuctionID = a.AuctionID) " +
                "ORDER BY a.EndTime DESC";

            pstmt = conn.prepareStatement(sqlFail);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            while(rs.next()) {
            %>

                <div class="item-row">
                    <div class="item-info">
                        <div class="item-name"><%= rs.getString("Name") %></div>
                        <span class="date"><%= rs.getTimestamp("EndTime") %></span>
                    </div>

                    <div class="status-area">
                        <button onclick="if(confirm('아이템을 인벤토리로 회수하시겠습니까?')) location.href='return_auction_action.jsp?auctionId=<%= rs.getInt("AuctionID") %>'" class="btn-retrieve">↩️ 회수 하기</button>
                    </div>
                </div>

            <% }
                rs.close(); pstmt.close(); %>
        </div>

        <div class="box">
            <h2 style="color:#00c6ff;">🛒 구매 완료 (지출)</h2>

            <%
            String sqlBuy =
                "SELECT a.AuctionID, i.Name, b.BidAmount, b.BidTime, a.ReceivedFlag " +
                "FROM BIDDING_RECORD b " +
                "JOIN AUCTION a ON b.AuctionID = a.AuctionID " +
                "JOIN ITEM i ON a.ItemID = i.ItemID " +
                "WHERE b.BidderID = ? AND a.EndTime < SYSDATE " +
                "AND b.BidAmount = (SELECT MAX(BidAmount) FROM BIDDING_RECORD WHERE AuctionID = a.AuctionID) " +
                "ORDER BY b.BidTime DESC";

            pstmt = conn.prepareStatement(sqlBuy);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                boolean received = (rs.getInt("ReceivedFlag") == 1);
            %>

                <div class="item-row">
                    <div class="item-info">
                        <div class="item-name"><%= rs.getString("Name") %></div>
                        <span class="date"><%= rs.getTimestamp("BidTime") %></span>
                    </div>

                    <div class="status-area">
                        <span class="minus">- <%= df.format(rs.getInt("BidAmount")) %> G</span>

                        <% if (!received) { %>
                            <button onclick="location.href='receive_item_action.jsp?auctionId=<%= rs.getInt("AuctionID") %>'" class="btn-get-item">📦 아이템 수령</button>
                        <% } else { %>
                            <span class="text-complete">수령 완료</span>
                        <% } %>
                    </div>
                </div>

            <% }
                conn.close();
            } catch(Exception e) { e.printStackTrace(); }
            %>
        </div>

    </div>

    <a href="index.jsp" class="home-btn">🏠 로비로 돌아가기</a>

</div>

</body>
</html>
