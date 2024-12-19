/**
 * @author Deloitte
 * @date 08/03/2022
 * @description Interface for FeatureManagementService class
 */
public interface IFeatureManagementService {
    /**
     * @description This method is used for checking if current user has custom permission
     * @param customPermissionName
     * @return Boolean - true if user has permission else false
     */
    Boolean checkPermission(String customPermissionName);
}