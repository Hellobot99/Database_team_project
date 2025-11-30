<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q3: 가격대별 물품 조회</title>
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

    input[type=number] { 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #1a1a1a; 
        color: #fff;
        font-size: 1rem;
        width: 120px;
        text-align: right;
        margin: 0 10px;
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
        margin-left: 15px;
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
        text-align: center; 
        border-bottom: 2px solid #444;
    }
    
    td { 
        padding: 12px; 
        border-bottom: 1px solid #333; 
        color: #e0e0e0; 
        text-align: center;
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
    String minPriceStr = request.getParameter("min_price");
    String maxPriceStr = request.getParameter("max_price");
    
    long minPrice = 0;
    long maxPrice = 999999999;
    
    if (minPriceStr != null && !minPriceStr.isEmpty()) {
        try { minPrice = Long.parseLong(minPriceStr); } catch (NumberFormatException e) {}
    }
    if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
        try { maxPrice = Long.parseLong(maxPriceStr); } catch (NumberFormatException e) {}
    }
%>
    <h2>Q3: 가격대별 물품 조회 (BETWEEN)</h2>
    
    <div class="search-box">
        <form action="admin_q3.jsp" method="get">
            가격 범위: 
            <input type="number" name="min_price" value="<%=minPrice == 0 ? "" : minPrice%>" placeholder="최소 가격">
            ~
            <input type="number" name="max_price" value="<%=maxPrice == 999999999 ? "" : maxPrice%>" placeholder="최대 가격">
            <input type="submit" value="조회">
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>Auction ID</th>
                <th>Item Name</th>
                <th>Category</th>
                <th>Current Price</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT A.AuctionID, I.Name, C.Name AS CategoryName, A.CurrentHighestPrice "
               + "FROM AUCTION A "
               + "JOIN ITEM I ON A.ItemID = I.ItemID "
               + "JOIN CATEGORY C ON I.CategoryID = C.CategoryID "
               + "WHERE A.CurrentHighestPrice BETWEEN ? AND ? "
               + "ORDER BY A.CurrentHighestPrice ASC";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setLong(1, minPrice);
        pstmt.setLong(2, maxPrice);
        
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
%>
            <tr>
                <td><%= rs.getString("AuctionID") %></td>
                <td><%= rs.getString("Name") %></td>
                <td><span style="background:#444; padding:2px 6px; border-radius:4px; font-size:0.8rem;"><%= rs.getString("CategoryName") %></span></td>
                <td style="color: #28a745; font-weight: bold;"><%= rs.getLong("CurrentHighestPrice") %> G</td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='4' style='color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
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