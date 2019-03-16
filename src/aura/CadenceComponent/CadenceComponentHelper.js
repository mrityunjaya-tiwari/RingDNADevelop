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
                    // Set All field list
                	var fieldList = wrapperResult.fieldList;
                    
                    for(var i=0;fieldList.length > i;i++){
                       //fieldList[i]["fieldsDetail"].sort((a, b) => a['fieldLabel'].localeCompare(b['fieldLabel']));
                       fieldList[i]["fieldsDetail"].sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                    }
                    
                    component.set('v.AllFieldList', fieldList);
                    
                    // Set cadence data
                    var result = wrapperResult.cObj;
                    component.set("v.cadence", wrapperResult.sObj); 
                    if(wrapperResult.sObj.cadenceActions){
                        component.set("v.cadenceActionList", wrapperResult.sObj.cadenceActions);                  
                    }
                    
                    //apply error message here.	
                    var entryCriterion = JSON.parse(wrapperResult.sObj.entranceCriteria);
                    var exitCriterion = JSON.parse(wrapperResult.sObj.exitCriteria);
                    component.set("v.entranceCriteriaSet",entryCriterion);
                    component.set("v.exitCriteriaSet",exitCriterion);
                    component.set("v.SpinnerForSync",false);
                }else if(state === "ERROR"){
                    var myUserContext = component.get("v.themeName");
                    if(myUserContext == 'Theme3') {
                        window.location = '/apex/CadenceErrorPage';
                    } else{
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef  : "RDNACadence:ErrorPage" ,
                            componentAttributes : {
                            }
                        });
                        evt.fire();
                    }}else{
                        component.set("v.SpinnerForSync",false);
                    }
            });
            $A.enqueueAction(cadence);
        }else{
            var cadence = { 'sobjectType': 'Sequence'};
            component.set("v.cadence", cadence);
        }
    },
    setPhoneRow : function(component, event, helper){
        helper.setCompanyRow(component, event, helper);
        var phRow = document.getElementsByClassName('ringdna-phone-td');  
        var rawData = component.get('v.pData');
        var cadencedata = component.get('v.cadence');
        var cadencActions = cadencedata.cadenceActions;
        var templateId ;
        var actionType;
        if(cadencActions.length>0){
            templateId = cadencActions[0].actiontemplateId;
            actionType = cadencActions[0].actiontype;
        }
        
        for (var index = 0; index < phRow.length ; index++){
            try {
                var rdpElement = phRow[index];
                if (rdpElement){
                    if (rawData[index].phone){
                        var phoneLink = '<div class="slds-col"><a href="tel:' + rawData[index].phone + '" tabindex="-1" class="ringdna-phone" data-phone="'+ rawData[index].phone + '">'+ rawData[index].phone + '</a></div>' ;
                        var url = $A.get('$Resource.cadence_icons') + '/message/msg-icon@3x.png' ;
                        var urlicon = $A.get('$Resource.cadence_icons') + '/rdna-icon/default/rdna-logo@3x.png' ;
                        var smsLink =  '<img class = "Oval" src=' + url + ' />';
                        smsLink = '<div class="slds-float_right slds-col"><a href="tel:'+ rawData[index].phone + '" class="ringdna-sms" data-phone="'+ rawData[index].phone + '" data-sms-template-id="'+ rawData[index].templateId + '">' + smsLink + '</a>';
                        var phoneLinkIcon =  '<img class = "OvalPLIs" src=' + urlicon + ' />';
                        if(actionType == 'Call'){
                            phoneLinkIcon = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '" data-call-notes-template-id="'+ rawData[index].templateId + '">' + phoneLinkIcon + '</a> </div>';
                        }else{
                            phoneLinkIcon = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '" data-vm-drop-id="'+ rawData[index].templateId + '">' + phoneLinkIcon + '</a> </div>';
                        }
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
    updateCriteriaList: function(component, event, helper){
        
        var cfList = [];
        var cList = component.get("v.contactFieldList");
        for(var x in cList){
            cfList.push(cList[x]);
        }
        
        var afList = component.get("v.accountFieldList");
        for(var i in afList){
            var obj = afList[i];
            cfList.push({
                'sobjectType': 'Criterion',
                'fieldDataType':  obj.fieldDataType,
                'fieldName' :  'Account.' + obj.fieldName,
                'fieldLabel': 'Account.' +obj.fieldLabel,
                'listPicklistValues' :obj.listPicklistValues,
                'picklistApiNameAndValues' :obj.picklistApiNameAndValues
            });
        }
        component.set("v.accountFieldList", cfList);
        var lfList = [];
        var lList = component.get("v.leadFieldList");
        for(var y in lList){
            lfList.push(lList[y]);
        }
        var dbList = component.get("v.dbFieldList");
        for(var j in dbList){
            var dbObj = dbList[j];
            lfList.push({
                'sobjectType': 'Criterion',
                'fieldDataType':  dbObj.fieldDataType,
                'fieldName' :  'DandBCompany.' + dbObj.fieldName,
                'fieldLabel': 'DandBCompany.' + dbObj.fieldLabel,
                'listPicklistValues' :dbObj.listPicklistValues,
                'picklistApiNameAndValues' :obj.picklistApiNameAndValues
            });
        }
        component.set("v.dbFieldList", lfList);
       
    },
    getObjectFieldsList: function(component, event, helper){
        var cadenceObj = component.get("v.cadence");
        var cadence = component.get("c.getObjCriList");
        component.set("v.SpinnerForSync",true);
        cadence.setParams({objectType: cadenceObj.recordType});
        cadence.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){                
               	var wrapperResult = response.getReturnValue();
                // Set All field list
                var fieldList = wrapperResult.fieldList;
                
                 for(var i=0;fieldList.length > i;i++){
                       //fieldList[i]["fieldsDetail"].sort((a, b) => a['fieldLabel'].localeCompare(b['fieldLabel']));
                       fieldList[i]["fieldsDetail"].sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                 }
                    
                
                component.set('v.AllFieldList', fieldList);
                component.set("v.SpinnerForSync",false);
            }else {
                component.set("v.SpinnerForSync",false);
            }
            component.set("v.settedSequenceType",false);
        });
        $A.enqueueAction(cadence);
    }
})