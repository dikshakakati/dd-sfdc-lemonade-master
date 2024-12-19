/**
 * @author DoorDash
 * @description Test class for the ProcessFlowRequestsSelector Selector class..
**/
@IsTest
private class ProcessFlowRequestsSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;


    @TestSetup
    static void setupData() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();

        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Address_Id__c = '12345',
            Legal_Business_Name__c = 'Legal Name LLC',
            Menu_UI_Type__c = ACCOUNT_MENU_UI_TYPE_RETAIL,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            Segment__c = 'Enterprise'
        );
        insert storeAccount;

        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;

        // Create a Process_Flow_Request__c object and insert
        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            RecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName().get('Bulk_Store_Onboarding').getRecordTypeId(),
            OwnerId = UserInfo.getUserId(),
            Contract__c = contract.Id,
            Stage__c = 'Work Order Type Selection',
            Status__c = 'In Progress'
        );
        insert processFlowRequest;


    }

    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        ProcessFlowRequestsSelector selectorInstance = new ProcessFlowRequestsSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();
        System.assertEquals(Schema.Process_Flow_Request__c.SObjectType, typeOfObj, 'The object type must match Process_Flow_Request__c');

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Process_Flow_Request__c.Id,
                Process_Flow_Request__c.Name,
                Process_Flow_Request__c.CreatedDate,
                Process_Flow_Request__c.CreatedById,
                Process_Flow_Request__c.LastModifiedDate,
                Process_Flow_Request__c.LastModifiedById,
                Process_Flow_Request__c.OwnerId,
                Process_Flow_Request__c.Batch_Delay_Number__c,
                Process_Flow_Request__c.Contract__c,
                Process_Flow_Request__c.Fixed_Store_IDs__c,
                Process_Flow_Request__c.Fixed_Stores_Count__c,
                Process_Flow_Request__c.Opportunity__c,
                Process_Flow_Request__c.Is_Closed__c,
                Process_Flow_Request__c.Removed_Stores__c,
                Process_Flow_Request__c.Result__c,
                Process_Flow_Request__c.Serialized_Object_Data__c,
                Process_Flow_Request__c.Stage__c,
                Process_Flow_Request__c.Status__c,
                Process_Flow_Request__c.Upload_Attempts__c,
                Process_Flow_Request__c.User_Feedback__c,
                Process_Flow_Request__c.Work_Order__c,
                Process_Flow_Request__c.Work_Order_Selection_Method__c,
                Process_Flow_Request__c.Serialized_Entitlements_Data__c,
                Process_Flow_Request__c.Group__c,
                Process_Flow_Request__c.CCP_ANSO_flow__c,
                Process_Flow_Request__c.CCP_Applied__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenIdsPassedThenRequestsReturned() {
        Process_Flow_Request__c processFlowRequest = [SELECT Id FROM Process_Flow_Request__c LIMIT 1];
        List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectById(new Set<Id>{processFlowRequest.Id});
        System.assertEquals(1, result.size(), 'Should return 1 Process Flow Request');
    }

    @isTest
    private static void testWhenContractIdsPassedThenRequestsReturned() {
        Process_Flow_Request__c processFlowRequest = [SELECT Contract__c FROM Process_Flow_Request__c LIMIT 1];
        List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectByContractId(processFlowRequest.Contract__c);
        System.assertEquals(1, result.size(), 'Should return 1 Process Flow Request for the Contract');
    }

    @isTest
    private static void testWhenContractIdsPassedThenReturnOpenRequestsForCurrentUser() {
        Process_Flow_Request__c processFlowRequest = [SELECT Contract__c FROM Process_Flow_Request__c LIMIT 1];
        List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectOpenRequestsForContractAndUser(processFlowRequest.Contract__c);
        System.assertEquals(1, result.size(), 'Should return 1 Open Process Flow Request for the Contract and User');
    }

    @isTest
    private static void testWhenSelectOpenBrandAndBusinessRequestsForOpportunityAndUserThenReturnProcessFlow() {
        Process_Flow_Request__c processFlowRequests = [SELECT Opportunity__c FROM Process_Flow_Request__c  LIMIT 1];

        Id recordId = processFlowRequests.Opportunity__c;
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByName()
                                                                                    .get('Brand and Business Reference Flow')
                                                                                    .getRecordTypeId();

        Process_Flow_Request__c pfr = new Process_Flow_Request__c(
        RecordTypeId = brandAndBusinessFlowRecordTypeId,
        Opportunity__c = recordId

    	);

    insert pfr;
	Process_Flow_Request__c processFlowRequest = [SELECT Opportunity__c FROM Process_Flow_Request__c WHERE Id =:pfr.Id];
    List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectOpenBrandAndBusinessRequestsForOpportunityAndUser(processFlowRequest.Id);
    System.assertNotEquals(1, result.size(), 'Should return 1 Open Process Flow Request for the brandAndBusinessFlowRecordTypeId');

    }

    @isTest
    private static void testWhenSelectOpenBrandAndBusinessRequestsForContractAndUserThenReturnProcessFlow() {
        Process_Flow_Request__c processFlowRequests = [SELECT Contract__c FROM Process_Flow_Request__c  LIMIT 1];

        Id recordId = processFlowRequests.Contract__c;
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByName()
                                                                                    .get('Brand and Business Reference Flow')
                                                                                    .getRecordTypeId();

        Process_Flow_Request__c pfr = new Process_Flow_Request__c(
        RecordTypeId = brandAndBusinessFlowRecordTypeId,
        Contract__c = recordId

    	);

    insert pfr;
	Process_Flow_Request__c processFlowRequest = [SELECT Contract__c FROM Process_Flow_Request__c WHERE Id =:pfr.Id];
    List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectOpenBrandAndBusinessRequestsForContractAndUser(processFlowRequest.Id);
    System.assertNotEquals(1, result.size(), 'Should return 1 Open Process Flow Request for the brandAndBusinessFlowRecordTypeId');

    }
    @isTest
    private static void testWhenSelectBrandAndBusinessFlowByIdsThenReturnProcessFlows() {
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByName()
                                                                                        .get('Brand and Business Reference Flow')
                                                                                        .getRecordTypeId();

        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            RecordTypeId = brandAndBusinessFlowRecordTypeId

        );

        insert processFlowRequest;

        Process_Flow_Request__c queriedProcessFlowRequest = [SELECT Id FROM Process_Flow_Request__c WHERE Id = :processFlowRequest.Id];
        List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectBrandAndBusinessFlowByIds(new Set<Id>{queriedProcessFlowRequest.Id});
        System.assertEquals(1, result.size(), 'Should return 1 Open Process Flow Request');
    }

    @isTest
    private static void testWhenSelectBrandAndBusinessFlowByContractOrOpportunityIdsThenReturnProcessFlows() {
         Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByName()
                                                                                        .get('Brand and Business Reference Flow')
                                                                                        .getRecordTypeId();
        Process_Flow_Request__c processFlowRequests = [SELECT Contract__c FROM Process_Flow_Request__c  LIMIT 1];
        Id recordId = processFlowRequests.Contract__c;
        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            RecordTypeId = brandAndBusinessFlowRecordTypeId,
            Contract__c = recordId

        );

        insert processFlowRequest;

        Process_Flow_Request__c queriedProcessFlowRequest = [SELECT Id,Contract__c FROM Process_Flow_Request__c WHERE Id = :processFlowRequest.Id];
        List<Process_Flow_Request__c> result = ProcessFlowRequestsSelector.newInstance().selectBrandAndBusinessFlowByContractOrOpportunityIds(new List<Id>{queriedProcessFlowRequest.Contract__c});
        System.assertEquals(1, result.size(), 'Should return 1 Open Process Flow Request');
    }

}