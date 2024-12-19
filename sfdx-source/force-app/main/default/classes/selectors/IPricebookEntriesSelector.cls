/**
 * @author Deloitte
 * @date 05/21/2024
 * @description Selector Class for Pricebook Entry.
 */
public interface IPricebookEntriesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting Pricebook Entries based on Product names and currency.
     * @param productNames
     * @param currencyIsoCode
     * @return List<PricebookEntry>
     */
    List<PricebookEntry> selectByProductNamesAndCurrency(
        Set<String> productNames,
        String currencyIsoCode
    );
}