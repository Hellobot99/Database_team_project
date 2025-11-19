<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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


<title>관리자 메뉴</title>
<style>
    body { font-family: sans-serif; padding: 20px; }
    .container { max-width: 800px; margin: auto; }
    .query-list { list-style: none; padding: 0; }
    .query-list li { background-color: #f4f4f4; border: 1px solid #ddd; padding: 10px; margin-bottom: 5px; }
    .query-list a { text-decoration: none; color: #007bff; font-weight: bold; }
    .query-list span { color: #555; display: block; font-size: 0.9em; margin-top: 4px; }
</style>
</head>
<body>

	<div class="container">
        <h1>관리자 메뉴 - Phase 2 쿼리</h1>
        
        <ul class="query-list">
            
            <li class="management">
                <a href="admin_user_manage.jsp">사용자 종합 관리 (추가/검색/변경/삭제)</a>
                <span>(동적 입력) USERS 테이블을 직접 관리합니다.</span>
            </li>
            
            <li>
                <a href="admin_q1.jsp">Q1: 잔액 N원 이상 사용자 조회</a>
                <span>(동적 입력) 'Balance' 값을 입력받아 조회합니다.</span>
            </li>
            
            </ul>
        
        <br>
        <a href="../index.jsp">메인 메뉴로 돌아가기</a>
    </div>

</body>
</html>