package com.example.Database_team_project;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "USERS")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;
    
    private int tierLevel;
    private int tierPoint;

    // --- ↑ 여기까지 ↑ ---

    // (필수) 기본 생성자
    public User() {
    }
}