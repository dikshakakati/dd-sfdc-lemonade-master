/**
 * @description Test class for ProvisioningEventsHandler
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class GenericLogEventsHandlerTest {

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenGenericLogEventPublishedThenGenericLogCreated() {

        List<Generic_Log_Event__e> genericLogEventsList = new List<Generic_Log_Event__e>{
            new Generic_Log_Event__e(
                Log_Details__c='{"sourceSystem":"DDMX"}'
            ),
        	new Generic_Log_Event__e(
                Log_Details__c='{"sourceSystem":"DDMX","message":{"logMessage":"Test Message"}}'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();

        EventBus.publish(genericLogEventsList);

        Test.stopTest();

        // then verify unitOfWork method calls
		((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
   			.registerNew(
     			fflib_Match.sObjectWith(
        			new Map<SObjectField, Object>{
                		Generic_Log__c.Log_Details__c => '{"sourceSystem":"DDMX"}'
                	}
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
   			.registerNew(
     			fflib_Match.sObjectWith(
        			new Map<SObjectField, Object>{
                		Generic_Log__c.Log_Details__c => '{"sourceSystem":"DDMX","message":{"logMessage":"Test Message"}}'
                	}
                )
            );
    }
}