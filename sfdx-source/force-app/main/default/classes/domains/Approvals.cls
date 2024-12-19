/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Domain class for sbaa__Approval__c object.
 */
public inherited sharing class Approvals extends fflib_SObjects implements IApprovals {
    private static final String APPROVAL_STATUS_APPROVED = 'Approved';
    private static final String APPROVAL_STATUS_REJECTED = 'Rejected';
    private static final String APPROVAL_STATUS_REQUESTED = 'Requested';
    private static final String APPROVED_NOTIFICATION_STATUS = 'This approval request has been already Approved by ';
    private static final String API_ENDPOINT =
        URL.getOrgDomainURL().toExternalForm() + '/services/apexrest/sbaa/ServiceRouter';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String HTTP_AUTHORIZATION = 'Authorization';
    private static final String HTTP_BEARER = 'Bearer ';
    private static final String HTTP_HEADER_CONTENT_TYPE = 'application/json;charset=UTF-8';
    private static final String HTTP_POST = 'POST';
    private static final String IDENTIFIER_REPLACE_ID = 'replaceId';
    private static final String IDENTIFIER_REPLACE_SAVER = 'replaceSaver';
    private static final String IDENTIFIER_REPLACE_COMMENTS = 'replaceComments';
    private static final String INVALID_APPROVAL_UPDATE_BY = ' by ';
    private static final String REQUEST_JSON_BODY = '{"model":"{\\"approvalId\\":\\"replaceId\\", \\"comments\\":\\"replaceComments\\"}","saver":"SBAA.ApprovalRestApiProvider.replaceSaver"}';
    private static final String REJECTED_NOTIFICATION_STATUS = 'This approval request has been already Rejected by ';
    private static final String SAVER_APPROVE = 'Approve';
    private static final String SAVER_REJECT = 'Reject';

    /**
     * @description It is used to return the IApprovals interface.
     * @param approvals
     * @return IApprovals
     */
    public static IApprovals newInstance(List<sbaa__Approval__c> approvals) {
        return (IApprovals) Application.Domain.newInstance(approvals);
    }

    /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public Approvals(List<sbaa__Approval__c> sObjects) {
        super(sObjects, Schema.sbaa__Approval__c.SObjectType);
    }

    /**
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
     * @description It is used for implementing fflib_IDomainConstructor Interface.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objects
         * @return sbaa__Approval__c
         */
        public fflib_ISObjects construct(List<Object> objects) {
            return new Approvals((List<sbaa__Approval__c>) objects);
        }
    }

    /**
     * @description It is used to initiate the Advanced Approvals Approve/Reject REST API on
     * update of a custom field 'Approval Status' from Slack notification.
     * @JIRA# LEM-13987
     * @param changedApprovals
     */
    public void initiateAdvancedApprovalsAPI(List<sbaa__Approval__c> changedApprovals) {
        List<Id> approvalIds = new List<Id>();
        Map<Id, String> approvalStatusById = new Map<Id, String>();
        Map<Id, String> approvalCommentsById = new Map<Id, String>();
        String requestBody;
        for (sbaa__Approval__c eachChangedApproval : changedApprovals) {
            checkApprovalUpdateEligibility(eachChangedApproval); //It is called from after update due to the conflicts with CPQ API that updates the comments first and then the status.
            approvalStatusById.put(eachChangedApproval.Id, eachChangedApproval.Approval_Status__c);
            approvalCommentsById.put(
                eachChangedApproval.Id,
                eachChangedApproval.sbaa__CommentsLong__c
            );
            approvalIds.add(eachChangedApproval.Id);
        }
        if (approvalIds.isEmpty()) {
            return;
        }
        for (Id eachId : approvalIds) {
            requestBody = (REQUEST_JSON_BODY).replace(IDENTIFIER_REPLACE_ID, eachId);
            requestBody = approvalCommentsById.get(eachId) == null
                ? (requestBody).replace(IDENTIFIER_REPLACE_COMMENTS, '')
                : (requestBody)
                      .replace(IDENTIFIER_REPLACE_COMMENTS, approvalCommentsById.get(eachId));
            if (approvalStatusById.get(eachId) == APPROVAL_STATUS_APPROVED) {
                requestBody = (requestBody).replace(IDENTIFIER_REPLACE_SAVER, SAVER_APPROVE);
            } else if (approvalStatusById.get(eachId) == APPROVAL_STATUS_REJECTED) {
                requestBody = (requestBody).replace(IDENTIFIER_REPLACE_SAVER, SAVER_REJECT);
            } else {
                return;
            }
            invokeAdvancedApprovalsRESTAPI(requestBody);
        }
    }

    /**
     * @description It is used to stamp the existing values on the fields 'Approval Status' and
     * 'Record Field' even though the value is changed by user in the Slack notification.
     * @JIRA #13987
     * @param existingApprovals
     */
    public void updateApprovalFieldsWithExistingValues(Map<Id, SObject> existingApprovals) {
        Map<Id, sbaa__Approval__c> existingApprovalsById = (Map<Id, sbaa__Approval__c>) existingApprovals;
        for (sbaa__Approval__c eachChangedApproval : (List<sbaa__Approval__c>) getRecords()) {
            eachChangedApproval.sbaa__ApprovalStep__c = existingApprovalsById.get(
                    (eachChangedApproval.Id)
                )
                .sbaa__ApprovalStep__c;
            eachChangedApproval.sbaa__RecordField__c = existingApprovalsById.get(
                    (eachChangedApproval.Id)
                )
                .sbaa__RecordField__c;
        }
    }

    /**
     * @description It is used to invoke the Advanced Approvals REST API.
     * TODO Make use of 'Named Credentials' for Header Authorization.
     * @JIRA #LEM-13987
     * @param requestBody
     */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    @future(callout=true)
    private static void invokeAdvancedApprovalsRESTAPI(String requestBody) {
        HttpResponse response = new HttpResponse();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(API_ENDPOINT);
            request.setMethod(HTTP_POST);
            request.setHeader(CONTENT_TYPE, HTTP_HEADER_CONTENT_TYPE);
            request.setHeader(HTTP_AUTHORIZATION, HTTP_BEARER + UserInfo.getSessionID());
            request.setBody(requestBody);
            response = http.send(request);
        } catch (Exception apiException) {
            Logger.publish(LogEntry.newExceptionLog(apiException, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to check whether the inputs given by the user in Slack Notification
     * is valid or not and throw an error message with the corresponding details.
     * @JIRA #LEM-13987
     * @param eachChangedApproval
     */
    private static void checkApprovalUpdateEligibility(sbaa__Approval__c eachChangedApproval) {
        if (
            eachChangedApproval.sbaa__Status__c != APPROVAL_STATUS_REQUESTED &&
            eachChangedApproval.Approval_Status__c != null &&
            eachChangedApproval.sbaa__ApprovedBy__c != null
        ) {
            eachChangedApproval.addError(
                APPROVED_NOTIFICATION_STATUS + eachChangedApproval.Approved_By_Name__c
            );
        } else if (
            eachChangedApproval.sbaa__Status__c != APPROVAL_STATUS_REQUESTED &&
            eachChangedApproval.Approval_Status__c != null &&
            eachChangedApproval.sbaa__RejectedBy__c != null
        ) {
            eachChangedApproval.addError(
                REJECTED_NOTIFICATION_STATUS + eachChangedApproval.Rejected_By_Name__c
            );
        }
    }

    /**
     * @description It is used to stamp the Requesting Reason field value from Quote to it's related requested Approvals.
     * @JIRA #LEM-15260
     */
    public void updateRequestedReasonFromQuote() {
        Set<Id> quoteIds = new Set<Id>();
        for (sbaa__Approval__c eachApproval : (List<sbaa__Approval__c>) getRecords()) {
            quoteIds.add(eachApproval.AQS_Quote__c);
        }
        Map<Id, SBQQ__Quote__c> quoteIdWithQuotes = new Map<Id, SBQQ__Quote__c>(
            QuotesSelector.newInstance().selectById(quoteIds)
        );
        for (sbaa__Approval__c eachApproval : (List<sbaa__Approval__c>) getRecords()) {
            eachApproval.Approval_Requested_Reason__c = quoteIdWithQuotes.get(
                    eachApproval.AQS_Quote__c
                )
                .Approval_Requested_Reason__c;
        }
    }
}