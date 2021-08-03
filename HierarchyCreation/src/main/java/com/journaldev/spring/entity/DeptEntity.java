package com.journaldev.spring.entity;

import lombok.*;

import javax.persistence.*;


@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "DEPT_DETAILS")
@Setter
public class DeptEntity {

    @Id
    @Column(name = "DEPARTMENT_ID")  
    private int deptId;


    @Column(name = "DEPT_NAME", nullable = false)
    private String deptName;
    
    @Column(name = "PARENT_DEPT_ID", nullable = false)
    private int parentDeptId;

}
