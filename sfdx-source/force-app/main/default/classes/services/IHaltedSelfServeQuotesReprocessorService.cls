/**
 * @author Deloitte
 * @date 12/03/2024
 * @description Interface of service class for logic related to re-processing of halted self-serve quotes.
 */
public interface IHaltedSelfServeQuotesReprocessorService {
    /**
     * @description It initiates the re-processing of halted self serve quotes due to cpq managed package queueable calculator jobs row locks.
     * @param selfServeHaltedQuotes
     */
    void initiateHaltedSelfServeQuotesReprocessing(List<SBQQ__Quote__c> selfServeHaltedQuotes);
}