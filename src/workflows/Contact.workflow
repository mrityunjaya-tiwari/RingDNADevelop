<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ringdna100__Unset_Contact_RingDNA_Context</fullName>
        <field>ringdna100__RingDNA_Context__c</field>
        <literalValue>0</literalValue>
        <name>Unset Contact RingDNA Context</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ringdna100__Unset Contact RingDNA Context</fullName>
        <actions>
            <name>ringdna100__Unset_Contact_RingDNA_Context</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.ringdna100__RingDNA_Context__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
