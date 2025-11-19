<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>사용자 종합 관리</title>
<style>
    body { font-family: sans-serif; padding: 20px; }
    .container { max-width: 900px; margin: auto; }
    table { border-collapse: collapse; width: 100%; margin-top: 15px; }
    th, td { border: 1px solid #ddd; padding: 8px; }
    th { background-color: #f2f2f2; }
    .form-box { border: 1px solid #ccc; padding: 20px; border-radius: 8px; margin-bottom: 20px; background-color: #f9f9f9; }
    .form-box input[type=text], .form-box input[type=password], .form-box input[type=number] { padding: 8px; }
    .form-box input[type=submit] { padding: 8px 12px; }
    .search-results a { color: #007bff; text-decoration: none; }
    .search-results a.delete { color: #dc3545; }
</style>
</head>
<body>
<div class="container">
    <h1>사용자 종합 관리</h1>
    
    <div class="form-box">
        <h3>1. 새 사용자 추가 (Create)</h3>
        <form action="admin_user_create_action.jsp" method="post">
            아이디: <input type="text" name="userID" required>
            비밀번호: <input type="text" name="password" value="1234" required>
            이름: <input type="text" name="name" required>
            <br> 등급: <input type="text" name="tier" value="Bronze" required>
            <input type="submit" value="추가하기">
        </form>
    </div>

    <div class="form-box">
        <h3>2. 사용자 검색 (Search)</h3>
        <form action="admin_user_manage.jsp" method="get">
            아이디(UserID) 또는 이름(Name)으로 검색:
            <input type="text" name="search_query" value="${param.search_query}">
            <input type="submit" value="검색">
        </form>
    </div>

    <h3>3. 사용자 목록 (Read / Update / Delete)</h3>
    <table class="search-results">
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
                <td><%= rs.getString("UserID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td><%= rs.getString("Tier") %></td>
                <td><%= rs.getLong("Balance") %></td>
                <td>
                    <a href="admin_user_update_form.jsp?userID=<%= rs.getString("UserID") %>">변경</a>
                    
                    <a href="admin_user_delete_action.jsp?userID=<%= rs.getString("UserID") %>"
                       onclick="return confirm('<%= rs.getString("UserID") %> 사용자를 정말 삭제하시겠습니까?');"
                       class="delete">삭제</a>
                </td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5'>DB 오류: " + e.getMessage() + "</td></tr>");
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