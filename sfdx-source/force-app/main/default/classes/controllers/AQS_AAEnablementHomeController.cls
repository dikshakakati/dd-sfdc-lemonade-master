/**
 * @description Advanced Approvals Quickstart package
 * @author ATG
 * @date 04/20/2022
 */
//Supressing CRUD validations because we are doing updates to Custom Settings, not the database.
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class AQS_AAEnablementHomeController{
    static final String AA_FOLDER_NAME = 'AQS AA Email Templates';
    /**
 	 * @description getter/setter for currentEmailTemplates variable
	 * @param
	 * @return List<sbaa__EmailTemplate__c> - Returns email template list
 	 */
    public List<sbaa__EmailTemplate__c> currentEmailTemplates {get;set;}
    /**
 	 * @description getter/setter for recordTypeSetting variable
	 * @param
	 * @return AQS_AA_Enablement_IDs__c
 	 */
      public AQS_AA_Enablement_IDs__c recordTypeSetting {get;set;}

    /**
 	 * @description constructor
 	 */
    public AQS_AAEnablementHomeController(){
        currentEmailTemplates = fetchEmailTemplates();
        recordTypeSetting = AQS_AA_Enablement_IDs__c.getOrgDefaults();
    }


    //-------------------------------------- Methods -----------------------------------------------------------------
    //------------------------------------------

    /**
 	 * @description SOQL to set email templates variable
     * @return List<sbaa__EmailTemplate__c>
 	 */
    public List<sbaa__EmailTemplate__c> fetchEmailTemplates(){
        return AQS_AAEmailTemplateSelector.newInstance().selectAllOrderedByName();
    }

    /**
 	 * @description method for creating email templates used by the button on VF page
	 * @param
	 * @return PageReference
 	 */
    public PageReference createTemplates() {

        //collects email templates from installed folder
        List<EmailTemplate> installedEmailTemplates = EmailTemplateSelector.newInstance().selectByFolderName(AA_FOLDER_NAME);

        AQS_AAEmailTemplateService.createTemplates(installedEmailTemplates);

        //rerenders the email template list
        fetchEmailTemplates();

        //adds a message displayed to the user when the creates email template records
        String emailTemplateMessage = 'Successfully added email templates!';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, emailTemplateMessage));

        return null;
    }

    /**
 	 * @description method used to update the record type custom setting fields, used by a button on the VF page
	 * @param
	 * @return PageReference
 	 */
    public PageReference updateCustomSetting(){
        //gets record types to update into custom setting
        String approvedQuoteRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('AQS Approved Quote').getRecordTypeId();
        String draftQuoteRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('AQS Draft Quote').getRecordTypeId();
        String inProgressQuoteRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('AQS In Progress Quote').getRecordTypeId();

        recordTypeSetting.AQS_Approved_Quote_RT__c = approvedQuoteRecordTypeID;
        recordTypeSetting.AQS_Draft_Quote_RT__c = draftQuoteRecordTypeID;
        recordTypeSetting.AQS_In_Progress_Quote_RT__c = inProgressQuoteRecordTypeID;

        //update custom setting with id's from installed record types
        if (recordTypeSetting.Id == null) {
            insert recordTypeSetting;
        }
        else {
            update recordTypeSetting;
        }

        //adds a message displayed to the user when the button is clicked
        if (String.isBlank(recordTypeSetting.AQS_Approved_Quote_RT__c) ||
            String.isBlank(recordTypeSetting.AQS_Draft_Quote_RT__c) ||
            String.isBlank(recordTypeSetting.AQS_In_Progress_Quote_RT__c)
            ){
            String customSettingUpdateMessage = 'One or more record type fields in the custom setting is blank and will cause errors when submitting for approval. You may need to manually update the custom setting "SBAA__Enablement_IDs__c" with the proper values.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, customSettingUpdateMessage));
        }
        else {
            String customSettingUpdateMessage = 'Successfully updated record type custom settings!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, customSettingUpdateMessage));
        }

        return null;
    }

    /**
 	 * @description method used to update the email custom setting field, used by a button on the VF page
	 * @param
	 * @return PageReference
 	 */
    public PageReference updateEmailLogoId(){
        //updates the approval email logo id field based on the user input
        //This is a custom setting, so this isn't doing DML, it is writing to the application Cache
        if (recordTypeSetting.Id == null) {
            insert recordTypeSetting;
        }
        else {
            update recordTypeSetting;
        }

        //adds a message displayed to the user when the button is clicked
        if ( String.isBlank(recordTypeSetting.AQS_Approval_Email_Logo_ID__c) ||
            ( recordTypeSetting.AQS_Approval_Email_Logo_ID__c.length() != 15 &&
              recordTypeSetting.AQS_Approval_Email_Logo_ID__c.length() != 18 ) )
        {
            String emailSettingUpdateMessage = 'The custom setting field has been updated, but the value may not be in the proper format. Ensure that you have a 15 or 18 digit document ID populated in the field.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, emailSettingUpdateMessage));
        }
        else {
            String emailSettingUpdateMessage = 'Successfully updated email custom setting!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, emailSettingUpdateMessage));
        }

        return null;
    }
}