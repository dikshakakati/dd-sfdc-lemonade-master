/**
 * @author Deloitte
 * @date 02/12/2022
 * @description Interface to add AccountContactRelation domain class methods.
 */
public interface IAccountContactRelations extends fflib_ISObjects {
    /**
     * @description It is used to validate the contact records with AccountContactRelation's role
     * as 'Accounting Contact' for blank SSN and Date of Birth.
     */
    void validateSSNAndBirthdate();

    /**
     * @description It is used to validate whether the OCR creation is needed or not when a
     * Decision Maker ACR is inserted.
     * @JIRA# LEM-13473
     */
    void validateOCRCreation();

    /**
     * @description It is used to update Roles on ACR based on SSMO events.
     */
    void updateRolesByEventType();
}