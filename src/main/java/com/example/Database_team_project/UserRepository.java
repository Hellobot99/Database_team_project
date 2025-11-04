package com.example.Database_team_project;

import org.springframework.data.jpa.repository.JpaRepository;

//JpaRepository<[어떤 Entity?], [ID의 타입?]>
public interface UserRepository extends JpaRepository<User, Long> {
 
 // (추가 기능) 
 // "username으로 User를 찾아줘" 라는 메서드
 // 이렇게 이름만 지어주면 JPA가 알아서 SQL을 만들어줍니다.
 User findByUsername(String username);
}