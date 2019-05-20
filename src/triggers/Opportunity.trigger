trigger Opportunity on Opportunity (after insert, after update) {
    SObjectDomain.triggerHandler(opportunities.class);
}