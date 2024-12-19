/**
 * @author Deloitte
 * @date 06/10/2024
 * @description Service implementation class for  InstantIngestionEnumMappingsService related logic.
 */
public inherited sharing class InstantIngestionEnumMappingsServiceImpl implements IInstantIngestionEnumMappingsService {
    private static final String AUTO_RUN_ADS = 'AUTO_RUN_ADS';
    private static final String AUTO_RUN_ADS_GROUP = 'Auto Run Ads';
    private static final String BRICK_MORTAR = 'Brick and Mortar';
    private static final String EMAIL = 'Email';
    private static final String FAX = 'Fax';
    private static final String FIFTEEN_TO_THIRTY = '23';
    private static final String FIVE_TO_FIFTEEN = '10';
    private static final String FOOD_TRUCK = 'Food Truck';
    private static final String MANDATORY_HEADER = 'MANDATORY_HEADER';
    private static final String MANDATORY_HEADER_GROUP = 'Mandatory Header Enabled';
    private static final String MERCHANT_TYPE_ENTERPRISE = 'MERCHANT_TYPE_ENTERPRISE';
    private static final String MERCHANT_TYPE_FOODTRUCK = 'MERCHANT_TYPE_FOODTRUCK';
    private static final String MERCHANT_TYPE_GHOSTKITCHEN = 'MERCHANT_TYPE_GHOSTKITCHEN';
    private static final String MERCHANT_TYPE_LIQUOR = 'MERCHANT_TYPE_LIQUOR';
    private static final String MERCHANT_TYPE_LOCAL = 'MERCHANT_TYPE_LOCAL';
    private static final String MERCHANT_TYPE_NATIONAL = 'MERCHANT_TYPE_NATIONAL';
    private static final String MERCHANT_TYPE_UNSPECIFIED = 'MERCHANT_TYPE_UNSPECIFIED';
    private static final String MERCHANT_TYPE_VIRTUAL = 'MERCHANT_TYPE_VIRTUAL';
    private static final String NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY = 'NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY';
    private static final String NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN = 'NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN';
    private static final String NUMBER_OF_LOCATIONS_ONE = 'NUMBER_OF_LOCATIONS_ONE';
    private static final String NUMBER_OF_LOCATIONS_ONE_TO_FIVE = 'NUMBER_OF_LOCATIONS_ONE_TO_FIVE';
    private static final String NUMBER_OF_LOCATIONS_THIRTY_PLUS = 'NUMBER_OF_LOCATIONS_THIRTY_PLUS';
    private static final String NUMBER_OF_LOCATIONS_TWO_TO_FIVE = 'NUMBER_OF_LOCATIONS_TWO_TO_FIVE';
    private static final String NUMBER_OF_LOCATIONS_UNSPECIFIED = 'NUMBER_OF_LOCATIONS_UNSPECIFIED';
    private static final String ORDER_PROTOCOL_EMAIL = 'ORDER_PROTOCOL_EMAIL';
    private static final String ORDER_PROTOCOL_FAX = 'ORDER_PROTOCOL_FAX';
    private static final String ORDER_PROTOCOL_INDICATOR_UNSPECIFIED = 'ORDER_PROTOCOL_INDICATOR_UNSPECIFIED';
    private static final String ORDER_PROTOCOL_POINT_OF_SALE = 'ORDER_PROTOCOL_POINT_OF_SALE';
    private static final String ORDER_PROTOCOL_TABLET = 'ORDER_PROTOCOL_TABLET';
    private static final String ORDER_PROTOCOL_TABLET_PRINTER = 'ORDER_PROTOCOL_TABLET_PRINTER';
    private static final String OPTIONAL_BANKING = 'OPTIONAL_BANKING';
    private static final String OPTIONAL_BANKING_GROUP = 'Optional Banking Enabled';
    private static final String OTHER = 'Other';
    private static final String ONE = '1';
    private static final String ONE_TO_FIVE = '2';
    private static final String POINT_OF_SALE = 'POS';
    private static final String PRIMARY_VERTICAL_FLORAL = 'Floral';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String SINGULARITY = 'SINGULARITY';
    private static final String SINGULARITY_GROUP = 'Singularity';
    private static final String SINGULARITY_2 = 'SINGULARITY_2';
    private static final String SINGULARITY_2_GROUP = 'Singularity_2';
    private static final String STRIPE_FC = 'STRIPE_FC';
    private static final String STRIPE_FC_GROUP = 'Stripe FC';
    private static final String TABLET = 'Tablet (DoorDash Owns)';
    private static final String TABLET_PRINTER = 'Tablet and Printer (DoorDash Owns)';
    private static final String THIRTY_PLUS = '30';
    private static final String TWO_TO_FIVE = '3';
    private static final String VERTICAL_TYPE_FLOWERS = 'VERTICAL_TYPE_FLOWERS';
    private static final String VERTICAL_TYPE_RESTAURANT = 'VERTICAL_TYPE_RESTAURANT';
    private static final String VERTICAL_TYPE_UNSPECIFIED = 'VERTICAL_TYPE_UNSPECIFIED';
    private static final String VIRTUAL_TYPE = 'Virtual';
    private static final String ZERO = '0';
    private static final String ERROR_MESSAGE_PRIMARY_VERTICAL = 'Unknown Primary :';
    private static final String ERROR_MESSAGE_ORDER_PROTOCOL = 'Unknown Order Protocol :';
    private static final String ERROR_MESSAGE_ESTIMATED_STORE = 'Unknown Estimated Store :';
    private static final String ERROR_MESSAGE_STORE_TYPE = 'Unknown Store Type :';
    private static final String ERROR_MESSAGE_TREATMENT_GROUP = 'Unknown Treatment Group :';
    private enum PRIMARYVERTICALENUMFIELDS {
        VERTICAL_TYPE_UNSPECIFIED,
        VERTICAL_TYPE_RESTAURANT,
        VERTICAL_TYPE_FLOWERS
    }
    private enum ORDERPROTOCOLENUMFIELDS {
        ORDER_PROTOCOL_INDICATOR_UNSPECIFIED,
        ORDER_PROTOCOL_TABLET_PRINTER,
        ORDER_PROTOCOL_TABLET,
        ORDER_PROTOCOL_EMAIL,
        ORDER_PROTOCOL_FAX,
        ORDER_PROTOCOL_POINT_OF_SALE
    }
    private enum ESTIMATEDSTOREENUMFIELDS {
        NUMBER_OF_LOCATIONS_UNSPECIFIED,
        NUMBER_OF_LOCATIONS_ONE,
        NUMBER_OF_LOCATIONS_ONE_TO_FIVE,
        NUMBER_OF_LOCATIONS_TWO_TO_FIVE,
        NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN,
        NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY,
        NUMBER_OF_LOCATIONS_THIRTY_PLUS
    }
    private enum STORETYPEENUMFIELDS {
        NUMBER_OF_LOCATIONS_THIRTY_PLUS,
        MERCHANT_TYPE_LOCAL,
        MERCHANT_TYPE_NATIONAL,
        MERCHANT_TYPE_UNSPECIFIED,
        MERCHANT_TYPE_LIQUOR,
        MERCHANT_TYPE_ENTERPRISE,
        MERCHANT_TYPE_VIRTUAL,
        MERCHANT_TYPE_GHOSTKITCHEN,
        MERCHANT_TYPE_FOODTRUCK
    }
    private enum TREATMENTGROUPNUMFIELDS {
        SINGULARITY,
        SINGULARITY_2,
        OPTIONAL_BANKING,
        AUTO_RUN_ADS,
        STRIPE_FC,
        MANDATORY_HEADER
    }
    private static final Map<String, PRIMARYVERTICALENUMFIELDS> PRIMARYVERTICALMAPPINGS = new Map<String, PRIMARYVERTICALENUMFIELDS>{
        VERTICAL_TYPE_UNSPECIFIED => PRIMARYVERTICALENUMFIELDS.VERTICAL_TYPE_UNSPECIFIED,
        VERTICAL_TYPE_RESTAURANT => PRIMARYVERTICALENUMFIELDS.VERTICAL_TYPE_RESTAURANT,
        VERTICAL_TYPE_FLOWERS => PRIMARYVERTICALENUMFIELDS.VERTICAL_TYPE_FLOWERS
    };
    private static final Map<String, ORDERPROTOCOLENUMFIELDS> ORDERPROTOCOLMAPPINGS = new Map<String, ORDERPROTOCOLENUMFIELDS>{
        ORDER_PROTOCOL_INDICATOR_UNSPECIFIED => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_INDICATOR_UNSPECIFIED,
        ORDER_PROTOCOL_TABLET_PRINTER => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_TABLET_PRINTER,
        ORDER_PROTOCOL_TABLET => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_TABLET,
        ORDER_PROTOCOL_EMAIL => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_EMAIL,
        ORDER_PROTOCOL_FAX => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_FAX,
        ORDER_PROTOCOL_POINT_OF_SALE => ORDERPROTOCOLENUMFIELDS.ORDER_PROTOCOL_POINT_OF_SALE
    };
    private static final Map<String, ESTIMATEDSTOREENUMFIELDS> ESTIMATEDSTOREMAPPINGS = new Map<String, ESTIMATEDSTOREENUMFIELDS>{
        NUMBER_OF_LOCATIONS_UNSPECIFIED => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_UNSPECIFIED,
        NUMBER_OF_LOCATIONS_ONE => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_ONE,
        NUMBER_OF_LOCATIONS_ONE_TO_FIVE => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_ONE_TO_FIVE,
        NUMBER_OF_LOCATIONS_TWO_TO_FIVE => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_TWO_TO_FIVE,
        NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN,
        NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY,
        NUMBER_OF_LOCATIONS_THIRTY_PLUS => ESTIMATEDSTOREENUMFIELDS.NUMBER_OF_LOCATIONS_THIRTY_PLUS
    };
    private static final Map<String, STORETYPEENUMFIELDS> STORETYPEMAPPINGS = new Map<String, STORETYPEENUMFIELDS>{
        MERCHANT_TYPE_NATIONAL => STORETYPEENUMFIELDS.MERCHANT_TYPE_NATIONAL,
        MERCHANT_TYPE_UNSPECIFIED => STORETYPEENUMFIELDS.MERCHANT_TYPE_UNSPECIFIED,
        MERCHANT_TYPE_ENTERPRISE => STORETYPEENUMFIELDS.MERCHANT_TYPE_ENTERPRISE,
        MERCHANT_TYPE_VIRTUAL => STORETYPEENUMFIELDS.MERCHANT_TYPE_VIRTUAL,
        MERCHANT_TYPE_GHOSTKITCHEN => STORETYPEENUMFIELDS.MERCHANT_TYPE_GHOSTKITCHEN,
        MERCHANT_TYPE_FOODTRUCK => STORETYPEENUMFIELDS.MERCHANT_TYPE_FOODTRUCK,
        MERCHANT_TYPE_LOCAL => STORETYPEENUMFIELDS.MERCHANT_TYPE_LOCAL,
        MERCHANT_TYPE_LIQUOR => STORETYPEENUMFIELDS.MERCHANT_TYPE_LIQUOR
    };
    private static final Map<String, TREATMENTGROUPNUMFIELDS> TREATMENTGROUPMAPPINGS = new Map<String, TREATMENTGROUPNUMFIELDS>{
        SINGULARITY => TREATMENTGROUPNUMFIELDS.SINGULARITY,
        SINGULARITY_2 => TREATMENTGROUPNUMFIELDS.SINGULARITY_2,
        OPTIONAL_BANKING => TREATMENTGROUPNUMFIELDS.OPTIONAL_BANKING,
        AUTO_RUN_ADS => TREATMENTGROUPNUMFIELDS.AUTO_RUN_ADS,
        STRIPE_FC => TREATMENTGROUPNUMFIELDS.STRIPE_FC,
        MANDATORY_HEADER => TREATMENTGROUPNUMFIELDS.MANDATORY_HEADER
    };
    /**
     * @description It is used to return the primary vertical details received in payload.
     * @param receivedPrimaryVertical
     * @return String
     */
    public String getPrimaryVertical(String receivedPrimaryVertical) {
        switch on PRIMARYVERTICALMAPPINGS.get(receivedPrimaryVertical) {
            when VERTICAL_TYPE_UNSPECIFIED, VERTICAL_TYPE_RESTAURANT {
                return PRIMARY_VERTICAL_RX;
            }
            when VERTICAL_TYPE_FLOWERS {
                return PRIMARY_VERTICAL_FLORAL;
            }
            when else {
                return ERROR_MESSAGE_PRIMARY_VERTICAL + ' ' + receivedPrimaryVertical;
            }
        }
    }
    /**
     * @description It is used to return the order Protocol details received in payload.
     * @param receivedOrderProtocol
     * @return String
     */
    public String getOrderProtocol(String receivedOrderProtocol) {
        switch on ORDERPROTOCOLMAPPINGS.get(receivedOrderProtocol) {
            when ORDER_PROTOCOL_INDICATOR_UNSPECIFIED {
                return OTHER;
            }
            when ORDER_PROTOCOL_TABLET_PRINTER {
                return TABLET_PRINTER;
            }
            when ORDER_PROTOCOL_TABLET {
                return TABLET;
            }
            when ORDER_PROTOCOL_EMAIL {
                return EMAIL;
            }
            when ORDER_PROTOCOL_FAX {
                return FAX;
            }
            when ORDER_PROTOCOL_POINT_OF_SALE {
                return POINT_OF_SALE;
            }
            when else {
                return ERROR_MESSAGE_ORDER_PROTOCOL + ' ' + receivedOrderProtocol;
            }
        }
    }
    /**
     * @description It is used to return the Estimated store details received in payload.
     * @param receivedEstimatedStore
     * @return String
     */
    public String getEstimatedStore(String receivedEstimatedStore) {
        switch on ESTIMATEDSTOREMAPPINGS.get(receivedEstimatedStore) {
            when NUMBER_OF_LOCATIONS_UNSPECIFIED {
                return ZERO;
            }
            when NUMBER_OF_LOCATIONS_ONE {
                return ONE;
            }
            when NUMBER_OF_LOCATIONS_ONE_TO_FIVE {
                return ONE_TO_FIVE;
            }
            when NUMBER_OF_LOCATIONS_TWO_TO_FIVE {
                return TWO_TO_FIVE;
            }
            when NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN {
                return FIVE_TO_FIFTEEN;
            }
            when NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY {
                return FIFTEEN_TO_THIRTY;
            }
            when NUMBER_OF_LOCATIONS_THIRTY_PLUS {
                return THIRTY_PLUS;
            }
            when else {
                return ERROR_MESSAGE_ESTIMATED_STORE + ' ' + receivedEstimatedStore;
            }
        }
    }
    /**
     * @description It is used to return the store type details received in payload.
     * @param  receivedStoreType
     * @return String
     */
    public String getStoreType(String receivedStoreType) {
        switch on STORETYPEMAPPINGS.get(receivedStoreType) {
            when MERCHANT_TYPE_LOCAL,
                MERCHANT_TYPE_NATIONAL,
                MERCHANT_TYPE_UNSPECIFIED,
                MERCHANT_TYPE_LIQUOR,
                MERCHANT_TYPE_ENTERPRISE {
                return BRICK_MORTAR;
            }
            when MERCHANT_TYPE_VIRTUAL, MERCHANT_TYPE_GHOSTKITCHEN {
                return VIRTUAL_TYPE;
            }
            when MERCHANT_TYPE_FOODTRUCK {
                return FOOD_TRUCK;
            }
            when else {
                return ERROR_MESSAGE_STORE_TYPE + ' ' + receivedStoreType;
            }
        }
    }
    /**
     * @description It is used to return the treatment group details received in payload.
     * @param receivedTreatmentGroup
     * @return String
     */
    public String getTreatmentGroup(String receivedTreatmentGroup) {
        switch on TREATMENTGROUPMAPPINGS.get(receivedTreatmentGroup) {
            when SINGULARITY {
                return SINGULARITY_GROUP;
            }
            when SINGULARITY_2 {
                return SINGULARITY_2_GROUP;
            }
            when OPTIONAL_BANKING {
                return OPTIONAL_BANKING_GROUP;
            }
            when AUTO_RUN_ADS {
                return AUTO_RUN_ADS_GROUP;
            }
            when STRIPE_FC {
                return STRIPE_FC_GROUP;
            }
            when MANDATORY_HEADER {
                return MANDATORY_HEADER_GROUP;
            }
            when else {
                return ERROR_MESSAGE_TREATMENT_GROUP + ' ' + receivedTreatmentGroup;
            }
        }
    }
}