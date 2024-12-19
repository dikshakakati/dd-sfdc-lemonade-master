/**
 * @author Scott McClung
 * @date 2023-02-16
 * @description Unit tests for ApplicationUnitOfWorkFactory class
 */
@IsTest( IsParallel=true )
private class ApplicationUnitOfWorkFactoryTest {

    @IsTest
    private static void testWhenCallingUnitOfWorkFactoryThenReturnRegisteredImplementationsAndMocks() {
        // Standard behaviour
        System.assert( UNITOFWORK.newInstance() instanceof fflib_SObjectUnitOfWork, 'Expected a registered implementation of fflib_SObjectUnitOfWork' );

        // Mocking behaviour
        UNITOFWORK.setMock( new fflib_SObjectMocks.SObjectUnitOfWork( new fflib_ApexMocks() ) );
        System.assert( UNITOFWORK.newInstance() instanceof fflib_SObjectMocks.SObjectUnitOfWork, 'Expected a registered mock implementation of fflib_SObjectUnitOfWork' );
    }

    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UNITOFWORK =
        new ApplicationUnitOfWorkFactory(
            new List<SObjectType>{
                Account.SObjectType
            }
        );
}