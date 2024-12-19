/**
 * @author Deloitte
 * @date 01/21/2024
 * @description Iterator for AggregateResult.
 */
public inherited sharing class AggregateResultIterator implements Iterator<AggregateResult> {
    AggregateResult[] aggregateResults { get; set; }
    // To track the index of returned aggregate result.
    Integer currentIndex { get; set; }

    /**
     * @description Parameterized constructor to query the database and get the aggregate results.
     * @param aggregateQuery
     */
    public AggregateResultIterator(String aggregateQuery) {
        currentIndex = 0;
        aggregateResults = Database.query(String.escapeSingleQuotes(aggregateQuery));
    }

    /**
     * @description Parameterized constructor to query the database and get the aggregate results.
     * @param aggregateQuery
     * @param filters
     * @param applicableAccessLevel
     */
    public AggregateResultIterator(
        String aggregateQuery,
        Map<String, Object> filters,
        AccessLevel applicableAccessLevel
    ) {
        currentIndex = 0;
        aggregateResults = Database.queryWithBinds(
            String.escapeSingleQuotes(aggregateQuery),
            filters,
            applicableAccessLevel
        );
    }

    /**
     * @description It checks whether there is any more aggregate result to iterate.
     * @return Boolean
     */
    public Boolean hasNext() {
        return aggregateResults != null &&
            !aggregateResults.isEmpty() &&
            currentIndex < aggregateResults.size();
    }

    /**
     * @description It returns an aggregate result at the next index.
     * @return AggregateResult
     */
    public AggregateResult next() {
        return aggregateResults[currentIndex++];
    }
}