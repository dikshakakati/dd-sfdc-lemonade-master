/**
 * @description       :
 * @author            : Pankaj
 * @group             :
 * @last modified on  : 07-15-2024
 * @last modified by  : SamikshaDD
**/
@SuppressWarnings('PMD.FieldNamingConventions')
public class RESSMOResponseWrapper {

	/**
	* @description Errors
	*/
	public class Errors {
	}

	public String message;
	public String error_message;
	public String uuid;
	public String storeAccountId;
	public Banking banking;
	public String onboardingLink;
    public Boolean success;
    public List<String> messages;

	/**
	* @description Banking
	*/
	public class Banking {
		public Boolean success;
		public List<Errors> errors;
	}

	/**
	* @description Parse
	* @author Pankaj | 07-09-2024
	* @param json
	* @return RESSMOResponseWrapper
	**/
	public static RESSMOResponseWrapper parse(String json) {
		return (RESSMOResponseWrapper) System.JSON.deserialize(json, RESSMOResponseWrapper.class);
	}
}