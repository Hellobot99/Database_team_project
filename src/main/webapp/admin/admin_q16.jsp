<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String itemIdStr = request.getParameter("itemId");
        String newDesc = request.getParameter("newDesc");
        
        if(itemIdStr != null && newDesc != null) {
            int itemId = Integer.parseInt(itemIdStr);
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                String sql = "UPDATE ITEM SET Description = ? WHERE ItemID = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, newDesc);
                pstmt.setInt(2, itemId);
                
                int count = pstmt.executeUpdate();
                if(count > 0) {
                    out.println("<script>alert('아이템 설명이 수정되었습니다.'); location.href='admin_q16.jsp';</script>");
                } else {
                    out.println("<script>alert('해당 아이템을 찾을 수 없습니다.'); history.back();</script>");
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
<title>Q16: 물품 설명 수정</title>
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
        max-width: 700px; 
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

    .form-group { margin-bottom: 20px; }
    
    label { 
        display: block; 
        margin-bottom: 8px; 
        font-weight: bold; 
        color: #bbb;
    }

    input[type=number], textarea { 
        width: 100%; 
        padding: 12px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #2a2a2a; 
        color: #fff;
        font-size: 1rem;
        box-sizing: border-box;
        font-family: 'Pretendard', sans-serif;
    }
    
    textarea { height: 150px; resize: vertical; }

    input[type=submit] {
        width: 100%;
        padding: 14px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        font-size: 1.1rem;
        margin-top: 10px;
        transition: background 0.2s;
    }
    input[type=submit]:hover { background-color: #0056b3; }

    .back-btn {
        display: block;
        text-align: center;
        margin-top: 20px;
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
    th { text-align: left; color: #888; padding: 5px; border-bottom: 1px solid #333; }
    td { padding: 8px 5px; border-bottom: 1px solid #333; }
</style>
</head>
<body>
<div class="container">
    <h2>Q16: 물품 설명(Description) 수정</h2>
    
    <form action="admin_q16.jsp" method="post">
        <div class="form-group">
            <label>대상 아이템 ID (ItemID)</label>
            <input type="number" name="itemId" required placeholder="아이템 번호 입력">
        </div>
        
        <div class="form-group">
            <label>새로운 설명 (Description)</label>
            <textarea name="newDesc" required placeholder="변경할 설명을 입력하세요..."></textarea>
        </div>
        
        <input type="submit" value="설명 수정 실행">
    </form>

    <div class="list-area">
        <h3 style="color:#aaa; font-size:1rem; margin-bottom:10px;">최근 등록된 아이템 (참고용)</h3>
        <table>
            <tr><th>ID</th><th>Name</th><th>Description</th></tr>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT ItemID, Name, Description FROM ITEM ORDER BY ItemID DESC FETCH FIRST 5 ROWS ONLY");
                    
                    while(rs.next()) {
                        String desc = rs.getString("Description");
                        if(desc != null && desc.length() > 20) desc = desc.substring(0, 20) + "...";
            %>
                <tr>
                    <td><%= rs.getInt("ItemID") %></td>
                    <td style="font-weight:bold; color:#fff;"><%= rs.getString("Name") %></td>
                    <td style="color:#aaa;"><%= desc %></td>
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