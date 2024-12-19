/**
 * @author Deloitte
 * @date 10/05/2022
 * @description BannerMessageWrapper for workStepDependenciesWarningBanner lightning web component.
 */
public class BannerMessageWrapper {
    @AuraEnabled
    public Boolean showMessage;
    @AuraEnabled
    public String bannerMessage;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param showMessage
     * @param bannerMessage
     */
    public BannerMessageWrapper(Boolean showMessage, String bannerMessage) {
        this.showMessage = showMessage;
        this.bannerMessage = bannerMessage;
    }
}