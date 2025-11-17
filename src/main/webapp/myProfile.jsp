<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 정보</title>
<style>
    body { 
        font-family: sans-serif; 
        
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        margin: 0;
        background-color: #f7f7f7;
    }
    
    .profile-wrapper {
        border: 1px solid #ccc; 
        padding: 30px; 
        border-radius: 8px; 
        background-color: #fff;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        width: 100%;
        max-width: 400px;
    }

    .profile { 
        border: 1px solid #ccc; 
        padding: 20px; 
        border-radius: 8px; 
        background-color: #f9f9f9;
    }
    .profile p { font-size: 1.1em; line-height: 1.6; }
    .profile p span { font-weight: bold; min-width: 80px; display: inline-block; }
    
    .btn {
        display: inline-block;
        padding: 10px 15px;
        margin-top: 15px;
        margin-right: 10px;
        background-color: #007bff;
        color: white;
        text-decoration: none;
        border-radius: 5px;
        font-size: 14px;
    }
    .btn-secondary { background-color: #6c757d; }
    
    .links-container {
        margin-top: 20px;
        text-align: center;
    }
</style>
</head>
<body>

<div class="profile-wrapper">

<%
    String userId = (String) session.getAttribute("loggedInUserId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return; 
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT UserID, Name, Tier, Balance FROM USERS WHERE UserID = ?";

    try {
    	conn = DBConnection.getConnection();
    	
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId); 
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>
            <h1>내 정보</h1>
            <div class="profile">
                <p><span>아이디:</span> <%= rs.getString("UserID") %></p>
                <p><span>이름:</span> <%= rs.getString("Name") %></p>
                <p><span>등급:</span> <%= rs.getString("Tier") %></p>
                <p><span>잔액:</span> <%= rs.getLong("Balance") %> 원</p>
            </div>
<%
        } else {
            out.println("<h2>오류</h2><p>로그인된 사용자 정보를 찾을 수 없습니다.</p>");
        }
    } catch (Exception e) {
        out.println("<h2>DB 오류</h2><p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

    <div class="links-container">
        <a href="updateProfile.jsp" class="btn">회원정보 변경</a>
        <a href="index.jsp" class="btn btn-secondary">메인 메뉴로</a>
    </div>
    
</div> </body>
</html>