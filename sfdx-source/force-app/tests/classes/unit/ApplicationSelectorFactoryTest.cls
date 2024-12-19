/**
 * @author Scott McClung
 * @date 2023-02-16
 * @description Unit tests for ApplicationSelectorFactory class
 */
@IsTest( IsParallel=true )
private class ApplicationSelectorFactoryTest {

    @IsTest
    private static void testWhenCallingSelectorFactoryThenReturnRegisteredImplementationsAndMocks() {
        // Standard behaviour
        System.assert( SELECTOR.newInstance( Account.SObjectType ) instanceof AccountsSelector, 'Expected a registered implementation of AccountSelector' );

        // Mocking behavior
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectSelector selectorMock = new fflib_SObjectMocks.SObjectSelector( mocks );
        List<Account> accounts = new List<Account>{
            (Account) new Fake( Account.class ).setFakeId().toSObject()
        };
        Set<Id> accountIds = new Map<Id, Account>( accounts ).keySet();

        mocks.startStubbing();
        mocks.when( selectorMock.sObjectType() ).thenReturn( Account.SObjectType );
        mocks.when( selectorMock.selectSObjectsById( accountIds ) ).thenReturn( accounts );
        mocks.stopStubbing();
        SELECTOR.setMock( selectorMock );

        System.assert( SELECTOR.newInstance( Account.SObjectType ) instanceof fflib_SObjectMocks.SObjectSelector, 'Expected a registered mock implementation of AccountSelector' );
    }

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory SELECTOR =
        new ApplicationSelectorFactory(
            new Map<SObjectType, Type>{
                Account.SObjectType => AccountsSelector.class
            }
        );

    /**
     * @description Test implementation of selector class for Account
     */
    public class AccountsSelector extends fflib_SObjectSelector {

        /**
         * @description Returns the list of fields to include in the query
         * @return - List of SObjectField
         */
        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField>{
                Account.Id,
                Account.Name
            };
        }

        /**
         * @description Returns the SObject type
         * @return - Account.SObjectType
         */
        public Schema.SObjectType getSObjectType() {
            return Account.SObjectType;
        }
    }
}