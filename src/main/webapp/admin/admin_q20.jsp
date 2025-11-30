<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String deleteDate = request.getParameter("deleteDate");
        
        if(deleteDate != null && !deleteDate.isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                String sql = "DELETE FROM AUCTION WHERE EndTime < TO_DATE(?, 'YYYY-MM-DD')";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, deleteDate);
                
                int count = pstmt.executeUpdate();
                out.println("<script>alert('" + count + "개의 마감된 경매가 삭제되었습니다.'); location.href='admin_q20.jsp';</script>");
            } catch(Exception e) {
                out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
            } finally {
                if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
                if(conn!=null) try{conn.close();}catch(Exception e){}
            }
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q20: 마감 물품 정리</title>
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
        padding: 40px; 
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

    .form-group { margin-bottom: 20px; text-align: center; }
    
    label { 
        font-weight: bold; 
        color: #bbb;
        margin-right: 10px;
    }

    input[type=date] { 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #2a2a2a; 
        color: #fff;
        font-size: 1rem;
    }

    input[type=submit] {
        padding: 10px 20px;
        background-color: #dc3545;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        font-size: 1rem;
        margin-left: 10px;
        transition: background 0.2s;
    }
    input[type=submit]:hover { background-color: #c82333; }

    .back-btn {
        display: block;
        text-align: center;
        margin-top: 30px;
        color: #888;
        text-decoration: none;
        transition: color 0.2s;
    }
    .back-btn:hover { color: #fff; text-decoration: underline; }
    
    .list-area {
        margin-top: 40px;
        border-top: 1px solid #444;
        padding-top: 20px;
    }
    
    table { width: 100%; border-collapse: collapse; }
    th { text-align: center; color: #888; padding: 10px; border-bottom: 1px solid #333; background: #252525; }
    td { padding: 10px; border-bottom: 1px solid #333; text-align: center; color: #ccc; }
</style>
</head>
<body>
<div class="container">
    <h2>Q20: 마감 기한 지난 물품 정리</h2>
    
    <form action="admin_q20.jsp" method="post" onsubmit="return confirm('선택한 날짜 이전에 마감된 모든 경매가 삭제됩니다. 계속하시겠습니까?');">
        <div class="form-group">
            <label>기준 날짜 (이 날짜 이전에 마감된 항목 삭제)</label>
            <input type="date" name="deleteDate" required>
            <input type="submit" value="일괄 삭제">
        </div>
    </form>

    <div class="list-area">
        <h3 style="color:#aaa; font-size:1rem; margin-bottom:10px;">현재 마감된 경매 목록 (삭제 대상 후보)</h3>
        <table>
            <tr>
                <th>AuctionID</th>
                <th>Item Name</th>
                <th>SellerID</th>
                <th>EndTime</th>
                <th>Price</th>
            </tr>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    String sql = "SELECT a.AuctionID, i.Name, a.SellerID, a.EndTime, a.CurrentHighestPrice " + 
                                 "FROM AUCTION a JOIN ITEM i ON a.ItemID = i.ItemID " + 
                                 "WHERE a.EndTime < SYSDATE " +
                                 "ORDER BY a.EndTime ASC FETCH FIRST 10 ROWS ONLY";
                    rs = stmt.executeQuery(sql);
                    
                    while(rs.next()) {
            %>
                <tr>
                    <td><%= rs.getInt("AuctionID") %></td>
                    <td><%= rs.getString("Name") %></td>
                    <td><%= rs.getString("SellerID") %></td>
                    <td style="color:#ff4444;"><%= rs.getTimestamp("EndTime") %></td>
                    <td><%= rs.getLong("CurrentHighestPrice") %></td>
                </tr>
            <%
                    }
                } catch(Exception e) {}
                finally {
                    if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close();
                }
            %>
        </table>
    </div>
    
    <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>