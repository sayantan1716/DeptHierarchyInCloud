package com.journaldev.spring.service.analyze;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Optional;
import java.util.Queue;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.journaldev.spring.domain.analyze.AnalysisDataBE;
import com.journaldev.spring.entity.DeptEntity;
import com.journaldev.spring.entity.Workgroup;
import com.journaldev.spring.repository.department.DeptRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AnalysisServiceImpl {

    @Autowired
    private DeptRepository deptRepository;
    @Autowired
    Workgroup workgroup;
  
    public DeptEntity currentDept;
    
    
    public DeptEntity getCurrentDept() {
        return this.currentDept;
    }
    
    public AnalysisDataBE analyzeDept(String deptName) {
       
       
        
        Queue<DeptEntity> deptQueue=new LinkedList<>();
       List<DeptEntity> listOfCocContainingDepts=new ArrayList<>();
       
      
        deptQueue.add( deptRepository.findByDeptName(deptName).get());
        
        while(!deptQueue.isEmpty()) {
            DeptEntity currentAnalyzingDept=deptQueue.poll();
                       
            Optional<List<DeptEntity>> listOfchildDept=deptRepository.findAllByParentDeptId(currentAnalyzingDept.getDeptId());
            
            if(listOfchildDept.isPresent()) {
                deptQueue.addAll(listOfchildDept.get());
               
            }else {
                listOfCocContainingDepts.add(currentAnalyzingDept);
            }
        }
        
        
        
        AnalysisDataBE analyzedDataBE= calculateAverage(listOfCocContainingDepts);
        return analyzedDataBE;
    }
    public AnalysisDataBE calculateAverage( List<DeptEntity> listOfCocContainingDepts) {
        
        List<Integer> listOfDevOpsStats=new ArrayList<Integer>();
        List<Integer> listOfFossStats=new ArrayList<Integer>();
        List<Integer> listOfCloudStats=new ArrayList<Integer>();
        
        
        for (DeptEntity deptEntity : listOfCocContainingDepts) {

            int requestedDeptId = deptEntity.getDeptId();
            List<workgroup> listOfCoc = workgroup.findAllByDeptId(requestedDeptId);

            for (Workgroup cocEntity : listOfCoc) {
               loadCocMaturity(cocEntity,listOfDevOpsStats,listOfFossStats,listOfCloudStats);
            }
        }
       
        AnalysisDataBE analyzedDataBE= calculateAverageMaturity(listOfDevOpsStats,listOfFossStats,listOfCloudStats);
        
        return analyzedDataBE;
    }
public void loadCocMaturity(Workgroup cocEntity,List<Integer> listOfDevOpsStats,List<Integer> listOfFossStats,List<Integer> listOfCloudStats) {
   
}
public AnalysisDataBE calculateAverageMaturity(List<Integer> listOfDevOpsStats,List<Integer> listOfFossStats,List<Integer> listOfCloudStats) {
    int totalDevOps = 0;
    int totalFoss = 0;
    int totalCloud = 0;
    for (Integer dPercentage : listOfDevOpsStats) {
        totalDevOps+=dPercentage;
    }
    for (Integer fPercentage : listOfFossStats) {
        totalFoss+=fPercentage;
    }
    for (Integer cPercentage : listOfCloudStats) {
        totalCloud+=cPercentage;
    }
    AnalysisDataBE analyzedDataBE=new AnalysisDataBE(Math.round(totalDevOps / listOfDevOpsStats.size()), Math.round(totalCloud  / listOfCloudStats.size()), Math.round(totalFoss  / listOfFossStats.size()));
    
    return analyzedDataBE;
}
public Optional<List<DeptEntity>> listOfImmediateChildDept(){
  
   return deptRepository.findAllByParentDeptId(this.currentDept.getDeptId());
}

public List<Workgroup> findChildCocs() {
    
    List<Workgroup> listOfWG=workgroup.findAllByDeptId(this.currentDept.getDeptId());
    return listOfWG;
}
public void setCurrentDept(String deptName) {
    deptName=deptName.replaceFirst("/", "");
    this.currentDept= deptRepository.findByDeptName(deptName).get();
  
}

 
}
