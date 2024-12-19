/**
 * @author Deloitte
 * @date 12/03/2024
 * @description Service class for logic related to re-processing of halted self-serve quotes.
 */
public inherited sharing class HaltedSelfServeQuotesReprocessorService {
    /**
     * @description It initiates the re-processing of halted self serve quotes due to cpq managed package queueable calculator jobs row locks.
     * @JIRA #LEM-23462
     * @param selfServeHaltedQuotes
     */
    public static void initiateHaltedSelfServeQuotesReprocessing(
        List<SBQQ__Quote__c> selfServeHaltedQuotes
    ) {
        service().initiateHaltedSelfServeQuotesReprocessing(selfServeHaltedQuotes);
    }

    /**
     * @description It creates instance of HaltedSelfServeQuotesReprocessorServiceImpl class.
     * @return IHaltedSelfServeQuotesReprocessorService - instance of HaltedSelfServeQuotesReprocessorServiceImpl
     */
    private static IHaltedSelfServeQuotesReprocessorService service() {
        return (IHaltedSelfServeQuotesReprocessorService) Application.Service.newInstance(
            IHaltedSelfServeQuotesReprocessorService.class
        );
    }
}