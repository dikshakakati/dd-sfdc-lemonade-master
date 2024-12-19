/**
 * @author Deloitte
 * @date 16/03/2022
 * @description Interface to add Contact domain class methods
 */
public interface IContacts extends fflib_ISObjects {
    /**
     * @description This method used to validate phone number.
     */
    void validateAndNormalizePhoneNumberFormat();

    /**
     * @description This method used to validate phone number and SSN field for a Contact having Accounting Contact role the store's corporate parent
     * having subscriptions to alcohol delivery or alcohol pickup and the store has eligible billing country or billing state.
     */
    void validateSSNAndBirthdateWithAccountingContactRole();
    /**
     * @description It is used to process contacts post lead conversion.
     * @param existing
     */
    void processContactsOnLeadConversion(Map<Id, SObject> existing);
}