<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String targetId = request.getParameter("targetId");
        String newTier = request.getParameter("newTier");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String updateSql = "UPDATE USERS SET Tier = ? WHERE UserID = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, newTier);
            pstmt.setString(2, targetId);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                out.println("<script>alert('등급이 변경되었습니다.'); location.href='admin_q17.jsp';</script>");
            } else {
                out.println("<script>alert('해당 유저를 찾을 수 없습니다.'); history.back();</script>");
            }
        } catch (Exception e) {
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q17: 회원 등급 변경</title>
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
        max-width: 600px; 
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

    .form-group { margin-bottom: 20px; }
    
    label { 
        display: block; 
        margin-bottom: 8px; 
        font-weight: bold; 
        color: #bbb;
    }

    input[type=text], select { 
        width: 100%; 
        padding: 12px; 
        border-radius: 6px; 
        border: 1px solid #555; 
        background-color: #2a2a2a; 
        color: #fff;
        font-size: 1rem;
        box-sizing: border-box;
    }

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
    
    .current-list {
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
    <h2>Q17: 회원 등급(Tier) 변경</h2>
    
    <form action="admin_q17.jsp" method="post">
        <div class="form-group">
            <label>대상 사용자 ID</label>
            <input type="text" name="targetId" required placeholder="유저 아이디 입력">
        </div>
        
        <div class="form-group">
            <label>변경할 등급</label>
            <select name="newTier">
                <option value="ROOKIE">ROOKIE (신규)</option>
                <option value="Bronze">Bronze</option>
                <option value="Silver">Silver</option>
                <option value="Gold">Gold</option>
                <option value="Diamond">Diamond</option>
                <option value="VIP">VIP</option>
                <option value="ADMIN">ADMIN (관리자)</option>
                <option value="BANNED">BANNED (정지)</option>
            </select>
        </div>
        
        <input type="submit" value="등급 변경 실행">
    </form>

    <div class="current-list">
        <h3 style="color:#aaa; font-size:1rem; margin-bottom:10px;">최근 가입 유저 목록 (참고용)</h3>
        <table>
            <tr><th>UserID</th><th>Name</th><th>Tier</th></tr>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT UserID, Name, Tier FROM USERS ORDER BY UserID DESC FETCH FIRST 5 ROWS ONLY");
                    
                    while(rs.next()) {
            %>
                <tr>
                    <td><%= rs.getString("UserID") %></td>
                    <td><%= rs.getString("Name") %></td>
                    <td style="color:#ffcc00;"><%= rs.getString("Tier") %></td>
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