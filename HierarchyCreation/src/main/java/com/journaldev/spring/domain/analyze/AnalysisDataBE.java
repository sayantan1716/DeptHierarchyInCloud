package com.journaldev.spring.domain.analyze;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Setter;


@AllArgsConstructor
@NoArgsConstructor
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class AnalysisDataBE {

    private int devOpLel;
    
    private int cloudLvl;
    
    private int fossLvl;
    
}
