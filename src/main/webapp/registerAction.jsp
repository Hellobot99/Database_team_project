<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 처리</title>
</head>
<body>
<h1>회원가입 처리 결과</h1>

<%
    request.setCharacterEncoding("UTF-8");

    String userID = request.getParameter("userID");
    String password = request.getParameter("password");
    String name = request.getParameter("name");

    Connection conn = null;
    PreparedStatement pstmt = null;
    String message = "";

    try {
    	conn = DBConnection.getConnection();

        String sql = "INSERT INTO USERS (UserID, Password, Name, Balance, Tier) "
                   + " VALUES (?, ?, ?, 0, 'Bronze')";

        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, userID);
        pstmt.setString(2, password);
        pstmt.setString(3, name);

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            message = "<h2>" + name + "님, 회원가입 성공!</h2>" 
                    + "<p>ID: " + userID + "로 등록되었습니다.</p>";
        } else {
            message = "<h2>회원가입 실패</h2><p>데이터베이스 처리 중 오류가 발생했습니다.</p>";
        }

    } catch (SQLException se) {
        if (se.getErrorCode() == 1) {
            message = "<h2>회원가입 실패</h2><p>오류: 이미 존재하는 아이디입니다: " + userID + "</p>";
        } else {
            message = "<h2>DB SQL 오류</h2><p>" + se.getMessage() + "</p>";
        }
        se.printStackTrace();
    } catch (Exception e) {
        message = "<h2>기타 오류</h2><p>" + e.getMessage() + "</p>";
        e.printStackTrace();
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

    <%= message %>

    <br>
    <a href="register.html">회원가입 페이지로 돌아가기</a>

</body>
</html>