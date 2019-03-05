trigger Lead on Lead (after insert, after update, before insert, before update) {
    SObjectDomain.triggerHandler(Leads.class);
}