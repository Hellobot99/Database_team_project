<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>인벤토리 관리</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { 
        font-family: 'Pretendard', sans-serif; 
        background: #fcfcfc;
        padding: 40px; 
        display: flex; 
        justify-content: center; 
        align-items: center; 
        min-height: 100vh;
        margin: 0;
    }

    .manage-card { 
        background: #fff; 
        width: 100%; 
        max-width: 500px; 
        padding: 40px; 
        border-radius: 16px; 
        border: 1px solid #e1e1e1; 
        border-top: 5px solid #ffc107;
        box-shadow: 0 10px 30px rgba(0,0,0,0.08); 
    }

    h2 { margin: 0 0 30px 0; text-align: center; color: #111; font-weight: 800; }
    
    label { display: block; margin-bottom: 8px; font-weight: 700; color: #555; font-size: 0.95rem; }

    input[type=text], input[type=number], select { 
        width: 100%; 
        padding: 12px 15px;
        margin-bottom: 20px; 
        border: 1px solid #ddd; 
        border-radius: 8px; 
        font-size: 1rem;
        box-sizing: border-box; 
        background-color: #f9f9f9;
        transition: all 0.2s;
        color: #333;
        font-family: 'Pretendard', sans-serif;
    }

    input:focus, select:focus {
        outline: none;
        border-color: #ffc107;
        background-color: #fff;
        box-shadow: 0 0 0 3px rgba(255, 193, 7, 0.1);
    }

    select {
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
        cursor: pointer;
        background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23333' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
        background-repeat: no-repeat;
        background-position: right 15px center;
        background-size: 16px;
    }

    .submit-btn { 
        width: 100%; 
        padding: 15px; 
        background: #333; 
        color: white; 
        border: none; 
        border-radius: 8px; 
        font-weight: bold; 
        cursor: pointer; 
        font-size: 1.1rem;
        margin-top: 10px;
        transition: background 0.2s;
    }
    .submit-btn:hover { background: #555; }

    .radio-group { display: flex; justify-content: center; gap: 20px; margin-bottom: 25px; background: #f1f3f5; padding: 10px; border-radius: 10px; }
    .radio-option { font-weight: bold; display: flex; align-items: center; cursor: pointer; }
    .radio-option input { margin-right: 8px; transform: scale(1.2); cursor: pointer; }
    .give-opt { color: #28a745; } 
    .take-opt { color: #dc3545; }

    .back-link {
        display: block; 
        text-align: center; 
        margin-top: 25px; 
        color: #888; 
        text-decoration: none; 
        font-size: 0.9rem;
    }
    .back-link:hover { color: #333; text-decoration: underline; }
</style>
</head>
<body>

<div class="manage-card">
    <h2>📦 인벤토리 관리</h2>
    
    <form action="admin_inventory_action.jsp" method="post">
        
        <label style="text-align:center;">작업 유형</label>
        <div class="radio-group">
            <label class="radio-option give-opt">
                <input type="radio" name="actionType" value="GIVE" checked> 지급 (Give)
            </label>
            <label class="radio-option take-opt">
                <input type="radio" name="actionType" value="TAKE"> 회수 (Take)
            </label>
        </div>

        <label>대상 유저 ID (UserID)</label>
        <input type="text" name="userId" placeholder="예: ryxur6097" required>

        <label>아이템 ID (ItemID)</label>
        <input type="number" name="itemId" placeholder="예: 32" required>

        <label>수량 (Quantity)</label>
        <input type="number" name="quantity" value="1" min="1" required>

        <label>아이템 상태 (Conditions)</label>
        <select name="conditions">
            <option value="New">New</option>
            <option value="Used">Used</option>
            <option value="Damaged">Damaged</option>
            <option value="Rare">Rare</option>
        </select>

        <button type="submit" class="submit-btn">실행하기</button>
    </form>
    
    <a href="admin_menu.jsp" class="back-link">↩ 관리자 메뉴로 돌아가기</a>
</div>

</body>
</html>