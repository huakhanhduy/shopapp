package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "roles")
public class Role extends BaseEntity {

    public Role() {
    }

    public Role(String roleName, String privileges) {
        this.roleName = roleName;
        this.privileges = privileges;
    }


    @Column(nullable = false, unique = true)
    private String roleName;

    @Column(columnDefinition = "TEXT")
    private String privileges;

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getPrivileges() {
        return privileges;
    }

    public void setPrivileges(String privileges) {
        this.privileges = privileges;
    }
}