/**
 * @author atg
 * @date 05/11/2022
 * @description Selector Class for Email Template Object
 */
public inherited sharing class EmailTemplateSelector extends fflib_SObjectSelector implements IEmailTemplateSelector {
    /**
     * @description default constructor for the class
     * @return EmailTemplateSelector - interface of IEmailTemplateSelector
     */
    public static IEmailTemplateSelector newInstance() {
        return (IEmailTemplateSelector) Application.Selector.newInstance(EmailTemplate.SObjectType);
    }

    /**
     * @description static Map which holds a reference to an Email Folder Name (key) and list of templates (value)
     *              to prevent redundant queries of the Email Templates
     * @return Map<String, List<EmailTemplate>>
    **/
    private static Map<String, List<EmailTemplate>> emailTemplatesAndFoldersMap {get {
        if(emailTemplatesAndFoldersMap == null) {
            emailTemplatesAndFoldersMap = new Map<String, List<EmailTemplate>>();
        }

        return emailTemplatesAndFoldersMap;
    } set;}

    /**
     * @description This method is for getting the fields on EMailTemplate object
     * @return Contact- Contact fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            EmailTemplate.Id,
            EmailTemplate.Name,
            EmailTemplate.Folder.Name
        };
    }

    /**
     * @description This method id for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return EmailTemplate.SObjectType;
    }

    /**
     * @description This method is used for getting sbaa__EmailTemplate__c based on ID
     * @param setIds Set of Ids
     * @return List of EmailTemplate
     */
    public List<EmailTemplate> selectById(Set<Id> setIds) {
        return (List<EmailTemplate>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is used for getting all EmailTemplate in a folder
     * @param folderName
     * @return List of EmailTemplate
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<EmailTemplate> selectByFolderName(String folderName) {
        // Prevent redundant queries when we've already retrieved the templates
        if(emailTemplatesAndFoldersMap.containsKey(folderName)) {
            return emailTemplatesAndFoldersMap.get(folderName);
        }

        //For some reason, the fflib_QueryFactory does not work correctly for email templates when called by non-SysAdmins.
        //When the SELECT is done using just SOQL, it works correctly for non-SysAdmin
        List<EmailTemplate> fetchedTemplates = [
            SELECT Id, Name, Folder.Name
            FROM EmailTemplate
            WHERE Folder.Name = :folderName
        ];

        emailTemplatesAndFoldersMap.put(folderName, fetchedTemplates);

        return fetchedTemplates;
    }

    /**
     * @description This method is used for getting Email Templates based on Name.
     * @JIRA# LEM-14703
     * @param templateNames
     * @return List<EmailTemplate>
     */
    public List<EmailTemplate> selectByTemplateNames(Set<String> templateNames) {
        fflib_QueryFactory emailTemplatesQuery = newQueryFactory()
            .selectField('Subject')
            .selectField('HtmlValue')
            .setCondition('Name IN :templateNames');
        return (List<EmailTemplate>) Database.query(emailTemplatesQuery.toSOQL());
    }
}