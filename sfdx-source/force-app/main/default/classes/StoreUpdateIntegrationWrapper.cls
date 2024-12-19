/**
 * @description  created to read the store sync event payload
 * @author rishab.goyal
 * @date 02-26-2024
 * @last modified on  : 02-26-2024
 * @last modified by  : rishab.goyal
**/
@SuppressWarnings('PMD.FieldNamingConventions, PMD.ExcessivePublicCount') //suppressed these PMD warning since they are the names in the payload which we cannot control
public class StoreUpdateIntegrationWrapper {

	/**
	 * @description  created to read Is_Active attribute
	 * @author rishab.goyal
	 * @date 02-26-2024
	**/
	public class Is_active {
		public Boolean value;
	}

	/**
	 * @description  created to read updated fields list
	 * @author rishab.goyal
	 * @date 02-26-2024
	**/
	public class Updated_fields {
		public Event_uuid updated_field_name;
		public Event_uuid old_value;
		public Event_uuid new_value;
	}

	/**
	 * @description  created to read value of any attribute
	 * @author rishab.goyal
	 * @date 02-26-2024
	**/
	public class Event_uuid {
		public String value;
	}

	/**
	 * @description  created to read value of created date attributes
	 * @author rishab.goyal
	 * @date 02-26-2024
	**/
	public class Created_at {
		public Integer seconds;
		public Integer nanos;
	}
	/**
	 * @description  created to read updated store attribute values
	 * @author rishab.goyal
	 * @date 02-26-2024
	**/
	public class Updated_store {
		public Event_uuid id;
		public Event_uuid business_id;
		public Is_active is_active;
		public Event_uuid order_protocol;
	}

	/**
	 * @description  created to read updated POS attribute values
	 * @author krishna S
	 * @date 04-01-2024
	**/
	public class PointOfSale {
		public string provider_type;
		public string location_id;
	}

	/**
	 * @description  created to read updated Sub Market attribute values
	 * @author krishna S
	 * @date 04-01-2024
	**/
	public class SubMarketRequest {
		public string Sub_Market_Name;
		public string Sub_Market_ID;
	}

	/**
	 * @description  created to read updated Address & submarket attribute values
	 * @author krishna S
	 * @date 04-01-2024
	**/
	public class AddressValidationResponse {
		public SubMarketRequest submarketRequest;
		public Account addressResponse;
	}

	public Event_uuid event_uuid;
	public Updated_store updated_store;
	public List<Updated_fields> updated_fields;
	public Created_at created_at;
	public PointOfSale point_of_sale;
	public AddressValidationResponse addressValidationResponse;

	/**
     * @description It is used for retrieving the field names and its current values in a map
     * @param storeupdate
	 * @return Map<String,String>
     */
	public static Map<String,String> fieldsUpdatedwithNewValues(StoreUpdateIntegrationWrapper storeupdate){
		Map<String,String> fieldsUpdatedwithNewValues = new Map<String,String>();
		for(StoreUpdateIntegrationWrapper.updated_fields updatedfield: storeupdate.updated_fields){
			if(updatedfield.updated_field_name!=null || updatedfield.new_value!=null){
				fieldsUpdatedwithNewValues.put(updatedfield.updated_field_name.value,updatedfield.new_value.value);
			}
		}
		return fieldsUpdatedwithNewValues;
	}
	/**
     * @description It is used for retrieving the field names and its old values in a map
     * @param storeupdate
	 * @return Map<String,String>
     */
    public static Map<String, String> fieldsUpdatedwithOldValues(StoreUpdateIntegrationWrapper storeupdate){
		Map<String, String> fieldsUpdatedwithOldValues = new Map<String, String>();
		for(StoreUpdateIntegrationWrapper.updated_fields updatedfield: storeupdate.updated_fields){
			if(updatedfield.updated_field_name!=null || updatedfield.old_value!=null){
				fieldsUpdatedwithOldValues.put(updatedfield.updated_field_name.value,updatedfield.old_value.value);
			}
		}
        return fieldsUpdatedwithOldValues;
	}
	/**
     * @description It is used for retrieving the payload in an object structure for reading thru the data in multiple places
     * @param json
	 * @return StoreUpdateIntegrationWrapper
     */
	public static StoreUpdateIntegrationWrapper parse(String json) {
		return (StoreUpdateIntegrationWrapper) System.JSON.deserialize(json, StoreUpdateIntegrationWrapper.class);
	}
}