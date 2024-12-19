/**
 * @description Test Class for ContractAssociatedAccounts Services
 * @author BizApps
 * @date 5-May-2023
 **/
@IsTest
private class ContractAssociatedAccountsServiceTest {
    @IsTest
    static void testWhenVariousSetsOfIdsAreUsedThenReturnBooleanIfBatchIsNeeded() {
        // Sets for testing
        Set<Id> smallSet = generateSetOfIds(75);
        Set<Id> mediumSet = generateSetOfIds(150);
        Set<Id> largeSet = generateSetOfIds(300);
        Set<Id> extraLargeSet = generateSetOfIds(8000);

        // Create a set with 175 unique IDs, then add 50 overlapping IDs to it
        Set<Id> overlappingMediumSet = generateSetOfIds(
            ContractAssociatedAccountsServiceImpl.AGREEMENT_BATCH_LIMIT - 25
        );

        for (Id thisId : mediumSet) {
            overlappingMediumSet.add(thisId);

            if (
                overlappingMediumSet.size() >=
                (ContractAssociatedAccountsServiceImpl.AGREEMENT_BATCH_LIMIT + 25)
            ) {
                break;
            }
        }

        Boolean emptyExistingListAndSmallNewListShouldBeFalse = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            smallSet
        );
        System.assert(
            !emptyExistingListAndSmallNewListShouldBeFalse,
            'This scenario contains 75 new IDs so should return false'
        );

