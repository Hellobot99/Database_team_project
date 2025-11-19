<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>사용자 정보 변경</title>
<style>
    body { font-family: sans-serif; padding: 20px; }
    .container { max-width: 500px; margin: auto; }
    form { border: 1px solid #ccc; padding: 20px; border-radius: 8px; }
    div { margin-bottom: 15px; }
    label { display: inline-block; width: 100px; font-weight: bold; }
    input[type=text], input[type=number] { padding: 8px; width: 200px; }
    input[disabled] { background-color: #eee; }
</style>
</head>
<body>
<div class="container">
<%
    String userID_to_update = request.getParameter("userID");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT Name, Password, Tier, Balance FROM USERS WHERE UserID = ?";
    
    String currentName = "", currentPassword = "", currentTier = "";
    long currentBalance = 0;

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID_to_update);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            currentName = rs.getString("Name");
            currentPassword = rs.getString("Password");
            currentTier = rs.getString("Tier");
            currentBalance = rs.getLong("Balance");
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
    <h2>사용자 정보 변경 (Update)</h2>
    <form action="admin_user_update_action.jsp" method="post">
        
        <input type="hidden" name="userID" value="<%= userID_to_update %>">
        
        <div><label>아이디:</label>
             <input type="text" value="<%= userID_to_update %>" disabled></div>
        
        <div><label for="name">이름:</label>
             <input type="text" id="name" name="name" value="<%= currentName %>" required></div>
        
        <div><label for="password">비밀번호:</label>
             <input type="text" id="password" name="password" value="<%= currentPassword %>" required></div>
        
        <div><label for="tier">등급:</label>
             <input type="text" id="tier" name="tier" value="<%= currentTier %>" required></div>
             
        <div><label for="balance">잔액:</label>
             <input type="number" id="balance" name="balance" value="<%= currentBalance %>" required></div>
             
        <input type="submit" value="변경하기">
    </form>
    <br>
    <a href="admin_user_manage.jsp">뒤로 가기</a>
</div>
</body>
</html>