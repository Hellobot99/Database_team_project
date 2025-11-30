<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String categoryIdStr = request.getParameter("categoryId");
        String rateStr = request.getParameter("rate");
        
        if(categoryIdStr != null && rateStr != null) {
            int categoryId = Integer.parseInt(categoryIdStr);
            double rate = Double.parseDouble(rateStr);
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                String sql = "UPDATE ITEM SET BasePrice = BasePrice * ? WHERE CategoryID = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setDouble(1, rate);
                pstmt.setInt(2, categoryId);
                
                int count = pstmt.executeUpdate();
                out.println("<script>alert('총 " + count + "개 아이템의 가격이 조정되었습니다.'); location.href='admin_q18.jsp';</script>");
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
<title>Q18: 물가 조정</title>
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

    select, input[type=number] { 
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
        background-color: #28a745;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        font-size: 1.1rem;
        margin-top: 10px;
        transition: background 0.2s;
    }
    input[type=submit]:hover { background-color: #218838; }

    .back-btn {
        display: block;
        text-align: center;
        margin-top: 20px;
        color: #888;
        text-decoration: none;
        transition: color 0.2s;
    }
    .back-btn:hover { color: #fff; text-decoration: underline; }
    
    .rate-info {
        font-size: 0.85rem;
        color: #ffcc00;
        margin-top: 5px;
        display: block;
    }
</style>
</head>
<body>
<div class="container">
    <h2>Q18: 물가 조정 (가격 일괄 변경)</h2>
    
    <form action="admin_q18.jsp" method="post" onsubmit="return confirm('정말로 가격을 변경하시겠습니까?');">
        
        <div class="form-group">
            <label>대상 카테고리</label>
            <select name="categoryId">
                <%
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT CategoryID, Name FROM CATEGORY ORDER BY CategoryID");
                        while(rs.next()) {
                            out.println("<option value='" + rs.getInt("CategoryID") + "'>" + rs.getString("Name") + "</option>");
                        }
                    } catch(Exception e) {}
                    finally { if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close(); }
                %>
            </select>
        </div>
        
        <div class="form-group">
            <label>변동률 (Rate)</label>
            <select name="rate">
                <option value="1.1">10% 인상 (x 1.1)</option>
                <option value="1.2">20% 인상 (x 1.2)</option>
                <option value="1.5">50% 인상 (x 1.5)</option>
                <option value="0.9">10% 인하 (x 0.9)</option>
                <option value="0.8">20% 인하 (x 0.8)</option>
                <option value="0.5">50% 인하 (x 0.5)</option>
            </select>
            <span class="rate-info">* 선택한 카테고리의 모든 아이템 기본 가격(BasePrice)이 변경됩니다.</span>
        </div>
        
        <input type="submit" value="가격 변경 실행">
    </form>
    
    <a href="admin_menu.jsp" class="back-btn">관리자 메뉴로 돌아가기</a>
</div>
</body>
</html>