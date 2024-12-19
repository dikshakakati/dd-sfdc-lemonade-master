/**
 * @author Deloitte
 * @date 08/03/2022
 * @description Service class for System.FeatureManagement class
 */
public inherited sharing class FeatureManagementService implements IFeatureManagementService {
    /**
     * @description default constructor for the class
     * @return IProfilesSelector - interface of ProfilesSelector
     */
    public static IFeatureManagementService newInstance() {
        return (IFeatureManagementService) Application.SERVICE.newInstance(
            IFeatureManagementService.class
        );
    }

    /**
     * @description This method is used for checking if current user has custom permission
     * @param customPermissionName
     * @return Boolean - true if user has permission else false
     */
    public Boolean checkPermission(String customPermissionName) {
        return FeatureManagement.checkPermission(customPermissionName);
    }
}