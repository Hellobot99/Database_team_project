<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection, java.text.DecimalFormat" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    DecimalFormat df = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 거래 내역</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        background: #121212; 
        color: #fff; 
        font-family: 'Pretendard', sans-serif; 
        margin: 0; 
        padding: 0; 
    }

    .main-wrapper {
        padding: 40px;
    }

    .container { max-width: 1000px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
    .box { background: #1e1e1e; padding: 20px; border-radius: 10px; border: 1px solid #333; }
    h2 { margin-top: 0; border-bottom: 2px solid #555; padding-bottom: 10px; font-size: 1.2rem; }
    .item-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #333; }
    .plus { color: #28a745; font-weight: bold; }
    .minus { color: #ff4444; font-weight: bold; }
    .date { font-size: 0.8em; color: #666; display: block; }
    
    .home-btn {
            display: block; width: 150px; margin: 50px auto; text-align: center;
            padding: 12px; background: #444; color: white; text-decoration: none; border-radius: 30px;
        }
        .home-btn:hover { background: #555; }
    
</style>
</head>
<body>

<jsp:include page="header.jsp" />

    <h1 style="text-align:center; margin-bottom:40px;">📜 나의 거래 내역 (Complete)</h1>
    
    <div class="container">
        <div class="box">
            <h2 style="color:#ffcc00;">💰 판매 완료 (수익)</h2>
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DBConnection.getConnection();
                String sqlSell = "SELECT i.Name, a.CurrentHighestPrice, a.EndTime " +
                                 "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID " +
                                 "WHERE a.SellerID = ? AND a.EndTime < SYSDATE AND a.CurrentHighestPrice > 0 " +
                                 "ORDER BY a.EndTime DESC";
                pstmt = conn.prepareStatement(sqlSell);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                while(rs.next()) {
            %>
                <div class="item-row">
                    <div>
                        <div><%= rs.getString(1) %></div>
                        <span class="date"><%= rs.getTimestamp(3) %></span>
                    </div>
                    <div class="plus">+ <%= df.format(rs.getInt(2)) %> G</div>
                </div>
            <%
                }
                rs.close(); pstmt.close();
            %>
        </div>

        <div class="box">
            <h2 style="color:#00c6ff;">🛒 구매 완료 (지출)</h2>
            <%
                String sqlBuy = "SELECT i.Name, b.BidAmount, b.BidTime " +
                                "FROM BIDDING_RECORD b " +
                                "JOIN AUCTION a ON b.AuctionID = a.AuctionID " +
                                "JOIN ITEM i ON a.ItemID = i.ItemID " +
                                "WHERE b.BidderID = ? AND a.EndTime < SYSDATE " +
                                "ORDER BY b.BidTime DESC";
                pstmt = conn.prepareStatement(sqlBuy);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                while(rs.next()) {
            %>
                <div class="item-row">
                    <div>
                        <div><%= rs.getString(1) %></div>
                        <span class="date"><%= rs.getTimestamp(3) %></span>
                    </div>
                    <div class="minus">- <%= df.format(rs.getInt(2)) %> G</div>
                </div>
            <%
                }
            } catch(Exception e) { e.printStackTrace(); }
            finally { if(conn!=null) conn.close(); }
            %>
        </div>
    </div>
    
    <a href="index.jsp" class="home-btn">로비로 돌아가기</a>
</body>
</html>