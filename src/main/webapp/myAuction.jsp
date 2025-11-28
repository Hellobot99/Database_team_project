<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { 
        response.sendRedirect("login.html"); 
        return; 
    }
    
    DecimalFormat formatter = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 경매 활동</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', sans-serif; 
        background-color: #121212; 
        color: #e0e0e0; 
        margin: 0; 
        padding: 0; 
    }

    .main-wrapper { padding: 40px; }

    .container { max-width: 1200px; margin: 0 auto; }

    h1 { 
        font-size: 2rem; 
        text-align: center; 
        color: #fff; 
        text-shadow: 0 0 10px #007bff; 
        margin-bottom: 50px; 
    }

    h2 {
        border-left: 5px solid #ffcc00;
        padding-left: 15px;
        margin-top: 60px;
        margin-bottom: 20px;
        color: #fff;
        font-size: 1.5rem;
    }

    .auction-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); 
        gap: 25px;
    }

    .item-card {
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        transition: transform 0.2s, box-shadow 0.2s;
        position: relative;
    }
    .item-card:hover { 
        transform: translateY(-5px); 
        box-shadow: 0 10px 20px rgba(0,0,0,0.5); 
        border-color: #007bff; 
    }

    .item-img {
        width: 100%; height: 140px; 
        background: #2a2a2a; 
        border-radius: 8px; 
        object-fit: contain; 
        margin-bottom: 15px;
        border: 1px solid #333;
    }

    .item-name { font-size: 1.2rem; font-weight: bold; margin-bottom: 10px; color: #fff; }
    .item-price { color: #ff4444; font-weight: bold; font-size: 1.3rem; margin-bottom: 5px; }
    
    .time-box {
        background: rgba(0,0,0,0.5);
        padding: 5px;
        border-radius: 4px;
        color: #bbb;
        font-size: 0.9rem;
        margin-bottom: 15px;
        font-family: monospace;
    }
    .time-urgent { color: #ff3333; animation: blink 1s infinite; }
    @keyframes blink { 50% { opacity: 0.5; } }

    .bid-form {
        display: flex;
        gap: 5px;
        margin-top: 10px;
    }
    
    .input-money {
        width: 65%;
        padding: 10px;
        border-radius: 6px;
        border: 1px solid #555;
        background: #2a2a2a;
        color: #fff;
        text-align: right;
        font-weight: bold;
    }
    .input-money:focus { outline: none; border-color: #ffcc00; }

    .btn-bid { 
        width: 35%;
        padding: 10px 0;
        background: linear-gradient(135deg, #007bff, #0056b3); 
        color: white; 
        border: none;
        border-radius: 6px;
        font-weight: bold;
        cursor: pointer;
    }
    .btn-bid:hover { filter: brightness(1.1); }

    .btn-delete { 
        display: block; width: 100%; margin-top: 10px;
        background: transparent; color: #888; font-size: 0.85rem; 
        border: 1px solid #444; padding: 8px 0; border-radius: 6px;
        text-decoration: none; transition: all 0.2s;
    }
    .btn-delete:hover { background: #dc3545; color: white; border-color: #dc3545; }

    .home-btn {
        display: inline-block; margin-top: 50px; padding: 12px 30px;
        background: #333; color: white; text-decoration: none; border-radius: 30px;
        font-weight: bold;
    }
    .home-btn:hover { background: #555; }
    
    .empty-msg { color: #555; text-align: center; padding: 30px; font-size: 1.1rem; grid-column: 1 / -1; }
</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <div class="container">
        <h1>📊 나의 경매 활동</h1>

        <h2>🙋‍♂️ 내가 입찰 중인 경매 (방어하기)</h2>
        <div class="auction-grid">
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DBConnection.getConnection();
                
                String sqlBid = "SELECT DISTINCT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime " +
                                "FROM BIDDING_RECORD b " +
                                "JOIN AUCTION a ON b.AuctionID = a.AuctionID " +
                                "JOIN ITEM i ON a.ItemID = i.ItemID " +
                                "WHERE b.BidderID = ? AND a.EndTime > SYSDATE " +
                                "ORDER BY a.EndTime ASC";
                
                pstmt = conn.prepareStatement(sqlBid);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                
                boolean hasBidItems = false;
                while(rs.next()){
                    hasBidItems = true;
                    int auctionId = rs.getInt(1);
                    String name = rs.getString(2);
                    int price = rs.getInt(3);
                    Timestamp endTime = rs.getTimestamp(4);
                    long endTimeMillis = endTime.getTime();
        %>
            <div class="item-card" style="border-color: #007bff;"> 
                <div style="position:absolute; top:10px; right:10px; background:#007bff; color:white; padding:2px 6px; border-radius:4px; font-size:0.7rem;">참여중</div>
                
                <img src="images/<%= name %>.png" class="item-img" onerror="this.src='https://via.placeholder.com/200x140/333/fff?text=Item'">
                <div class="item-name"><%= name %></div>
                <div class="item-price"><%= formatter.format(price) %> G</div>
                <div class="time-box" data-end="<%= endTimeMillis %>">계산 중...</div>
                
                <form action="auction_bid.jsp" method="POST" class="bid-form">
                    <input type="hidden" name="auctionId" value="<%= auctionId %>">
                    <input type="number" name="amount" class="input-money" placeholder="입찰가" min="<%= price + 1 %>" required>
                    <button type="submit" class="btn-bid">추가 입찰</button>
                </form>
            </div>
        <%
                }
                if(!hasBidItems) {
                    out.println("<div class='empty-msg'>현재 참여 중인 경매가 없습니다.</div>");
                }
                rs.close();
                pstmt.close();
        %>
        </div>

        <h2 style="border-color: #ff4444;">⭐ 관심 경매 (지켜보는 중)</h2>
        <div class="auction-grid">
        <%
                String sqlFav = "SELECT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime " +
                                "FROM FAVORITE f " +
                                "JOIN AUCTION a ON f.AuctionID = a.AuctionID " +
                                "JOIN ITEM i ON a.ItemID = i.ItemID " +
                                "WHERE f.UserID = ? AND a.EndTime > SYSDATE " +
                                "ORDER BY f.AddedTime DESC";
                
                pstmt = conn.prepareStatement(sqlFav);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                
                boolean hasFavItems = false;
                while(rs.next()){
                    hasFavItems = true;
                    int auctionId = rs.getInt(1);
                    String name = rs.getString(2);
                    int price = rs.getInt(3);
                    Timestamp endTime = rs.getTimestamp(4);
                    long endTimeMillis = endTime.getTime();
        %>
            <div class="item-card">
                <img src="images/<%= name %>.png" class="item-img" onerror="this.src='https://via.placeholder.com/200x140/333/fff?text=Item'">
                <div class="item-name"><%= name %></div>
                <div class="item-price"><%= formatter.format(price) %> G</div>
                <div class="time-box" data-end="<%= endTimeMillis %>">계산 중...</div>
                
                <form action="auction_bid.jsp" method="POST" class="bid-form">
                    <input type="hidden" name="auctionId" value="<%= auctionId %>">
                    <input type="number" name="amount" class="input-money" placeholder="입찰가" min="<%= price + 1 %>" required>
                    <button type="submit" class="btn-bid">입찰</button>
                </form>
                
                <a href="delete_favorite.jsp?auctionId=<%= auctionId %>" class="btn-delete" onclick="return confirm('관심 목록에서 삭제하시겠습니까?');">🗑 관심 해제</a>
            </div>
        <%
                }
                if(!hasFavItems) {
                    out.println("<div class='empty-msg'>관심 등록한 아이템이 없습니다.</div>");
                }
            } catch(Exception e) {
                e.printStackTrace();
                out.println("<div class='empty-msg'>DB 오류: " + e.getMessage() + "</div>");
            } finally {
                if(rs != null) try{rs.close();}catch(Exception e){}
                if(pstmt != null) try{pstmt.close();}catch(Exception e){}
                if(conn != null) try{conn.close();}catch(Exception e){}
            }
        %>
        </div>

        <div style="text-align:center;">
            <a href="index.jsp" class="home-btn">로비로 돌아가기</a>
        </div>
    </div>
</div>

<script>
    function updateTimers() {
        const now = new Date().getTime();
        document.querySelectorAll('.time-box').forEach(timer => {
            const endTime = parseInt(timer.getAttribute('data-end'));
            const diff = endTime - now;
            
            if (diff <= 0) {
                timer.innerHTML = "🚫 종료됨";
                timer.style.color = "#555";
            } else {
                const h = Math.floor(diff / (1000 * 60 * 60));
                const m = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const s = Math.floor((diff % (1000 * 60)) / 1000);
                timer.innerHTML = `⏰ \${h}시간 \${m}분 \${s}초`;
                if(h < 1) timer.classList.add('time-urgent');
            }
        });
    }
    setInterval(updateTimers, 1000);
    updateTimers();
</script>

</body>
</html>