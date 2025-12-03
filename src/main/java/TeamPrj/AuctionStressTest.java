package TeamPrj;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

public class AuctionStressTest {

    private static final String BASE_URL = "http://localhost:8080/Database_team_project";
    
    private static final String LAST_ID_URL = BASE_URL + "/get_last_auction.jsp";
    private static final String MIN_BID_URL = BASE_URL + "/get_min_bid.jsp";
    
    private static final String LOGIN_ACTION_URL = BASE_URL + "/loginAction.jsp"; 
    private static final String BID_ACTION_URL = BASE_URL + "/auction_bid.jsp";

    private static final String PASSWORD = "1234"; 

    private static final int THREAD_COUNT = 100;
    
    private static AtomicInteger bidCounter;
    
    private static AtomicInteger successCount = new AtomicInteger(0);
    private static AtomicInteger defenseCount = new AtomicInteger(0);
    private static AtomicInteger failCount = new AtomicInteger(0);

    public static void main(String[] args) {
        String targetAuctionId = fetchLatestAuctionId();
        int startBidAmount = fetchMinBid(targetAuctionId);

        System.out.println(">>> 동시성 테스트 시작 [Target: " + targetAuctionId + "번 경매] <<<");
        System.out.println(">>> 설정: 총 " + THREAD_COUNT + "명, 시작가 " + startBidAmount + "원 부터 <<<");
        
        bidCounter = new AtomicInteger(startBidAmount - 1);

        List<String> cookies = new ArrayList<>();
        List<String> loggedInUsers = new ArrayList<>();

        System.out.println("\n[단계 1] 로그인 및 세션 쿠키 수집 중...");

        int loginSuccessCount = 0;
        int loginFailCount = 0;

        for (int i = 1; i <= THREAD_COUNT; i++) {
            String userId = "user" + i;
            String cookie = loginAndGetCookie(userId, PASSWORD);
            if (cookie != null) {
                cookies.add(cookie);
                loggedInUsers.add(userId);
                loginSuccessCount++;
            } else {
                loginFailCount++;
                System.err.println(" - " + userId + " 로그인 실패");
            }
        }

        System.out.println("로그인 단계 완료: 총 " + loginSuccessCount + "명 성공 / " + loginFailCount + "명 실패");
        System.out.println("\n[단계 2] 동시 입찰 공격 시작 (Thread Pool 실행)");
        ExecutorService executor = Executors.newFixedThreadPool(cookies.size());

        for (int i = 0; i < cookies.size(); i++) {
            String cookie = cookies.get(i);
            final String currentUser = loggedInUsers.get(i);

            executor.execute(() -> {
                int individualAmount = bidCounter.incrementAndGet(); 
                sendBidRequest(cookie, targetAuctionId, String.valueOf(individualAmount));
            });
        }

        executor.shutdown();
        while (!executor.isTerminated()) { }

        System.out.println("\n=================================================");
        System.out.println("               테스트 결과 검증 (Validation)        ");
        System.out.println("=================================================");
        
        int expectedFinalPrice = bidCounter.get();

        int actualFinalPrice = fetchMinBid(targetAuctionId) - 1;

        System.out.println(" [Expected] 프로그램이 시도한 최고가 : " + expectedFinalPrice + " G");
        System.out.println(" [Actual]   DB에 저장된 최종 낙찰가  : " + actualFinalPrice + " G");
        System.out.println(" -----------------------------------------------");

        if (expectedFinalPrice == actualFinalPrice) {
            System.out.println(" ✅ [검증 성공] 데이터가 완벽하게 일치합니다!");
            System.out.println("    (모든 낮은 금액의 덮어쓰기 시도가 DB Lock에 의해 정상 방어되었습니다)");
        } else {
            System.out.println(" ❌ [검증 실패] 데이터 불일치 발생!");
            System.out.println("    (Race Condition으로 인해 더 낮은 가격이 최종 반영되었을 수 있습니다)");
        }
        System.out.println("=================================================");
        
        System.out.println(" 상세 통계:");
        System.out.println("  - 입찰 성공 (갱신) : " + successCount.get());
        System.out.println("  - 방어 성공 (방어) : " + defenseCount.get());
        System.out.println("  - 기타 실패 (오류) : " + failCount.get());
    }


    private static String loginAndGetCookie(String id, String pwd) {
        try {
            URL url = URI.create(LOGIN_ACTION_URL).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setInstanceFollowRedirects(false);
            conn.setDoOutput(true);
            String params = "userID=" + id + "&password=" + pwd;
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = params.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            List<String> cookies = conn.getHeaderFields().get("Set-Cookie");
            if (cookies != null) {
                for (String cookie : cookies) {
                    if (cookie.startsWith("JSESSIONID")) return cookie.split(";")[0];
                }
            }
        } catch (Exception e) {}
        return null;
    }

    private static void sendBidRequest(String cookie, String auctionId, String amount) {
        try {
            URL url = URI.create(BID_ACTION_URL).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Cookie", cookie);
            String params = "auctionId=" + auctionId + "&amount=" + amount;
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = params.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            int responseCode = conn.getResponseCode();
            
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
            String inputLine;
            StringBuilder content = new StringBuilder();
            while ((inputLine = in.readLine()) != null) content.append(inputLine);
            in.close();
            
            String responseBody = content.toString();
            String resultMsg = parseResult(responseBody);
            
            if (resultMsg.contains("입찰 성공")) successCount.incrementAndGet();
            else if (resultMsg.contains("방어 성공")) defenseCount.incrementAndGet();
            else failCount.incrementAndGet();
          
            
        } catch (Exception e) {
            failCount.incrementAndGet();
        }
    }

    private static String parseResult(String responseBody) {
        if (responseBody.contains("입찰 성공")) return "[입찰 성공]";
        if (responseBody.contains("최소") && responseBody.contains("이상이어야")) return "[방어 성공] (금액 낮음)";
        if (responseBody.contains("잔액이 부족")) return "[실패] 잔액 부족";
        if (responseBody.contains("마감")) return "[실패] 경매 마감";
        return "[오류] " + responseBody.trim().substring(0, Math.min(responseBody.length(), 20));
    }
    
    private static String fetchLatestAuctionId() {
        try {
            URL url = URI.create(LAST_ID_URL).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder content = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) content.append(inputLine);
            in.close();
            String res = content.toString().trim();
            return res.isEmpty() ? "1" : res;
        } catch (Exception e) { return "1"; }
    }

    private static int fetchMinBid(String auctionId) {
        try {
            String requestUrl = MIN_BID_URL + "?auctionId=" + auctionId;
            URL url = URI.create(requestUrl).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder content = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) content.append(inputLine);
            in.close();
            String res = content.toString().trim();
            return res.isEmpty() ? 1 : Integer.parseInt(res);
        } catch (Exception e) { return 1; }
    }
}