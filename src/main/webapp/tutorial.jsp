<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>튜토리얼 - 가이드</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background: #121212; color: #fff; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    
    .main-wrapper { padding: 40px; display: flex; justify-content: center; }
    .container { max-width: 900px; width: 100%; }
    
    h1 { text-align: center; margin-bottom: 40px; color: #ffcc00; text-shadow: 0 0 10px #ff9900; }
    
    .guide-box {
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 12px;
        padding: 30px;
        margin-bottom: 30px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }
    
    .guide-title {
        font-size: 1.5rem; font-weight: bold; color: #fff; 
        border-bottom: 2px solid #444; padding-bottom: 10px; margin-bottom: 20px;
        display: flex; align-items: center; gap: 10px;
    }
    
    .guide-content { font-size: 1.1rem; line-height: 1.8; color: #ccc; margin-bottom: 20px; }
    
    .step { margin-bottom: 15px; }
    
    .check-area {
        text-align: right;
        border-top: 1px solid #333;
        padding-top: 15px;
    }

    .check-label {
        cursor: pointer;
        font-weight: bold;
        color: #888;
        transition: color 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }
    
    input[type="checkbox"] {
        width: 18px; height: 18px; cursor: pointer; accent-color: #28a745;
    }

    input[type="checkbox"]:checked + span {
        color: #28a745;
    }

    .submit-btn {
        display: block; width: 300px; margin: 50px auto; text-align: center;
        padding: 15px; background: #444; color: #aaa; text-decoration: none; border-radius: 50px;
        font-weight: bold; font-size: 1.1rem; border: none; cursor: not-allowed; transition: all 0.3s;
    }
    
    .submit-btn.active {
        background: #28a745; color: white; cursor: pointer; box-shadow: 0 0 15px rgba(40, 167, 69, 0.5);
    }
    .submit-btn.active:hover { background: #218838; }
</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <div class="container">
        <h1>📘 초보자를 위한 거래소 가이드</h1>
        
        <form action="tutorial_complete_action.jsp" method="post">
            
            <div class="guide-box">
                <div class="guide-title">🔍 아이템 구매하기 (입찰)</div>
                <div class="guide-content">
                    <div class="step">1. 메인 화면에서 <strong>[검색]</strong> 메뉴를 눌러 경매장에 입장합니다.</div>
                    <div class="step">2. 원하는 아이템을 찾은 후, 현재 가격보다 높은 금액을 입력하고 <strong>[⚡ 입찰하기]</strong> 버튼을 누릅니다.</div>
                    <div class="step">3. <strong>[내 경매 활동]</strong> 메뉴에서 실시간 입찰 현황을 확인할 수 있습니다.</div>
                    <div class="step">4. 경매 시간이 종료될 때까지 최고 입찰가를 유지하면 낙찰됩니다!</div>
                </div>
                <div class="check-area">
                    <label class="check-label">
                        <input type="checkbox" class="guide-check" onchange="checkAll()">
                        <span>확인했습니다</span>
                    </label>
                </div>
            </div>

            <div class="guide-box">
                <div class="guide-title">💰 아이템 판매하기 (등록)</div>
                <div class="guide-content">
                    <div class="step">1. 메인 화면에서 <strong>[판매 관리]</strong> 메뉴로 이동합니다.</div>
                    <div class="step">2. 왼쪽 <strong>[내 인벤토리]</strong> 목록에서 판매할 아이템의 <strong>[⬆️ 등록]</strong> 버튼을 누릅니다.</div>
                    <div class="step">3. 시작 가격과 경매 진행 시간(1~48시간)을 설정하고 등록합니다.</div>
                    <div class="step">4. 등록된 물품은 오른쪽 <strong>[판매 중인 아이템]</strong> 목록에서 확인하거나 취소할 수 있습니다.</div>
                </div>
                <div class="check-area">
                    <label class="check-label">
                        <input type="checkbox" class="guide-check" onchange="checkAll()">
                        <span>확인했습니다</span>
                    </label>
                </div>
            </div>

            <div class="guide-box">
                <div class="guide-title">📈 시세 확인하기</div>
                <div class="guide-content">
                    <div class="step">1. <strong>[시세]</strong> 메뉴에서는 이미 거래가 완료된 아이템들의 낙찰 가격을 볼 수 있습니다.</div>
                    <div class="step">2. 구매하거나 판매하기 전에 시세를 검색하여 적절한 가격을 파악하세요.</div>
                    <div class="step">3. 최근 거래일시와 낙찰가를 분석하면 더 큰 수익을 낼 수 있습니다!</div>
                </div>
                <div class="check-area">
                    <label class="check-label">
                        <input type="checkbox" class="guide-check" onchange="checkAll()">
                        <span>확인했습니다</span>
                    </label>
                </div>
            </div>

            <button type="submit" id="finishBtn" class="submit-btn" disabled>모든 가이드를 확인해주세요</button>
        </form>
    </div>
</div>

<script>
    function checkAll() {
        const checkboxes = document.querySelectorAll('.guide-check');
        const finishBtn = document.getElementById('finishBtn');
        let allChecked = true;

        checkboxes.forEach(chk => {
            if (!chk.checked) allChecked = false;
        });

        if (allChecked) {
            finishBtn.disabled = false;
            finishBtn.classList.add('active');
            finishBtn.innerText = "가이드 확인 완료 (10,000 G 받기)";
        } else {
            finishBtn.disabled = true;
            finishBtn.classList.remove('active');
            finishBtn.innerText = "모든 가이드를 확인해주세요";
        }
    }
    
    checkAll();
</script>

</body>
</html>