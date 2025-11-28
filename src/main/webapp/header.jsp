<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String headerUserId = (String) session.getAttribute("userId");
    String headerUserTier = (String) session.getAttribute("userTier");
    
    if (headerUserId == null) headerUserId = "GUEST";
    if (headerUserTier == null) headerUserTier = "Visitor";
%>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    .global-header {
        background-color: #1e1e1e;
        padding: 10px 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 2px solid #333;
        position: sticky;
        top: 0;
        z-index: 1000;
        font-family: 'Pretendard', sans-serif;
    }

    .gh-logo {
        display: flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        color: #fff;
        transition: opacity 0.2s;
    }
    .gh-logo:hover { opacity: 0.8; }
    .gh-logo-icon { font-size: 1.8rem; }
    .gh-logo-text { font-size: 1.2rem; font-weight: 900; letter-spacing: -0.5px; color: #fff; }

    .gh-user-area {
        display: flex;
        align-items: center;
        gap: 20px;
        color: #e0e0e0;
    }
    .gh-user-info { font-weight: bold; font-size: 1rem; }
    .gh-tier-badge { 
        color: #ffcc00; 
        background: rgba(255, 204, 0, 0.1); 
        padding: 2px 8px; 
        border-radius: 4px; 
        margin-left: 5px; 
        font-size: 0.9rem; 
    }
    
    .gh-logout-btn {
        color: #ff4444; 
        text-decoration: none; 
        font-size: 0.9em; 
        border: 1px solid #444; 
        padding: 5px 12px; 
        border-radius: 20px; 
        transition: all 0.2s;
    }
    .gh-logout-btn:hover { background: #ff4444; color: white; border-color: #ff4444; }
</style>

<div class="global-header">
    <a href="<%= request.getContextPath() %>/index.jsp" class="gh-logo">
        <span class="gh-logo-text">TRADING CENTER</span>
    </a>

    <div class="gh-user-area">
        <% if (!"GUEST".equals(headerUserId)) { %>
            <div class="gh-user-info">
                👤 <%= headerUserId %>
                <span class="gh-tier-badge"><%= headerUserTier %></span>
            </div>
            <a href="<%= request.getContextPath() %>/logoutAction.jsp" class="gh-logout-btn">로그아웃</a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login.html" class="gh-logout-btn" style="color:#007bff; border-color:#007bff;">로그인</a>
        <% } %>
    </div>
</div>