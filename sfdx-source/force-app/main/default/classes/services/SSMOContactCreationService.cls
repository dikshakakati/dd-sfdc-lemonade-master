/**
 * @author Deloitte
 * @date   05/16/2024
 * @description This is the service class for Contact creation from SSMO Payload
 */
public inherited sharing class SSMOContactCreationService implements ISSMOContactCreationService {
    /**
     * @description default constructor for the class
     * @return ISSMOContactCreationService - interface of SSMOContactCreationService
     */
    public static ISSMOContactCreationService service() {
        return (ISSMOContactCreationService) Application.Service.newInstance(
            ISSMOContactCreationService.class
        );
    }

    /**
     * @description It is used to update contact record on the basis of parsed payload.
     * @JIRA# LEM-14817
     * @param inputPayload
     * @param contactToUpdate
     * @return Contact
     */
    public static Contact updateContactSSMO(
        SSMOFalloutWrapper inputPayload,
        Contact contactToUpdate
    ) {
        return service().updateContactSSMO(inputPayload, contactToUpdate);
    }

    /**
     * @description It is used to insert contact with Basic fields on basis of payload.
     * @JIRA# LEM-14817
     * @param payLoad
     * @param contactToInsert
     * @return Contact
     */
    public static Contact insertContactSSMO(SSMOFalloutWrapper payLoad, Contact contactToInsert) {
        return service().insertContactSSMO(payLoad, contactToInsert);
    }
}