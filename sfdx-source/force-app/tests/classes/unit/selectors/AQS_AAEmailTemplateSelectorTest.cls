/**
 * @author atg
 * @date 05/19/2022
 * @description This is test class for AQS_AAEmailTemplateSelector class
 */
@isTest
private class AQS_AAEmailTemplateSelectorTest {
    /**
     * @description This is method used to test AQS_AAEmailTemplateSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        AQS_AAEmailTemplateSelector templatesInstance = new AQS_AAEmailTemplateSelector();
        Schema.SObjectType typeOfObj = templatesInstance.getSObjectType();
        System.assertEquals(Schema.sbaa__EmailTemplate__c.SObjectType, typeOfObj, 'The object type must be sbaa__EmailTemplate__c');

        List<Schema.SObjectField> fieldList = templatesInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                sbaa__EmailTemplate__c.Id,
                sbaa__EmailTemplate__c.Name,
                sbaa__EmailTemplate__c.sbaa__TemplateId__c,
                sbaa__EmailTemplate__c.CreatedDate,
                sbaa__EmailTemplate__c.CreatedById
                },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is method used to test AQS_AAEmailTemplateSelector selectAllOrderedByName
     */
    @isTest
    private static void testWhenSelectAllOrderedByNameThenReturnRecords() {
        //We cannot insert Email Template data in Apex tests, it needs to be set up in the org beforehand.
        EmailTemplate standardTemplate = [SELECT Id, Name, Folder.Name FROM EmailTemplate WHERE Folder.Name = 'AQS AA Email Templates' LIMIT 1];
        sbaa__EmailTemplate__c addedSBAAEmailTemplate = new sbaa__EmailTemplate__c(Name = standardTemplate.Name, sbaa__templateID__c = standardTemplate.Id);
        insert addedSBAAEmailTemplate;

        List<sbaa__EmailTemplate__c> emailTemplates = AQS_AAEmailTemplateSelector.newInstance().selectAllOrderedByName();
        System.assertNotEquals(emailTemplates.size(), 0, 'Folder should be set up with Records');
    }

}