/**
 * @author Deloitte
 * @date 03/24/2023
 * @description Test class for Contract Brand Associations selector.
 */
@isTest(SeeAllData=false)
private class ContractBrandAssociationsSelectorTest {
    /**
     * @description This method used to test Contract Brand Associations selector class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ContractBrandAssociationsSelector selector = new ContractBrandAssociationsSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Contract_Brand_Association__c.Id,
                Contract_Brand_Association__c.Brand__c,
                Contract_Brand_Association__c.Brand_Id__c,
                Contract_Brand_Association__c.Contract__c,
                Contract_Brand_Association__c.Status__c
            },
            fieldList,
            'Mismatch in field list.'
        );
        System.assertEquals(
            Schema.Contract_Brand_Association__c.SObjectType,
            typeOfObj,
            'The object type must be Contract Brand Association.'
        );
    }

    /**
     * @description It is used to test if Contract Brand Associations are fetched when the record
     * Ids are passed.
     */
    @isTest
    private static void testWhenAssociationIdsArePassedThenContractBrandAssociationsAreFetched() {
        Account parentAccount = new Account(Name = 'Test Parent Account', Segment__c = 'Enterprise');
        insert parentAccount;
        List<Contract> childContracts = new List<Contract>{
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            ),
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            )
        };
        insert childContracts;

        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = 'Enterprise'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;

        Contract_Brand_Association__c association = new Contract_Brand_Association__c(
            Contract__c = childContracts[0].Id,
            Brand__c = brandKFC.Id,
            Status__c = 'Active'
        );
        insert association;

        List<Contract_Brand_Association__c> associationById = ContractBrandAssociationsSelector.newInstance()
            .selectById(new Set<Id>{ association.Id });
        List<Contract_Brand_Association__c> associationByContract = ContractBrandAssociationsSelector.newInstance()
            .selectByContracts(new Set<String>{ childContracts[0].Id });

        System.assertEquals(
            1,
            associationById.size(),
            'The Contract Brand Association was not appropritely fetched.'
        );
        System.assertEquals(
            1,
            associationByContract.size(),
            'The Contract Brand Association was not appropritely fetched.'
        );
    }

     /**
     * @description It is used to test if Contract Brand Associations are fetched when the record
     * Ids are passed.
     */
    @isTest
    private static void testWhenAssociationIdsAndContaractIdArePassedThenContractBrandAssociationsAreFetched() {
       Account parentAccount = new Account(Name = 'Test Parent Account', Segment__c = 'Enterprise');
        insert parentAccount;
        List<Contract> childContracts = new List<Contract>{
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            ),
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            )
        };
        insert childContracts;

        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = 'Enterprise'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;

        Contract_Brand_Association__c association = new Contract_Brand_Association__c(
            Contract__c = childContracts[0].Id,
            Brand__c = brandKFC.Id,
            Status__c = 'Active'
        );
        insert association;


      /*  List<Contract_Brand_Association__c> associationById = ContractBrandAssociationsSelector.newInstance()
            .selectById(new Set<Id>{ association.Id });
        List<Contract_Brand_Association__c> associationByContract = ContractBrandAssociationsSelector.newInstance()
            .selectByContractAndBrandAsscs(childContracts[0].Id, new Set<Id>{brandKFC.Id});*/


        ContractBrandAssociationsSelector relationshipSelectorInstance = new ContractBrandAssociationsSelector();
        Test.startTest();
        List<Contract_Brand_Association__c> contractBrandAssociationInstance = relationshipSelectorInstance.selectByContractAndBrandAsscs(
          childContracts[0].Id, new Set<Id>{brandKFC.Id}
        );

        Test.stopTest();

        System.assertEquals(
            1,
            contractBrandAssociationInstance.size(),
            'The Contract Brand Association was not appropritely fetched.'
        );
    }

}