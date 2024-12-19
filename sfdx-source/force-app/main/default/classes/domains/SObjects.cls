/**
 * @description Virtual class to add common sobject domain functionality without needing to
 * make changes to the fflib packages.  All sobject domain classes should inherited from
 * SObjects rather than fflib_SObjects.
 * @author Scott McClung
 * @date 2023/02/16
 */
public virtual class SObjects extends fflib_SObjects implements ISObjects {
    /**
     * @description Class constructor
     * @param records Collection of SObjects
     * @param sObjectType The SObject type of the records in the collection
     */
    public SObjects( List<SObject> records, Schema.SObjectType sObjectType ) {
        super( records, sObjectType );
    }

    /**
     * @description Convenience method to return the number of records in the domain collection
     * @return Number of records
     */
    public Integer size() {
        return this.getRecords().size();
    }

    /**
     * @description Getter that extracts the string values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of String values
     */
    protected virtual List<String> getStringFieldValues( Schema.SObjectField sObjectField ) {
        List<String> results = new List<String>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( String.valueOf( value ) );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the unique id values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return Set of Id values
     */
    protected virtual Set<Id> getIdFieldValues( Schema.SObjectField sObjectField ) {
        Set<Id> results = new Set<Id>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( (Id) value );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the date values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Date values
     */
    protected virtual List<Date> getDateFieldValues( Schema.SObjectField sObjectField ) {
        List<Date> results = new List<Date>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( Date.valueOf( value ) );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the datetime values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Datetime values
     */
    protected virtual List<Datetime> getDatetimeFieldValues( Schema.SObjectField sObjectField ) {
        List<Datetime> results = new List<Datetime>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( Datetime.valueOf( value ) );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the decimal values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Decimal values
     */
    protected virtual List<Decimal> getDecimalFieldValues( Schema.SObjectField sObjectField ) {
        List<Decimal> results = new List<Decimal>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( (Decimal) value );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the double values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Double values
     */
    protected virtual List<Double> getDoubleFieldValues( Schema.SObjectField sObjectField ) {
        List<Double> results = new List<Double>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( (Double) value );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the integer values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Integer values
     */
    protected virtual List<Integer> getIntegerFieldValues( Schema.SObjectField sObjectField ) {
        List<Integer> results = new List<Integer>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( Integer.valueOf( value ) );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts the long values from the given field from all records
     * @param sObjectField The field token to extract the value from
     * @return List of Long values
     */
    protected virtual List<Long> getLongFieldValues( Schema.SObjectField sObjectField ) {
        List<Long> results = new List<Long>();
        for( SObject record : getRecords() ) {
            Object value = record.get( sObjectField );
            if( value != null ) {
                results.add( (Long) value );
            }
        }
        return results;
    }

    /**
     * @description Getter that extracts a map of all records grouped by an Id field
     * Id field could be the record id or a reference/lookup field.
     * @param field The field token to extract the value from
     * @return Map records grouped by Id
     */
    protected virtual Map<Id, SObject> getSObjectsByIdField( Schema.SObjectField field ) {
        String strSObjectType = String.valueOf( this.getSObjectType() );
        Map<Id, SObject> results = (Map<Id, SObject>) getDynamicMapInstance( 'Id', strSObjectType );
        for( SObject record : this.getRecords() ) {
            Object value = record.get( field );
            if( value != null ) {
                results.put( (Id) value, record );
            }
        }
        return results;
    }

    /**
     * @description Filter that selects records that have a null value in at least one of the given fields
     * @param sObjectFields The field tokens to evaluate for null values
     * @return List of records
     */
    protected virtual List<SObject> getRecordsWithAnyNullFieldValues( Set<SObjectField> sObjectFields ) {
        List<SObject> result = new List<SObject>();
        for( SObject record : getRecords() ) {
            if( recordHasAnyNullValues( sObjectFields, record ) ) {
                result.add( record );
            }
        }
        return result;
    }

    /**
     * @description Filter that selects records that have a null value in all of the given fields
     * @param sObjectFields The field tokens to evaluate for null values
     * @return List of records
     */
    protected virtual List<SObject> getRecordsWithAllNullFieldValues( Set<SObjectField> sObjectFields ) {
        List<SObject> result = new List<SObject>();
        for( SObject record : getRecords() ) {
            if( recordHasAllNullValues( sObjectFields, record ) ) {
                result.add( record );
            }
        }
        return result;
    }

    /**
     * @description Filter that selects records that have a non-null value in all of the given fields
     * @param sObjectFields The field tokens to evaluate for null values
     * @return List of records
     */
    protected virtual List<SObject> getRecordsWithAllNotNullFieldValues( Set<SObjectField> sObjectFields ) {
        List<SObject> result = new List<SObject>();
        for( SObject record : getRecords() ) {
            if( !recordHasAnyNullValues( sObjectFields, record ) ) {
                result.add( record );
            }
        }
        return result;
    }

    /**
     * @description Filter that selects records that have a non-null value in at least one of the given fields
     * @param sObjectFields The field tokens to evaluate for null values
     * @return List of records
     */
    protected virtual List<SObject> getRecordsWithAnyNotNullFieldValues( Set<SObjectField> sObjectFields ) {
        List<SObject> result = new List<SObject>();
        for( SObject record : getRecords() ) {
            if( !recordHasAllNullValues( sObjectFields, record ) ) {
                result.add( record );
            }
        }
        return result;
    }

    /**
    * @description checks if all the field values given are return if they are matching
    * @author VenkateshDD | 10-09-2024
    * @param fieldValuesMap
    * @return virtual
    **/
    protected virtual List<SObject> getRecordsByMultipleFieldValue(Map<SObjectField, Object> fieldValuesMap) {
        List<SObject> results = new List<SObject>();
        for( SObject record : getRecords() ) {
            Boolean hasAllValues = true;
            for( SObjectField field : fieldValuesMap.keySet() ) {
                if( record.get( field ) != fieldValuesMap.get( field ) ) {
                    hasAllValues = false;
                    break;
                }
            }
            if( hasAllValues ) {
                results.add( record );
            }
        }
        return results;
    }

    private static Object getDynamicMapInstance( String keyType, String valueType ) {
        if( String.isBlank( keyType ) || String.isBlank( valueType ) ) {
            throw new DeveloperException( 'Generating a dynamic map requires a valid type for key and value.' );
        }
        String typeName = String.format( 'Map<{0},{1}>', new String[]{ keyType, valueType } );
        Type typeMap = Type.forName( typeName );
        return typeMap.newInstance();
    }

    private static Boolean recordHasAnyNullValues( Set<SObjectField> sObjectFields, SObject record ) {
        for( SObjectField sObjectField : sObjectFields ) {
            if( record.get( sObjectField ) == null ) {
                return true;
            }
        }
        return false;
    }

    private static Boolean recordHasAllNullValues( Set<SObjectField> sObjectFields, SObject record ) {
        for( SObjectField sObjectField : sObjectFields ) {
            if( record.get( sObjectField ) != null ) {
                return false;
            }
        }
        return true;
    }

    /**
     * @description Custom exception class for error handling
     */
    public class DeveloperException extends Exception {}
}