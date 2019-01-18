({
    helperMethod : function() {
        
    },
    
    getCadenceData: function(component,helper){
        component.set("v.SpinnerForSync",true);
        var cadenceId = component.get("v.recordId");
        if(cadenceId){
            var cadence = component.get("c.getCadenceData");
            cadence.setParams({cadenceId: cadenceId});
            cadence.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var wrapperResult = response.getReturnValue();
                    // Set contact list
                    var conList = wrapperResult.conCriList;
                    var sortedConList = conList.sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                    component.set("v.contactFieldList", sortedConList); 
                    //Set lead List
                    var ldList = wrapperResult.ldCriList;
                    var sortedLdList = ldList.sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                    component.set("v.leadFieldList", sortedLdList);
                    // Set cadence data
                    var result = wrapperResult.cObj;
                    component.set("v.cadence", result);
                    
                    if(result.RDNACadence__CadenceActions__r){
                        component.set("v.cadenceActionList", result.RDNACadence__CadenceActions__r);
                    }
                    
                    
                    //apply error message here.	
                    var entryCriterion = JSON.parse(result.RDNACadence__Entrance_Criteria__c);
                    var exitCriterion = JSON.parse(result.RDNACadence__Exit_Criteria__c);
                    
                    component.set("v.entranceCriteriaSet",entryCriterion);
                    component.set("v.exitCriteriaSet",exitCriterion);
                    component.set("v.SpinnerForSync",false);
                }else{
                    component.set("v.SpinnerForSync",false);
                }
            });
            $A.enqueueAction(cadence);
        }else{
            var cadence = { 'sobjectType': 'RDNACadence__Cadence__c', 'Name': '','RDNACadence__Record_Type__c':'', 'RDNACadence__Participent_Activation__c':''};
            component.set("v.cadence", cadence);
            var cadence = component.get("c.getObjCriList");
            cadence.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var wrapperResult = response.getReturnValue();
                    // Set contact list
                    var conList = wrapperResult.conCriList;
                    var sortedConList = conList.sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                    component.set("v.contactFieldList", sortedConList); 
                    //Set lead List
                    var ldList = wrapperResult.ldCriList;
                    var sortedLdList = ldList.sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                    component.set("v.leadFieldList", sortedLdList);
                    component.set("v.SpinnerForSync",false);
                }else{
                    component.set("v.SpinnerForSync",false);
                }
            });
            $A.enqueueAction(cadence);
        }
    },
    setPhoneRow : function(component, event, helper){
        helper.setCompanyRow(component, event, helper);
        var phRow = document.getElementsByClassName('ringdna-phone-td');  
        var rawData = component.get('v.pData');
        for (var index = 0; index < phRow.length ; index++){
            try {
                var rdpElement = phRow[index];
                if (rdpElement){
                    if (rawData[index].phone){
                        var phoneLink = '<div class="slds-col"><a href="tel:' + rawData[index].phone + '" tabindex="-1" class="ringdna-phone" data-phone="'+ rawData[index].phone + '">'+ rawData[index].phone + '</a></div>' ;
                        var url = $A.get('$Resource.cadence_icons') + '/message/msg-icon@3x.png' ;
                        var urlicon = $A.get('$Resource.cadence_icons') + '/rdna-icon/default/rdna-logo@3x.png' ;
                        var smsLink =  '<img class = "Oval" src=' + url + ' />';
                        smsLink = '<div class="slds-float_right slds-col"><a href="tel:'+ rawData[index].phone + '" class="ringdna-sms" data-phone="'+ rawData[index].phone + '">' + smsLink + '</a>';
                        var phoneLinkIcon =  '<img class = "OvalPLIs" src=' + urlicon + ' />';
                        phoneLinkIcon = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '">' + phoneLinkIcon + '</a> </div>';
                        
                        rdpElement.innerHTML =   '<div class="slds-grid slds-truncate">' + phoneLink  + smsLink + phoneLinkIcon  + '</div>';
                    }else{
                        rdpElement.innerHTML = '';
                    }
                }
            }catch(err){
            }
        }
    },
    setCompanyRow : function(component, event, helper){
        var phRow = document.getElementsByClassName('ringdna-company-td');  
        var rawData = component.get('v.pData');
        for (var index = 0; index < phRow.length ; index++){
            try {
                var rdpElement = phRow[index];
                if (rdpElement){
                    if (rawData[index].objType == 'Lead' && rawData[index].company){
                            var companyName = rawData[index].company;
                            rdpElement.innerHTML =   '<div class=" slds-truncate">' + companyName +  '</div>';
                    }else if(rawData[index].company) { 
                        var cLink = '<a href="/' + rawData[index].companyId + '" title="' + rawData[index].company + '" target="_self" tabindex="-1">'+ rawData[index].company + '</a>';
                        rdpElement.innerHTML = '<div class=" slds-truncate">' + cLink +  '</div>';
                    }else {
                        rdpElement.innerHTML = '';
                    }
                }
            }catch(err){
            }
        }
    },
})