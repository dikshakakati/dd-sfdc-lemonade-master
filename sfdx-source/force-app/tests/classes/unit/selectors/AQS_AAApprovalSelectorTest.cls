/**
 * @author atg
 * @date 05/17/2022
 * @description This is test class for GroupMembersSelector class
 */
@isTest
private class AQS_AAApprovalSelectorTest {
    private static final String APPROVED = 'Approved';
    private static final String REQUESTED = 'Requested';

    /**
     * @description This is method used to test sbaa__Approval__c selector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        AQS_AAApprovalSelector selectorInstance = new AQS_AAApprovalSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();
        System.assertEquals(Schema.sbaa__Approval__c.SObjectType, typeOfObj, 'The object type must be sbaa__Approval__c');

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                sbaa__Approval__c.Id,
                sbaa__Approval__c.AQS_Quote__c,
                sbaa__Approval__c.sbaa__Approver__c,
                sbaa__Approval__c.sbaa__AssignedTo__c,
                sbaa__Approval__c.CreatedDate,
                sbaa__Approval__c.LastModifiedDate,
                sbaa__Approval__c.sbaa__Status__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is method used to test selectApprovedOrderedByLastModifiedDate and selectRequestedForUserIds
     */
    @isTest
    private static void testWhenSelectCalledThenReturnCorrectRecords() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(Alias = 'test',
                                Email='testUser1@test.com',
                                EmailEncodingKey='UTF-8',
                                LastName='TestLastName',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = testProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName='userEmail4306@test.com');
        insert testUser;

        Account testAccount = new Account(name='Test CPQAccount', BillingStreet = '123 Test Street', BillingCity = 'Missoula', BillingState = 'Montana', BillingPostalCode = '59801', BillingCountry = 'United States', Segment__c = 'Enterprise');
        insert testAccount;

