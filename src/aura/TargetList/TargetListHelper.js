<aura:component controller="TargetListController" implements="flexipage:availableForRecordHome,flexipage:availableForAllPageTypes,force:hasRecordId,force:lightningQuickAction,force:appHostable" access="global">
    
    <ltng:require scripts="{!join(',',
            $Resource.StreamingAPI + '/cometd.js',
            $Resource.StreamingAPI + '/jquery-1.5.1.js',
            $Resource.StreamingAPI + '/json2.js',
            $Resource.StreamingAPI + '/jquery.cometd.js')}"
                  afterScriptsLoaded="{!c.refreshData}"
    />
    <aura:attribute name="sessionId" type="String"/>
    
    <!--  HANDLERS -->
    <aura:handler name="init" value="{!this}" action="{!c.init}" />
    <aura:handler name="datatableEvt" event="c:DatatableEvent" action="{!c.handleDatatableEvent}"/>
    
    <aura:attribute name="totalNumberOfRows" type="Integer" default="0" description="Contains the data of total no of records present on table" />
    <aura:attribute name="sortBy" type="String" default="Type"/>
    <aura:attribute name="showModal" type="Boolean" default="false"/>
    <aura:attribute name="rowsToDelete" type="List"/>
    <aura:attribute name="pushTopic" type="boolean" default="false"/>
    <aura:handler name="change" value="{!v.pushTopic}" action="{!c.callRefresh}"/>
    
    <!-- DATATABLE ATTRIBUTES -->
    <aura:attribute name="columns" type="List"/>
    <aura:attribute name="rawData" type="List"/>
    <aura:attribute name="rawDataForFilter" type="List"/>
    <aura:attribute name="selectedRows" type="List"/> 
    <aura:attribute name="hideCheckboxes" type="boolean"/>
    <aura:attribute name="recordsPerPage" type="Integer" default="25"/>
    <!--  / DATATABLE ATTRIBUTES -->
    <aura:attribute name="setPhoneLink" type="boolean" default = "false"/>
    <aura:handler name="change" value="{!v.setPhoneLink}" action="{!c.setPhoneLink}"/> 
    <aura:handler event="force:refreshView" action="{!c.init}" />
    <aura:handler name="cadencePagination" event="c:CadPagination" action="{!c.handlePagination}"/>
    <aura:attribute name="data" type="List" />
    <aura:handler name="change" value="{!v.data}" action="{!c.pageUpdated}"/> 
    <!--create a component attributs -->
    <aura:attribute name="spinner" type="boolean" default="false"/>
    <c:SpinnerComponent spinnerSync = "{!v.spinner}"/>
    <aura:attribute name="selectedGroup" type="String" default=""/>
    <aura:attribute name="groupList" type="List"/>
    <aura:attribute name="currentUserId" type="String"/>
    <aura:attribute name="themeName" type="String"/>
    <aura:attribute name="listViewCondition" type="boolean" default="true"/>
    
    <!-- Search -->
    <aura:attribute name="sStr" type="String"/>
    <aura:attribute name="otFilter" type="String"/>
    <aura:attribute name="ctFilter" type="String"/>
    <aura:attribute name="atFilter" type="String"/>
    
    <aura:attribute name="otList" type = "List"/>
    <aura:attribute name="cList" type = "List"/>
    <aura:attribute name="atList" type = "List"/>
    <!-- PAGE HEADER -->
    <div class="slds-page-header slds-p-left_medium" style="background-color: #fafafa">
        
        <div class="slds-grid">
            <div>
                <img class = "rdna-logo" src="{!$Resource.cadence_icons + '/rdna-logo/rdna-logo@2x.png'}"/>
            </div>
            <div class="slds-col slds-has-flexi-truncate slds-m-left_small">
                <p class="slds-line-height_reset topHeaderSmall slds-p-left_xx-small">Today</p>
                <h1 class="slds-page-header__title slds-m-right_small slds-align-middle slds-truncate headerLarge"  title="All Cadence">ringDNA Today</h1>
            </div>
            
            <aura:if isTrue="{!v.selectedRows.length > 0}">
                <div>
                    <lightning:button class = "rdna-remove-button rdna-remove-button-text" aura:id="remove" label="Remove" onclick="{!c.removeActions}"/> 
                </div>
            </aura:if>
        </div>
              
        <div class="slds-grid slds-m-top_small">
            <div class= "slds-col slds-size_1-of-8 topHeaderSmall slds-m-top_large">
                <span>{!v.totalNumberOfRows} Items • Sorted by {!v.sortBy} 
                </span>
            </div>
            
            <div class= "slds-col slds-size_1-of-6 topHeaderSmall slds-m-top_small slds-p-left_x-small rdna-classic-search">
                <lightning:input type="search" 
                                 variant = "label-hidden"  
                                 label="Search" 
                                 placeholder="Search"
                                 value="{!v.sStr}"
                                 onchange="{!c.searchInputText}" 
                                 name="search" />
            </div>
            
            <div class= "slds-col slds-size_1-of-8 topHeaderSmall slds-m-right_medium">
                <lightning:select variant = "label-hidden" name="select" label='' value="{!v.otFilter}" onchange="{!c.filterObjectType}">
                    <option value="">Type</option>
                     <aura:iteration var="ot" items="{!v.otList}">
                        <option value="{!ot}">{! ot }</option>
                    </aura:iteration>
                </lightning:select>
            </div>
            
            <div class= "slds-col slds-size_1-of-8 topHeaderSmall slds-m-right_medium">
                <lightning:select variant = "label-hidden" name="select1" label='' value="{!v.ctFilter}" onchange="{!c.filterCadenceType}">
                    <option value="">Sequence</option>
                    <aura:iteration var="cad" items="{!v.cList}">
                        <option value="{!cad}">{! cad }</option>
                    </aura:iteration>
                </lightning:select>
            </div> 
            <div class= "slds-col slds-size_1-of-8 topHeaderSmall slds-m-right_medium">
                <lightning:select variant = "label-hidden" name="select1" label='' value="{!v.atFilter}" onchange="{!c.filterActionType}">
                    <option value="">Action Type</option>
                     <aura:iteration var="at" items="{!v.atList}">
                        <option value="{!at}">{! at }</option>
                    </aura:iteration>
                </lightning:select>
            </div> 
            <div class= "slds-col topHeaderSmall slds-m-top_large slds-m-left_x-large slds-p-left_large slds-float_right rdna-text-align">Select group</div>
            <div class= "slds-col slds-size_1-of-8 topHeaderSmall">
                <lightning:select  variant = "label-hidden" aura:id="grp-opt" label="select" value="{!v.selectedGroup}" onchange="{!c.updateTargetList}">
                    <aura:iteration var="group" items="{!v.groupList}">
                        <option value="{!group.Id}">{! group.Name }</option>
                    </aura:iteration>
                </lightning:select>
            </div>
            
        </div> 
        
        <!-- RECORD TABLE -->
        <div >
            <div class="slds-m-top_medium rdna-classic-datatableStyling">
                <c:Datatable columns = "{!v.columns}" rawData = "{!v.rawData}" aura:id = "datatable" hideCheckboxColumn = "{!v.hideCheckboxes}" 
                                       sortBy = "{!v.sortBy}" rowsToLoad = "{!v.recordsPerPage}" 
                                       isListView="{!v.listViewCondition}" 
                                       rawDataForFilter = "{!v.rawDataForFilter}"
                                       data="{!v.data}"
									   isTodayListView = "true"
                                       selectedNoOfRecords="true"/> 
            </div>
        </div> 
    </div>
    <!-- / PAGE HEADER -->   
    <!-- / RECORD TABLE -->
    <!-- DELETE CONFIRMATION MODAL -->
    <aura:if isTrue="{!v.showModal}">
        <div class="demo-only" style="height: 640px;">
            <section role="dialog" tabindex="-1" aria-labelledby="modal-heading-01" aria-modal="true" aria-describedby="modal-content-id-1" class="slds-modal slds-fade-in-open">
                <div class="slds-modal__container">
                    <header class="slds-modal__header">
                        <h2 id="modal-heading-01" class="slds-text-heading_medium slds-hyphenate">Remove Action</h2>
                    </header>
                    <div class="slds-modal__content slds-p-around_medium" id="modal-content-id-1">
                        <p>Are you sure you want to remove this action? The action will be completed and removed from the target list.</p>
                    </div>
                    <footer class="slds-modal__footer">
                        <lightning:button label="Delete" variant="brand" onclick="{!c.deletePartActions}"/>   
                        <lightning:button label="Cancel" onclick="{!c.cancel}"/>
                    </footer>
                </div>
            </section>
            <div class="slds-backdrop slds-backdrop_open"></div>
        </div>
    </aura:if>    
    <!-- / DELETE CONFIRMATION MODAL -->
</aura:component>