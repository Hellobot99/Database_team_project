<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q1: 잔액 조회</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', sans-serif; 
        background-color: #121212; 
        color: #e0e0e0; 
        margin: 0; 
        padding: 40px; 
    }

    .container { 
        max-width: 800px; 
        margin: 0 auto; 
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 30px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    h2 { 
        margin-top: 0;
        color: #fff;
        text-align: center;
        margin-bottom: 30px;
        border-bottom: 2px solid #444;
        padding-bottom: 15px;
    }

    .search-form {
        background: #2a2a2a;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
        margin-bottom: 20px;
        border: 1px solid #444;
    }

    .form-input { 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #1a1a1a; 
        color: #fff;
        font-size: 1rem;
        width: 150px;
        text-align: right;
        margin: 0 10px;
    }

    .btn-search {
        padding: 10px 20px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        font-size: 1rem;
        transition: background 0.2s;
    }
    .btn-search:hover { background-color: #0056b3; }

    table { 
        width: 100%; 
        border-collapse: collapse; 
        margin-top: 20px; 
        background-color: #252525;
        border-radius: 8px;
        overflow: hidden;
    }
    
    th { 
        background-color: #333; 
        color: #bbb; 
        padding: 12px; 
        text-align: left; 
        border-bottom: 2px solid #444;
    }
    
    td { 
        padding: 12px; 
        border-bottom: 1px solid #333; 
        color: #e0e0e0; 
    }

    tr:last-child td { border-bottom: none; }
    tr:hover { background-color: #2a2a2a; }

    .back-btn {
        display: block;
        width: 200px;
        margin: 30px auto 0;
        padding: 12px;
        background-color: #444;
        color: #ccc;
        text-align: center;
        text-decoration: none;
        border-radius: 50px;
        font-weight: bold;
        transition: background 0.2s;
    }
    .back-btn:hover { background-color: #555; color: #fff; }
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
    
    <div class="search-form">
        <form action="admin_q1.jsp" method="get">
            잔액이 
            <input type="number" name="balance_gt" value="<%= balance_gt %>" class="form-input"> 
            원보다 큰 사용자
            <input type="submit" value="조회" class="btn-search">
        </form>
    </div>

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
                <td style="color: #28a745; font-weight: bold;"><%= rs.getLong("Balance") %> G</td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='3' style='text-align:center; color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
        </tbody>
    </table>
    
    <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>