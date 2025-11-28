<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="TeamPrj.DBConnection" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 캐릭터 정보</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', sans-serif; 
        margin: 0; 
        padding: 0;
        background-color: #121212;
        color: #e0e0e0;
    }
    
    .main-wrapper {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 90vh; 
        padding: 40px;
    }
    
    .profile-card { 
        background: #1e1e1e;
        border: 2px solid #333; 
        padding: 40px; 
        border-radius: 15px; 
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        width: 100%;
        max-width: 450px;
        text-align: center;
        position: relative;
    }

    .profile-card::before {
        content: "CHARACTER PROFILE";
        position: absolute;
        top: -12px;
        left: 50%;
        transform: translateX(-50%);
        background: #121212;
        padding: 0 15px;
        color: #ffcc00;
        font-weight: bold;
        letter-spacing: 2px;
        font-size: 0.9rem;
    }

    h1 {
        margin-bottom: 30px;
        color: #fff;
        text-shadow: 0 0 10px #007bff;
    }

    .info-group {
        text-align: left;
        background: #2a2a2a;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 25px;
        border: 1px solid #444;
    }

    .info-row {
        display: flex;
        justify-content: space-between;
        margin-bottom: 15px;
        font-size: 1.1em;
        border-bottom: 1px solid #333;
        padding-bottom: 10px;
    }
    .info-row:last-child {
        border-bottom: none;
        margin-bottom: 0;
        padding-bottom: 0;
    }

    .label { color: #888; font-weight: bold; }
    .value { color: #fff; font-weight: bold; }
    
    .tier-badge { color: #ffcc00; text-shadow: 0 0 5px #ffaa00; }
    .money-value { color: #28a745; }

    .btn-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    
    .btn {
        display: block;
        width: 100%;
        padding: 12px 0;
        text-decoration: none;
        border-radius: 8px;
        font-weight: bold;
        transition: all 0.2s;
        box-sizing: border-box;
    }

    .btn-primary {
        background-color: #007bff;
        color: white;
        border: none;
    }
    .btn-primary:hover { background-color: #0056b3; }

    .btn-secondary {
        background-color: #444;
        color: #ccc;
    }
    .btn-secondary:hover { background-color: #555; color: #fff; }

    .btn-danger {
        background-color: transparent;
        border: 1px solid #dc3545;
        color: #dc3545;
        font-size: 0.9em;
        margin-top: 10px;
    }
    .btn-danger:hover { background-color: #dc3545; color: white; }

</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <div class="profile-card">

    <%
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect("login.html");
            return; 
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        DecimalFormat formatter = new DecimalFormat("#,###");

        String sql = "SELECT UserID, Name, Tier, Balance FROM USERS WHERE UserID = ?";

        try {
            conn = DBConnection.getConnection();
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId); 
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String tier = rs.getString("Tier");
                long balance = rs.getLong("Balance");
    %>
                <div style="font-size: 4rem; margin-bottom: 10px;">👤</div>
                
                <h1><%= rs.getString("Name") %></h1>

                <div class="info-group">
                    <div class="info-row">
                        <span class="label">계정 ID</span>
                        <span class="value"><%= rs.getString("UserID") %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">플레이어 등급</span>
                        <span class="value tier-badge"><%= tier != null ? tier : "ROOKIE" %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">보유 자산</span>
                        <span class="value money-value"><%= formatter.format(balance) %> G</span>
                    </div>
                </div>
    <%
            } else {
                out.println("<h2 style='color:red'>오류</h2><p>사용자 정보를 불러올 수 없습니다.</p>");
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

        <div class="btn-container">
            <a href="updateProfile.jsp" class="btn btn-primary">정보 수정</a>
            <a href="index.jsp" class="btn btn-secondary">로비로 돌아가기</a>
            
            <a href="deleteAccount.html" class="btn btn-danger" onclick="return confirm('정말로 탈퇴하시겠습니까? 모든 데이터가 삭제됩니다.');">회원 탈퇴</a>
        </div>
        
    </div> 
</div>

</body>
</html>