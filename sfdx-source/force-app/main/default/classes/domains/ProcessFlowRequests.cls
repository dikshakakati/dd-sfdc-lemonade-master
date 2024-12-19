/**
 * @description       : Domain Class for Process_Flow_Request Object
 * @author            : rishab.goyal
 * @group             :
 * @last modified on  : 04-09-2024
 * @last modified by  : Gaurav
**/
public inherited sharing class ProcessFlowRequests extends fflib_SObjects implements IProcessFlowRequests {

    private static final String BRAND_AND_BUSINESS_NOTIFICATION_SUBJECT = ' New Business Id(s) have been successfully created!';
    private static final String ORG_WIDE_ADDRESS_CREATE_BRAND_NOTIFICATION = System.label.Brand_and_Business_Flow_Email_Notification_OWA ;
    private static final String CUSTOM_NOTIFICATION_CREATE_BRAND_NOTIFICATION = 'Create_Brand_Notification';
    private static final String LOG_SEND_NOTIFICATION_ERROR = 'Send Notification on External Id Created on Brand and Business Reference Flow';
    private static final String LOG_DOMAIN = 'Sales';

    /**
 	 * @description This method is used to return the IProcessFlowRequests interface
	 * @param recordList - Process_Flow_Request__c record list
	 * @return IProcessFlowRequests - Returns IProcessFlowRequests Interface
 	 */
	public static IProcessFlowRequests newInstance(List<Process_Flow_Request__c> recordList) {
		return (IProcessFlowRequests) Application.Domain.newInstance(recordList);
	}

	/**
 	 * @description Default constructor for the class
	 * @param sObjectList
 	 */
	public ProcessFlowRequests(List<Process_Flow_Request__c> sObjectList) {
		super(sObjectList, Schema.Process_Flow_Request__c.SObjectType);
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
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
 	 * @description This class is used for implementing fflib_IDomainConstructor Interface
 	 */
    public class Constructor implements fflib_IDomainConstructor {
		/**
 		 * @description Constructor method implementation from fflib_IDomainConstructor class
		 * @param objectList
 		 * @return ProcessFlowRequests - List of ProcessFlowRequests
		 */
        public fflib_SObjects construct( List<Object> objectList ) {
            if(ProcessFlowRequests.constructorMock != null) {
                return (fflib_SObjects) ProcessFlowRequests.constructorMock.construct(objectList);
            }
            return new ProcessFlowRequests( (List<SObject>) objectList );
        }
    }


    /** @description if an Process FLow Request Stage is Update to External Ids then send the email using Notifcation Service.
     *
    */
    public void sendNotifcationsForProcessFlowRequestWithExternalIdsCreated() {
    // Add implementation here
        Set<Id> processFlowRequestIds = new Set<Id>();
        for (Process_Flow_Request__c processFlowRequest : (List<Process_Flow_Request__c>) getRecords()) {
            processFlowRequestIds.add(processFlowRequest.Id);
        }
        if(processFlowRequestIds.isEmpty()){
            return;
        }
        sendNotificationForProcessFlowRequestWithExternalIdsCreated(processFlowRequestIds);
    }

    /**
    * @description method to send Emaik and Bell Notification for Process Flow Request with External Ids Created
    * @author rishab.goyal | 03-20-2024
    * @param processFlowRequestIds
    **/
    public static void sendNotificationForProcessFlowRequestWithExternalIdsCreated(Set<Id> processFlowRequestIds) {
        CustomNotificationType notificationType = getCreateBrandNotification(CUSTOM_NOTIFICATION_CREATE_BRAND_NOTIFICATION);
        if(notificationType==null){
            return;
        }
        Id customNotificationTypeId = notificationType.Id;

        OrgWideEmailAddress owea = getOrgWideEmailAddressforEmailNotification(ORG_WIDE_ADDRESS_CREATE_BRAND_NOTIFICATION);

        List<Process_Flow_Request__c> processFlowRequests = ProcessFlowRequestsSelector.newInstance().selectBrandAndBusinessFlowByIds(processFlowRequestIds);

        List<String> tableRows = new List<String>();

        Set<Id> businessReferenceIds = new Set<Id>();
        for(Process_Flow_Request__c processFlowRequest : processFlowRequests) {
            businessReferenceIds.addAll(BusinessReferences.getAllBzRefsFromSerializedData(processFlowRequest.Serialized_Object_Data__c));
        }

        Map<Id,Business_Reference__c> businessReferencesMap = new Map<Id,Business_Reference__c>(BusinessReferencesSelector.newInstance().selectByIds(businessReferenceIds));


        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Process_Flow_Request__c processFlowRequest : processFlowRequests) {

            Set<Id> bRefsforProcessFlowRequest = BusinessReferences.getAllBzRefsFromSerializedData(processFlowRequest.Serialized_Object_Data__c);
            if(bRefsforProcessFlowRequest.isEmpty()) {
                continue;
            }
            List<String> businessIds = new List<String>();
            for (Id businessReferenceId : bRefsforProcessFlowRequest) {

                Business_Reference__c businessReference = businessReferencesMap.get(businessReferenceId);
                businessIds.add(businessReference.External_Id__c);
                String brandUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + businessReference.Brand__c;
                String businessUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + businessReference.Id;

                String row = '<tr><td style="border:1px solid black;"><a href="' + brandUrl + '">' + businessReference.Brand__r.Name + '</a></td><td style="border:1px solid black;"><a href="' + businessUrl + '">' + businessReference.External_Id__c + '</a></td></tr>';
                tableRows.add(row);
            }

            String userName = processFlowRequest.CreatedBy.FirstName == NULL ? processFlowRequest.CreatedBy.Name : processFlowRequest.CreatedBy.FirstName;
            emails.add(constructSingleEmail(userName,processFlowRequest.CreatedBy.Email,tableRows,owea));

            String notificationBody = 'The following Business IDs have been created: ' + String.join(businessIds, ', ');

            Set<String> recipientsIds = new Set<String>();
            recipientsIds.add(processFlowRequest.CreatedBy.Id);
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(BRAND_AND_BUSINESS_NOTIFICATION_SUBJECT);
            notification.setBody(notificationBody);
            notification.setNotificationTypeId(customNotificationTypeId);
            notification.setTargetId(processFlowRequest.Opportunity__c!=null?processFlowRequest.Opportunity__c:processFlowRequest.Contract__c);
			sendNotification(notification,recipientsIds);
        }
       sendEmailNotifications(emails);

    }

    @testVisible
    private static void sendEmailNotifications(List<Messaging.SingleEmailMessage> emails){
         try {
            Messaging.sendEmail(emails);
        }
        catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SEND_NOTIFICATION_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    @testVisible
    private static void sendNotification(Messaging.CustomNotification notification,Set<String> recipientsIds){
        try {
            notification.send(recipientsIds);
        }
        catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SEND_NOTIFICATION_ERROR,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
                .logException(ex)
            );
        }
    }

    /**
     * @description Returns the CustomNotificationType used in Brand and Business Reference Flow
     * @return CustomNotificationType
     * @param customNotificationName
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @testVisible
    private static CustomNotificationType getCreateBrandNotification(String customNotificationName) {
        CustomNotificationType notificationType;
        try {
            notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = :customNotificationName];
        } catch(Exception ex) {
            notificationType = null;
        }
        return notificationType;
    }

    /**
     * @description Returns the OrgWideEmailAddress used in Brand and Business Reference Flow to send email
     * @return OrgWideEmailAddress
     * @param address
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @testVisible
    private static OrgWideEmailAddress getOrgWideEmailAddressforEmailNotification(String address) {
        OrgWideEmailAddress owea;
        try {
            owea = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address = :address Limit 1];
        } catch(Exception ex) {
            owea = null;
        }
        return owea;
    }

    /**
    * @description Method to construct Email body for Process Flow Notification of Brand and Business
    * @author rishab.goyal | 03-20-2024
    * @param recipientName
    * @param tableRows
    * @return String
    **/
    @TestVisible
    private static String constructEmailBodyforProcessFlowNotification(String recipientName, List<String> tableRows){
        String emailBody = 'Hello&nbsp;<b>'+recipientName+'</b>,<br/><br/>';
        emailBody += 'The following Business Ids have been successfully created:<br/><br/>';
        emailBody += '<table style="border:1px solid black; border-collapse: collapse; width: 60%;">';
        emailBody += '<tr><th style="border:1px solid black; text-align: left;">Brand Name</th><th style="border:1px solid black; text-align: left;">Business Id</th></tr>';
        for (String row : tableRows) {
            emailBody += row;
        }
        emailBody += '</table><br/><br/>';
        emailBody += 'Thank you,<br/> DDMx Salesforce Team';
        return emailBody;

    }

    /**
    * @description method to construct Single Email for Process Flow Notification of Brand and Business
    * @author rishab.goyal | 03-20-2024
    * @param recipientName
    * @param recipientEmail
    * @param tableRows
    * @param owea
    * @return Messaging.SingleEmailMessage
    **/
    @TestVisible
    private static Messaging.SingleEmailMessage constructSingleEmail(String recipientName,String recipientEmail, List<String> tableRows,OrgWideEmailAddress owea){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ recipientEmail });
        email.setSubject(BRAND_AND_BUSINESS_NOTIFICATION_SUBJECT);
        email.setHtmlBody(constructEmailBodyforProcessFlowNotification(recipientName,tableRows));
        if (owea!=null ) {
            email.setOrgWideEmailAddressId(owea.Id);
        }
        return email;
    }

}