/**
 * @author Shiva Pochamalla
 * @description This is the test class for InboundIngestionLoggerService
 */
@isTest
public class InboundIngestionLoggerServiceTest {
	/**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    private static void testWhenLogIsCreatedforSuccessThenVerifySuccess() {

        test.startTest();
        IInboundIngestionLoggerEntry le = InboundIngestionLoggerService.createInboundIngestionLog('IngestionLog', 'Sales', '1232323', '23424', '342343');
        InboundIngestionLoggerService.logSuccess(le, 'testing success');
        test.stopTest();
        Generic_Log__c gl = [select id,log_details__c from generic_log__c limit 1];
        System.assert(gl.log_details__c.contains('testing success'),'success');
    }

    /**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    private static void testWhenLogIsCreatedforExceptionThenVerifyException() {

        test.startTest();
        try{
            throw new IllegalArgumentException('Any exception related text');
        }catch(exception e){


            IInboundIngestionLoggerEntry le = InboundIngestionLoggerService.createInboundIngestionLog('IngestionLog', 'Sales', '1232323', '23424', '342343');
            InboundIngestionLoggerService.logException(le, e,'business error message','',new set<String>{},'Exception');
        }
        test.stopTest();
        Generic_Log__c gl = [select id,log_details__c from generic_log__c limit 1];
        System.assert(gl.log_details__c.contains('exception'),'exception');
    }

    /**
     * @description Test When Log Is Created And Published
     */
    @IsTest
    private static void testWhenGovernorLimitsExceededThenVerifyLimits() {

        test.startTest();

            IInboundIngestionLoggerEntry le = InboundIngestionLoggerService.createInboundIngestionLog('IngestionLog', 'Sales', '1232323', '23424', '342343');
            String govLimitsException = InboundIngestionLoggerService.errorOnGovtLimitsExceeded();
            govLimitsException = 'Salesforce Governor Limit - DML limit is exceeded';
            InboundIngestionLoggerService.logGovLimitsException(le, GovLimitsException, '', 'InboundIngestionLoggerServiceTest', 'testWhenGovernorLimitsExceeded');


        test.stopTest();
        Generic_Log__c gl = [select id,log_details__c from generic_log__c limit 1];
        System.assert(gl.log_details__c.contains('Salesforce Governor Limit'),'Gov Limits');
    }


}