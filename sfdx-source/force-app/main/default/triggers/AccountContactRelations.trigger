/**
 * @author Deloitte
 * @date 02/12/2022
 * @description Trigger on AccountContactRelation Object
 */
trigger AccountContactRelations on AccountContactRelation(before update, before insert, after insert) {
    fflib_SObjectDomain.triggerHandler(AccountContactRelationsHandler.class);
}