/**
 * @author Scott McClung
 * @date 2023-02-16
 * @description Unit tests for ApplicationDomainFactory class
 */
@IsTest( IsParallel=true )
private class ApplicationDomainFactoryTest {

    @IsTest
    private static void testWhenCallingDomainFactoryThenReturnRegisteredImplementationsAndMocks() {
        // Standard behavior
        fflib_IDomain domainObjectAcct = DOMAIN.newInstance( new Account[]{ (Account) new Fake( Account.class ).setFakeId().toSObject() } );
        System.assert( domainObjectAcct instanceof AccountsDomain, 'Expected a registered implementation of AccountsDomain' );

        // Mocking behavior
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();
        fflib_ISObjectDomain domainMock = new fflib_SObjectMocks.SObjectDomain( mocks );
        mocks.when( domainMock.sObjectType() ).thenReturn( Account.SObjectType );
        mocks.stopStubbing();
        DOMAIN.setMock( domainMock );

        domainObjectAcct = DOMAIN.newInstance( new Account[]{ (Account) new Fake( Account.class ).setFakeId().toSObject() } );

        System.assert( domainObjectAcct instanceof fflib_SObjectMocks.SObjectDomain, 'Expected a registered mock implementation of AccountsDomain' );
    }

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory DOMAIN =
        new ApplicationDomainFactory(
            ApplicationDomainFactoryTest.SELECTOR,
            new Map<SObjectType, Type>{
                Account.SObjectType => AccountsConstructor.class
            }
        );
    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory DOMAINTWO =
        new ApplicationDomainFactory(
            ApplicationDomainFactoryTest.SELECTOR,
            new Map<Object, Type>{
               new Account() => AccountsConstructor.class
            }
        );

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory SELECTOR =
        new ApplicationSelectorFactory(
            new Map<SObjectType, Type>{
                Account.SObjectType => AccountsSelector.class
            }
        );

    /**
     * @description Test implementation of domain class for Account
     */
    public class AccountsDomain extends fflib_SObjectDomain {

        /**
         * @description Account domain class
         * @param sObjectList - List of Accounts
         */
        public AccountsDomain( List<Account> sObjectList ) {
            super( sObjectList );
        }

        /**
         * @description Account domain class
         * @param sObjectList - List of Accounts
         * @param sObjectType - Account.SObjectType
         */
        public AccountsDomain( List<SObject> sObjectList, SObjectType sObjectType ) {
            super( sObjectList, sObjectType );
        }
    }

    /**
     * @description Test implementation of domain constructor class for Account
     */
    public class AccountsConstructor implements fflib_SObjectDomain.IConstructable2 {

        /**
         * @description Constructor for Account domain class
         * @param sObjectList - List of Accounts
         * @return - Account domain class
         */
        public fflib_SObjectDomain construct( List<SObject> sObjectList ) {
            return new AccountsDomain( sObjectList );
        }

        /**
         * @description Domain constructor
         * @param sObjectList - List of SObjects
         * @param sObjectType - SObjectType of the records included in the list
         * @return - Account domain class
         */
        public fflib_SObjectDomain construct( List<SObject> sObjectList, SObjectType sObjectType ) {
            return new AccountsDomain( sObjectList, sObjectType );
        }
    }

}