        Boolean emptyExistingListAndLargeNewListShouldBeTrue = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            largeSet
        );
        System.assert(
            emptyExistingListAndLargeNewListShouldBeTrue,
            'This scenario contains 300 new IDs so should return true'
        );

        Boolean twoEmptyListsShouldBeFalse = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            new Set<Id>()
        );
        System.assert(
            !twoEmptyListsShouldBeFalse,
            'This scenario contains 0 new IDs so should return false'
        );

        Boolean twoBigListsShouldBeTrue = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            extraLargeSet
        );
        System.assert(
            twoBigListsShouldBeTrue,
            'This scenario contains 8300 new IDs so should return true'
        );

        Boolean overlappingMediumListsShouldBeFalse = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            overlappingMediumSet
        );
        System.assert(
            overlappingMediumListsShouldBeFalse,
            'This scenario contains 225 new IDs so should return true'
        );

        Boolean overlappingMediumListsShouldBeTrue = ContractAssociatedAccountsServiceImpl.getIsBatchAgreementCreationNeeded(
            overlappingMediumSet
        );
        System.assert(
            overlappingMediumListsShouldBeTrue,
            'This scenario contains 225 new IDs so should return true'
        );
    }

    @IsTest
    static void testWhenObjectListsArePassedToGetSublistThenReturnCorrectlySplitList() {
        List<Id> idsList = new List<Id>();
        for (Integer i = 0; i < 5000; i++) {
            idsList.add(Fake.generateId(Account.class));
        }

        List<Id> results = ContractAssociatedAccountsServiceImpl.getSublist(idsList, 0, 5000);
        System.assertEquals(
            5000,
            results.size(),
            'All 5000 items should be included in the return list.'
        );

        List<Id> subsetResults = ContractAssociatedAccountsServiceImpl.getSublist(
            idsList,
            1000,
            4000
        );
        System.assertEquals(
            3000,
            subsetResults.size(),
            '3000 items should be included in the return list.'
        );
    }

    private static void verifyNumberOfIdsInString(String idString, Integer numberExpected) {
        List<Id> allIds = idString.split(',');
        System.assertEquals(
            numberExpected,
            allIds.size(),
            'Unexpected number of Ids associated to record'
        );
    }

    private static Set<Id> generateSetOfIds(Integer numberOfIds) {
        Set<Id> setOfIds = new Set<Id>();
        for (Integer i = 0; i < numberOfIds; i++) {
            setOfIds.add(Fake.generateId(Account.class));
        }

        return setOfIds;
    }

    @IsTest
    static void testWhenInputtingContractIdThenReturnSetOfAssociatedAccountIdsFromChildRecords() {
        Contract testContract = (Contract) new Fake(Contract.class).setFakeId().toSObject();

        Set<Id> accountIdsForFirstContract1 = generateSetOfIds(
            ContractAssociatedAccountsServiceImpl.MAX_IDS_PER_RECORD
        );
        Set<Id> accountIdsForFirstContract2 = generateSetOfIds(100);

        Contract_Associated_Accounts__c association1 = (Contract_Associated_Accounts__c) new Fake(
                Contract_Associated_Accounts__c.class
            )
            .setField(Contract_Associated_Accounts__c.Contract__c, testContract.Id)
            .setField(Contract_Associated_Accounts__c.Order__c, 1)
            .setField(
                Contract_Associated_Accounts__c.Associated_Account_Ids__c,
                String.join(new List<Id>(accountIdsForFirstContract1), ',')
            )
            .setFakeId()
            .toSObject();
        Contract_Associated_Accounts__c association2 = (Contract_Associated_Accounts__c) new Fake(
                Contract_Associated_Accounts__c.class
            )
            .setField(Contract_Associated_Accounts__c.Contract__c, testContract.Id)
            .setField(Contract_Associated_Accounts__c.Order__c, 2)
            .setField(
                Contract_Associated_Accounts__c.Associated_Account_Ids__c,
                String.join(new List<Id>(accountIdsForFirstContract2), ',')
            )
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IContractAssociatedAccountsSelector caaSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(caaSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.when(caaSelectorMock.selectByContractId(testContract.Id))
            .thenReturn(new List<Contract_Associated_Accounts__c>{ association1, association2 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(caaSelectorMock);

        Test.startTest();
        Set<Id> resultSet = ContractAssociatedAccountsServiceImpl.getAssociatedAccountIdsForContract(
            testContract.Id
        );
        Test.stopTest();

        System.assertEquals(
            ContractAssociatedAccountsServiceImpl.MAX_IDS_PER_RECORD + 100,
            resultSet.size(),
            'All Associated IDs should be included in the return set'
        );
        System.assert(
            resultSet.containsAll(accountIdsForFirstContract1),
            'All the Account IDs from the first child record should be included in the result set'
        );
        System.assert(
            resultSet.containsAll(accountIdsForFirstContract2),
            'All the Account IDs from the second child record should be included in the result set'
        );
    }

    @IsTest
    static void testWhenGenerateContractAssociationsWithGroupForExistingAndNewStoresIsCalledThenCreateCaas() {
        ContractAssociatedAccountsServiceImpl service = new ContractAssociatedAccountsServiceImpl();
        Contract testContract = (Contract) new Fake(Contract.class).setFakeId().toSObject();
        Id quoteLineGroup1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);

        List<Id> allIdsToUse = new List<Id>(generateSetOfIds(1000));

        Set<Id> allIdsToUseSet = new Set<Id>(allIdsToUse);

        String accountIdsString1 = String.join(new List<Id>(allIdsToUseSet), ',');

        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id productId1 = fflib_IDGenerator.generate(Product2.SObjectType);

        SBQQ__Subscription__c mockSubscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productId1)
                    .setField(Product2.Name, 'Marketplace')
            )
            .toSObject();

        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id productId2 = fflib_IDGenerator.generate(Product2.SObjectType);
        SBQQ__Subscription__c mockSubscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Delivery')
            .setField(SBQQ__Subscription__c.Package__c, productId1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productId2)
                    .setField(Product2.Name, 'Delivery')
            )
            .toSObject();

        String productName = mockSubscription1.SBQQ__ProductName__c;
        Id productId = mockSubscription1.Id;
        String packageName = mockSubscription2.SBQQ__ProductName__c;
        Id packageId = mockSubscription2.Id;

        List<String> productDeselected = new List<String>{ productId };

        AssociatedAccountsWrapper.ProductSubId productSubWrap = new AssociatedAccountsWrapper.ProductSubId(
            productId,
            productName
        );
        List<AssociatedAccountsWrapper.ProductSubId> productSubIdList = new List<AssociatedAccountsWrapper.ProductSubId>{
            productSubWrap
        };
        AssociatedAccountsWrapper.SelectedPackage selectedWrapper = new AssociatedAccountsWrapper.SelectedPackage(
            packageId,
            packageName,
            productSubIdList
        );
        AssociatedAccountsWrapper.DeselectedPackage deselectedWrapper = new AssociatedAccountsWrapper.DeselectedPackage(
            packageId,
            productDeselected
        );

        List<AssociatedAccountsWrapper.SelectedPackage> selectedList = new List<AssociatedAccountsWrapper.SelectedPackage>();
        selectedList.add(selectedWrapper);
        List<AssociatedAccountsWrapper.DeselectedPackage> deselectedList = new List<AssociatedAccountsWrapper.DeselectedPackage>();
        deselectedList.add(deselectedWrapper);

        AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements selectedAndDeselectedEntitlements = new AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements(
            selectedList,
            deselectedList
        );

        List<AssociatedAccountsWrapper> associatedAccountsWrapperList = new List<AssociatedAccountsWrapper>();
        associatedAccountsWrapperList.add(
            new AssociatedAccountsWrapper(
                quoteLineGroup1,
                accountIdsString1,
                testContract.Id,
                true,
                selectedAndDeselectedEntitlements
            )
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        service.generateContractAssociationsWithGroupForExistingAndNewStores(
            associatedAccountsWrapperList, true, 'No'
        );

        System.assertEquals(
            1,
            service.associationsToUpsert.size(),
            'A single CAA should be inserted'
        );
        System.assert(
            service.associationsToUpsert[0].Batch_Process_Enabled__c,
            'The Batch flag should be set to true with the large number of new IDs.'
        );
        System.assertEquals(
            'Not Started',
            service.associationsToUpsert[0].Batch_Process_Status__c,
            'The Batch Status should be set from the IDs update.'
        );

        verifyNumberOfIdsInString(service.associationsToUpsert[0].Associated_Account_Ids__c, 1000);
    }
}