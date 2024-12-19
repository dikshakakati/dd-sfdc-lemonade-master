/**
 * @description Service Class for Nintex UseCases
 * @author Scott/ATG/Bhargavi
 */

public inherited sharing class NintexSubmissionService {

     /**
    * @description Constructor to perform before update processing
    * @param opportunities
    */
    public static void submitOpportunities(IOpportunities opportunities) {
        service().submitOpportunities(opportunities);
    }

    private static INintexSubmissionService service() {
        return (INintexSubmissionService) Application.Service.newInstance(INintexSubmissionService.class);
    }
}