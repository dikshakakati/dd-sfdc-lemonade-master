/**
 * @author Deloitte
 * @date 07/11/2024
 * @description Domain Class for Content Version object.
 */
public inherited sharing class ContentVersions extends fflib_SObjects implements IContentVersions {
    private static final String CONTENT_VERSION_TYPE_FRAUD = 'Fraud';
    private static final String MX_FRAUD_DOCUMENT_API_NAME = 'Mx_Fraud_Document__c';

    /**
     * @description It returns the IContentVersions interface.
     * @param sObjects - Content Versions record list
     * @return IContentVersions - Returns IContentVersions Interface
     */
    public static IContentVersions newInstance(List<ContentVersion> sObjects) {
        return (IContentVersions) Application.Domain.newInstance(sObjects);
    }

    /**
     * @description Default constructor for the class.
     * @param sObjects
     */
    public ContentVersions(List<ContentVersion> sObjects) {
        super(sObjects, Schema.ContentVersion.SObjectType);
    }

    /**
     * @description It associates the newly created Fraud Content Version records
     * to Mx Fraud Document record.
     * @JIRA LEM-17403
     */
    public void addToMxFraudDocuments() {
        for (ContentVersion eachContentVersion : (List<ContentVersion>) getRecords()) {
            updateFirstPublishLocationIdOnFraudDocuments(eachContentVersion);
        }
    }

    /**
     * @description It updates the Mx Fraud Document Id based on First Publish Location Id.
     * @JIRA LEM-17403
     * @param newContentVersion
     */
    public void updateFirstPublishLocationIdOnFraudDocuments(ContentVersion newContentVersion) {
        if (
            newContentVersion.FirstPublishLocationId != null &&
            String.isNotBlank(newContentVersion.FirstPublishLocationId)
        ) {
            if (
                newContentVersion.FirstPublishLocationId.getSObjectType().getDescribe().getName() ==
                MX_FRAUD_DOCUMENT_API_NAME
            ) {
                newContentVersion.Mx_Fraud_Document__c = newContentVersion.FirstPublishLocationId;
                newContentVersion.Type__c = CONTENT_VERSION_TYPE_FRAUD;
            }
        }
    }

    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description constructor menthod implementation from fflib_IDomainConstructor class.
         * @param sObjects
         * @return ContentVersions - List of Content Versions
         */
        public fflib_SObjects construct(List<Object> sObjects) {
            return new ContentVersions((List<SObject>) sObjects);
        }
    }
}