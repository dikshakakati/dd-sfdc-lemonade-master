/**
 * @author Deloitte
 * @date 05/07/2024
 * @JIRA# LEM-13995
 * @description Wrapper class to hold package details.
 */
public class MerchantPopUpPackageWrapper {
    /**
     * @description Map of Package Details
     */
    public List<packageDetails> packageDetails { get; set; }

    /**
     * @description Store data of all the packageDetails
     */
    public class PackageDetails {
        /**
         * @description Store the package.
         */
        public String packageName { get; set; }
        /**
         * @description List of products associated with the package.
         */
        public String products { get; set; }
    }
}