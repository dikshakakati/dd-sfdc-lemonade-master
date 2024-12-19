/**  
 * @author Deloitte
 * @date 15/04/2022
 * @description Trigger on Contact Object
 */

trigger Contacts on Contact (before insert, before update, before delete, after insert,after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(ContactsHandler.class);

}