package com.example.Database_team_project;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service // "이 클래스는 비즈니스 로직을 담당합니다"
public class UserService {

    @Autowired // 스프링에게 "UserRepository(DB 담당)를 연결해줘"
    private UserRepository userRepository;

    // (참고) 비밀번호 암호화 기능은 나중에 추가해야 합니다.
    
    /**
     * 회원가입 로직
     */
    public User registerUser(String username, String password) {
        // 1. 새 User 객체 만들기
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(password); // (주의) 실제로는 암호화 필요!
        newUser.setTierLevel(1);
        newUser.setTierPoint(0);

        // 2. DB 담당자(Repository)에게 "저장해줘" 요청
        return userRepository.save(newUser);
    }
}