/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Controller class for Onboarding Inputs from Mx (Guest User) in Experience Cloud.
 * TODO: Re-access "without sharing" aspect in Guest Profile context.
 */
public without sharing class MxOnboardingCommunityController {
    private static final String FORM_TYPE_MX_FORM = 'Mx FORM';
    private static final String LOG_DOMAIN = 'Onboarding Inputs';
    private static final String LOG_RECORD_CREATION_ERROR = 'Exception occured during Mx Form submission.';
    private static final String MX_ONBOARDING_LINK_INACTIVE_REASON_SUBMITTED = 'Submitted';
    private static final String MX_ONBOARDING_LINK_STATUS_ACTIVE = 'Active';
    private static final String MX_ONBOARDING_LINK_STATUS_INACTIVE = 'Inactive';
    private static final Map<String, String> LANGUAGE_CODE_TO_LANGUAGE = new Map<String, String>{
        'en' => 'English',
        'fr' => 'French'
    };

    /**
     * @description It fetches 'Active' "Mx Onboarding Link" corresponding to
     * the passed uniqueIdentifier.
     * @JIRA# LEM-15113
     * @param uniqueIdentifier
     * @return Mx_Onboarding_Link__c
     */
    @AuraEnabled(cacheable=true)
    public static Mx_Onboarding_Link__c getMxOnboardingLink(String uniqueIdentifier) {
        Mx_Onboarding_Link__c mxOnboardingLinkToReturn;
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .currentOnBoardingLinkByUUID(uniqueIdentifier);
        if (
            mxOnboardingLinks != null &&
            !mxOnboardingLinks.isEmpty() &&
            mxOnboardingLinks[0] != null &&
            mxOnboardingLinks[0].Status__c == MX_ONBOARDING_LINK_STATUS_ACTIVE &&
            mxOnboardingLinks[0].Expiration_Date_Time__c > System.now()
        ) {
            mxOnboardingLinkToReturn = mxOnboardingLinks[0];
        }
        return mxOnboardingLinkToReturn;
    }

    /**
     * @description It submits Guest User's Onboarding Inputs and initiates data creation.
     * @JIRA# LEM-15113
     * @param oiMainDataWrapperJSON
     * @param mxOnboardingLinkId
     * @param emailId
     * @param mxFormLanguage
     */
    @AuraEnabled
    public static void submitMXForm(
        String oiMainDataWrapperJSON,
        Id mxOnboardingLinkId,
        String emailId,
        String mxFormLanguage
    ) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        // Set "Mx Onboarding Link" to 'Inactive'
        try {
            Boolean recordSave = false;
            // Initiates the data creation
            recordSave = OIDataService.saveMXFormDetails(oiMainDataWrapperJSON, mxOnboardingLinkId);
            if (recordSave) {
                Mx_Onboarding_Link__c mxOnBoardinglink = new Mx_Onboarding_Link__c(
                    Id = mxOnboardingLinkId,
                    Status__c = MX_ONBOARDING_LINK_STATUS_INACTIVE,
                    Inactive_Reason__c = MX_ONBOARDING_LINK_INACTIVE_REASON_SUBMITTED,
                    Mx_Form_Language__c = LANGUAGE_CODE_TO_LANGUAGE.get(mxFormLanguage)
                );
                if (String.isNotBlank(emailId)) {
                    mxOnBoardinglink.Submitted_By_Mx_Email__c = emailId;
                }
                unitOfWorkInstance.registerDirty(mxOnBoardinglink);
                unitOfWorkInstance.commitWork();
            }
        } catch (Exception mxOnboardingInputsException) {
            Logger.publish(
                LogEntry.newExceptionLog(mxOnboardingInputsException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_RECORD_CREATION_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(mxOnboardingInputsException)
            );
        }
    }
}