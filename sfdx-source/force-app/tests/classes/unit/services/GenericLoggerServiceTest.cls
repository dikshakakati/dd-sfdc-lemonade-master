/**
 * @description This is the test class for GenericLoggerService
 * @author Shiva Pochamalla
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class GenericLoggerServiceTest {

    /**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    public static void testWhenLogIsCreatedThenPublished() {

        String serviceName = 'serviceName';
        String domainName = 'domainName';

        fflib_ApexMocks.ApexMocksException mockException;
        try{
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            Application.UnitOfWork.setMock(mockUow);
            
            IGenericLogEntry logEntry = GenericLoggerService.createGenericLog(serviceName,domainName,GenericLogEntry.SeverityLevel.LOW);
    	
            Test.startTest();
            
            GenericLoggerService.publish(logEntry);
            
            Test.stopTest();
    
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, mocks.times(1).description('Unit of work not committed'))).commitWork();
                
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, 'Error When Log Is Created Then Published');
    }
    
    /**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    public static void testWhenLogsAreCreatedThenPublished() {

        String serviceName = 'serviceName';
        String domainName = 'domainName';

        fflib_ApexMocks.ApexMocksException mockException;
        try{
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            Application.UnitOfWork.setMock(mockUow);
            
            IGenericLogEntry logEntry1 = GenericLoggerService.createGenericLog(serviceName,domainName,GenericLogEntry.SeverityLevel.LOW);
    	    IGenericLogEntry logEntry2 = GenericLoggerService.createGenericLog(serviceName,domainName,GenericLogEntry.SeverityLevel.HIGH);
            Test.startTest();
            
            GenericLoggerService.publish(new List<IGenericLogEntry>{logEntry1,logEntry2});
            
            Test.stopTest();
    
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, mocks.times(1).description('Unit of work not committed'))).commitWork();
                
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, 'Error When Log Is Created Then Published');
    }
}