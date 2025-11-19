<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q1: 잔액 조회</title>
<style>
    body { font-family: sans-serif; padding: 20px; }
    .container { max-width: 800px; margin: auto; }
    table { border-collapse: collapse; width: 100%; margin-top: 15px; }
    th, td { border: 1px solid #ddd; padding: 8px; }
    th { background-color: #f2f2f2; }
    .form-input { padding: 8px; }
</style>
</head>
<body>
<div class="container">
<%
    String balanceParam = request.getParameter("balance_gt");
    long balance_gt = 10000;
    if (balanceParam != null && !balanceParam.isEmpty()) {
        try {
            balance_gt = Long.parseLong(balanceParam);
        } catch (NumberFormatException e) {

        }
    }
%>

    <h2>Q1: 잔액 N원 이상 사용자 조회</h2>
    
    <form action="admin_q1.jsp" method="get">
        잔액이 
        <input type="number" name="balance_gt" value="<%= balance_gt %>" class="form-input"> 
        원보다 큰 사용자 조회
        <input type="submit" value="조회">
    </form>

    <table>
        <thead>
            <tr><th>UserID</th><th>Name</th><th>Balance</th></tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT UserID, Name, Balance FROM USERS WHERE Balance > ?";

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setLong(1, balance_gt);
        
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
%>
            <tr>
                <td><%= rs.getString("UserID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td><%= rs.getLong("Balance") %></td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='3'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
        </tbody>
    </table>
    <br>
    <a href="admin_menu.jsp">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>