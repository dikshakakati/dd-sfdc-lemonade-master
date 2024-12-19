/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Test class for MxFraudDocumentsSelector class.
 */
@isTest(SeeAllData=false)
private class MxFraudDocumentsSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String MX_COUNTRY = 'US';
    private static final String MX_DOCUMENT_TYPE_PASSPORT = 'Passport';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Mx Fraud Document.';
    private static final String OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mx Fraud Document record is not returned.';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        MxFraudDocumentsSelector mxFraudDocumentsSelectorInstance = new MxFraudDocumentsSelector();
        Schema.SObjectType typeOfObject = mxFraudDocumentsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = mxFraudDocumentsSelectorInstance.getSObjectFieldList();
        MxFraudDocumentsSelector.newInstance();
        System.assertEquals(
            Schema.Mx_Fraud_Document__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Mx_Fraud_Document__c.Id,
                Mx_Fraud_Document__c.CreatedDate,
                Mx_Fraud_Document__c.Document_Title__c,
                Mx_Fraud_Document__c.Document_Version__c,
                Mx_Fraud_Document__c.LastModifiedDate,
                Mx_Fraud_Document__c.Mx_Country__c,
                Mx_Fraud_Document__c.Mx_Document_Type__c,
                Mx_Fraud_Document__c.Mx_Document_Verification_Notes__c,
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                Mx_Fraud_Document__c.Mx_Store_Id__c,
                Mx_Fraud_Document__c.Name,
                Mx_Fraud_Document__c.Store_Id__c,
                Mx_Fraud_Document__c.Work_Plan__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Mx Fraud Documents are returned based on the passed Store Account Ids.
     */
    @isTest
    private static void testWhenStoreAccountIdsReceivedThenReturnMxFraudDocumentDetails() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert storeAccount;
        Mx_Fraud_Document__c newMxFraudDocument = new Mx_Fraud_Document__c(
            Mx_Store_Id__c = storeAccount.Id,
            Mx_Country__c = MX_COUNTRY,
            Mx_Document_Type__c = MX_DOCUMENT_TYPE_PASSPORT
        );
        insert newMxFraudDocument;
        List<Mx_Fraud_Document__c> queryResult = MxFraudDocumentsSelector.newInstance()
            .selectByStoreAccountIds(new Set<Id>{ storeAccount.Id });
        System.assertEquals(
            newMxFraudDocument.Id,
            queryResult[0].Id,
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}