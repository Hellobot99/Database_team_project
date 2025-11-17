<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>경북대학교 경매 시스템</title>
<style>
    body { font-family: sans-serif; padding: 20px; }
    .menu { border: 1px solid #ccc; padding: 20px; border-radius: 8px; max-width: 500px; margin: auto; }
    .menu a {
        display: block;
        padding: 12px;
        margin: 8px 0;
        background-color: #007bff;
        color: white;
        text-decoration: none;
        text-align: center;
        border-radius: 5px;
        font-size: 16px;
    }
    .menu a.logout { background-color: #dc3545; }
    .menu a.admin-btn { background-color: #28a745; } 
    .welcome { font-size: 1.2em; font-weight: bold; text-align: center; margin-bottom: 20px; }
</style>
</head>
<body>

    <div class="menu">
        <h1>경북대학교 경매 시스템</h1>

<%
    String userId = (String) session.getAttribute("loggedInUserId");
    String userName = (String) session.getAttribute("loggedInName");
    String userTier = (String) session.getAttribute("userTier");

    if (userId == null) {
%>
        <p class="welcome">로그인이 필요합니다.</p>
        <a href="login.html">로그인</a>
        <a href="register.html">회원가입</a>
<%
    } else {
%>
        <p class="welcome"><%= userName %>님 (<%= userTier %>), 환영합니다!</p>
        
        <a href="myProfile.jsp">내 정보 조회</a>
        <a href="deleteAccount.html">회원 탈퇴</a>
        <a href="logoutAction.jsp" class="logout">로그아웃</a>
<%
        if ("ADMIN".equals(userTier)) {
%>
            <hr>
            <h3>관리자 전용</h3>
            <a href="admin/admin_menu.jsp" class="admin-btn">관리자 메뉴</a>
<%
        }
    }
%>
    </div>

</body>
</html>