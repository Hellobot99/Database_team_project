<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*, TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>사용자 종합 관리</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, Roboto, sans-serif;
        background-color: #121212; 
        color: #e0e0e0; 
        margin: 0; 
        padding: 40px; 
    }

    .container { max-width: 1200px; margin: 0 auto; }

    .header-title { 
        font-size: 2rem; 
        font-weight: 800; 
        color: #fff; 
        border-bottom: 3px solid #333; 
        padding-bottom: 20px; 
        margin-bottom: 40px; 
        letter-spacing: -1px;
        text-shadow: 0 0 10px rgba(0,0,0,0.5);
    }

    .top-layout {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 40px;
    }

    .card {
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 25px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
    }

    .card h3 {
        margin-top: 0;
        margin-bottom: 20px;
        font-size: 1.2rem;
        color: #007bff;
        border-bottom: 1px solid #444;
        padding-bottom: 10px;
    }

    .form-group { margin-bottom: 15px; }
    
    label { display: block; font-weight: bold; margin-bottom: 5px; font-size: 0.9rem; color: #aaa; }
    
    input[type=text], input[type=password], input[type=number] {
        width: 100%;
        padding: 10px;
        border: 1px solid #444;
        border-radius: 6px;
        font-size: 0.95rem;
        box-sizing: border-box;
        background-color: #2a2a2a;
        color: #fff;
    }
    
    input[type=text]:focus, input[type=password]:focus {
        outline: none; border-color: #007bff;
    }

    input[type=submit] {
        background: #007bff;
        color: white;
        border: none;
        padding: 12px;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        width: 100%;
        font-size: 1rem;
        transition: background 0.2s;
    }
    input[type=submit]:hover { background-color: #0056b3; }

    .table-container {
        border: 1px solid #333;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        background: #1e1e1e;
    }

    table { width: 100%; border-collapse: collapse; }
    
    th {
        background-color: #252525;
        color: #bbb;
        font-weight: bold;
        padding: 15px;
        text-align: left;
        border-bottom: 2px solid #444;
    }
    
    td {
        padding: 15px;
        border-bottom: 1px solid #333;
        color: #e0e0e0;
    }
    
    tr:hover { background-color: #2a2a2a; }

    .btn-action {
        display: inline-block;
        padding: 6px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 0.85rem;
        font-weight: bold;
        margin-right: 5px;
        transition: background 0.2s;
    }

    .btn-edit { background-color: #007bff; color: white; }
    .btn-edit:hover { background-color: #0056b3; }
    
    .btn-delete { background-color: #dc3545; color: white; }
    .btn-delete:hover { background-color: #c82333; }

    .back-btn {
        display: inline-block;
        margin-top: 30px;
        padding: 10px 20px;
        background-color: #333;
        color: #ccc;
        text-decoration: none;
        border-radius: 50px;
        font-weight: bold;
        transition: background 0.2s;
    }
    .back-btn:hover { background-color: #444; color: #fff; }
</style>
</head>
<body>

<div class="container">
    <div class="header-title">사용자 종합 관리</div>
    
    <div class="top-layout">
        <div class="card">
            <h3>➕ 새 사용자 추가</h3>
            <form action="admin_user_create_action.jsp" method="post">
                <div class="form-group">
                    <label>아이디</label>
                    <input type="text" name="userID" required placeholder="User ID">
                </div>
                <div class="form-group">
                    <label>비밀번호</label>
                    <input type="text" name="password" value="1234" required>
                </div>
                <div class="form-group">
                    <label>이름</label>
                    <input type="text" name="name" required placeholder="Name">
                </div>
                <div class="form-group">
                    <label>등급</label>
                    <input type="text" name="tier" value="Bronze" required>
                </div>
                <input type="submit" value="추가하기">
            </form>
        </div>

        <div class="card">
            <h3>🔍 사용자 검색</h3>
            <form action="admin_user_manage.jsp" method="get">
                <div class="form-group">
                    <label>검색어 (ID 또는 이름)</label>
                    <input type="text" name="search_query" value="${param.search_query}" placeholder="검색어를 입력하세요...">
                </div>
                <input type="submit" value="검색" style="background-color: #28a745;">
            </form>
        </div>
    </div>

    <h3 style="margin-bottom: 15px; color: #ffcc00;">📋 사용자 목록</h3>
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>UserID</th>
                    <th>Name</th>
                    <th>Tier</th>
                    <th>Balance</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String searchQuery = request.getParameter("search_query");
    
    String sql = "SELECT UserID, Name, Tier, Balance FROM USERS";
    if (searchQuery != null && !searchQuery.isEmpty()) {
        sql += " WHERE UserID LIKE ? OR Name LIKE ?";
    }
    sql += " ORDER BY Name";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        if (searchQuery != null && !searchQuery.isEmpty()) {
            pstmt.setString(1, "%" + searchQuery + "%");
            pstmt.setString(2, "%" + searchQuery + "%");
        }
        
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
%>
            <tr>
                <td style="font-weight:bold; color:#fff;"><%= rs.getString("UserID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td><span style="background:#444; color:#ccc; padding:2px 6px; border-radius:4px; font-size:0.8rem;"><%= rs.getString("Tier") %></span></td>
                <td style="color:#28a745;"><%= rs.getLong("Balance") %> G</td>
                <td>
                    <a href="admin_user_update_form.jsp?userID=<%= rs.getString("UserID") %>" class="btn-action btn-edit">수정</a>
                    <a href="admin_user_delete_action.jsp?userID=<%= rs.getString("UserID") %>"
                       onclick="return confirm('<%= rs.getString("UserID") %> 사용자를 정말 삭제하시겠습니까?');"
                       class="btn-action btn-delete">삭제</a>
                </td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='text-align:center; color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
            </tbody>
        </table>
    </div>

    <div style="text-align: center;">
        <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
    </div>
</div>

</body>
</html>