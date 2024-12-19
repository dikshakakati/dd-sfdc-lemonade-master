/**
 * @author SamikshaDD
 * @date 03/07/2024
 * @description Controller class for ManageRESSMOLink related logic.
 */
public with sharing class ManageRESSMOLinkController {

    private static final String CONTRACT = 'Contract';
    private static final String QUOTE = 'Quote';
    private static final String MX_INACTIVE_REASON_EXPIRED	 = 'Expired';
    private static final String MX_STATUS_ACTIVE = 'Active';
    private static final String MX_STATUS_INACTIVE = 'Inactive';
    private static Map<String, Set<String>> sobjectToSetOfField;
    private static String source;
    private static List<Response> responses;
    private static final String STATUS_FAILED = 'Failed';
    private static final String PARSER_EXCEPTION_ILLEGAL_VALUE_FOR_PRIMITIVE = 'An Apex error occurred: System.JSONException: Illegal value for primitive';

    /**
    * @description
    */
    @InvocableMethod(
        label='Manage RESSMO Link'
        description='Manage a RESSMO Link to Expire or Extend'
        )

    /**
    * @description
    * @jira LEM-18297
    * @param requests
    * @return List<Response>
    **/
    public static List<Response> manageRESSMOLink(List<Request> requests) {
		responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
    		return new List<Response>();
		}
        Set<Id> contractIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        source = processRequestsAndSetFieldValue(requests, contractIds, quoteIds);
        sobjectToSetOfField = new Map<String, Set<String>>{
            'Account' => new Set<String>{'Unique_Identifier__c'},
            'Xref' => new Set<String>{'External_Id__c'}
        };
        if (quoteIds != null && !quoteIds.isEmpty()) {
            processQuotes(quoteIds, requests[0]);
        }else if (contractIds!=null && !contractIds.isEmpty()) {
            processContracts(contractIds, requests[0]);
        }

        return responses;
    }

    private static String processRequestsAndSetFieldValue(List<Request> requests, Set<Id> contractIds, Set<Id> quoteIds) {
        String reqSource = '';
        for (Request req : requests) {
            if (String.isNotBlank(req.contractId)) {
                contractIds.add(req.contractId);
            }
            if (String.isNotBlank(req.quoteId)) {
                quoteIds.add(req.quoteId);
            }
            reqSource = req.source;
        }
        return reqSource;
    }

    /**
    * @description
    * @jira LEM-18297
    * @param quoteIds
    * @param request
    **/
    private static void processQuotes(Set<Id> quoteIds, Request request) {
        Set<String> quoteFieldSet = new Set<String>{'RESSMO_Store_Account_Id__c', 'SSMO_Expiration_Date__c'};
        List<SBQQ__Quote__c> quoteList = QuotesSelector.newInstance().selectQuoteByIdWithGivenFields(quoteIds, quoteFieldSet);
        if (quoteList.isEmpty()) {
            return;
        }
        Id storeAccountId = quoteList[0].RESSMO_Store_Account_Id__c !=null ? quoteList[0].RESSMO_Store_Account_Id__c : null;
        if (storeAccountId != null) {
            manageRESSMOLinkAPICall(storeAccountId, request, quoteList, null);
        }
    }

    /**
    * @description
    * @jira LEM-18297
    * @param contractIds
    * @param request
    **/
    private static void processContracts(Set<Id> contractIds, Request request) {
        Set<String> contractFieldSet = new Set<String>{'RESSMO_Store_Account_Id__c'};
        List<Contract> contracts = ContractsSelector.newInstance().selectContractByIdWithGivenFields(contractIds, contractFieldSet);
        if (contracts.isEmpty()) {
            return; // No contracts foundH
        }
        Id storeAccountId = contracts[0].RESSMO_Store_Account_Id__c !=null ? contracts[0].RESSMO_Store_Account_Id__c : null;
        if (storeAccountId != null) {
            manageRESSMOLinkAPICall(storeAccountId,request, null, contracts);
        }
    }

    /**
    * @description
    * @jira LEM-18297
    * @param recordId
    * @param request
    * @param quoteList
    * @param contracts
    **/
    private static void manageRESSMOLinkAPICall(Id recordId, Request request, List<SBQQ__Quote__c> quoteList, List<Contract> contracts){
        Id storeAccountId = recordId;
        Response res = new Response();
        List<Account> storeAccounts = AccountsSelector.newInstance().selectAccountByIdWithXref(new Set<Id>{storeAccountId}, sobjectToSetOfField);
        String manageRESSMOPayload = prepareManageRESSMOLinkPayload(request.ExpirationDate, storeAccounts[0]);
        try {
            SSMOWrapper.ResultMessageWrapper result = RESSMOService.ssmoManageRESSMOLinkAPICall(manageRESSMOPayload);
            if (result.status == STATUS_FAILED) {
                res.success = false;
                if (!result.messages.isEmpty()) {
                    res.message = result.messages[0];
                }
            } else {
                res.success = true;
                res.message = '';
                handleSourceSpecificUpdates(request, quoteList, contracts, result);
                }
        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage().replace(PARSER_EXCEPTION_ILLEGAL_VALUE_FOR_PRIMITIVE, System.Label.RESSMO_ManageRESSMOLink_Parser_Exception);
            throw new FlowException(res.message);
        }
        responses.add(res);
    }

    /**
    * @description
    * @jira LEM-18297
    * @param request
    * @param quoteList
    * @param contracts
    * @param result
    **/
    private static void handleSourceSpecificUpdates(Request request, List<SBQQ__Quote__c> quoteList, List<Contract> contracts, SSMOWrapper.ResultMessageWrapper result) {
        if (source.equalsIgnoreCase(CONTRACT) && contracts != null && contracts[0].Mx_Onboarding_Links__r != null) {
            List<Mx_Onboarding_Link__c> mxOnboarding = contracts[0].Mx_Onboarding_Links__r;
            updateMxOnboardingLinks(mxOnboarding, request);
        }
    }

    /**
    * @description
    * @jira LEM-18297
    * @param mxOnboarding
    * @param request
    **/
    private static void updateMxOnboardingLinks(List<Mx_Onboarding_Link__c> mxOnboarding, Request request) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Mx_Onboarding_Link__c link = mxOnboarding[0];
        if (request.ExpirationDate != null && request.ExpirationDate > System.now()){
            DateTime expDate = request.ExpirationDate;
            Datetime convertedDateTime = expDate.addHours(-(UserInfo.getTimeZone().getOffset(expDate) / 3600000.0).intValue());
            link.Expiration_Date_Time__c = convertedDateTime;
        }
        else{
            link.Expiration_Date_Time__c = System.now() - 1;
        }
        link.Status__c = (request.ExpirationDate != null && request.ExpirationDate > System.now()) ? MX_STATUS_ACTIVE : MX_STATUS_INACTIVE;
        link.Inactive_Reason__c = (request.ExpirationDate != null && request.ExpirationDate > System.now()) ? null : MX_INACTIVE_REASON_EXPIRED;
        uow.registerDirty(link);
        uow.commitWork();
    }
    /**
    * @description
    * @jira LEM-18297
    * @param expirationDate
    * @param storeAccount
    * @return String
    **/
    public static String prepareManageRESSMOLinkPayload(Date expirationDate, Account storeAccount){
        Map<String, Object> jsonMap = new Map<String, Object>();
        Map<String, Object> storeAccountMap = new Map<String, Object>();
        storeAccountMap.put('Unique_Identifier__c', storeAccount.Unique_Identifier__c!=null?storeAccount.Unique_Identifier__c:''); //variables to be added
        jsonMap.put('StoreAccount', storeAccountMap);
        Map<String, Object> dateMap = new Map<String, Object>();
        dateMap.put('SSMO_Expiration_Date__c', expirationDate);
        jsonMap.put('Quote', dateMap);
        Map<String, Object> paymentAccountObj = new Map<String, Object>();
        jsonMap.put('PaymentAccount', paymentAccountObj);
        jsonMap.put('voidOrExpire', true);

        return JSON.serialize(jsonMap);
    }

    /**
    * @description Request
    */
    public class Request {
        @InvocableVariable(required = false)
        public Id contractId;
        @InvocableVariable(required = false)
        public Id quoteId;
        @InvocableVariable (required = true)
        public String source;
 		@InvocableVariable(required = false)
        public Date expirationDate;
    }

    /**
    * @description Response
    */
    public class Response {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String message;
    }
}