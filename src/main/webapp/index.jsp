<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    String userTier = (String) session.getAttribute("userTier");
    if (userId == null) { response.sendRedirect("login.html"); return; }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>경매장 메인</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background-color: #121212; color: #e0e0e0; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    
    .lobby-container { max-width: 1100px; margin: 50px auto; text-align: center; }
    h1 { margin-bottom: 40px; color: #fff; text-shadow: 0 0 10px #ff9900; }

    .menu-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 15px;
        padding: 20px;
    }

    .menu-card {
        background: #2a2a2a;
        border: 2px solid #444;
        border-radius: 12px;
        height: 220px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-decoration: none;
        color: #fff;
        transition: all 0.2s;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }

    .menu-card:hover { transform: translateY(-5px); border-color: #ff9900; background: #333; }
    
    .menu-icon { font-size: 3.5em; margin-bottom: 15px; }
    .menu-title { font-size: 1.4em; font-weight: bold; }
    .menu-desc { font-size: 0.9em; color: #888; margin-top: 5px; }

    .search-card { border-bottom: 5px solid #00c6ff; }
    .market-card { border-bottom: 5px solid #28a745; }
    .sell-card   { border-bottom: 5px solid #ffc107; }
    .guide-card  { border-bottom: 5px solid #d63384; }

    .sub-menu { margin-top: 40px; background: #1e1e1e; padding: 20px; border-radius: 10px; display: inline-block; border: 1px solid #333; }
    .sub-link { color: #aaa; text-decoration: none; margin: 0 15px; font-weight: bold; transition: color 0.2s; }
    .sub-link:hover { color: #fff; text-decoration: underline; }
</style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="lobby-container">
        <h1>TRADING CENTER</h1>

        <div class="menu-grid">
            <a href="auction_list.jsp" class="menu-card search-card">
                <div class="menu-icon">🔍</div>
                <div class="menu-title">검색 (구매)</div>
                <div class="menu-desc">등록된 아이템 입찰하기</div>
            </a>

            <a href="market_price.jsp" class="menu-card market-card">
                <div class="menu-icon">📈</div>
                <div class="menu-title">시세</div>
                <div class="menu-desc">최근 거래 완료된 가격</div>
            </a>

            <a href="show_my_registered_item_list_action.jsp" class="menu-card sell-card">
                <div class="menu-icon">💰</div>
                <div class="menu-title">판매 관리</div>
                <div class="menu-desc">내 아이템 등록/삭제 하기</div>
            </a>

            <a href="tutorial.jsp" class="menu-card guide-card">
                <div class="menu-icon">📘</div>
                <div class="menu-title">튜토리얼</div>
                <div class="menu-desc">게임 이용 가이드</div>
            </a>
        </div>
        
        <div class="sub-menu">
            <a href="my_history.jsp" class="sub-link" style="color:#ffcc00;">📜 나의 거래 내역</a> | 
            <a href="myAuction.jsp" class="sub-link">참여 중인 경매</a> |
            <a href="myProfile.jsp" class="sub-link">내 정보</a>
            <% if ("ADMIN".equals(userTier)) { %> | <a href="admin/admin_menu.jsp" class="sub-link" style="color:#28a745;">관리자</a> <% } %>
        </div>
    </div>

    <script>
        window.onload = function() {
            var tier = "<%= userTier %>";
            var hasSeenTutorial = localStorage.getItem("hasSeenTutorial");

            if ((tier === "ROOKIE") && !hasSeenTutorial) {
                if(confirm("신규 플레이어시군요! \n게임 이용 방법을 알 수 있는 [튜토리얼]로 이동하시겠습니까?")) {
                    localStorage.setItem("hasSeenTutorial", "true");
                    location.href = "tutorial.jsp";
                } else {
                    localStorage.setItem("hasSeenTutorial", "true");
                }
            }
        }
    </script>
</body>
</html>