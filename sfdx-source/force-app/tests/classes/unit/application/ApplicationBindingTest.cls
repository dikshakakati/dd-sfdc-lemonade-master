/**
 * @description test class for ApplicationBinding
 * @author DoorDash
 * @date 2023-10-05
 */
@isTest(seeAllData=false)
public with sharing class ApplicationBindingTest {
 	private static final String DEVELOPER_NAME = 'Domain_Account';
    private static final String MASTER_LABEL = 'Domain Account';
    private static final String LABEL = 'Domain Account';
    private static final String APPLICATION_TYPE = 'Domain';
    private static final String BINDING_OBJECT = 'Account';
	private static final String BINDING_OBJECT_API_NAME = 'Account';
    private static final String IMPLEMENTATION_TYPE = 'Accounts.Constructor';
    private static final String INVALID_TYPE = 'InvalidType';
    private static final String INVALID_OBJECT = 'InvalidObject';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT= 'Unexpected result: The object type must be Application Binding Object.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_DEVELOPER_NAME = 'Unexpected result: There is a mismatch in developer name.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_APPLICATION_TYPE = 'Unexpected result: There is a mismatch in application type.';
	private static final String ASSERT_MESSAGE_MISMATCH_IN_BINDING_OBJECT = 'Unexpected result: There is a mismatch in binding object.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_ALL_EVENT_DATA = 'Unexpected result: There is a mismatch in all events data.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_IMPLEMENTATION_TYPE = 'Unexpected result: There is a mismatch in Implementation type.';

    /**
     * @description To test when application binding record passed then return application type.
     */
    @isTest
    private static void testWhenApplicationBindingRecordPassedThenBindingValuesReturned() {
        ApplicationBinding__mdt applicationMetaDataAccount = new ApplicationBinding__mdt(
            MasterLabel = MASTER_LABEL,
            DeveloperName = DEVELOPER_NAME,
            ApplicationType__c = APPLICATION_TYPE,
            BindingObject__c = BINDING_OBJECT,
            BindingObjectApiName__c = BINDING_OBJECT_API_NAME,
            ImplementationType__c = IMPLEMENTATION_TYPE
        );
        ApplicationBinding appBinding = new ApplicationBinding(applicationMetaDataAccount);
        System.assertNotEquals( null, appBinding, 'Applicatoin binding instance is null');
        System.assertEquals( ApplicationBindingType.DOMAIN, appBinding.getApplicationType(), ASSERT_MESSAGE_MISMATCH_IN_APPLICATION_TYPE );
        System.assertEquals( Schema.getGlobalDescribe().get(BINDING_OBJECT_API_NAME), appBinding.getBindingObject(), ASSERT_MESSAGE_MISMATCH_IN_BINDING_OBJECT );
        System.assertEquals( System.Type.forName( IMPLEMENTATION_TYPE ), appBinding.getImplementationType(), ASSERT_MESSAGE_MISMATCH_IN_IMPLEMENTATION_TYPE );
    }
     /**
     * @description To test when null values passed to the constructor return the null values.
     */
     @isTest
    static void testWhenNullPassedToTheConstructorThenReturnException() {
        try {
            new ApplicationBinding(null);
            System.assert(false, 'Expected DeveloperException was not thrown.');
        } catch(ApplicationBinding.DeveloperException e) {
            System.assert(e.getMessage().contains('ApplicationBinding constructor requires an instance of ApplicationBinding__mdt.'),
                'Expected exception not thrown when null passed to the constructor');
        }
    }
     /**
     * @description To test when application binsing record passed then return application type.
     */
    @isTest
    static void testWhenInvalidApplicationTypePassedThenExceptionReturned() {
        ApplicationBinding__mdt mockBinding = new ApplicationBinding__mdt(
            ApplicationType__c = INVALID_TYPE
        );
        try {
            new ApplicationBinding(mockBinding);
            System.assert(false, 'Expected DeveloperException was not thrown.');
        } catch(ApplicationBinding.DeveloperException e) {
            System.assert(e.getMessage().contains('Unable to identify binding type'),
                'Expected exception not thrown when invalid application type passed');
        }
    }
     /**
     * @description To test when application binsing record passed then return application type.
     */
     @isTest
    static void testWhenInvalidBindingObjectPassedThenReturnException() {
        ApplicationBinding__mdt mockBinding = new ApplicationBinding__mdt(
            ApplicationType__c = APPLICATION_TYPE,
            BindingObjectApiName__c = INVALID_OBJECT
        );
        try {
            new ApplicationBinding(mockBinding);
            System.assert(false, 'Expected DeveloperException was not thrown.');
        } catch(ApplicationBinding.DeveloperException e) {
            system.assert(e.getMessage().contains('Failed to find (S)Object'),
                         'Expected exception not thrown when invalid Object passed ');
        }
    }
     /**
     * @description To test when application binsing record passed then return application type.
     */
    @isTest
    static void testWhenInvalidBindingTypePassedThenReturnException() {
        ApplicationBinding__mdt mockBinding = new ApplicationBinding__mdt(
            ApplicationType__c = APPLICATION_TYPE,
            BindingObjectApiName__c = BINDING_OBJECT,
            BindingType__c = INVALID_TYPE
        );
        try {
            new ApplicationBinding(mockBinding);
            System.assert(false, 'Expected DeveloperException was not thrown.');
        } catch(ApplicationBinding.DeveloperException e) {
            System.assert(e.getMessage().contains('Unable to find')
                , 'Expected exception not thrown when invalid binding type passed');
        }
    }
     /**
     * @description To test when application binsing record passed then return application type.
     */
    @isTest
    static void testWhenInvalidImplementationTypePassedThenReturnException() {
        ApplicationBinding__mdt mockBinding = new ApplicationBinding__mdt(
            ApplicationType__c = APPLICATION_TYPE,
            BindingObjectApiName__c = BINDING_OBJECT,
            ImplementationType__c = INVALID_TYPE
        );
        try {
            new ApplicationBinding(mockBinding);
            System.assert(false, 'Expected DeveloperException was not thrown.');
        } catch(ApplicationBinding.DeveloperException e) {
            System.assert(e.getMessage().contains('Unable to find'),
            'Expected exception not thrown when invalid implementation type passed');
        }
    }
}