        Opportunity testOppty = new Opportunity(AccountId = testAccount.Id,
                                                Name='Test CPQOpp', StageName='Open',
                                                CloseDate=Date.today().addDays(30));
        insert testOppty;

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                SBQQ__Opportunity2__c = testOppty.Id,
                                                SBQQ__StartDate__c = Date.today(),
                                                SBQQ__EndDate__c = Date.today().addMonths(12));
        insert testQuote;

        SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                SBQQ__Opportunity2__c = testOppty.Id,
                                                SBQQ__StartDate__c = Date.today(),
                                                SBQQ__EndDate__c = Date.today().addMonths(12));
        insert testQuote2;

        SBAA__ApprovalRule__c testApprovalRuleQuote = new SBAA__ApprovalRule__c(Name='Test Approval Rule',
                                                                                SBAA__TargetObject__c = 'SBQQ__Quote__c',
                                                                                SBAA__ApprovalStep__c = 10);
        insert testApprovalRuleQuote;


        SBAA__Approver__c testApprover = new SBAA__Approver__c(Name = 'Test User', SBAA__User__c = testUser.Id);
        insert testApprover;

        SBAA__Approval__c testRequestedApproval1 = new SBAA__Approval__c(SBAA__Status__c = REQUESTED,
                                                                    SBAA__RecordField__c = 'AQS_Quote__c',
                                                                    SBAA__ApprovalStep__c = 10,
                                                                    SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                    SBAA__AssignedTo__c = testUser.Id,
                                                                    AQS_Quote__c = testQuote.Id );
        insert testRequestedApproval1;

        SBAA__Approval__c testRequestedApproval2 = new SBAA__Approval__c(SBAA__Status__c = REQUESTED,
                                                                    SBAA__RecordField__c = 'AQS_Quote__c',
                                                                    SBAA__ApprovalStep__c = 10,
                                                                    SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                    SBAA__AssignedTo__c = null,
                                                                    AQS_Quote__c = testQuote.Id );
        insert testRequestedApproval2; //NOT assigned to the User.

        SBAA__Approval__c testApprovedApproval = new SBAA__Approval__c(SBAA__Status__c = APPROVED,
                                                                    SBAA__RecordField__c = 'AQS_Quote__c',
                                                                    SBAA__ApprovalStep__c = 10,
                                                                    SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                    SBAA__AssignedTo__c = testUser.Id,
                                                                    AQS_Quote__c = testQuote2.Id );
        insert testApprovedApproval;


        List<SBAA__Approval__c>  approvedList = AQS_AAApprovalSelector.newInstance().selectApprovedOrderedByLastModifiedDate();
        System.assertEquals(approvedList.size(), 1, 'List should have 1 approved Record');
        System.assertEquals(approvedList[0].Id, testApprovedApproval.Id, 'Id should be correct');
        System.assertEquals(approvedList[0].sbaa__Status__c, APPROVED, 'Status should be Approved');

        List<SBAA__Approval__c>  requestedList = AQS_AAApprovalSelector.newInstance().selectRequestedForUserIds(new Set<Id> {testUser.Id});
        System.assertEquals(requestedList.size(), 1, 'List should have 1 requested Record');
        System.assertEquals(requestedList[0].Id, testRequestedApproval1.Id, 'Id should be correct');
        System.assertEquals(requestedList[0].sbaa__Status__c, REQUESTED, 'Status should be Requested');

    }

    /**
     * @description This is method used to test selectApprovedOrderedByLastModifiedDate and selectRequestedForUserIds
     * can be used by Standard users if they have the correct permission sets.
     */
    @isTest
    private static void testWhenSelectCalledStandardUserThenReturnCorrectRecords() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        PermissionSet cpqPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'QuoteToCash' LIMIT 1];
        PermissionSet salesPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Sales' LIMIT 1];
        PermissionSet aaPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'AdvancedApprovalsUser' LIMIT 1];

        PermissionSetLicense cpqAAPermissionSetLicense = [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQAAPerm' LIMIT 1];
        PermissionSetLicense cpqPermissionSetLicense = [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' LIMIT 1];

        User testUser = new User(Alias = 'test',
                                Email='testUser1@test.com',
                                EmailEncodingKey='UTF-8',
                                LastName='TestLastName',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = standardUser.Id,
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName='userEmail4306@test.com');
        insert testUser;
        //Add QuoteToCash Permission set the StandardUser
        insert new PermissionSetLicenseAssign(AssigneeId = testUser.id, PermissionSetLicenseId = cpqAAPermissionSetLicense.id);
        insert new PermissionSetLicenseAssign(AssigneeId = testUser.id, PermissionSetLicenseId = cpqPermissionSetLicense.id);
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = cpqPermissionSet.Id);
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = salesPermissionSet.Id);
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = aaPermissionSet.Id);

        //Ensure a standard user can insert Approvals
        System.runAs(testUser) {

            Account testAccount = new Account(name='Test CPQAccount',
                                                BillingStreet = '123 Test Street',
                                                BillingCity = 'Missoula',
                                                BillingState = 'Montana',
                                                BillingPostalCode = '59801',
                                                BillingCountry = 'United States',
                                                Primary_Vertical__c = 'Rx',
                                                RecordTypeId = accRecordType,
                                                Segment__c = 'Enterprise',
                                                Legal_Business_Name__c = 'Doordash Legal');
            insert testAccount;
            Opportunity testOppty = new Opportunity(AccountId = testAccount.Id,
                                                    Name='Test CPQOpp', StageName='Open',
                                                    CloseDate=Date.today().addDays(30));
            insert testOppty;
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                    SBQQ__Opportunity2__c = testOppty.Id,
                                                    SBQQ__StartDate__c = Date.today(),
                                                    SBQQ__EndDate__c = Date.today().addMonths(12));
            insert testQuote;
            SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(SBQQ__Account__c = testAccount.Id,
                                                    SBQQ__Opportunity2__c = testOppty.Id,
                                                    SBQQ__StartDate__c = Date.today(),
                                                    SBQQ__EndDate__c = Date.today().addMonths(12));
            insert testQuote2;
            SBAA__ApprovalRule__c testApprovalRuleQuote = new SBAA__ApprovalRule__c(Name='Test Approval Rule',
                                                                                    SBAA__TargetObject__c = 'SBQQ__Quote__c',
                                                                                    SBAA__ApprovalStep__c = 10);
            insert testApprovalRuleQuote;
            SBAA__Approver__c testApprover = new SBAA__Approver__c(Name = 'Test User', SBAA__User__c = testUser.Id);
            insert testApprover;


            SBAA__Approval__c testRequestedApproval1 = new SBAA__Approval__c(SBAA__Status__c = REQUESTED,
                                                                        SBAA__RecordField__c = 'AQS_Quote__c',
                                                                        SBAA__ApprovalStep__c = 10,
                                                                        SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                        SBAA__AssignedTo__c = testUser.Id,
                                                                        AQS_Quote__c = testQuote.Id );
            insert testRequestedApproval1;

            SBAA__Approval__c testRequestedApproval2 = new SBAA__Approval__c(SBAA__Status__c = REQUESTED,
                                                                        SBAA__RecordField__c = 'AQS_Quote__c',
                                                                        SBAA__ApprovalStep__c = 10,
                                                                        SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                        SBAA__AssignedTo__c = null,
                                                                        AQS_Quote__c = testQuote.Id );
            insert testRequestedApproval2; //NOT assigned to the User.

            SBAA__Approval__c testApprovedApproval = new SBAA__Approval__c(SBAA__Status__c = APPROVED,
                                                                        SBAA__RecordField__c = 'AQS_Quote__c',
                                                                        SBAA__ApprovalStep__c = 10,
                                                                        SBAA__Rule__c = testApprovalRuleQuote.Id,
                                                                        SBAA__AssignedTo__c = testUser.Id,
                                                                        AQS_Quote__c = testQuote2.Id );
            insert testApprovedApproval;


            List<SBAA__Approval__c>  approvedList = AQS_AAApprovalSelector.newInstance().selectApprovedOrderedByLastModifiedDate();
            System.assertEquals(approvedList.size(), 1, 'List should have 1 approved Record');
            System.assertEquals(approvedList[0].Id, testApprovedApproval.Id, 'Id should be correct');
            System.assertEquals(approvedList[0].sbaa__Status__c, APPROVED, 'Status should be Approved');

            List<SBAA__Approval__c>  requestedList = AQS_AAApprovalSelector.newInstance().selectRequestedForUserIds(new Set<Id> {testUser.Id});
            System.assertEquals(requestedList.size(), 1, 'List should have 1 requested Record');
            System.assertEquals(requestedList[0].Id, testRequestedApproval1.Id, 'Id should be correct');
            System.assertEquals(requestedList[0].sbaa__Status__c, REQUESTED, 'Status should be Requested');
        }
    }
}