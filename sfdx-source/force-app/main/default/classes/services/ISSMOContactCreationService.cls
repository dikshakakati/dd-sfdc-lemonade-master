/**
 * @author Deloitte
 * @date 05/17/2024
 * @description : Contact creation for SSMO payload
 */
public interface ISSMOContactCreationService {
    /**
     * @description It is used to update contact record on the basis of parsed payload.
     * @JIRA# LEM-14817
     * @param inputPayload
     * @param contactToUpdate
     * @return Contact
     */
    Contact updateContactSSMO(SSMOFalloutWrapper inputPayload, Contact contactToUpdate);

    /**
     * @description It is used to insert contact with Basic fields on basis of payload.
     * @JIRA# LEM-14817
     * @param payLoad
     * @param contactToInsert
     * @return Contact
     */
    Contact insertContactSSMO(SSMOFalloutWrapper payLoad, Contact contactToInsert);
}