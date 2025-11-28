<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>캐릭터 정보 수정</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', sans-serif; 
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        margin: 0;
        background-color: #121212;
        color: #e0e0e0;
    }
    
    .update-card { 
        background: #1e1e1e;
        border: 2px solid #333; 
        padding: 40px; 
        border-radius: 15px; 
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        width: 100%;
        max-width: 450px;
        position: relative;
    }

    h3 { 
        text-align: center; 
        margin-top: 0; 
        margin-bottom: 30px;
        color: #fff;
        text-shadow: 0 0 10px #007bff;
        font-size: 1.5rem;
    }
    
    .form-group { margin-bottom: 20px; }
    
    label { 
        display: block; 
        margin-bottom: 8px; 
        color: #888; 
        font-weight: bold; 
        font-size: 0.9rem;
    }
    
    input[type=text], input[type=password] { 
        width: 100%; 
        padding: 12px; 
        background: #2a2a2a;
        border: 1px solid #444; 
        border-radius: 6px; 
        color: #fff;
        font-size: 1rem;
        box-sizing: border-box;
        transition: border-color 0.2s;
    }
    
    input:focus {
        outline: none;
        border-color: #007bff;
    }
    
    input[disabled] { 
        background-color: #151515; 
        color: #555; 
        border-color: #333;
        cursor: not-allowed;
    }
    
    input[type=submit] { 
        width: 100%; 
        padding: 14px; 
        background: linear-gradient(135deg, #007bff, #0056b3); 
        color: white; 
        border: none; 
        cursor: pointer; 
        font-size: 1.1rem; 
        font-weight: bold;
        border-radius: 8px;
        margin-top: 10px;
        transition: transform 0.1s;
    }
    input[type=submit]:hover {
        transform: translateY(-2px);
        filter: brightness(1.1);
    }
    
    .btn-back {
        display: block;
        width: 100%;
        padding: 14px 0;
        text-align: center;
        margin-top: 10px;
        background-color: #444;
        color: #ccc;
        text-decoration: none;
        border-radius: 8px;
        font-weight: bold;
        font-size: 1.1rem;
        box-sizing: border-box;
        transition: all 0.2s;
    }
    .btn-back:hover { 
        background-color: #555; 
        color: #fff; 
    }

    .notice-text {
        font-size: 0.85rem;
        color: #ff4444;
        margin-top: 6px;
        display: block;
    }
</style>
</head>
<body>

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return; 
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT Name, Password, Tier FROM USERS WHERE UserID = ?";
    
    String currentName = "";
    String currentPassword = "";
    String currentTier = "";

    try {
        conn = DBConnection.getConnection();
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            currentName = rs.getString("Name");
            currentPassword = rs.getString("Password");
            currentTier = rs.getString("Tier");
        } else {
            out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
            return;
        }
    } catch (Exception e) {
        out.println("DB 오류: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

    <div class="update-card">

        <h3>⚙️ 캐릭터 정보 수정</h3>
        
        <form action="updateProfileAction.jsp" method="post">
            
            <div class="form-group">
                <label>계정 ID (변경 불가)</label>
                <input type="text" name="userID" value="<%= userId %>" disabled>
            </div>
            
            <div class="form-group">
                <label for="name">캐릭터 이름 (닉네임)</label>
                <input type="text" id="name" name="name" value="<%= currentName %>" required placeholder="새로운 이름을 입력하세요">
                <span class="notice-text">* 닉네임 변경 시 10,000 G 수수료가 차감됩니다.</span>
            </div>
    
            <div class="form-group">
                <label for="password">비밀번호 변경</label>
                <input type="text" id="password" name="password" value="<%= currentPassword %>" required>
            </div>
    
            <div class="form-group">
                <label>플레이어 등급 (변경 불가)</label>
                <input type="text" name="tier" value="<%= currentTier != null ? currentTier : "ROOKIE" %>" disabled>
            </div>
            
            <input type="submit" value="변경사항 저장">
        </form>
        
        <a href="myProfile.jsp" class="btn-back">저장하지 않고 돌아가기</a>

    </div>

</body>
</html>