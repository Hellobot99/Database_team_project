<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<%
    String tier = (String) session.getAttribute("userTier");
    if (tier == null || !tier.equals("ADMIN")) {
        response.sendRedirect("../login.html");
        return;
    }
%>

<title>관리자 대시보드</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />

<style>
    body { 
        font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, Roboto, sans-serif;
        background-color: #121212; 
        color: #e0e0e0; 
        margin: 0; 
        padding: 40px; 
    }
    
    .container { 
        max-width: 1100px; 
        margin: 0 auto; 
    }

    h1 { 
        font-size: 2rem; 
        font-weight: 800; 
        color: #fff; 
        border-bottom: 3px solid #333; 
        padding-bottom: 20px; 
        margin-bottom: 40px;
        letter-spacing: -1px;
        text-shadow: 0 0 10px rgba(0,0,0,0.5);
    }

    h2 {
        font-size: 1.1rem;
        color: #aaa;
        font-weight: 700;
        margin-top: 50px;
        margin-bottom: 15px;
        padding-left: 10px;
        border-left: 4px solid #007bff; 
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
        margin-bottom: 40px;
    }

    .action-card {
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 25px;
        transition: all 0.2s ease;
        box-shadow: 0 4px 6px rgba(0,0,0,0.2);
        display: flex;
        flex-direction: column;
        justify-content: center;
        text-decoration: none;
        color: #e0e0e0;
        position: relative;
        overflow: hidden;
    }

    .action-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 123, 255, 0.1);
        background: #252525;
        border-color: #555;
    }
    .action-card:hover h3 { color: #007bff; }

    .action-card h3 { margin: 0 0 10px 0; font-size: 1.3rem; color: #fff; }
    .action-card span { font-size: 0.9rem; color: #888; line-height: 1.4; }
    
    .query-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(480px, 1fr)); 
        gap: 12px;
        padding: 0;
        list-style: none;
    }

    .query-item {
        background: #1e1e1e; 
        border: 1px solid #333;
        border-radius: 8px;
        padding: 15px 20px;
        transition: background 0.2s;
        display: flex;
        flex-direction: column;
    }

    .query-item:hover {
        background: #252525;
        border-color: #555;
    }

    .query-item a {
        text-decoration: none;
        color: #fff;
        font-weight: 600;
        font-size: 1rem;
        margin-bottom: 4px;
        display: block;
    }
    
    .query-item a:hover { color: #007bff; text-decoration: underline; }

    .query-item span {
        font-size: 0.85rem;
        color: #888;
    }

    .home-btn {
        display: inline-block;
        margin-top: 40px;
        padding: 12px 25px;
        background-color: #333;
        color: white;
        text-decoration: none;
        border-radius: 50px;
        font-weight: bold;
        transition: background 0.2s;
    }
    .home-btn:hover { background-color: #555; }

</style>
</head>
<body>

    <div class="container">
        <h1>ADMIN DASHBOARD <span style="font-size:1rem; font-weight:normal; color:#777;"> | 관리자 제어 패널</span></h1>
        
        <div class="dashboard-grid">
            <a href="admin_user_manage.jsp" class="action-card" style="border-left: 5px solid #007bff;">
                <h3>사용자 종합 관리</h3>
                <span>회원 정보 추가, 검색, 수정, 삭제 및 테이블 전체 관리</span>
            </a>

            <a href="admin_inventory_manage.jsp" class="action-card" style="border-left: 5px solid #ffc107;">
                <h3>인벤토리 관리</h3>
                <span>특정 유저에게 아이템 지급(Give) 또는 회수(Take)</span>
            </a>
        </div>

        <h2>검색 및 필터링</h2>
        <ul class="query-grid">
            <li class="query-item">
                <a href="admin_q1.jsp">Q1: 잔액 N원 이상 사용자 조회</a>
                <span>Balance 값을 입력받아 부자 유저를 조회합니다.</span>
            </li>
            <li class="query-item">
                <a href="admin_q2.jsp">Q2: 특정 키워드가 포함된 물품 검색</a>
                <span>물품 이름 또는 설명에 포함된 단어로 검색 (LIKE)</span>
            </li>
            <li class="query-item">
                <a href="admin_q3.jsp">Q3: 가격대별 물품 조회</a>
                <span>최소~최대 가격 사이의 매물을 조회 (BETWEEN)</span>
            </li>
            <li class="query-item">
                <a href="admin_q4.jsp">Q4: 특정 날짜 이후 가입한 회원 조회</a>
                <span>신규 가입자 현황 파악 (Date 비교)</span>
            </li>
        </ul>

        <h2>조인 (Complex Join)</h2>
        <ul class="query-grid">
            <li class="query-item">
                <a href="admin_q5.jsp">Q5: 물품별 판매자 정보 상세 조회</a>
                <span>ITEM과 USERS 테이블 조인</span>
            </li>
            <li class="query-item">
                <a href="admin_q6.jsp">Q6: 특정 카테고리의 물품 목록 조회</a>
                <span>카테고리 선택 -> 해당 물품 리스트 (Join)</span>
            </li>
            <li class="query-item">
                <a href="admin_q7.jsp">Q7: 모든 입찰 기록과 입찰자명 조회</a>
                <span>BID, ITEM, USERS 3중 조인 결과 확인</span>
            </li>
            <li class="query-item">
                <a href="admin_q8.jsp">Q8: 입찰 내역이 없는 사용자 목록</a>
                <span>활동하지 않는 유령 회원 조회 (Outer Join)</span>
            </li>
        </ul>

        <h2>통계 및 집계 (Group By)</h2>
        <ul class="query-grid">
            <li class="query-item">
                <a href="admin_q9.jsp">Q9: 카테고리별 등록된 물품 개수</a>
                <span>GROUP BY Category, COUNT(*)</span>
            </li>
            <li class="query-item">
                <a href="admin_q10.jsp">Q10: 사용자별 총 입찰 횟수/평균가</a>
                <span>VIP 유저 분석용 (AVG, COUNT)</span>
            </li>
            <li class="query-item">
                <a href="admin_q11.jsp">Q11: 가장 비싼 물품 TOP 5</a>
                <span>ORDER BY Price DESC, ROWNUM &lt;= 5</span>
            </li>
            <li class="query-item">
                <a href="admin_q12.jsp">Q12: 입찰자가 3명 이상인 인기 물품</a>
                <span>GROUP BY Item -> HAVING Count &gt;= 3</span>
            </li>
        </ul>

        <h2>심화 검색 (Subquery)</h2>
        <ul class="query-grid">
            <li class="query-item">
                <a href="admin_q13.jsp">Q13: 전체 평균 가격보다 비싼 물품</a>
                <span>평균가 이상의 고가 아이템 필터링 (Subquery)</span>
            </li>
            <li class="query-item">
                <a href="admin_q14.jsp">Q14: 최고가 입찰을 한 사용자 정보</a>
                <span>가장 큰 금액을 베팅한 유저 찾기</span>
            </li>
            <li class="query-item">
                <a href="admin_q15.jsp">Q15: 특정 판매자 물품에 입찰한 사람</a>
                <span>특정 판매자와 거래를 시도한 유저 조회 (IN 절)</span>
            </li>
        </ul>

        <h2>데이터 조작 (Action)</h2>
        <ul class="query-grid">
            <li class="query-item">
                <a href="admin_q16.jsp">Q16: 물품 설명(Description) 수정</a>
                <span>잘못된 설명 수정 (UPDATE)</span>
            </li>
            <li class="query-item">
                <a href="admin_q17.jsp">Q17: 회원의 등급(Tier) 변경</a>
                <span>블랙리스트 지정 또는 등급 상향 (UPDATE)</span>
            </li>
            <li class="query-item">
                <a href="admin_q18.jsp">Q18: 물가 조정 (가격 일괄 변경)</a>
                <span>특정 카테고리 물품 가격 일괄 인상/인하 처리</span>
            </li>
            <li class="query-item">
                <a href="admin_q19.jsp">Q19: 특정 입찰 내역 삭제 (입찰 취소)</a>
                <span>잘못된 입찰 기록 강제 삭제 (DELETE)</span>
            </li>
            <li class="query-item">
                <a href="admin_q20.jsp">Q20: 마감 기한 지난 물품 정리</a>
                <span>기간 만료 아이템 삭제 또는 종료 처리</span>
            </li>
        </ul>

        <div style="text-align: center;">
            <a href="../index.jsp" class="home-btn">게임 로비로 돌아가기</a>
        </div>
    </div>

</body>
</html>