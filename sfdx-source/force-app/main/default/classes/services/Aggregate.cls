/**
 * @description Proxy class for AggregateResult that allows summary data to be mocked in unit tests
 * @author Deloitte
 * @date 23/3/2022
 */
public class Aggregate {
    /**
     * @description Convert to aggregate instance
     * @param lstResults
     * @return Aggregate[]
     */
    public static Aggregate[] convertResults(AggregateResult[] lstResults) {
        Aggregate[] lstRecords = new List<Aggregate>{};
        for (AggregateResult result : lstResults) {
            lstRecords.add(new Aggregate(result));
        }
        return lstRecords;
    }

    /**
     * @description Create map of aggregate result
     * @param alias
     * @param lstAggregate
     * @return Map<Id, Aggregate>
     */
    public static Map<Id, Aggregate> mapBy(String alias, Aggregate[] lstAggregate) {
        Map<Id, Aggregate> response = new Map<Id, Aggregate>();
        if (String.isBlank(alias) || lstAggregate == null) {
            return response;
        }
        for (Aggregate a : lstAggregate) {
            response.put((Id) a.get(alias), a);
        }
        return response;
    }

    private final Map<String, Object> data;

    /**
     * @description Constructor of class
     * @param result
     */
    public Aggregate(AggregateResult result) {
        data = result.getPopulatedFieldsAsMap();
    }

    @TestVisible
    private Aggregate() {
        data = new Map<String, Object>();
    }

    /**
     * @description Get alias
     * @param alias
     * @return Object
     */
    public Object get(String alias) {
        return data.get(alias);
    }

    /**
     * @description Put alias
     * @param alias
     * @param value
     * @return Aggregate
     */
    @TestVisible
    private Aggregate put(String alias, Object value) {
        data.put(alias, value);
        return this;
    }
}