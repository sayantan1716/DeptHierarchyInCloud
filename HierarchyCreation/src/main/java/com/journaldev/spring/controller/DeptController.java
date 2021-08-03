package com.journaldev.spring.controller;

import java.util.HashMap;
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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/deptFamily")
public class DeptController {
    

    @Autowired
    private DeptService deptService;
    
    @GetMapping(value = "/analyzeDeptHierarchy", produces = MediaType.APPLICATION_JSON_VALUE)
    @CrossOrigin(origins = "*",
            allowedHeaders = "*",
            exposedHeaders = {"Set-Cookie"},
            maxAge = 3600,
            methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS, RequestMethod.HEAD, RequestMethod.PUT}
    )
    public ResponseEntity<Map<String, List<String>>> getChildDept(@RequestParam("Dept") String Dept) {

        Map<String, List<String>> mapOfDeptFamily = new HashMap<>();

        mapOfDeptFamily = deptService.getDeptFamily(Dept, mapOfDeptFamily);

        return new ResponseEntity<>(mapOfDeptFamily, HttpStatus.OK);
    }
    
    @GetMapping(value = "/analyzeHeadDept", produces = MediaType.APPLICATION_JSON_VALUE)
    @CrossOrigin(origins = "*",
            allowedHeaders = "*",
            exposedHeaders = {"Set-Cookie"},
            maxAge = 3600,
            methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS, RequestMethod.HEAD, RequestMethod.PUT}
    )
    public ResponseEntity< List<String>> getHeadDept() {


        return new ResponseEntity<>(deptService.getHeadDept(), HttpStatus.OK);
    }
}
