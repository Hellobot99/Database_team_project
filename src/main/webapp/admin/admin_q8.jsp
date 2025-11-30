<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q8: 입찰 내역 없는 사용자</title>
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
        margin-bottom: 10px;
        border-bottom: 2px solid #444;
        padding-bottom: 15px;
    }
    
    .subtitle {
        text-align: center;
        color: #aaa;
        margin-bottom: 30px;
        font-size: 0.9rem;
    }

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
    
    .tier-badge {
        background: #444; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 0.8rem;
    }
</style>
</head>
<body>
<div class="container">
    <h2>Q8: 입찰 내역이 없는 사용자 목록</h2>
    <p class="subtitle">경매에 한 번도 참여하지 않은(입찰 기록이 없는) 유령 회원 조회 (Outer Join)</p>

    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>User Name</th>
                <th>Tier</th>
                <th>Balance</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String sql = "SELECT U.UserID, U.Name, U.Tier, U.Balance "
               + "FROM USERS U "
               + "LEFT JOIN BIDDING_RECORD B ON U.UserID = B.BidderID "
               + "WHERE B.BidderID IS NULL "
               + "ORDER BY U.UserID ASC";

    try {
        conn = DBConnection.getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        
        while(rs.next()) {
%>
            <tr>
                <td><%= rs.getString("UserID") %></td>
                <td style="font-weight:bold; color:#fff;"><%= rs.getString("Name") %></td>
                <td><span class="tier-badge"><%= rs.getString("Tier") %></span></td>
                <td style="color:#28a745;"><%= rs.getLong("Balance") %> G</td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='4' style='color:red;'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e){}
        if(stmt != null) try { stmt.close(); } catch(Exception e){}
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
        </tbody>
    </table>
    
    <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>