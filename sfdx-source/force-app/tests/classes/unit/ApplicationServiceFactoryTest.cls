/**
 * @author Scott McClung
 * @date 2023-02-16
 * @description Unit tests for ApplicationServiceFactory class
 */
@IsTest( IsParallel=true )
private class ApplicationServiceFactoryTest {

    @IsTest
    private static void testWhenCallingServiceFactoryThenReturnRegisteredImplementationsAndMocks() {
        // Standard behaviour
        System.assert( SERVICE.newInstance( IAccountService.class ) instanceof AccountsServiceImpl, 'Expected a registered implementation of AccountServiceImpl' );

        // Mocking behaviour
        SERVICE.setMock( IAccountService.class, new AccountsServiceMock() );
        System.assert( SERVICE.newInstance( IAccountService.class ) instanceof AccountsServiceMock, 'Expected a registered mock implementation of AccountServiceImpl' );
    }

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory SERVICE =
        new ApplicationServiceFactory(
            new Map<Type, Type>{
                IAccountService.class => AccountsServiceImpl.class
            }
        );

    /**
     * @description Test implementation of service interface for Account
     */
    public interface IAccountService {}

    /**
     * @description Test implementation of service implementation class for Account
     */
    public class AccountsServiceImpl implements IAccountService {}

    /**
     * @description Stubbed service implementation class for Account
     */
    public class AccountsServiceMock implements IAccountService {}
}