/**
 * @description Domain Class for Xref__c Object
 * @author Deloitte
 * @date 2023-04-18
 */
public inherited sharing class Xrefs extends SObjects implements IXrefs {

    @testvisible private static final String COO_PROCESS_VIA_BATCH = 'Process via Batch Mode';
    @testvisible private static final String COO_PROCESS_VIA_ASYNC = 'Process via Async Mode';
    private static final Integer ASYNC_GET_STORE_LIMIT = 50;
    private static final string SUCCESS_STRING = 'Success';
    private static final string UNKNOWN_STRING = 'Unknown';
    @testvisible private static final string INTEGRATION_TYPE = 'Xref Provisioning';

    /**
     * @description This method is used to return the IOrders interface
     * @param recordList - Xrefs record list
     * @return IXrefs - Returns IXrefs Interface
     */
    public static IXrefs newInstance( List<Xref__c> recordList ) {
        return (IXrefs) Application.Domain.newInstance( recordList );
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Xrefs( List<Xref__c> sObjectList ) {
        super( sObjectList, Schema.Xref__c.SObjectType );
    }

    /**
     * @description To Invoke COO process for these Xrefs LEM-5768
     */
    public void invokeCooProcess() {
        Map<Id, Xref__c> xrefsWithCooProcessAsAsyncMap = new Map<Id, Xref__c>(
            (List<Xref__c>) getRecordsByFieldValue(
                Xref__c.Coo_Process__c,
                COO_PROCESS_VIA_ASYNC
            )
        );

        Map<Id, Xref__c> xrefsWithCooProcessAsBatchMap = new Map<Id, Xref__c>(
            (List<Xref__c>) getRecordsByFieldValue(
                Xref__c.Coo_Process__c,
                COO_PROCESS_VIA_BATCH
            )
        );

        if( !xrefsWithCooProcessAsAsyncMap.isEmpty() ) {
            processCooViaAsync( xrefsWithCooProcessAsAsyncMap.keyset() );
        }

        if( !xrefsWithCooProcessAsBatchMap.isEmpty() ) {
            Database.executeBatch( new COOXrefsProcessingBatch(), ASYNC_GET_STORE_LIMIT );
        }
    }

    @future( callout=true )
    private static void processCooViaAsync( Set<Id> xrefIdSet ) {
        try {
            if( !xrefIdSet.isEmpty() && xrefIdSet.size() <= ASYNC_GET_STORE_LIMIT ) {
                ChangeOfOwnershipService.processCooXrefsMarkedForAsyncProcess( xrefIdSet );
            } else if( xrefIdSet.size() > ASYNC_GET_STORE_LIMIT ) {
                fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                for( Id xrefId : xrefIdSet ) {
                    Xref__c xrefToUpdate = new Xref__c( Id = xrefId, Coo_Process__c = COO_PROCESS_VIA_BATCH );
                    uow.registerDirty( xrefToUpdate );
                }
                commitWork( uow );
            }
        } catch( Exception ex ) {
            Logger.publish( LogEntry.newExceptionLog( ex, LogEntry.SeverityLevel.HIGH ) );
        }
    }

    /**
     * @description It validate and update Work Plan fields on Before Update trigger event.
     */
    public void updateIntegrationMessageAndProvisioningCategory() {
        for( Xref__c xref : (List<Xref__c>) getRecords() ) {
            if( xref.Provisioning_Error_Message__c == SUCCESS_STRING ) {
                xref.Integration_Message__c = SUCCESS_STRING;
                xref.Provisioning_Error_Category__c = '';
            } else if( String.isBlank( xref.Provisioning_Error_Message__c ) ) {
                xref.Integration_Message__c = xref.Provisioning_Error_Message__c;
                xref.Provisioning_Error_Category__c = '';
            } else {
                updateBusinessFriendlyErrorMessageAndCategory( xref );
            }
        }
    }

    private void updateBusinessFriendlyErrorMessageAndCategory( Xref__c xref ) {
        Business_Friendly_Mapping__mdt businessFriendlyMessageDetails = GetBusinessFriendlyMessageService.getMessageDetails( xref.Provisioning_Error_Message__c, INTEGRATION_TYPE );
        if( businessFriendlyMessageDetails == null ) {
            xref.Provisioning_Error_Category__c = UNKNOWN_STRING;
            xref.Integration_Message__c = xref.Provisioning_Error_Message__c;
        } else {
            xref.Provisioning_Error_Category__c = businessFriendlyMessageDetails.Message_Category__c;
            xref.Integration_Message__c = businessFriendlyMessageDetails.Business_Friendly_Message__c;
        }
    }
    /**
     * @description It is used to invoke the calling of method
     * which is used to set Brand on Business References.
     * @JIRA# LEM-16030
     * @param accountIdsWithXref
     */
    //Adding this to future context to resolve SOQL 101 error.
    @future
    public static void invokeBrandOnBusinessReferencesByXrefs( Set<Id> accountIdsWithXref ) {
        Map<Id, Id> businessRefToBrandId = new Map<Id, Id>();
        for(
            Xref__c eachXref : XrefsSelector.newInstance().selectByAccountIds( accountIdsWithXref )
        ) {
            if( eachXref.Business_Reference__r.Brand__c == null ) {
                businessRefToBrandId.put(
                    eachXref.Business_Reference__c,
                    eachXref.Salesforce_Account_Name__r.Brand__c
                );
            }
        }
        if( !( businessRefToBrandId.keySet().isEmpty() ) ) {
            BusinessReferences.setBrandOnBusinessReference( businessRefToBrandId );
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork( fflib_ISObjectUnitOfWork unitOfWork ) {
        try {
            unitOfWork.commitWork();
        } catch( Exception unitOfWorkException ) {
            Logger.publish(
                LogEntry.newExceptionLog( unitOfWorkException, LogEntry.SeverityLevel.HIGH )
            );
        }
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock( fflib_IDomainConstructor mock ) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return xrefs - List of xrefs
         */
        public fflib_SObjects construct( List<Object> objectList ) {
            if( Xrefs.constructorMock != null ) {
                return (fflib_SObjects) Xrefs.constructorMock.construct( objectList );
            }
            return new Xrefs( (List<SObject>) objectList );
        }
    }
}