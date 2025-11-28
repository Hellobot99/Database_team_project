<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection, java.text.DecimalFormat" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    
    request.setCharacterEncoding("UTF-8");
    String searchKeyword = request.getParameter("searchKeyword");
    if(searchKeyword == null) searchKeyword = "";
    
    DecimalFormat df = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>판매 관리</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background: #121212; color: #fff; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    .main-wrapper { padding: 30px; }
    
    h1 { text-align: center; margin-bottom: 30px; text-shadow: 0 0 10px #ffc107; color: #fff; }

    .split-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 30px;
        max-width: 1400px;
        margin: 0 auto;
        height: 80vh;
    }

    .panel {
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 20px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    
    .panel-header {
        font-size: 1.3rem; font-weight: bold; margin-bottom: 15px; padding-bottom: 10px;
        border-bottom: 2px solid #444; display: flex; justify-content: space-between; align-items: center;
    }

    .search-form { display: flex; gap: 5px; }
    .search-input { padding: 8px; border-radius: 4px; border: 1px solid #555; background: #222; color: #fff; width: 150px; }
    .search-btn { padding: 8px 12px; border-radius: 4px; border: none; background: #444; color: #fff; cursor: pointer; }
    .search-btn:hover { background: #666; }

    .scroll-area { flex: 1; overflow-y: auto; padding-right: 5px; }
    
    .item-row {
        display: flex; align-items: center; justify-content: space-between;
        background: #2a2a2a; border: 1px solid #444; border-radius: 8px;
        padding: 15px; margin-bottom: 10px; transition: transform 0.2s;
    }
    .item-row:hover { transform: translateX(5px); border-color: #777; }

    .item-info { display: flex; align-items: center; gap: 15px; }
    .item-img { width: 50px; height: 50px; background: #111; border-radius: 6px; object-fit: contain; border: 1px solid #333; }
    .item-detail div { margin-bottom: 3px; }
    .item-name { font-weight: bold; font-size: 1.1rem; color: #eee; }
    .item-meta { font-size: 0.9rem; color: #aaa; }

    .btn { padding: 8px 16px; border-radius: 6px; border: none; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; font-size: 0.9rem; }
    .btn-register { background: #28a745; color: white; }
    .btn-register:hover { background: #218838; }
    .btn-delete { background: #dc3545; color: white; }
    .btn-delete:hover { background: #c82333; }
    
    .home-btn {
            display: block; width: 150px; margin: 50px auto; text-align: center;
            padding: 12px; background: #444; color: white; text-decoration: none; border-radius: 30px;
        }
        .home-btn:hover { background: #555; }

    .empty-msg { text-align: center; color: #666; margin-top: 50px; }
    
    .home-link { display: block; text-align: center; margin-top: 20px; color: #888; text-decoration: none; }
    .home-link:hover { color: #fff; text-decoration: underline; }
</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <h1>💰 판매 관리 (등록 / 취소)</h1>

    <div class="split-container">
        
        <div class="panel">
            <div class="panel-header">
                <span style="color:#28a745;">📦 내 인벤토리 (등록 대기)</span>
                <form action="show_my_registered_item_list_action.jsp" class="search-form">
                    <input type="text" name="searchKeyword" value="<%= searchKeyword %>" class="search-input" placeholder="아이템 검색">
                    <button type="submit" class="search-btn">🔍</button>
                </form>
            </div>
            
            <div class="scroll-area">
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    String sqlInven = "SELECT v.InventoryID, i.ItemID, i.Name, v.Quantity, v.Conditions " +
                                      "FROM INVENTORY v JOIN ITEM i ON v.ItemID = i.ItemID " +
                                      "WHERE v.UserID = ? AND v.Quantity > 0 ";
                                      
                    if(!searchKeyword.isEmpty()) {
                        sqlInven += "AND i.Name LIKE ? ";
                    }
                    sqlInven += "ORDER BY i.Name ASC";
                    
                    pstmt = conn.prepareStatement(sqlInven);
                    pstmt.setString(1, userId);
                    if(!searchKeyword.isEmpty()) {
                        pstmt.setString(2, "%" + searchKeyword + "%");
                    }
                    rs = pstmt.executeQuery();
                    
                    boolean hasInven = false;
                    while(rs.next()) {
                        hasInven = true;
                %>
                    <div class="item-row">
                        <div class="item-info">
                            <img src="images/<%= rs.getString("Name") %>.png" class="item-img" onerror="this.src='https://via.placeholder.com/50?text=IMG'">
                            <div class="item-detail">
                                <div class="item-name"><%= rs.getString("Name") %></div>
                                <div class="item-meta">수량: <%= rs.getInt("Quantity") %>개 | 상태: <%= rs.getString("Conditions") %></div>
                            </div>
                        </div>
                        <a href="auction_register.jsp?invenId=<%= rs.getInt("InventoryID") %>&itemId=<%= rs.getInt("ItemID") %>&name=<%= rs.getString("Name") %>" class="btn btn-register">
                            등록
                        </a>
                    </div>
                <%
                    }
                    if(!hasInven) out.println("<div class='empty-msg'>등록 가능한 아이템이 없습니다.</div>");
                    rs.close(); pstmt.close();
                %>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <span style="color:#ffc107;">🏷️ 판매 중인 아이템 (경매)</span>
            </div>
            
            <div class="scroll-area">
                <%
                    String sqlAuc = "SELECT a.AuctionID, i.Name, a.CurrentHighestPrice, a.EndTime " +
                                    "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID " +
                                    "WHERE a.SellerID = ? AND a.EndTime > SYSDATE " +
                                    "ORDER BY a.EndTime ASC";
                    pstmt = conn.prepareStatement(sqlAuc);
                    pstmt.setString(1, userId);
                    rs = pstmt.executeQuery();
                    
                    boolean hasAuc = false;
                    while(rs.next()) {
                        hasAuc = true;
                %>
                    <div class="item-row" style="border-left: 4px solid #ffc107;">
                        <div class="item-info">
                            <img src="images/<%= rs.getString("Name") %>.png" class="item-img" onerror="this.src='https://via.placeholder.com/50?text=IMG'">
                            <div class="item-detail">
                                <div class="item-name"><%= rs.getString("Name") %></div>
                                <div class="item-meta" style="color:#ff4444;">현재가: <%= df.format(rs.getInt("CurrentHighestPrice")) %> G</div>
                                <div class="item-meta">마감: <%= rs.getTimestamp("EndTime") %></div>
                            </div>
                        </div>
                        <a href="delete_auction_action.jsp?auctionId=<%= rs.getInt("AuctionID") %>" 
                           onclick="return confirm('정말로 경매를 취소하시겠습니까?');" 
                           class="btn btn-delete">
                            🗑 삭제
                        </a>
                    </div>
                <%
                    }
                    if(!hasAuc) out.println("<div class='empty-msg'>판매 중인 아이템이 없습니다.</div>");
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close();
                }
                %>
            </div>
        </div>
    </div>
    
    <a href="index.jsp" class="home-btn">로비로 돌아가기</a>
</div>

</body>
</html>