/**
 * @author Shiva Pochamalla
 * @description This is the test class for GenericLoggerImpl
 */
@isTest
private class GenericLoggerImplTest {
    /**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    public static void testWhenLogIsCreatedThenPublished() {

        String serviceName = 'serviceName';
        String domainName = 'domainName';
        IGenericLogEntry logEntry = new GenericLogEntry(serviceName,domainName,GenericLogEntry.SeverityLevel.LOW);

        fflib_ApexMocks.ApexMocksException mockException;
        try{
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            Application.UnitOfWork.setMock(mockUow);
    
            GenericLoggerImpl logImpl = new GenericLoggerImpl();
            logImpl.publish(logEntry);
    
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, mocks.times(1).description('Unit of work not committed'))).commitWork();
                
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, 'Error When Log Is Created Then Published');
    }
}