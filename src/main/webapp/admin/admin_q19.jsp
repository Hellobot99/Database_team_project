<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String bidIdStr = request.getParameter("bidId");
        
        if(bidIdStr != null && !bidIdStr.isEmpty()) {
            int bidId = Integer.parseInt(bidIdStr);
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                String sql = "DELETE FROM BIDDING_RECORD WHERE BidID = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, bidId);
                
                int count = pstmt.executeUpdate();
                if(count > 0) {
                    out.println("<script>alert('입찰 내역(ID:" + bidId + ")이 삭제되었습니다.'); location.href='admin_q19.jsp';</script>");
                } else {
                    out.println("<script>alert('해당 입찰 내역을 찾을 수 없습니다.'); history.back();</script>");
                }
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
<title>Q19: 입찰 내역 삭제</title>
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

    input[type=number] { 
        width: 150px; 
        padding: 10px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #2a2a2a; 
        color: #fff;
        font-size: 1rem;
        box-sizing: border-box;
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
    
    .btn-del-small {
        background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 0.8rem;
    }
</style>
</head>
<body>
<div class="container">
    <h2>Q19: 특정 입찰 내역 삭제 (입찰 취소)</h2>
    
    <form action="admin_q19.jsp" method="post" onsubmit="return confirm('정말로 이 입찰 내역을 삭제하시겠습니까?');">
        <div class="form-group">
            <label>삭제할 입찰 ID (BidID)</label>
            <input type="number" name="bidId" required placeholder="ID 입력">
            <input type="submit" value="삭제 실행">
        </div>
    </form>

    <div class="list-area">
        <h3 style="color:#aaa; font-size:1rem; margin-bottom:10px;">최근 입찰 내역 (참고용)</h3>
        <table>
            <tr>
                <th>BidID</th>
                <th>AuctionID</th>
                <th>BidderID</th>
                <th>Amount</th>
                <th>Time</th>
                <th>관리</th>
            </tr>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT BidID, AuctionID, BidderID, BidAmount, BidTime FROM BIDDING_RECORD ORDER BY BidTime DESC FETCH FIRST 10 ROWS ONLY");
                    
                    while(rs.next()) {
                        int bId = rs.getInt("BidID");
            %>
                <tr>
                    <td><%= bId %></td>
                    <td><%= rs.getInt("AuctionID") %></td>
                    <td><%= rs.getString("BidderID") %></td>
                    <td style="color:#28a745;"><%= rs.getLong("BidAmount") %></td>
                    <td style="font-size:0.9rem;"><%= rs.getTimestamp("BidTime") %></td>
                    <td>
                        <form action="admin_q19.jsp" method="post" style="margin:0;">
                            <input type="hidden" name="bidId" value="<%= bId %>">
                            <button type="submit" class="btn-del-small" onclick="return confirm('삭제하시겠습니까?');">삭제</button>
                        </form>
                    </td>
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