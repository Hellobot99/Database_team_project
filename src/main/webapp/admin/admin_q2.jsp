<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q2: 물품 키워드 검색</title>
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
        max-width: 900px; 
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

    .search-box {
        background: #2a2a2a;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
        margin-bottom: 20px;
        border: 1px solid #444;
    }

    input[type=text] { 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #1a1a1a; 
        color: #fff;
        font-size: 1rem;
        width: 250px;
        margin-right: 10px;
    }

    input[type=submit] {
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
    input[type=submit]:hover { background-color: #0056b3; }

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
    String keywordParam = request.getParameter("keyword");
    String searchKeyword = (keywordParam != null) ? keywordParam : "";
%>

    <h2>Q2: 특정 키워드가 포함된 물품 검색</h2>
    
    <div class="search-box">
        <form action="admin_q2.jsp" method="get">
            키워드 입력: 
            <input type="text" name="keyword" value="<%=searchKeyword%>" placeholder="아이템 이름 또는 설명">
            <input type="submit" value="검색">
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Item Name</th>
                <th>Category</th>
                <th>Description</th>
                <th>Base Price</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT I.ItemID, I.Name, C.Name AS CategoryName, I.Description, I.BasePrice "
               + "FROM ITEM I "
               + "JOIN CATEGORY C ON I.CategoryID = C.CategoryID "
               + "WHERE UPPER(I.Name) LIKE UPPER(?) OR UPPER(I.Description) LIKE UPPER(?) "
               + "ORDER BY I.Name ASC";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, "%" + searchKeyword + "%");
        pstmt.setString(2, "%" + searchKeyword + "%");
        
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            String desc = rs.getString("Description");
            if(desc == null) desc = "-";
            if(desc.length() > 20) desc = desc.substring(0, 20) + "...";
%>
            <tr>
                <td><%= rs.getString("ItemID") %></td>
                <td style="font-weight:bold; color:#fff;"><%= rs.getString("Name") %></td>
                <td><span style="background:#444; padding:2px 6px; border-radius:4px; font-size:0.8rem;"><%= rs.getString("CategoryName") %></span></td>
                <td style="color:#aaa;"><%= desc %></td>
                <td style="color:#28a745;"><%= rs.getLong("BasePrice") %> G</td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='text-align:center; color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e){}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
        </tbody>
    </table>
    
    <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>