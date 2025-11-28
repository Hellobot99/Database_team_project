<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%
    String invenId = request.getParameter("invenId");
    String itemId = request.getParameter("itemId");
    String itemName = request.getParameter("name");
    
    if(invenId == null || itemId == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>경매 물품 등록</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background: #121212; color: #fff; font-family: 'Pretendard', sans-serif; }
    .reg-container { max-width: 500px; margin: 100px auto; background: #1e1e1e; padding: 40px; border-radius: 12px; border: 1px solid #333; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    h2 { text-align: center; margin-bottom: 30px; color: #ffc107; }
    label { display: block; margin-bottom: 8px; font-weight: bold; color: #aaa; }
    input[type=number], select { width: 100%; padding: 12px; margin-bottom: 20px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; box-sizing: border-box; }
    .item-preview { text-align: center; margin-bottom: 20px; padding: 15px; background: #252525; border-radius: 8px; }
    .btn-submit { width: 100%; padding: 15px; background: #28a745; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 1.1rem; }
    .btn-submit:hover { background: #218838; }
    .btn-cancel { display: block; text-align: center; margin-top: 15px; color: #888; text-decoration: none; }
</style>
</head>
<body>
    <div class="reg-container">
        <h2>⬆️ 경매 물품 등록</h2>
        
        <div class="item-preview">
            <h3 style="margin:0;"><%= itemName %></h3>
            <span style="color:#888; font-size:0.9rem;">Item ID: <%= itemId %></span>
        </div>

        <form action="auction_register_action.jsp" method="post">
            <input type="hidden" name="invenId" value="<%= invenId %>">
            <input type="hidden" name="itemId" value="<%= itemId %>">
            
            <label>시작 가격 (최소 입찰가)</label>
            <input type="number" name="startPrice" placeholder="가격 입력 (Gold)" min="1" required>
            
            <label>경매 기간</label>
            <select name="durationHours">
                <option value="1">1시간</option>
                <option value="6">6시간</option>
                <option value="12">12시간</option>
                <option value="24" selected>24시간 (1일)</option>
                <option value="48">48시간 (2일)</option>
            </select>
            
            <button type="submit" class="btn-submit">등록하기</button>
        </form>
        
        <a href="show_my_registered_item_list_action.jsp" class="btn-cancel">취소</a>
    </div>
</body>
</html>