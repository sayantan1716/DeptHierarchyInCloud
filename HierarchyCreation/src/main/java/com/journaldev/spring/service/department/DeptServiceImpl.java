package com.journaldev.spring.service.dept;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Queue;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.journaldev.spring.entity.DeptEntity;
import com.journaldev.spring.repository.department.DeptRepository;
import com.journaldev.spring.service.analyze.AnalysisServiceImpl;



@Service
public class DeptServiceImpl{

    @Autowired
    private AnalysisServiceImpl analysisService;
    
    @Autowired
    private DeptRepository deptRepository;
    
 
    
    
    public Map<String, List<String>> getDeptFamily(String deptName,
            Map<String, List<String>> mapOfDeptFamily) {
      
        Queue<List<String>> queueOfChildren=new LinkedList<>();
        List<String> listOfChildren=  getListOfChild(deptName);
        queueOfChildren.add(listOfChildren) ;       
        mapOfDeptFamily.put(deptName,  listOfChildren);
       
        while(!queueOfChildren.isEmpty()) {
            
             listOfChildren=queueOfChildren.poll();
             
             for (String eachChild : listOfChildren) {
                 
                 List<String> listOfChildOfChild=  getListOfChildren(eachChild);
                 mapOfDeptFamily.put(eachChild,  listOfChildOfChild);
                
            }
            
        }
        
        
        
        return mapOfDeptFamily;
    }

    public List<String>  getListOfChild(String deptName) {
        List<Object> listOfChildren=null;
        analysisService.setCurrentDept(deptName);
        
        Optional<List<DeptEntity>> listOfImmediateChildDept =
                analysisService.listOfImmediateChildDept();

        if (listOfImmediateChildDept.isPresent()) {
            listOfChildren=listOfImmediateChildDept.get().stream().map(eachDept -> eachDept.getDeptName()).collect(Collectors.toList());
                    
        }  
 return new ArrayList<String>();
    }
    public void  getHeadDept() {
        List<DeptEntity> listOfHeadDepts=deptRepository.findAllByParentDeptId(0).get();
   
    }
    
}
