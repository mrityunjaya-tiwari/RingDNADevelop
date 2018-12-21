trigger Contact on Contact (after insert, after update, before insert, before update) {
    SObjectDomain.triggerHandler(Contacts.class);
}