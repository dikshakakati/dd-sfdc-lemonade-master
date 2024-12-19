/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service implementation class for outbound integration payloads related logic.
 */
public inherited sharing class OutboundIntegrationPayloadServiceImpl implements IOutboundIntegrationPayloadService {
    private static final String DASH_SPLIT = '-';
    private static final String EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Email_Payload_Chunk_Size';
    private static final String ENTITY_NAME_INTERFACE_TRANSACTION = 'InterfaceTransaction';
    private static final String ENTITY_NAME_MX_ORDER = 'Merchant Order';
    private static final String ENTITY_NAME_STORE_ACCOUNT = 'StoreAccount';
    private static final String ENTITY_NAME_WORK_STEP = 'WorkStep';
    private static final String PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Photoshoot_Payload_Chunk_Size';
    private static final String TABLET_OUTBOUND_EVENT_NAME = 'tablet-order-create-event';
    private static final String TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Tablet_Payload_Chunk_Size';

    private Integer emailPayloadChunkSize;
    private Integer photoshootPayloadChunkSize;
    private Integer tabletPayloadChunkSize;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public OutboundIntegrationPayloadServiceImpl() {
        collectStaticConfigurations();
    }

    /**
     * @description It is used to collect related record Ids from Activation Checklist payload.
     * @JIRA# LEM-13305
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public Map<String, Set<String>> collectRecordIdsFromActivationChecklistPayload(
        List<String> outboundPayloads
    ) {
        Map<String, Set<String>> entityNameToIds = new Map<String, Set<String>>();
        entityNameToIds.put(ENTITY_NAME_STORE_ACCOUNT, new Set<String>());
        entityNameToIds.put(ENTITY_NAME_WORK_STEP, new Set<String>());
        ActivationChecklistOutboundWrapper activationChecklistWrapper;
        for (String eachOutboundPayload : outboundPayloads) {
            activationChecklistWrapper = (ActivationChecklistOutboundWrapper) JSON.deserialize(
                eachOutboundPayload,
                ActivationChecklistOutboundWrapper.class
            );
            for (
                ActivationChecklistOutboundWrapper.ActivationChecklistDetails eachActivationChecklistDetails : activationChecklistWrapper.requestPayload
            ) {
                entityNameToIds.get(ENTITY_NAME_STORE_ACCOUNT)
                    .add(eachActivationChecklistDetails.accountSalesforceId);
                entityNameToIds.get(ENTITY_NAME_WORK_STEP)
                    .add(eachActivationChecklistDetails.workStepSalesforceId);
            }
        }
        return entityNameToIds;
    }

    /**
     * @description It is used to collect related record Ids from Email payload.
     * @JIRA# LEM-13778
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public Map<String, Set<String>> collectRecordIdsFromEmailPayload(
        List<String> outboundPayloads
    ) {
        Map<String, Set<String>> entityNameToIds = new Map<String, Set<String>>();
        entityNameToIds.put(ENTITY_NAME_INTERFACE_TRANSACTION, new Set<String>());
        EmailOutboundPayloads.EmailOutboundWrapper newEmailOutboundWrapper;
        EmailOutboundPayloads emailOutboundPayloadsInstance = new EmailOutboundPayloads();
        for (String eachOutboundPayload : outboundPayloads) {
            newEmailOutboundWrapper = (EmailOutboundPayloads.EmailOutboundWrapper) JSON.deserialize(
                eachOutboundPayload,
                EmailOutboundPayloads.EmailOutboundWrapper.class
            );
            entityNameToIds.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                .addAll(
                    emailOutboundPayloadsInstance.getInterfaceTransactionSFIDs(
                        newEmailOutboundWrapper
                    )
                );
        }
        return entityNameToIds;
    }

    /**
     * @description It is used to collect related record Ids from Mx Fraud Documents payloads.
     * @JIRA# LEM-15836
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public Map<String, Set<String>> collectRecordIdsFromMxFraudPayload(
        List<String> outboundPayloads
    ) {
        Map<String, Set<String>> entityNameToIds = new Map<String, Set<String>>();
        entityNameToIds.put(ENTITY_NAME_INTERFACE_TRANSACTION, new Set<String>());
        MxFraudDocumentsPayloads.MxFraudDocumentDetails newMxFraudDocumentDetails;
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadsInstance = new MxFraudDocumentsPayloads();
        for (String eachOutboundPayload : outboundPayloads) {
            newMxFraudDocumentDetails = (MxFraudDocumentsPayloads.MxFraudDocumentDetails) JSON.deserialize(
                eachOutboundPayload,
                MxFraudDocumentsPayloads.MxFraudDocumentDetails.class
            );
            entityNameToIds.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                .add(
                    mxFraudDocumentsPayloadsInstance.getInterfaceTransactionSFID(
                        newMxFraudDocumentDetails
                    )
                );
        }
        return entityNameToIds;
    }

    /**
     * @description It is used to collect related record Ids from Mx Order payload.
     * @JIRA# LEM-13506
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    public Map<String, Set<String>> collectRecordIdsFromMxOrderPayload(
        List<String> outboundPayloads
    ) {
        Map<String, Set<String>> entityNameToIds = new Map<String, Set<String>>();
        entityNameToIds.put(ENTITY_NAME_STORE_ACCOUNT, new Set<String>());
        entityNameToIds.put(ENTITY_NAME_MX_ORDER, new Set<String>());
        MerchantOrdersPayloads.MerchantOrdersWrapper mxOrderWrapper;
        MerchantOrdersPayloads merchantOrdersPayloadsInstance = new MerchantOrdersPayloads();
        for (String eachOutboundPayload : outboundPayloads) {
            mxOrderWrapper = (MerchantOrdersPayloads.MerchantOrdersWrapper) JSON.deserialize(
                eachOutboundPayload,
                MerchantOrdersPayloads.MerchantOrdersWrapper.class
            );
            entityNameToIds.get(ENTITY_NAME_STORE_ACCOUNT)
                .addAll(merchantOrdersPayloadsInstance.getAccountSFIDs(mxOrderWrapper));
            entityNameToIds.get(ENTITY_NAME_MX_ORDER)
                .addAll(merchantOrdersPayloadsInstance.getOrderSFIDs(mxOrderWrapper));
        }
        return entityNameToIds;
    }

    /**
     * @description It is used to collect related record Ids from Mx Order payload.
     * @JIRA# LEM-13506
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    public Map<String, Set<String>> collectRecordIdsFromPhotoshootMxOrderPayload(
        List<String> outboundPayloads
    ) {
        Map<String, Set<String>> entityNameToIds = new Map<String, Set<String>>();
        entityNameToIds.put(ENTITY_NAME_STORE_ACCOUNT, new Set<String>());
        entityNameToIds.put(ENTITY_NAME_MX_ORDER, new Set<String>());
        MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper mxOrderWrapper;
        MerchantOrdersPayloads merchantOrdersPayloadsInstance = new MerchantOrdersPayloads();
        for (String eachOutboundPayload : outboundPayloads) {
            mxOrderWrapper = (MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper) JSON.deserialize(
                eachOutboundPayload,
                MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper.class
            );
            entityNameToIds.get(ENTITY_NAME_STORE_ACCOUNT)
                .addAll(merchantOrdersPayloadsInstance.getPhotoshootAccountSFIDs(mxOrderWrapper));
            entityNameToIds.get(ENTITY_NAME_MX_ORDER)
                .addAll(merchantOrdersPayloadsInstance.getPhotoshootOrderSFIDs(mxOrderWrapper));
        }
        return entityNameToIds;
    }

    /**
     * @description It generates chunked payloads for Email integration based on
     * passed Interface Transactions and configured chunk size.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsForEmailIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        List<String> interfaceTransactionsChunkedPayloads = new List<String>();
        EmailOutboundPayloads emailOutboundPayloadsInstance = new EmailOutboundPayloads();
        EmailOutboundPayloads.EmailOutboundWrapper newEmailOutboundWrapper = new EmailOutboundPayloads.EmailOutboundWrapper(
            getUUID()
        );
        EmailOutboundPayloads.EmailOutboundDetails newEmailOutboundDetails;
        Integer payloadCountInCurrentChunk = 0;
        Integer processedPayloadCount = 0;
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            processedPayloadCount = processedPayloadCount + 1;
            payloadCountInCurrentChunk = payloadCountInCurrentChunk + 1;
            newEmailOutboundDetails = (EmailOutboundPayloads.EmailOutboundDetails) JSON.deserialize(
                eachInterfaceTransaction.Payload__c,
                EmailOutboundPayloads.EmailOutboundDetails.class
            );
            emailOutboundPayloadsInstance.setInterfaceTransactionSFID(
                newEmailOutboundDetails,
                eachInterfaceTransaction.Id
            );
            if (payloadCountInCurrentChunk < emailPayloadChunkSize) {
                emailOutboundPayloadsInstance.setRequestPayload(
                    newEmailOutboundWrapper,
                    newEmailOutboundDetails
                );
                if (processedPayloadCount == interfaceTransactions.size()) {
                    interfaceTransactionsChunkedPayloads.add(
                        JSON.Serialize(newEmailOutboundWrapper)
                    );
                }
            } else {
                emailOutboundPayloadsInstance.setRequestPayload(
                    newEmailOutboundWrapper,
                    newEmailOutboundDetails
                );
                interfaceTransactionsChunkedPayloads.add(JSON.Serialize(newEmailOutboundWrapper));
                newEmailOutboundWrapper = new EmailOutboundPayloads.EmailOutboundWrapper(getUUID());
                payloadCountInCurrentChunk = 0;
            }
        }
        return interfaceTransactionsChunkedPayloads;
    }

    /**
     * @description It generates chunked payloads for Mx Fraud Document integration based on
     * passed Interface Transactions and configured chunk size.
     * As per discussion with Mulesoft team, updated the logic to send one payload per store.
     * Bulk payload/chunking will not be handled by Mulesoft.
     * @JIRA# LEM-15836
     * @param interfaceTransactions
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsForMxFraudDocumentsIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        List<String> interfaceTransactionsChunkedPayloads = new List<String>();
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadsInstance = new MxFraudDocumentsPayloads();
        MxFraudDocumentsPayloads.MxFraudDocumentDetails newMxFraudDocumentDetails;
        Integer processedPayloadCount = 0;
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            processedPayloadCount = processedPayloadCount + 1;
            newMxFraudDocumentDetails = (MxFraudDocumentsPayloads.MxFraudDocumentDetails) JSON.deserialize(
                eachInterfaceTransaction.Payload__c,
                MxFraudDocumentsPayloads.MxFraudDocumentDetails.class
            );
            mxFraudDocumentsPayloadsInstance.setInterfaceTransactionSFID(
                newMxFraudDocumentDetails,
                eachInterfaceTransaction.Id
            );
            interfaceTransactionsChunkedPayloads.add(JSON.Serialize(newMxFraudDocumentDetails));
        }
        return interfaceTransactionsChunkedPayloads;
    }

    /**
     * @description It generates chunked payloads for passed Interface Transactions
     * based on configured chunk size.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsForMxOrderIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        List<String> interfaceTransactionsChunkedPayloads = new List<String>();
        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.MerchantOrdersWrapper newMerchantOrdersWrapper = new MerchantOrdersPayloads.MerchantOrdersWrapper(
            getUUID(),
            TABLET_OUTBOUND_EVENT_NAME
        );
        Integer orderCountInCurrentChunk = 0;
        Integer processedOrderCount = 0;
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            processedOrderCount = processedOrderCount + 1;
            orderCountInCurrentChunk = orderCountInCurrentChunk + 1;
            if (orderCountInCurrentChunk < tabletPayloadChunkSize) {
                mxOrdersPayloadsInstance.setOrder(
                    newMerchantOrdersWrapper,
                    (MerchantOrdersPayloads.MxOrdersOutboundWrapper) JSON.deserialize(
                        eachInterfaceTransaction.Payload__c,
                        MerchantOrdersPayloads.MxOrdersOutboundWrapper.class
                    )
                );
                if (processedOrderCount == interfaceTransactions.size()) {
                    interfaceTransactionsChunkedPayloads.add(
                        JSON.Serialize(newMerchantOrdersWrapper)
                    );
                }
            } else {
                mxOrdersPayloadsInstance.setOrder(
                    newMerchantOrdersWrapper,
                    (MerchantOrdersPayloads.MxOrdersOutboundWrapper) JSON.deserialize(
                        eachInterfaceTransaction.Payload__c,
                        MerchantOrdersPayloads.MxOrdersOutboundWrapper.class
                    )
                );
                interfaceTransactionsChunkedPayloads.add(JSON.Serialize(newMerchantOrdersWrapper));
                newMerchantOrdersWrapper = new MerchantOrdersPayloads.MerchantOrdersWrapper(
                    getUUID(),
                    TABLET_OUTBOUND_EVENT_NAME
                );
                orderCountInCurrentChunk = 0;
            }
        }
        return interfaceTransactionsChunkedPayloads;
    }

    /**
     * @description It generates chunked payloads for passed Interface Transactions
     * based on configured chunk size.
     * @JIRA# LEM-13499
     * @param interfaceTransactions
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsForMxOrderPhotoshootIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        List<String> interfaceTransactionsChunkedPayloads = new List<String>();
        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper newMerchantOrdersWrapper = new MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper(
            getUUID()
        );
        Integer orderCountInCurrentChunk = 0;
        Integer processedOrderCount = 0;
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            processedOrderCount = processedOrderCount + 1;
            orderCountInCurrentChunk = orderCountInCurrentChunk + 1;
            if (orderCountInCurrentChunk < photoshootPayloadChunkSize) {
                mxOrdersPayloadsInstance.setPhotoshootOrder(
                    newMerchantOrdersWrapper,
                    (MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper) JSON.deserialize(
                        eachInterfaceTransaction.Payload__c,
                        MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper.class
                    )
                );
                if (processedOrderCount == interfaceTransactions.size()) {
                    interfaceTransactionsChunkedPayloads.add(
                        JSON.Serialize(newMerchantOrdersWrapper)
                    );
                }
            } else {
                mxOrdersPayloadsInstance.setPhotoshootOrder(
                    newMerchantOrdersWrapper,
                    (MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper) JSON.deserialize(
                        eachInterfaceTransaction.Payload__c,
                        MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper.class
                    )
                );
                interfaceTransactionsChunkedPayloads.add(JSON.Serialize(newMerchantOrdersWrapper));
                newMerchantOrdersWrapper = new MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper(
                    getUUID()
                );
                orderCountInCurrentChunk = 0;
            }
        }
        return interfaceTransactionsChunkedPayloads;
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.emailPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.photoshootPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.tabletPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It generates a sequence of alpha-numeric ID used as unique identifier
     * for outbound integration payload.
     * @return String
     */
    private String getUUID() {
        Blob blbKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blbKey);
        String uuid =
            hexKey.SubString(0, 8) +
            DASH_SPLIT +
            hexKey.SubString(8, 12) +
            DASH_SPLIT +
            hexKey.SubString(12, 16) +
            DASH_SPLIT +
            hexKey.SubString(16, 20) +
            DASH_SPLIT +
            hexKey.substring(20);
        return uuid;
    }
}