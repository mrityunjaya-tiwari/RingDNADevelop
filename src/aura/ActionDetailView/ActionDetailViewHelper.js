({
    getData : function(component, event, helper) {
        
        component.set('v.spinner', true);
        var id = component.get('v.recordId');
        
        if(id == null || id === undefined) {
            //alert("Data no longer exist");
            helper.openRecordList();
            
        }
        
        var action = component.get('c.getActionData');
        action.setParams({actionId : id});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.record', data.action);
                
                //Making url for cadence rows
                var cadRecords = data.cadWrapper;
                cadRecords.forEach(function(record) {
                    record.linkName = '/'+record.id;
                }); 	
                component.set('v.cadRawData', cadRecords);                
                
                var partRecords = data.participantList;
                partRecords.forEach(function(record) {
                    record.linkName = '/'+record.id;
                    if (record.company){
                        record.linkcompany = '/'+record.companyId;  
                    }
                }); 	
                component.set('v.partRawData', partRecords);
                component.set('v.spinner', false);
                
                component.set('v.setCompanyRow', true);
            } /*else if(state === "ERROR"){
            
                var myUserContext = component.get("v.themeName");
                if(myUserContext == 'Theme3') {
            window.location = '/apex/ErrorPage'
                } else{
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef  : "c:ErrorPage" ,
                    componentAttributes : {
                    }
                });
                evt.fire();
            }}*/
            else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    editRecord : function(component, event, id) {
        var myUserContext = component.get("v.themeName");
        
        if(myUserContext == 'Theme3') {
            window.location = '/apex/EditActionDetails?id='+id;
        } 
        else {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:ActionDetails" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire(); 
        }
    },
    openRecordList : function(component, event) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef  : "c:CadenceActionList" ,
            componentAttributes : {
            }
        });
        evt.fire();
    },
    setCompanyRow : function(component, event, helper){
        helper.setPhoneRow(component, event, helper);
        var phRow = document.getElementsByClassName('ringdna-company-td');  
        var rawData = component.get('v.data');
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
    setPhoneRow : function(component, event, helper){
        var phRow = document.getElementsByClassName('ringdna-phone-td');  
        var rawData = component.get('v.data');
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
})