/**
 * @author Deloitte
 * @date 04/27/2024
 * @description Interface for StaticResource Selector class methods.
 */
public interface IStaticResourcesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting Static Resource by passed fileName.
     * @param fileName
     * @return List<StaticResource>
     */
    List<StaticResource> selectByName(String fileName);
}