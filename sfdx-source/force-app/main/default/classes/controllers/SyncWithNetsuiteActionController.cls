/**
 * @author Deloitte
 * @date 10/07/2022
 * @description This is the controller class to invoke netsuite integration methods.
 */
public class SyncWithNetsuiteActionController {
    private static final String ERROR_KEY = 'error';
    private static final String STATUS_KEY = 'status';
    private static final String MESSAGE_KEY = 'message';
    private static final String SPLIT_STRING = '~~';
    //private static final String STATUS_KEY='status';
    /**
     * @description It returns custom setting value True or False. If it returns true then will call Restlet else Middleware.
     * @return boolean
     */
    @AuraEnabled
    public static boolean isRestlet() {
        return Sync_With_Netsuite_Process__c.getOrgDefaults().Restlet_API_Call__c;
    }
    /**
     * @description - Mthod invokes from LWC record action button
     * @param paymentAccountId
     * @return static Map<String,Object>
     */
    @AuraEnabled
    public static Map<String, Object> syncWithNetsuite(Id paymentAccountId) {
        Map<String, Object> requestRespone = new Map<String, Object>();
        INetsuiteIntegrator nsIntegrator = null;
        if(isRestlet()){
            nsIntegrator = new NetsuiteIntegratorRestletServiceImpl();
        }else{
            nsIntegrator = new NetsuiteIntegratorMiddlewareServiceImpl();
        }
        List<String> errorMessages = nsIntegrator.performReadinessCheckValidations(
            paymentAccountId
        );
        if (errorMessages != null && !errorMessages.isEmpty()) {
            throw new AuraHandledException(string.join(errorMessages,SPLIT_STRING));
        }
        Map<String, Object> synWithNetSuiteResponse = nsIntegrator.syncWithNetsuite(
            paymentAccountId
        );
        requestRespone.put(STATUS_KEY, synWithNetSuiteResponse.get(STATUS_KEY));
        requestRespone.put(MESSAGE_KEY , synWithNetSuiteResponse.get(MESSAGE_KEY));
        return requestRespone;
    }
}