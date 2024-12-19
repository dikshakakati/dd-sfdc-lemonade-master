/**
 * @author Deloitte
 * @date 01/21/2024
 * @description Iterable for AggregateResult.
 */
public class AggregateResultIterable implements Iterable<AggregateResult> {
    private AccessLevel applicableAccessLevel;
    @TestVisible
    private String aggregateQuery;
    private Map<String, Object> filters;

    /**
     * @description Parameterized constructor to initialize class variables.
     * @param aggregateQuery
     */
    public AggregateResultIterable(String aggregateQuery) {
        this.aggregateQuery = aggregateQuery;
    }

    /**
     * @description Parameterized constructor to initialize class variables.
     * @param aggregateQuery
     * @param filters
     * @param applicableAccessLevel
     */
    public AggregateResultIterable(
        String aggregateQuery,
        Map<String, Object> filters,
        AccessLevel applicableAccessLevel
    ) {
        this.applicableAccessLevel = applicableAccessLevel;
        this.aggregateQuery = aggregateQuery;
        this.filters = filters;
    }

    /**
     * @description It returns Iterator for AggregateResult.
     * @return Iterator<AggregateResult>
     */
    public Iterator<AggregateResult> iterator() {
        return new AggregateResultIterator(aggregateQuery, filters, applicableAccessLevel);
    }
}