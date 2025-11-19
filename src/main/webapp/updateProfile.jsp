<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보 변경</title>
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
    
    .update-wrapper {
        border: 1px solid #ccc; 
        padding: 30px; 
        border-radius: 8px; 
        background-color: #fff;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        width: 100%;
        max-width: 400px;
    }
    
    h3 { 
        text-align: center; 
        margin-top: 0;
    }
    
    div { 
        margin-bottom: 15px; 
    }
    
    label { 
        display: block;
        margin-bottom: 5px;
        font-weight: bold; 
    }
    
    input[type=text], input[type=password] { 
        padding: 10px; 
        width: 95%; 
        border: 1px solid #ddd; 
        border-radius: 4px; 
        font-size: 16px;
    }
    
    input[disabled] { 
        background-color: #eee; 
        color: #777;
    }
    
    input[type=submit] { 
        width: 100%; 
        padding: 12px; 
        background-color: #28a745; 
        color: white; 
        border: none; 
        cursor: pointer; 
        font-size: 16px;
        border-radius: 4px;
    }
    
    .link-to-profile {
        display: block;
        text-align: center;
        margin-top: 20px;
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

    String serverIP = "localhost";
    String strSID = "orcl"; 
    String portNum = "1521";
    String user = "DBA_PROJECT";
    String pass = "1234";
    String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT Name, Password, Tier FROM USERS WHERE UserID = ?";
    
    String currentName = "";
    String currentPassword = "";
    String currentTier = "";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(url, user, pass);
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            currentName = rs.getString("Name");
            currentPassword = rs.getString("Password");
            currentTier = rs.getString("Tier");
        } else {
            out.println("<h2>사용자 정보 없음</h2>");
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

    <div class="update-wrapper">

        <h3>:: 회원정보 변경 ::</h3>
        <form action="updateProfileAction.jsp" method="post">
            
            <div>
                <label>아이디:</label>
                <input type="text" name="userID" value="<%= userId %>" disabled>
            </div>
            
            <div>
                <label for="name">이름 (닉네임):</label>
                <input type="text" id="name" name="name" value="<%= currentName %>" required>
            </div>
    
            <div>
                <label for="password">비밀번호:</label>
                <input type="text" id="password" name="password" value="<%= currentPassword %>" required>
            </div>
    
            <div>
                <label>등급:</label>
                <input type="text" name="tier" value="<%= currentTier %>" disabled>
            </div>
            
            <br>
            <input type="submit" value="변경하기">
        </form>
        
        <a href="myProfile.jsp" class="link-to-profile">내 정보로 돌아가기</a>

    </div> </body>
</html>