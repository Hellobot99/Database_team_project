# 경매장 거래 시스템

## 한줄 소개

**"데이터베이스 설계 및 구축을 목표로 개발된, 사용자 간 실시간 물품 거래 및 경매 플랫폼입니다."**


## 목차

1.  [소개](#소개)
2.  [배경 및 목적](#배경-및-목적)
3.  [주요 기능](#주요-기능)
4.  [설치 및 실행](#설치-및-실행)
5.  [아키텍처 및 코드 설명](#아키텍처-및-코드-설명)
6.  [저자](#저자)

## [소개]

이 프로젝트는 데이타베이스 Team 7이 개발한 **온라인 경매 시스템**입니다. Java(JSP)와 Oracle Database를 기반으로 구축되었으며, 사용자는 보유한 아이템을 경매에 부치거나 다른 사용자의 물품에 입찰하여 거래할 수 있습니다. 관리자는 전체 시스템의 회원, 물품, 경매 현황을 모니터링하고 관리할 수 있는 기능을 제공합니다.

<img width="1631" height="701" alt="image" src="https://github.com/user-attachments/assets/268ad8cd-761c-423d-879d-4970b46bee0b" />

## [배경 및 목적]

  * **데이터베이스 설계 실습**: 복잡한 데이터 관계(1:N, M:N)를 포함하는 경매 시스템을 직접 설계하며 ERD 구축 능력을 함양합니다.
  * **웹 애플리케이션 연동**: JSP와 JDBC를 활용하여 데이터베이스와 웹 클라이언트 간의 연동 과정을 학습합니다.
  * **거래 로직 구현**: 경매 등록, 입찰, 낙찰, 수수료 정산 등 비즈니스 로직을 트랜잭션 단위로 처리하여 데이터 무결성을 보장하는 시스템을 구현합니다.

## [주요 기능]

### 일반 사용자

  * **계정 관리**: 회원가입, 로그인/로그아웃, 정보 수정, 회원 탈퇴
  <img width="1629" height="752" alt="image" src="https://github.com/user-attachments/assets/3927df3e-590b-44d2-b3ae-497856f0b118" />

  * **인벤토리**: 내 보유 아이템 조회 및 관리
  <img width="1621" height="750" alt="image" src="https://github.com/user-attachments/assets/aa93815a-6f78-4740-adc6-b32ba0619852" />

  * **경매 참여**:
      * **물품 등록**: 인벤토리 내 아이템을 경매에 등록 (시작가, 종료 시간 설정)
      * **입찰(Bidding)**: 진행 중인 경매에 입찰 (현재 최고가 갱신)
      * **관심 등록**: 관심 있는 경매 즐겨찾기(Favorite) 추가/삭제
  <img width="1616" height="754" alt="image" src="https://github.com/user-attachments/assets/e6259734-7c8f-482e-960c-873d1dd95b15" />

  * **마이 페이지**: 입찰 내역, 등록한 경매 내역, 낙찰 결과 확인

<img width="1618" height="751" alt="image" src="https://github.com/user-attachments/assets/991a294d-be98-4417-bdc9-ad31bd9e4314" />


### 관리자

  * **대시보드**: 시스템 전반의 통계 데이터 확인
  <img width="1618" height="752" alt="image" src="https://github.com/user-attachments/assets/4cb7f693-cecb-437e-ab5e-f8b27ae66cf3" />

  * **회원 관리**: 전체 회원 목록 조회, 특정 회원 강제 탈퇴 및 정보 수정

  <img width="1615" height="752" alt="image" src="https://github.com/user-attachments/assets/25c9cef7-be1b-4c50-83fb-9441916d827d" />

  * **인벤토리 관리**: 모든 사용자의 인벤토리 조회 및 아이템 상태 관리

  <img width="1616" height="752" alt="image" src="https://github.com/user-attachments/assets/1884f7e5-f315-4f17-ac59-db8f07040bd6" />

  * **고급 분석 (Advanced Queries)**:
      * 잔액 기준 VIP/Blacklist 사용자 필터링
      * 날짜별/카테고리별 경매 통계 조회
      * 특정 경매의 상세 입찰 로그 및 트래킹
   <img width="1616" height="750" alt="image" src="https://github.com/user-attachments/assets/ecb01746-1986-4837-af5b-d888d7b3219e" />


## [설치 및 실행]

### 필수 요구 사항 (Prerequisites)

  * **OS**: Windows 10/11
  * **Java**: JDK 1.8 이상
  * **Database**: Oracle Database 11g XE 이상
  * **Server**: Apache Tomcat 9.0
  * **IDE**: Eclipse IDE for Enterprise Java and Web Developers

### 설치 단계 (Installation Steps)

1.  **Repository Clone**

    ```bash
    git clone [레포지토리 주소]
    ```

2.  **Database Configuration**

      * Oracle DB에 접속하여 제공된 SQL 파일을 순서대로 실행합니다.

    <!-- end list -->

    1.  `create_table_ver1.3.sql` (테이블, 시퀀스, 제약조건 생성)
    2.  `insert_table_ver1.3.sql` (기초 데이터 및 더미 데이터 삽입)

3.  **Project Import & Setup**

      * Eclipse 실행 \> `File` \> `Import` \> `Web` \> `WAR file` 또는 `Existing Projects` 선택.
      * `src/main/java/TeamPrj/DBConnection.java` 파일을 열어 DB 정보를 수정합니다.

    <!-- end list -->

    ```java
    // DBConnection.java
    String url = "jdbc:oracle:thin:@localhost:1521:xe"; // 본인의 DB SID 확인
    String uid = "system"; // 본인의 DB ID
    String upw = "1234";   // 본인의 DB Password
    ```

4.  **Run Server**

      * 프로젝트 우클릭 \> `Run As` \> `Run on Server`.
      * 웹 브라우저에서 `http://localhost:8080/[프로젝트명]/index.jsp` 접속.

## [아키텍처 및 코드 설명]

### 기술 스택 (Tech Stack)

| 분류 | 기술 |
| :-- | :-- |
| **Frontend** | HTML5, CSS3, JavaScript |
| **Backend** | Java (JSP, Servlet) |
| **Database** | Oracle Database (JDBC) |
| **WAS** | Apache Tomcat 9.x |

### 디렉토리 구조 (File Structure)

```
📦 Project-Root
├── 📂 src/main/java/TeamPrj
│   └── 📄 DBConnection.java   # Oracle DB 연결을 담당하는 자바 클래스
├── 📂 src/main/webapp
│   ├── 📂 admin               # 관리자용 페이지 (통계, 회원관리 등)
│   ├── 📂 images              # 아이템 및 UI 리소스 이미지
│   ├── 📂 WEB-INF/lib         # ojdbc10.jar 등 라이브러리 폴더
│   ├── 📄 index.jsp           # 메인 홈페이지
│   ├── 📄 login.jsp           # 로그인 페이지 및 로직
│   ├── 📄 auction_list.jsp    # 진행 중인 경매 목록 조회
│   ├── 📄 auction_bid.jsp     # 경매 입찰 처리 로직
│   └── ...                    # 기타 기능별 JSP 파일
└── 📄 create_table_1.3.sql # DB 스키마 생성 스크립트
```

### 데이터베이스 설계 (ERD)

*본 프로젝트는 **USERS, ITEM, INVENTORY, AUCTION, BIDDING\_RECORD** 등의 테이블이 유기적으로 연결되어 있습니다.*

<img width="1851" height="1073" alt="diagram" src="https://github.com/user-attachments/assets/0a5eb67f-ea92-44e3-a23b-8757386767fa" />


## [저자]

**DataBase Team 7**

- **김성용**  
  - 소속: 경북대학교 컴퓨터학부 (글솦)
  - 역할: 인벤토리 기능 / 경매 등록 & 취소 / 경매장 목록(조회/필터) / 종료 경매 기록(조회/필터) / Transaction(낙관적 검증)
 
- **김태준**  
  - 소속: 경북대학교 컴퓨터학부 (글솦) 
  - 역할: 초기 백엔드 세팅, UI/UX 개발, 유저 프로필 기능 개발, 관리자 기능 개발, 동시성 테스트 기능 개발, 튜토리얼 기능 제작, 경매 기능 업그레이드

- **하성민**  
  - 소속: 경북대학교 컴퓨터학부 (심컴)
  - 역할: 즐겨찾기/인벤토리 기능/ 카테고리/ 유저정보/시퀀스 작업/ 관리자 기능 개선/ 튜토리얼 기능 개선/ 기타 코드 성능 최적화
