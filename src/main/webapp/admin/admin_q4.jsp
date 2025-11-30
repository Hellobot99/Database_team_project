<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q4: 인벤토리 검색</title>
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

    .form-row { 
        margin-bottom: 15px; 
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 10px;
    }
    
    label { 
        font-weight: bold; 
        color: #bbb; 
        width: 80px; 
        text-align: right;
    }

    input[type=text] { 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #1a1a1a; 
        color: #fff;
        font-size: 1rem;
        width: 250px;
    }

    input[type=submit] {
        padding: 10px 30px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        font-size: 1rem;
        transition: background 0.2s;
        margin-top: 5px;
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
    String userIdParam = request.getParameter("user_id");
    String itemNameParam = request.getParameter("item_name");

    String searchUserId = (userIdParam != null) ? userIdParam : "";
    String searchItemName = (itemNameParam != null) ? itemNameParam : "";
%>
    <h2>Q4: 사용자 인벤토리 검색</h2>
    
    <div class="search-box">
        <form action="admin_q4.jsp" method="get">
            <div class="form-row">
                <label>사용자 ID</label>
                <input type="text" name="user_id" value="<%=searchUserId%>" placeholder="ID 포함 검색">
            </div>
            <div class="form-row">
                <label>아이템명</label>
                <input type="text" name="item_name" value="<%=searchItemName%>" placeholder="아이템명 포함 검색">
            </div>
            <div class="form-row">
                <input type="submit" value="검색하기">
            </div>
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Item Name</th>
                <th>Category Name</th>
                <th>Quantity</th>
                <th>Conditions</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT INV.UserID, I.Name AS ItemName, C.Name AS CategoryName, INV.Quantity, INV.Conditions "
               + "FROM INVENTORY INV, ITEM I, CATEGORY C "
               + "WHERE INV.ItemID = I.ItemID "
               + "  AND I.CategoryID = C.CategoryID "
               + "  AND INV.UserID LIKE ? "
               + "  AND I.Name LIKE ?";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, "%" + searchUserId + "%");
        pstmt.setString(2, "%" + searchItemName + "%");
        
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
%>
            <tr>
                <td><%= rs.getString("UserID") %></td>
                <td style="font-weight:bold; color:#fff;"><%= rs.getString("ItemName") %></td>
                <td><span style="background:#444; padding:2px 6px; border-radius:4px; font-size:0.8rem;"><%= rs.getString("CategoryName") %></span></td>
                <td style="color:#28a745;"><%= rs.getInt("Quantity") %></td>
                <td><%= rs.getString("Conditions") %></td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
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