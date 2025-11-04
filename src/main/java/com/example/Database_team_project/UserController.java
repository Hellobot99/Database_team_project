package com.example.Database_team_project;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import lombok.Getter;
import lombok.Setter;

@RestController // "이 클래스는 API 요청을 받는 입구입니다"
public class UserController {

    @Autowired // 스프링에게 "UserService(로직 담당)를 연결해줘"
    private UserService userService;

    /**
     * 회원가입 API
     * (POST /register 요청을 받습니다)
     */
    @PostMapping("/register")
    public User register(@RequestBody UserRegistrationRequest request) {
        
        // 1. 요청받은 정보(request)를 로직 담당자(Service)에게 전달
        return userService.registerUser(request.getUsername(), request.getPassword());
    }
}

@Getter
@Setter
// (참고) API 요청 본문을 받을 별도 클래스
class UserRegistrationRequest {
    private String username;
    private String password;
    
}
