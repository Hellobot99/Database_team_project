<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection, java.text.DecimalFormat" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    
    String searchItem = request.getParameter("searchItem");
    if(searchItem == null) searchItem = "";
    
    String searchCategory = request.getParameter("searchCategory");
    if(searchCategory == null) searchCategory = "";
    
    String minPriceStr = request.getParameter("minPrice");
    if(minPriceStr == null) minPriceStr = "";
    
    String maxPriceStr = request.getParameter("maxPrice");
    if(maxPriceStr == null) maxPriceStr = "";

    DecimalFormat formatter = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>경매 목록</title>
    <link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
    <style>
        body { background-color: #1a1a1a; color: #fff; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
        
        .main-wrapper { padding: 40px; }
        .container { max-width: 1200px; margin: 0 auto; }

        h2 { text-align: center; color: #ffcc00; text-shadow: 0 0 10px #ffaa00; margin-bottom: 30px;}
        
        .search-box {
            background: #2a2a2a; padding: 25px; border-radius: 12px; border: 1px solid #444;
            display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: center; margin-bottom: 40px;
        }
        
        .input-group { display: flex; align-items: center; gap: 8px; }
        label { font-weight: bold; color: #bbb; font-size: 0.9rem; }
        
        input[type=text], input[type=number] {
            padding: 10px; border-radius: 6px; border: 1px solid #555; background: #111; color: #fff; 
            font-family: 'Pretendard';
        }
        input[type=text] { width: 140px; }
        input[type=number] { width: 100px; text-align: right; }

        .btn-search {
            background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 6px; 
            font-weight: bold; cursor: pointer; transition: background 0.2s;
        }
        .btn-search:hover { background: #218838; }

        .auction-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 25px;
        }

        .item-card {
            background: #2a2a2a; 
            border: 1px solid #444;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            transition: all 0.3s ease;
            position: relative;
        }
        .item-card:hover { 
            transform: translateY(-5px);
            border-color: #ffcc00; 
            box-shadow: 0 10px 20px rgba(255, 204, 0, 0.2);
        }
        
        .item-img {
            width: 100%;
            height: 160px;
            background-color: #111;
            object-fit: contain;
            border-radius: 8px;
            margin-bottom: 15px;
            border: 1px solid #333;
        }
        
        h3 { margin: 10px 0; font-size: 1.2rem; }

        .price { 
            color: #ff4444; 
            font-weight: 800; 
            font-size: 1.4rem; 
            margin: 10px 0;
            text-shadow: 0 0 5px rgba(255, 68, 68, 0.4);
        }
        
        .time-box {
            background: rgba(0,0,0,0.3);
            border-radius: 5px;
            padding: 5px;
            color: #ccc;
            font-size: 0.95rem; 
            margin-bottom: 15px;
            font-family: monospace;
        }
        .time-urgent { color: #ff3333; font-weight: bold; animation: blink 1s infinite; }

        @keyframes blink { 50% { opacity: 0.5; } }

        .bid-btn {
            background: linear-gradient(45deg, #ffcc00, #ffaa00);
            border: none; 
            padding: 10px 0;
            width: 100%;
            font-weight: bold; 
            color: #000;
            cursor: pointer; 
            border-radius: 6px;
            font-size: 1rem;
        }
        .bid-btn:hover { filter: brightness(1.1); }
        
        .bid-input {
            width: 60%;
            padding: 10px;
            border-radius: 6px;
            border: 1px solid #555;
            background: #222;
            color: #fff;
            margin-bottom: 10px;
            text-align: right;
        }

        .fav-link {
            display: inline-block;
            margin-top: 15px;
            color: #888;
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s;
        }
        .fav-link:hover { color: #ffcc00; }
        
        .home-btn {
            display: block; width: 150px; margin: 50px auto; text-align: center;
            padding: 12px; background: #444; color: white; text-decoration: none; border-radius: 30px;
        }
        .home-btn:hover { background: #555; }
    </style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <div class="container">
        
        <h2>🔥 진행 중인 경매 🔥</h2>

        <form action="auction_list.jsp" method="GET" class="search-box">
            <div class="input-group">
                <label>아이템명</label>
                <input type="text" name="searchItem" value="<%= searchItem %>" placeholder="예: 검">
            </div>
            
            <div class="input-group">
                <label>카테고리</label>
                <input type="text" name="searchCategory" value="<%= searchCategory %>" placeholder="예: 전사">
            </div>

            <div class="input-group">
                <label>가격대</label>
                <input type="number" name="minPrice" value="<%= minPriceStr %>" placeholder="최소">
                <span>~</span>
                <input type="number" name="maxPrice" value="<%= maxPriceStr %>" placeholder="최대">
            </div>
            
            <button type="submit" class="btn-search">🔍 검색</button>
        </form>

        <div class="auction-grid">

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                
                String sql = "SELECT a.AuctionID, i.Name AS ITEM_NAME, a.CurrentHighestPrice, a.EndTime " +
                             "FROM AUCTION a " + 
                             "JOIN ITEM i ON a.ItemID = i.ItemID " +
                             "LEFT JOIN CATEGORY c ON i.CategoryID = c.CategoryID " + 
                             "WHERE a.EndTime > SYSDATE ";

                if (!searchItem.isEmpty()) sql += "AND UPPER(i.Name) LIKE UPPER(?) ";
                if (!searchCategory.isEmpty()) sql += "AND UPPER(c.Name) LIKE UPPER(?) ";
                
                if (!minPriceStr.isEmpty()) sql += "AND a.CurrentHighestPrice >= ? ";
                if (!maxPriceStr.isEmpty()) sql += "AND a.CurrentHighestPrice <= ? ";
                
                sql += "ORDER BY a.EndTime ASC";

                pstmt = conn.prepareStatement(sql);

                int pIndex = 1;
                if (!searchItem.isEmpty()) pstmt.setString(pIndex++, "%" + searchItem + "%");
                if (!searchCategory.isEmpty()) pstmt.setString(pIndex++, "%" + searchCategory + "%");
                if (!minPriceStr.isEmpty()) pstmt.setInt(pIndex++, Integer.parseInt(minPriceStr));
                if (!maxPriceStr.isEmpty()) pstmt.setInt(pIndex++, Integer.parseInt(maxPriceStr));

                rs = pstmt.executeQuery();
                boolean hasData = false;

                while(rs.next()) {
                    hasData = true;
                    int auctionId = rs.getInt("AuctionID");
                    String itemName = rs.getString("ITEM_NAME");
                    int currentPrice = rs.getInt("CurrentHighestPrice");
                    Timestamp endTime = rs.getTimestamp("EndTime");
                    long endTimeMillis = endTime.getTime();
        %>

            <div class="item-card">
                <img src="images/<%= itemName %>.png" class="item-img" alt="<%= itemName %>" onerror="this.src='https://via.placeholder.com/200x160/000000/FFFFFF?text=Item+Image'">
                
                <h3><%= itemName %></h3>
                
                <div class="price"><%= formatter.format(currentPrice) %> G</div>
                
                <div class="time-box" id="timer-<%= auctionId %>" data-end="<%= endTimeMillis %>">
                    계산 중...
                </div>

                <form action="auction_bid.jsp" method="POST">
                    <input type="hidden" name="auctionId" value="<%= auctionId %>">
                    <input type="number" name="amount" class="bid-input" placeholder="입찰가" min="<%= currentPrice + 1 %>" required>
                    <button type="submit" class="bid-btn">⚡ 입찰하기</button>
                </form>
                
                <a href="add_favorite.jsp?auctionId=<%= auctionId %>" class="fav-link">★ 관심 등록</a>
            </div>

        <%
                }
                if (!hasData) {
        %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 50px; color: #888;">
                조건에 맞는 진행 중인 경매가 없습니다.
            </div>
        <%
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                if(rs!=null) rs.close();
                if(pstmt!=null) pstmt.close();
                if(conn!=null) conn.close();
            }
        %>

        </div>

        <a href="index.jsp" class="home-btn">로비로 돌아가기</a>
    </div>
</div>

<script>
    function updateTimers() {
        const now = new Date().getTime();
        
        const timers = document.querySelectorAll('.time-box');
        
        timers.forEach(timer => {
            const endTime = parseInt(timer.getAttribute('data-end'));
            const diff = endTime - now;
            
            if (diff <= 0) {
                timer.innerHTML = "🚫 경매 종료";
                timer.style.color = "#888";
            } else {
                const hours = Math.floor(diff / (1000 * 60 * 60));
                const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((diff % (1000 * 60)) / 1000);
                
                const hStr = String(hours).padStart(2, '0');
                const mStr = String(minutes).padStart(2, '0');
                const sStr = String(seconds).padStart(2, '0');
                
                timer.innerHTML = "⏰ " + hStr + ":" + mStr + ":" + sStr + " 남음";
                
                if (hours < 1) {
                    timer.classList.add('time-urgent');
                }
            }
        });
    }

    setInterval(updateTimers, 1000);
    updateTimers();
</script>

</body>
</html>