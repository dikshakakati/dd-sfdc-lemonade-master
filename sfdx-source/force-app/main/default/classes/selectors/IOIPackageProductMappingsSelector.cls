/**
 * @author Deloitte
 * @date 06/26/2024
 * @description Interface of selector class for OIPackageProductMapping__mdt metadata.
 *
 */
public interface IOIPackageProductMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting all package and product mapping for
     * OIPackageProductMapping__mdt.
     * @JIRA# LEM-15355
     * @return List<OIPackageProductMapping__mdt>
     */
    List<OIPackageProductMapping__mdt> getAllMappings();
}