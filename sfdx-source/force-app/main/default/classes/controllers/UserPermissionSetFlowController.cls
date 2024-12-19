/**
 * @author Deloitte
 * @date   07/23/2024
 * @description This is the service implementation class to get the user permission in Flow
 */
public inherited sharing class UserPermissionSetFlowController {
    private static final String SPLIT_KEY = '~';
    private static final String USERID_BIND_VAR  = 'userId';
    private static List<List<sObject>> userPermissions = new List<List<sObject>>();
    @InvocableMethod(
        label='Get User Permission'
        description='Returns Whether User Has Permission Or Not'
    )
    /**
     * @description It is used for retrieving field permission for the flow user
     * @param soqlQuery
     * @return List<List<sObject>>
     */
    public static List<List<sObject>> getPermissionDetails(List<String> soqlQuery) {
        List<String> permissionSetQueryTemplate = (soqlQuery?.get(0))?.split(SPLIT_KEY);
        Map<String, Object> bindsVar = new Map<String, Object>{ USERID_BIND_VAR => permissionSetQueryTemplate?.get(1)};
        userPermissions.add(
            (List<sObject>) Database.queryWithBinds(
                permissionSetQueryTemplate.get(0),
                bindsVar,
                AccessLevel.System_Mode
         ));
         return userPermissions;
    }
}