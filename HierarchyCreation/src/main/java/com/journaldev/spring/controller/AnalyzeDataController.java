package com.journaldev.spring.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/dept")
public class AnalyzeDataController {

    @Autowired
    private AnalyzerService analyzeService;
    
     @GetMapping(value = "/analyzeMaturity", produces = MediaType.APPLICATION_JSON_VALUE)
    @CrossOrigin(origins = "*",
            allowedHeaders = "*",
            exposedHeaders = {"Set-Cookie"},
            maxAge = 3600,
            methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS, RequestMethod.HEAD, RequestMethod.PUT}
    )
    public ResponseEntity<Map<String,AnalyzedDataBE>> getMaturity(@RequestParam("dept") String dept) {
         
         Map<String,AnalyzedDataBE> maturityMapOfdept=new LinkedHashMap<>();
         AnalyzedDataBE analyzedResult=null;
         
         analyzeService.setCurrentdept(dept);
          analyzedResult= analyzeService.analyzedept(analyzeService.getCurrentdept().getdeptName());
         maturityMapOfdept.put(dept, analyzedResult);
         
         Optional<List<DeptEntity>> listImmediateChilddept=analyzeService.listImmediateChilddept();
         
         if(listImmediateChilddept.isPresent()) {
             for (DeptEntity childdept : listImmediateChilddept.get()) {
                 String childdeptName=childdept.getdeptName();
                  analyzedResult= analyzeService.analyzedept(childdeptName);
                  
                 
                  if(childdeptName.length()>=4)
                      childdeptName=childdeptName.substring(0, 3)+"/"+childdeptName.substring(3, childdeptName.length());
                  
                  maturityMapOfdept.put(childdeptName, analyzedResult);
            }
         
            
         }
         return new ResponseEntity<>(maturityMapOfdept,HttpStatus.OK);
    }
     
     
     @GetMapping(value = "/getChildMaturity", produces = MediaType.APPLICATION_JSON_VALUE)
    @CrossOrigin(origins = "*",
            allowedHeaders = "*",
            exposedHeaders = {"Set-Cookie"},
            maxAge = 3600,
            methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS, RequestMethod.HEAD, RequestMethod.PUT}
    )
    public ResponseEntity<List<String>> getChilddept(@RequestParam("dept") String dept) {

         List<String> listOfChildren=null;
        analyzeService.setCurrentdept(dept);
        
        Optional<List<DeptEntity>> listImmediateChilddept =
                analyzeService.listImmediateChilddept();

        if (listImmediateChilddept.isPresent()) {
            listOfChildren=listImmediateChilddept.get().stream().map(eachDept -> eachDept.getdeptName()).collect(Collectors.toList());
                    
        } 
        
        return  new ResponseEntity<>(listOfChildren,HttpStatus.OK);
    }
}
