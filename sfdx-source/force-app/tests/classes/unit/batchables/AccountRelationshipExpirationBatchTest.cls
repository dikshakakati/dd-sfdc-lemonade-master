/**
 * @author Deloitte
 * @date 19/05/2022
 * @description This is the test class for AccountRelationshipExpirationBatch class
 */
@isTest
public class AccountRelationshipExpirationBatchTest {
    private static final String RELATIONSHIP_STATUS_ACTIVE = 'Active';
    @IsTest
    static void testWhenAccountRelationshipsWithPastEndDateExistsThenAccountRelationshipStatusIsChangedToInactive() {
        //ARRANGE
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setFakeId()
            .toSObject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 2 - Batch')
            .setFakeId()
            .toSObject();

        Account_Relationship__c relationshipWithPastEndDate = (Account_Relationship__c) new Fake(
                Account_Relationship__c.class
            )
            .setField(Account_Relationship__c.Relationship_Type__c, 'Agency')
            .setField(Account_Relationship__c.Inverse_Relationship_Type__c, 'Agency')
            .setField(Account_Relationship__c.Relationship_Status__c, 'Active')
            .setField(Account_Relationship__c.End_Date__c, System.today().addDays(-1))
            .setField(Account_Relationship__c.Account__c, account1.Id)
            .setField(Account_Relationship__c.Related_Account__c, account2.Id)
            .setFakeId()
            .toSObject();

        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            relationshipWithPastEndDate
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        AccountRelationshipExpirationBatch batch = new AccountRelationshipExpirationBatch();
        batch.execute(null, relationshipRecords);

        //ASSERT
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
        System.assertEquals(
            'Inactive',
            relationshipRecords[0].Relationship_Status__c,
            'Status is not updated as expected'
        );
    }
}