({
    getData : function(component, event, helper) {
        component.set('v.spinner', true);
        var action = component.get('c.getTargetListInitData');
        var gId = '';
        var stdGrp = component.get('v.selectedGroup');
        if (stdGrp){
            gId = stdGrp;
        }
        action.setParams({
            pgId :  gId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records = response.getReturnValue();
                records.tlWList.forEach(function(record){
                    record.linkName = '/'+record.participantId; 
                    record.linknextAction = '/'+record.nextAction;
                    if(record.actionType == 'Call' || record.actionType == 'Call+Voicemail') {
                        record.actionIcon = 'action:call';
                        record.actionClass = 'ringdna-phone-td';
                    } else if(record.actionType == 'Email') {
                        record.actionIcon = 'action:email';
                        record.actionClass = 'ringdna-email-td';
                    } else if(record.actionType == 'SMS') {
                        record.actionIcon = 'action:sms';	
                        record.actionClass = 'ringdna-sms-td';  
                    } else if(record.actionType == 'Task') {
                        record.actionIcon = 'action:email';	
                        record.actionClass = 'ringdna-task-td';  
                    }
                    
                    
                    if(record.type == 'Contact') {
                        if(record.companyId != undefined) {
                            record.companyLink = '/'+record.companyId;
                        } 
                    } else {
                        record.companyLink = record.company;
                    }
                    
                    
                });
                component.set('v.rawDataForFilter', records.tlWList);
                component.set('v.rawData', records.tlWList);
                if (records.tlWList.length > 8 || records.tlWList.length == 0){
                    component.set('v.listViewCondition', false);
                } else{
                    component.set('v.listViewCondition', true);
                }
                if (records.tlWList.length == 0){
                    component.set('v.data', records.tlWList);
                }
                component.set('v.totalNumberOfRows', records.tlWList.length);
//                var setPL = component.get('v.setPhoneLink');
                component.set('v.setPhoneLink', true);
                
                component.set('v.selectedGroup', records.selectedGroup);
                if (! records.selectedGroup){
                    component.set('v.groupList', records.pgList);
                }
                
                helper.clearFilter(component);
                helper.setFilterData(component, event, helper);
                component.set('v.spinner', false);
            } else {
                console.log('got an error in fething data');
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    getRowActions : function (component, row, doneCallback) {
        var actions = [{
            'label': 'Remove',
            'name': 'delete'
        }];
        actions.push({
            'label': 'View',
            'name': 'view'
        });
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    
    performActions : function(component, event, helper, actionName, row) {
        
        var rows = [];
        rows.push(row);
        switch (actionName) {
            case 'view':
                helper.viewParticipant(component, event, helper, row.participantId);
                break;
            case 'delete':
                component.set('v.rowsToDelete', rows);
                component.set('v.showModal', true);
                break;
        }
    }, 
    
    deleteParticipantActions : function(component, event, helper, ids) {
        component.set('v.showModal', false);
        var action = component.get('c.deletePA');
        action.setParams({
            "ids" : ids
        });
        console.log('Hello');
        action.setCallback(this, function(response) {
            console.log('Deletion performed');
            var state = response.getState();
            if(state === "SUCCESS") {
                
                //helper.getData(component, event, helper);
                console.log('Deletion performed');
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('Deletion not done');
            }
        });
        $A.enqueueAction(action);
    },
    
    removeCss : function(component, event, helper){
        var cmpTarget = component.find('datatable');
        $A.util.removeClass(cmpTarget, 'slds-table_bordered');
        $A.util.removeClass(cmpTarget, 'slds-table--bordered');
    },
    
    viewParticipant : function(component, event, helper, id) {
        var myUserContext = component.get("v.themeName");
        console.log('viewParticipant',myUserContext);
        if(myUserContext == 'Theme3' ) {
            window.location = '/'+id;
        } 
        else {
            var sObectEvent = $A.get("e.force:navigateToSObject");
            sObectEvent.setParams({
                "recordId": id,
                "slideDevName": "detail"
            });
            sObectEvent.fire();
        }
    },
    setPhoneLink : function(component, event, helper){
        helper.setPhoneRow(component, event, helper); 
        helper.setCompanyRow(component, event, helper);
        var elList = document.getElementsByClassName('ringdna-phone-td');     
        var rawData = component.get('v.data');
       
        for (var index = 0; index < elList.length ; index++){ 
            var rdpElement = elList[index];
            if (rdpElement){
                try {
                    if(rawData[index].actionClass == 'ringdna-phone-td'){
                        var url = $A.get('$Resource.cadence_icons') + '/call/call-icon@3x.png' ;
                        if (rawData[index].actionPerformDay == 'Previous'){
                            url = $A.get('$Resource.cadence_icons') + '/call/FF4545/call-icon-FF4545@3x.png' ;
                        }
                        var innerHtml =  '<img class = "Oval" src=' + url + ' />';  
                        if( rawData[index].actionType == 'Call'){
                        innerHtml = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '" data-call-notes-template-id="'+ rawData[index].tempId +'">' + innerHtml + '</a>';
                        }else{innerHtml = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '" data-vm-drop-id="'+ rawData[index].tempId +'">' + innerHtml + '</a>';}
                        
                        var div = '<div>' + rawData[index].nextAction + '</div>';
                        var ActionLink = '<a href="/' + rawData[index].nextAction  +'" target="_self" tabindex="-1">'+ rawData[index].linkActionName + '</a>';
                        rdpElement.innerHTML = '<div class="slds-truncate">' + innerHtml + ' ' + ActionLink + '</div>';
                    }
                    if(rawData[index].actionClass == 'ringdna-email-td'){
                        var url = $A.get('$Resource.cadence_icons')+ '/email/email-icon@3x.png';
                        if (rawData[index].actionPerformDay == 'Previous'){
                            url = $A.get('$Resource.cadence_icons') + '/email/FF4545/email-icon-FF4545@3x.png' ;
                        }
                        var innerHtml =  '<img class = "Oval" src=' + url + ' />';
                        var hostName = window.location.hostname;
                        if(rawData[index].emailType !='NATIVE'){
                            if(rawData[index].type == 'Contact') {
                                innerHtml = '<a href="https://' + hostName + '/_ui/core/email/author/EmailAuthor?p2_lkid='+ rawData[index].participantId + '&rtype=003&template_id=' + rawData[index].emailTempId + '"'+ ' target="_blank" ' + '>' + innerHtml + '</a>';
                            } else {
                                innerHtml = '<a href="https://' + hostName + '/_ui/core/email/author/EmailAuthor?p2_lkid='+ rawData[index].participantId + '&rtype=00Q&template_id=' + rawData[index].emailTempId + '"'+ ' target="_blank" ' + '>' + innerHtml + '</a>';	
                            }
                        }
                        else{
                            var reDirectUrl =window.location.pathname;
                            reDirectUrl = '/lightning/n/' + rawData[index].nameSpace +'Native_Email';
                            var themeName = component.get("v.themeName");
                            if(themeName == 'Theme3'  || themeName == 'Theme4t' || themeName == 'Theme4d') {
                                innerHtml = '<a href="https://' + hostName +'/apex/NativeEmailPage?pId=' + rawData[index].participantId + '&template_id=' + rawData[index].emailTempId + '&sequencePart_id=' + rawData[index].participantActionsId+ '"'+ ' target="_blank" ' + '>' + innerHtml + '</a>';
                            } else{
                                innerHtml = '<a href="https://' + hostName +reDirectUrl+'?pId=' + rawData[index].participantId + '&template_id=' + rawData[index].emailTempId + '&sequencePart_id=' + rawData[index].participantActionsId+ '"'+ ' target="_blank" ' + '>' + innerHtml + '</a>';
                            }
                        }
                        var ActionLink = '<a href="/' + rawData[index].nextAction + '" target="_self" tabindex="-1">'+ rawData[index].linkActionName + '</a>';
                        rdpElement.innerHTML = '<div class="slds-truncate">' + innerHtml + ' ' + ActionLink + '</div>';
                    }
                    if(rawData[index].actionClass == 'ringdna-sms-td'){
                        var url = $A.get('$Resource.cadence_icons') + '/message/msg-icon@3x.png' ;
                        if (rawData[index].actionPerformDay == 'Previous'){
                            url = $A.get('$Resource.cadence_icons') + '/message/FF4545/msg-icon-FF4545@3x.png' ;
                        }
                        var innerHtml =  '<img class = "Oval" src=' + url + ' />';
                        innerHtml = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-sms" data-phone="'+ rawData[index].phone + '" data-sms-template-id="'+ rawData[index].tempId + '">' + innerHtml + '</a>';
                        var ActionLink = '<a href="/' + rawData[index].nextAction + '" target="_self" tabindex="-1">'+ rawData[index].linkActionName + '</a>';
                        rdpElement.innerHTML =  '<div class="slds-truncate">' + innerHtml + ' ' + ActionLink + '</div>';
                    }
                    if(rawData[index].actionClass == 'ringdna-task-td'){
                        var url = $A.get('$Resource.cadence_icons') + '/task-icon/task-icon@3x.png' ;
                        if (rawData[index].actionPerformDay == 'Previous'){
                            url = $A.get('$Resource.cadence_icons') + '/task-icon/task-icon@3x.png' ;
                        }
                        var innerHtml =  '<img class = "Oval" src=' + url + ' />';
                        innerHtml = '<a href="/'+rawData[index].taskId+'" target="_blank"  >' + innerHtml + '</a>';
                        var ActionLink = '<a href="/' + rawData[index].nextAction + '" target="_self" tabindex="-1">'+ rawData[index].linkActionName + '</a>';
                        rdpElement.innerHTML =  '<div class="slds-truncate">' + innerHtml + ' ' + ActionLink + '</div>';
                    }
                }
                catch(err){
                }
            }
        }
    },
    setPhoneRow : function(component, event, helper){
        var phRow = document.getElementsByClassName('ringdna-phone-row');    
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
                        if( rawData[index].actionType == 'Call'){
                           phoneLinkIcon = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '">' + phoneLinkIcon + '</a> </div>'; 
                        }else{
                        phoneLinkIcon = '<a href="tel:'+ rawData[index].phone + '" class="ringdna-phone" data-phone="'+ rawData[index].phone + '">' + phoneLinkIcon + '</a> </div>';
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
        var rawData = component.get('v.data');
        for (var index = 0; index < phRow.length ; index++){
            try {
                var rdpElement = phRow[index];
                if (rdpElement){
                    if (rawData[index].type == 'Lead' && rawData[index].company){
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
        //helper.removeRingDNAIcons(component, event, helper);
    },
    removeRingDNAIcons:function(component, event, helper){
        window.setTimeout(
            $A.getCallback(function() {
                var elements = document.getElementsByClassName('ringdna-company-td');
                while(elements.length > 0){
                    elements[0].parentNode.removeChild(elements[0]);
                }
            }), 500
        );
    },
    /*Filters*/
    applyMultipleFilters : function(component, event, helper){
        helper.getInputResult(component, event, helper);
        helper.filterObjectType(component, event, helper);
        helper.filterCadenceType(component, event, helper);
        helper.filterActionType(component, event, helper);
        var records = component.get("v.rawData");
        component.set('v.totalNumberOfRows', records.length);
    },
    getInputResult:function(component, event, helper){
        var tData = component.get('v.rawDataForFilter');
        var data = component.get("v.rawDataForFilter");
        var term = component.get("v.sStr");
        var results = data, regex;
        try {
            regex = new RegExp(term, "ig");
            results = data.filter(row=>helper.serchResult(row, regex));
        } catch(e) {
        }
        component.set("v.rawData", results);
        
    },
    serchResult:function(row, regex){
        var strPriproty = (row.priority ? row.priority.toString() : "");
        var strCompany = (row.company ? row.company.toString() : "");
        var strType = (row.type ? row.type.toString() : "");
        var strEmail = (row.email ? row.email.toString() : "");
        var strPhone = (row.phone ? row.phone.toString() : "");
        var strLinkActionName = (row.linkActionName ? row.linkActionName.toString() : "");
        return ( (row.name.search(regex) == -1 ? false : true) 
               // || (strPriproty.search(regex) == -1 ? false : true) 
               // || (strCompany.search(regex) == -1 ? false : true) 
               // || (strType.search(regex) == -1 ? false : true) 
              //  || (strEmail.search(regex) == -1 ? false : true) 
              //  || (strPhone.search(regex) == -1 ? false : true) 
              //  || (strLinkActionName.search(regex) == -1 ? false : true) 
               ) ;
    },
    filterObjectType:function(component, event, helper){
        var data = component.get("v.rawData");
        var term = component.get("v.otFilter");
        var results = data, regex;
        try {
            regex = new RegExp(term, "ig");
            results = data.filter(row=>! row.type.search(regex) );
        } catch(e) {
        }
        component.set("v.rawData", results);
        
    },
    filterCadenceType:function(component, event, helper){
        var data = component.get("v.rawData");
        var term = component.get("v.ctFilter");
        var results = data, regex;
        try {
            regex = new RegExp(term, "ig");
            results = data.filter(row=> (row.cadenceName == term || term =='') );
        } catch(e) {
        }
        component.set("v.rawData", results);
        
    },
    filterActionType:function(component, event, helper){
        var data = component.get("v.rawData");
        var term = component.get("v.atFilter");
        var results = data, regex;
        try {
            regex = new RegExp(term, "ig");
            results = data.filter(row=> (row.actionType == term || term ==''));
        } catch(e) {
        }
        component.set("v.rawData", results);
    },
    setFilterData:function(component, event, helper){
        var rawData = component.get('v.rawData');
        var otList = component.get('v.otList');
        var cList = component.get('v.cList');
        var atList = component.get('v.atList');
        for(var i = 0; i < rawData.length ; i++){
            var wObj = rawData[i];
            if (otList.indexOf(wObj.type) == -1){
                otList.push(wObj.type);
            }
            if (cList.indexOf(wObj.cadenceName) == -1){
                cList.push(wObj.cadenceName);
            }
            if (atList.indexOf(wObj.actionType) == -1){
                atList.push(wObj.actionType);
            }
        }
        component.set('v.otList', otList);
        component.set('v.cList', cList);
        component.set('v.atList', atList);
    },
    clearFilter:function (component){
        component.set('v.sStr', '');
        component.set('v.otFilter', '');
        component.set('v.ctFilter', '');
        component.set('v.atFilter', '');
    },
    
    refresh : function(component, event, helper) {
        		
        var action = component.get("c.retrieveSesstionId");
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.sessionId", response.getReturnValue());
                // Connect to the CometD endpoint
		        $.cometd.init({
		           url: '/cometd/39.0',
		           requestHeaders: { Authorization: component.get("v.sessionId")}
		       });

		       // Subscribe to a topic. JSON-encoded update will be returned
		       // in the callback
		       $.cometd.subscribe('/topic/actionperform', function(message) {
				   console.log('Hello This is fine');
                   console.log(message);
                   console.log('Hello This is fine', message.data.sobject);
		           var pt = component.get('v.pushTopic');
                   component.set('v.pushTopic', !pt);
                   //helper.getData(component, event, helper);
                   
		        });
            }
        });
        $A.enqueueAction(action);
    }, 
    
    startPushTopic : function(component, event, helper) {
        console.log('IN start pushh');
    	var action = component.get('c.createPushTopic'); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('Created PushTopic');        
            }
        });
        $A.enqueueAction(action);
    }
    
})