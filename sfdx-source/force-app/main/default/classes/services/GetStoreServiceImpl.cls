/**
 * @author DoorDash
 * @date   04/18/2023
 * @description This is the service interface implementation for retrieving the store details
 */
public class GetStoreServiceImpl implements IGetStoreService {

    private static final Integer SUCCESS_CODE = 200;
    public static final string DRIVE_STORE_ID_MAP_KEY = 'drive-store-id';
    @testvisible private static final string API_DRIVE_STORE_ID_ATTRIBUTE = 'drive_store_id';
    public static final string GET_STORE_API_STATUS_MAP_KEY = 'get-store-api-status';
    public static final string GET_STORE_API_RESPONSE_MAP_KEY = 'get-store-api-response';
    public static final string GET_STORE_API_STATUS_SUCCESS = 'Success';
    public static final string GET_STORE_API_STATUS_FAILURE = 'Failure';
    public static final String SANDBOX_NAMED_CREDENTIAL = Label.NamedCredentialAPIName;
    public static final String PROD_NAMED_CREDENTIAL = Label.ProdNamedCredentialAPIName;
    public static final String STORE_DETAILS_PREFIX = Label.StoreDetailsPrefix;
    public static final String PROD_STORE_DETAILS_PREFIX = Label.ProdStoreDetailsPrefix;

    /**
     * @description method to get the drive store Id for a given store
     * @param storeNumber Store number for which we need to retrieve the information
     * @return String
     */
    public Map<String, String> getDriveStoreId(String storeNumber) {
        Map<String, String> retMap = new Map<String, String>();
        try{
            Integer statusCode;
            Integer retryCount = 0;
            HttpResponse response = new HttpResponse();

            while(retryCount < 2){
                response =  (new Http()).send(generateHttpRequest(storeNumber));
                statusCode = response.getStatusCode();
                if(statusCode == SUCCESS_CODE){
                    break;
                }
                retryCount++;
            }

            if(statusCode == SUCCESS_CODE){
                Map<String, Object> getStoreApiResponse = (Map<String, Object>)JSON.deserializeUntyped (response.getBody());
                String driveStoreId = getStoreApiResponse.get(API_DRIVE_STORE_ID_ATTRIBUTE) == null ? '' : String.valueOf(getStoreApiResponse.get(API_DRIVE_STORE_ID_ATTRIBUTE));
                retMap.put(DRIVE_STORE_ID_MAP_KEY, driveStoreId);
                retMap.put(GET_STORE_API_STATUS_MAP_KEY, GET_STORE_API_STATUS_SUCCESS);
            } else {
                retMap.put(GET_STORE_API_STATUS_MAP_KEY, GET_STORE_API_STATUS_FAILURE);
                retMap.put(GET_STORE_API_RESPONSE_MAP_KEY, response.getBody());
            }
        } catch(Exception e){
            retMap.put(GET_STORE_API_STATUS_MAP_KEY, GET_STORE_API_STATUS_FAILURE);
            retMap.put(GET_STORE_API_RESPONSE_MAP_KEY, e.getMessage());
        }
        return retMap;
    }

    /**
     * @description method to generate HttpRequest
     * @param storeNumber
     * @return HttpRequest
     */
    private HttpRequest generateHttpRequest(String storeNumber) {
        Boolean isSandbox = false;
        List<String> urlSplit = URL.getOrgDomainUrl().toExternalForm().split('--');
        if (urlSplit.size() > 1) {
        isSandbox = true;
        }
        String namedCredential = isSandbox ? SANDBOX_NAMED_CREDENTIAL : PROD_NAMED_CREDENTIAL;
        String endpoint = isSandbox ? STORE_DETAILS_PREFIX : PROD_STORE_DETAILS_PREFIX ;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+namedCredential+endpoint+storeNumber);
        req.setMethod('GET');
        return req;
    }
}