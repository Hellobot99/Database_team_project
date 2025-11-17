<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>경북대학교 경매 시스템</title>

<style>
    body {
        font-family: Pretendard, sans-serif;
        background: #f7f7f7;
        margin: 0;
        padding: 0;
    }

    .container {
        width: 500px;
        margin: 50px auto;
        background: white;
        border-radius: 15px;
        padding: 40px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        text-align: center;
    }

    h1 { font-size: 28px; margin-bottom: 25px; }
    h2 { font-weight: normal; margin-bottom: 30px; }

    .btn {
        display: block;
        width: 90%;
        padding: 14px;
        margin: 10px auto;
        border: none;
        border-radius: 8px;
        font-size: 18px;
        font-weight: 600;
        cursor: pointer;
        color: white;
        text-decoration: none;
    }

    .blue { background: #007bff; }
    .red { background: #dc3545; }
    .green { background: #28a745; }
    .yellow { background: #ffc107; color:black; }
    .grey { background: #6c757d; }
    .section-title {
        text-align: left;
        margin-top: 40px;
        font-size: 20px;
        font-weight: 700;
    }
</style>
</head>

<body>

<div class="container">

    <h1>경북대학교 경매 시스템</h1>
    <h2><%= userId %>님 환영합니다!</h2>

    <a href="myProfile.jsp" class="btn blue">내 정보 조회</a>
    <a href="inventory.jsp" class="btn blue">내 인벤토리</a>
    <a href="deleteAccount.html" class="btn blue">회원 탈퇴</a>
    <a href="logoutAction.jsp" class="btn red">로그아웃</a>

    <div class="section-title">경매 기능</div>

    <a href="auction_list.jsp" class="btn blue">경매 목록 보기</a>
    <a href="category_list.jsp" class="btn blue">카테고리별 아이템</a>
    <a href="favorite_list.jsp" class="btn blue">내 즐겨찾기</a>
    <a href="myAuction.jsp" class="btn blue">내가 참여한 경매</a>
    <a href="close_auction.jsp" class="btn yellow">경매 종료</a>
    <a href="delete_auction.jsp" class="btn grey">경매 삭제</a>

    <div class="section-title">관리자 전용</div>

    <a href="admin/adminMenu.jsp" class="btn green">관리자 메뉴</a>

</div>

</body>
</html>
