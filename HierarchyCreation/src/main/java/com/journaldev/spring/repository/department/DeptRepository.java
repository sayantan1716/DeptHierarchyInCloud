package com.journaldev.spring.repository.department;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.journaldev.spring.entity.DeptEntity;




@Repository
public interface DeptRepository extends CrudRepository<DeptEntity, Integer>{
    
    @Procedure
    int pushDepartments(String departmentName, int parentDepartmentId);
    
   
    Optional<DeptEntity> findByDeptName(String departmentName);
    
    Optional<List<DeptEntity>> findAllByParentDepartmentId(int parentDepartmentId);
    
    @Query("SELECT max(departmentId) FROM DeptEntity ")
    int findMaxDeptId();
    
}
