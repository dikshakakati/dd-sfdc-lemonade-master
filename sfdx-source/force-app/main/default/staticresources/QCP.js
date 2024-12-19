/**
 * @description : This script runs under the CPQ Quote Calculator Plugin for Page Security and Quote Calculations.
 * This script lives as record data in the CPQ SBQQ__CustomScript__c object, but is checked in to git for versioning.
 * Updates need to be copy and pasted into the custom script record in the org you are working.
 *
 * For documentation visit:
 * Quote Calculator Plugin (QCP) - https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_plugins.meta/cpq_dev_plugins/cpq_dev_jsqcp_parent.htm
 * Page Security Plugin (PSP) - https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_plugins.meta/cpq_dev_plugins/cpq_javascript_page_security_plugin.htm
 */

/**
* @description : The calculator calls this method after it completes a calculation to determine if a field is editable on the line editor screen.
* @param {fieldName} : The quote line field that should be Editable or not.
* @returns Boolean : true if editable
*/
export function isFieldEditable(fieldName, line) {
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') && (fieldName == 'Original_Commission__c' || fieldName == 'SBQQ__ListPrice__c' || fieldName == 'Store_Account__c')) {
        return false;
    }
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') && (!line.SBQQ__Quote__r.Trial_Period_Quote__c) && (fieldName == 'Trial_Commission__c')) {
        return false;
    }
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') &&
        (line.SBQQ__Existing__c || (line.SBQQ__RequiredBy__r == null && (line.SBQQ__ProductFamily__c != 'Advertisement' && line.SBQQ__ProductFamily__c != 'Marketplace Promotion'))) &&
        (fieldName == 'Original_Commission__c' ||
            fieldName == 'SBQQ__ListPrice__c' ||
            fieldName == 'Store_Account__c' ||
            fieldName == 'SBQQ__SpecialPrice__c' ||
            fieldName == 'Trial_Commission__c' ||
            fieldName == 'Fee_Type__c' ||
            fieldName == 'Trial_Period__c' ||
            fieldName == 'Trial_End_Date__c' ||
            fieldName == 'Trial_Fee__c' ||
            fieldName == 'Requested_Commission__c')) {
        return false;
    }
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') &&
        (line.SBQQ__Existing__c) && line.Is_Original_Line_Cloned__c == true &&
        (fieldName == 'SBQQ__Quantity__c')) {
        return false;
    }
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') &&
        (!line.SBQQ__Existing__c) && line.SBQQ__Bundle__c == true &&
        (fieldName == 'SBQQ__Quantity__c')) {
        return false;
    }
    if ((line.SBQQ__Quote__r.Segment__c == 'SMB') &&
        (line.SBQQ__Existing__c || (!line.Is_Editable__c)) &&
        (fieldName == 'Fee_Type__c')) {
        return false;
    }
    if (line.CurrencyIsoCode == 'USD' &&
        (line.Package__c == 'Small Order Fulfillment (SOF)' || line.Package__c == 'Large Order Fulfillment (LOF)') &&
        (line.SBQQ__ProductName__c == 'Regulatory Dasher Fee - NYC' ||
            line.SBQQ__ProductName__c == 'Regulatory Dasher Fee - CA' ||
            line.SBQQ__ProductName__c == 'Regulatory Dasher Fee - Seattle')
    ) {
        return false;
    }
}

/**
 * @description : The calculator calls this method before calculation begins, but after formula fields have been evaluated.
 * @param {quoteLineModel[]} quoteLineModels JS array containing all lines in a quote.
 * @param {quoteModel} quoteModel JS representation of the quote.
 * @returns {Promise}
 */
export function onBeforeCalculate(quoteModel, quoteLineModels, conn) {
    let primaryMxCategory = quoteModel.record.Account_Primary_Vertical__c ? quoteModel.record.Account_Primary_Vertical__c : 'Rx';
    let dateComparison = quoteModel.record.SBQQ__StartDate__c ? convertDateString(quoteModel.record.SBQQ__StartDate__c) : 'TODAY';
    let quoteDRN = quoteModel.record.Deck_Rank__c;
    let quoteCurrency = quoteModel.record.CurrencyIsoCode;
    let quoteSplitCategory = quoteModel.record.Contract_Split_Category__c;
    let QueryResult;
    let productSearchKeys = [];
    let searchKeyData = {};
    let coreMarketplacePackageQuoteLines = [];
    let nonCoreMarketplacePackageQuoteLines = [];
    let isHardwareIncluded = false;
    let hardwareOptions = ['Tablet Fee', 'Printer Fee'];
    let coreMarketplacePackages = ['Basic Package', 'Plus Package', 'Premier Package', 'Self-Delivery'];
    let excludeAdsAndPromoProducts = ['Store Rewards (DD Loyalty)', 'Banners', 'CRM', 'DashPass Exclusive Items'];
    let hardwareCRTByProductName = new Map();
    let isCaviarAdded = false;
    let caviarPackageProducts = [];
    let caviarCRTByPackageProduct = new Map();
    let drivePackagesQuoteLines = [];
    let drivePackages = ['Small Order Fulfillment (SOF)', 'Large Order Fulfillment (LOF)'];
    let coreMarketplacePackageQuoteLinesForCaviar = [];
    let IsClonedCore = false;
    let isClonedAP = false;
    quoteModel.record.Is_Core_Upgraded__c = false;
    let quoteEligibleForAlcohol = [];

    // Extract unsaved quote lines from the quoteLineModels
    const quoteLines = quoteLineModels.map(quoteLineModel => quoteLineModel.record);
    let startDateCount = 0;
    let delayAfterCount = 0;
    let AlcoholPickupcount = 0;
    let AlcoholDeliverycount = 0;
    let packageProductToRequestedCommissionAD = new Map();
    let packageProductToRequestedCommissionAP = new Map();

    quoteLines.forEach(line => {
        if (line.SBQQ__ProductName__c == 'Alcohol Delivery' && line.SBQQ__Quantity__c != 0 && !line.SBQQ__Existing__c) {
            if (!packageProductToRequestedCommissionAD.has(line.Package__c)) {
                packageProductToRequestedCommissionAD.set(line.Package__c, line.Requested_Commission__c);
            }
        }
        if (line.SBQQ__ProductName__c == 'Alcohol Pickup' && line.SBQQ__Quantity__c != 0 && !line.SBQQ__Existing__c) {
            if (!packageProductToRequestedCommissionAP.has(line.Package__c)) {
                packageProductToRequestedCommissionAP.set(line.Package__c, line.Requested_Commission__c);
            }
        }
    });
    quoteLines.forEach(line => {
        if (packageProductToRequestedCommissionAD.size > 0) {

            if (line.SBQQ__ProductName__c == 'Delivery' && packageProductToRequestedCommissionAD.has(line.Package__c) && line.SBQQ__Quantity__c != 0) {
                if (line.Requested_Commission__c != packageProductToRequestedCommissionAD.get(line.Package__c)) {
                    AlcoholDeliverycount++;
                }
            }
        }
        if (packageProductToRequestedCommissionAP.size > 0) {
            if (line.SBQQ__ProductName__c == 'Pickup' && packageProductToRequestedCommissionAP.has(line.Package__c) && line.SBQQ__Quantity__c != 0) {
                if (line.Requested_Commission__c != packageProductToRequestedCommissionAP.get(line.Package__c)) {
                    AlcoholPickupcount++;
                }
            }
        }
        if (AlcoholPickupcount > 0) {
            quoteModel.record.Alcohol_Pickup_and_Pickup_Check__c = true;
        }
        else {
            quoteModel.record.Alcohol_Pickup_and_Pickup_Check__c = false;
        }
        if (AlcoholDeliverycount > 0) {
            quoteModel.record.Alcohol_Delivery_And_Delivery_Check__c = true;
        }
        else {
            quoteModel.record.Alcohol_Delivery_And_Delivery_Check__c = false;
        }
    });

    quoteLines.forEach(line => {
        if ((line.SBQQ__ProductCode__c === '10062' || line.SBQQ__ProductCode__c === '10061') && !line.SBQQ__Existing__c && line.SBQQ__UpgradedSubscription__c == null && !quoteEligibleForAlcohol.includes(quoteModel.record.Id)) {
            quoteEligibleForAlcohol.push((quoteModel.record.Id));
            quoteModel.record.Alcohol_Product_Quantity__c = true;
        }
        if (!quoteEligibleForAlcohol.includes(quoteModel.record.Id) && quoteModel.record.Alcohol_Product_Quantity__c != false) {
            quoteModel.record.Alcohol_Product_Quantity__c = false;
        }
        if (!line.SBQQ__Existing__c && quoteModel.record.Segment__c == 'SMB' && line.Split_Category__c == 'A&P'
            && !excludeAdsAndPromoProducts.includes(line.SBQQ__ProductName__c) && ((quoteModel.record.Opportunity_Type__c == 'New' && line.Start_Date__c != null) ||
                (quoteModel.record.Opportunity_Type__c == 'Existing' && line.Start_Date__c == null))) {
            startDateCount++;
        }
        if (startDateCount > 0) {
            quoteModel.record.Check_Start_Date_For_A_P_Product__c = true;
        }
        else {
            quoteModel.record.Check_Start_Date_For_A_P_Product__c = false;
        }
        if (!line.SBQQ__Existing__c && quoteModel.record.Segment__c == 'SMB' && line.Split_Category__c == 'A&P'
            && !excludeAdsAndPromoProducts.includes(line.SBQQ__ProductName__c) && ((quoteModel.record.Opportunity_Type__c == 'New' && line.Delay_after_Activation_days__c == null) || (quoteModel.record.Opportunity_Type__c == 'Existing' && line.Delay_after_Activation_days__c != null))) {
            delayAfterCount++;
        }
        if (delayAfterCount > 0) {
            quoteModel.record.Check_Delay_After_Activation_For_A_P__c = true;
        }
        else {
            quoteModel.record.Check_Delay_After_Activation_For_A_P__c = false;
        }
        //line.Opportunity_Record_Type_Text__c = quoteModel.record.Opportunity_Record_Type__c;
        //line.Deal_Desk_Submitted__c = quoteModel.record.Deal_Desk_Submitted__c;
        //Build search key for query
        if (line.SBQQ__Product__c && line.Parent_Package_Id__c && line.CurrencyIsoCode && primaryMxCategory && quoteModel.record.Segment__c == 'SMB') {
            let key = buildSearchKey(primaryMxCategory, line);
            //Don't search for keys that have already been priced.
            if (!line.Pricing_Search_Complete__c) {
                productSearchKeys.push(key);
            }
            //associate search key to relevant data
            searchKeyData[key] = { quoteLine: line, quote: quoteModel.record, rates: [] };
        }
        line.SBQQ__SpecialPriceType__c = 'Custom'; // BZAP-13968
        let isMarketplaceQuoteLine = line.SBQQ__ProductFamily__c == 'Marketplace' && !line.Package__c;
        if (isMarketplaceQuoteLine && coreMarketplacePackages.includes(line.SBQQ__ProductName__c)) {
            coreMarketplacePackageQuoteLines.push(line.SBQQ__ProductName__c);
            coreMarketplacePackageQuoteLinesForCaviar.push(line.SBQQ__ProductName__c);
        }
        else if (isMarketplaceQuoteLine) {
            nonCoreMarketplacePackageQuoteLines.push(line.SBQQ__ProductName__c);
        }
        if (!isHardwareIncluded && hardwareOptions.includes(line.SBQQ__ProductName__c)) {
            isHardwareIncluded = true;
        }
        if (line.Package__c === 'Caviar') {
            caviarPackageProducts.push(line.Package_Product__c);
        }
        if (!isCaviarAdded && line.SBQQ__ProductName__c === 'Caviar') {
            isCaviarAdded = true;
        }

    });

    quoteLines.forEach(line => {
        if (quoteModel.record.SBQQ__Type__c === 'Amendment' && quoteModel.record.Segment__c === 'SMB' && quoteSplitCategory === 'Core') {
            if (line.Split_Category__c == 'Core' && !line.SBQQ__Existing__c) {
                IsClonedCore = true;
            }
            if (line.Split_Category__c == 'A&P' && !line.SBQQ__Existing__c) {
                isClonedAP = true;
            }
        }
    });
    if (!IsClonedCore && isClonedAP) {
        quoteModel.record.Is_Core_Upgraded__c = true;
    }


    if (productSearchKeys.length > 0) {
        let searchKeyList = "('" + productSearchKeys.join("', '") + "')";
        let queryString = 'SELECT Id, Name, Product__c, Package_Product__c, Package__c, CurrencyIsoCode, Account_Primary_Vertical__c, Search_Key__c, Start__c, End__c, Region__c, Submarket_Name__c, Deck_Rank__c, Segment__c, Filter_Value_1__c,';
        queryString += ' Target_Rate__c, Floor_Rate__c, Price__c, Original_Commission__c, Ceiling_Rate__c, LastModifiedDate, Ace_Basic__c, Ace_Floor__c, Ceiling_Fee__c, Floor_Fee__c, User_Manager_Commission_Threshold__c,';
        queryString += ' User_Manager_Fee_Threshold__c, Deal_Desk_Commission_Threshold__c, Deal_Desk_Fee_Threshold__c, Dependent_Product__c';
        queryString += ' FROM Commission_Rate__c WHERE Start__c <= ' + dateComparison + ' AND End__c >= ' + dateComparison + ' AND Search_Key__c IN ';
        queryString += searchKeyList;
        queryString += ' AND CurrencyIsoCode = ' + "'" + quoteCurrency + "'";
        queryString += ' AND Package_Product__c = null';
        // query results
        return conn.query(queryString)
            .then(function (results) {
                if (results.totalSize) {
                    results.records.forEach(rate => {
                        let quoteLine = searchKeyData[rate.Search_Key__c].quoteLine;
                        let quote = searchKeyData[rate.Search_Key__c].quote;
                        if (quoteLine && quote) {
                            //determine number of matching fields for the rate entry against the quote line
                            rate.supplementalFieldMatches = countSupplementalFieldMatches(rate, quote, quoteLine);
                        }
                        searchKeyData[rate.Search_Key__c].rates.push(rate);
                    });
                }
                //Go back through sourced quote line data and determine rate match based on best criteria and map quote line field values
                quoteLines.filter(ql => ql.Package__c != 'Caviar').filter(ql => ql.Package__c != 'Hardware').forEach(line => {
                    if (!line.Pricing_Search_Complete__c) {
                        let key = buildSearchKey(primaryMxCategory, line);
                        let qlRateData = searchKeyData[key];
                        if (qlRateData && qlRateData.rates.length > 0) {
                            //If there are more than one rate find the one that had the most supplemental matches.
                            if (qlRateData.rates.length > 1) {
                                let mostMatches = Math.max(...Array.from(qlRateData.rates, r => r.supplementalFieldMatches));
                                let bestMatchRate = qlRateData.rates.find(r => r.supplementalFieldMatches === mostMatches);
                                line = mapCommissionRateFieldsToQL(bestMatchRate, line, quoteDRN);
                            } else {
                                line = mapCommissionRateFieldsToQL(qlRateData.rates[0], line, quoteDRN);
                            }
                            //Price serch is complete
                            line.Pricing_Search_Complete__c = true;
                        }
                    }
                });

                //Hardware Package is added
                if (isHardwareIncluded) {
                    if (coreMarketplacePackageQuoteLines.length === 0 && nonCoreMarketplacePackageQuoteLines) {
                        coreMarketplacePackageQuoteLines = nonCoreMarketplacePackageQuoteLines;
                    }
                    let packageNameList = "('" + coreMarketplacePackageQuoteLines.join("', '") + "')";
                    let hardwareOptionsList = "('" + hardwareOptions.join("', '") + "')";
                    let getCRTForHardwareOptions = 'Select Id,Price__c,Package__r.Name,Product__r.Name  from Commission_Rate__c where Package__r.Name IN ';
                    getCRTForHardwareOptions += packageNameList;
                    getCRTForHardwareOptions += ' And CurrencyIsoCode = ' + "'" + quoteCurrency + "'" + ' And Product__r.Name IN ' + hardwareOptionsList + ' Order by Price__c Desc';
                    QueryResult = conn.query(getCRTForHardwareOptions);
                    QueryResult.then(function (results) {
                        if (results.totalSize > 0) {
                            results.records.forEach(rate => {
                                hardwareCRTByProductName.set(rate.Product__r.Name, rate);
                            });
                            quoteLines.filter(ql => ql.Package__c == 'Hardware').forEach(line => {
                                if (!line.Pricing_Search_Complete__c && hardwareOptions.includes(line.SBQQ__ProductName__c)) {

                                    line = mapCommissionRateFieldsToQL(hardwareCRTByProductName.get(line.SBQQ__ProductName__c), line, quoteDRN);
                                    line.Pricing_Search_Complete__c = true;
                                }
                            });
                        }
                    });
                }

                //Caviar Package is Added
                if (isCaviarAdded) {
                    let packageNameList = "('" + coreMarketplacePackageQuoteLinesForCaviar.join("', '") + "')";
                    let caviarPackageOptionsProducts = "('" + caviarPackageProducts.join("', '") + "')";

                    let getCRTForCaviarProduct = 'Select Id, Price__c, Package__r.Name,Product__r.Name, ';
                    getCRTForCaviarProduct += 'Package_Product__c, CurrencyIsoCode, LastModifiedDate, Target_Rate__c, ';
                    getCRTForCaviarProduct += 'Floor_Rate__c, Original_Commission__c, Ceiling_Rate__c, Ceiling_Fee__c, ';
                    getCRTForCaviarProduct += 'Floor_Fee__c, User_Manager_Commission_Threshold__c, User_Manager_Fee_Threshold__c, ';
                    getCRTForCaviarProduct += 'Deal_Desk_Fee_Threshold__c, Deal_Desk_Commission_Threshold__c, Dependent_Product__c ';
                    getCRTForCaviarProduct += ' from Commission_Rate__c where Active__c = true AND (Package__r.Name IN ';
                    getCRTForCaviarProduct += packageNameList;
                    getCRTForCaviarProduct += 'OR Package__r.Name = ';
                    getCRTForCaviarProduct += "'Caviar'";
                    getCRTForCaviarProduct += ' ) AND Package_Product__c IN '
                    getCRTForCaviarProduct += caviarPackageOptionsProducts;
                    getCRTForCaviarProduct += ' And CurrencyIsoCode = ' + "'" + quoteCurrency + "'";

                    return conn.query(getCRTForCaviarProduct)
                        .then(function (results) {
                            if (results.totalSize > 0) {
                                results.records.forEach(rate => {
                                    if (
                                        coreMarketplacePackageQuoteLines.includes(rate.Package__r.Name)
                                        && coreMarketplacePackageQuoteLines.length > 0) {
                                        caviarCRTByPackageProduct.set(rate.Product__r.Name, rate);
                                    }
                                    if (coreMarketplacePackageQuoteLines.length === 0) {
                                        if (rate.Package__r.Name === 'Caviar') {
                                            caviarCRTByPackageProduct.set(rate.Product__r.Name, rate);
                                        }
                                    }
                                });

                                quoteLines.filter(ql => ql.Package__c == 'Caviar').forEach(line => {
                                    if (!line.Pricing_Search_Complete__c && caviarPackageProducts.includes(line.Package_Product__c) && caviarCRTByPackageProduct.get(line.SBQQ__ProductName__c)) {
                                        line = mapCommissionRateFieldsToQL(caviarCRTByPackageProduct.get(line.SBQQ__ProductName__c), line, quoteDRN);
                                        line.Pricing_Search_Complete__c = true;
                                    }
                                });
                            }
                        });
                }

            });

    }
    return Promise.resolve();
}
export function buildSearchKey(primaryMxCategory, quoteLine) {
    return quoteLine.SBQQ__Product__c + quoteLine.Parent_Package_Id__c + quoteLine.CurrencyIsoCode + primaryMxCategory;
}

export function convertDateString(startDate) {
    const splitStart = startDate.split("-");
    //In the date construtor, Month is zero based, so we must subtract 1.
    const quoteStartDate = new Date(parseInt(splitStart[0]), parseInt(splitStart[1]) - 1, parseInt(splitStart[2]));

    return quoteStartDate.toISOString().split('T')[0];
}
//BZAP-12492 - Determine how many supplemental field matches exist on the commission rate record
//Matches are given priority by the decimal portion.
export function countSupplementalFieldMatches(rate, quote, quoteLine) {
    let matches = 0.0;
    if (rate.Filter_Value_1__c) {
        if (rate.Filter_Value_1__c == quote.Quarterly_Rate_Threshold__c) {
            matches = matches + 1.1;
        } else {
            matches = matches - 0.1;
        }
    }
    if (rate.Segment__c) {
        if (rate.Segment__c == quote.Mx_Attributes__c) {
            matches = matches + 1.01;
        } else {
            matches = matches - 0.01;
        }
    }
    if (rate.Deck_Rank__c) {
        if (rate.Deck_Rank__c == quote.Deck_Rank__c) {
            matches = matches + 1.001;
        } else {
            matches = matches - 0.001;
        }
    }
    if (rate.Region__c) {
        if (quote.Business_Region__c == rate.Region__c) {
            matches = matches + 1.0001;
        } else {
            matches = matches - 0.0001;
        }
    }
    return matches;
}

export function mapCommissionRateFieldsToQL(rate, quoteLine, quoteDRN) {
    //quoteLine.Requested_Commission__c = rate.Original_Commission__c;
    quoteLine.CR_Modified_Date__c = rate.LastModifiedDate;
    quoteLine.Target_Rate__c = rate.Target_Rate__c;
    quoteLine.Floor_Rate__c = rate.Floor_Rate__c;
    quoteLine.SBQQ__ListPrice__c = rate.Price__c;
    quoteLine.Default_Fee__c = rate.Price__c;
    quoteLine.Commission_Rate_Number__c = rate.Id;
    quoteLine.Original_Commission__c = rate.Original_Commission__c;
    quoteLine.Default_Commission__c = rate.Original_Commission__c;
    quoteLine.Pricing_Audit__c = 'Apex';
    quoteLine.SBQQ__OriginalPrice__c = rate.Price__c;
    quoteLine.Ceiling_Rate__c = rate.Ceiling_Rate__c;
    quoteLine.Merchant_Deck_Rank__c = quoteDRN;
    quoteLine.Maximum_Fee__c = rate.Ceiling_Fee__c;
    quoteLine.Minimum_Fee__c = rate.Floor_Fee__c;
    quoteLine.User_Manager_Commission_Threshold__c = rate.User_Manager_Commission_Threshold__c;
    quoteLine.User_Manager_Fee_Threshold__c = rate.User_Manager_Fee_Threshold__c;
    quoteLine.Deal_Desk_Commission_Threshold__c = rate.Deal_Desk_Commission_Threshold__c;
    quoteLine.Deal_Desk_Fee_Threshold__c = rate.Deal_Desk_Fee_Threshold__c;
    quoteLine.Dependent_Product__c = rate.Dependent_Product__c;
    return quoteLine;
}


/**
* @description : The calculator calls this method after it evaluates price rules.
*/
export async function onAfterCalculate(quoteModel, quoteLineModels, conn) {
    const quotelineGroups = quoteModel.groups;
    const quoteLines = quoteLineModels.map(quoteLineModel => quoteLineModel.record);
    let hasQuoteLineGroups = false;
    quotelineGroups.forEach((group) => {
        hasQuoteLineGroups = true;
        const lines = group.lineItems.map(quoteLineModel => quoteLineModel.record);
        setTrialPeriodMismatch(lines);
    });
    quoteLines.forEach(line => {
        line.Is_Original_Line_Cloned__c = false;
    });
    setClonedLineFlagOnOriginalLine(quoteModel, quoteLines);

    //this condition is added to run the trial period check when there are no groups on cart. If and when we make a group
    //mandatory on cart then this can be removed.
    if (!hasQuoteLineGroups) {
        setTrialPeriodMismatch(quoteLines);
    }

    // Added conditional call to calculateQuoteTier LEM-14403
    if (quoteModel.record.Override_Tier__c == false) {
        await calculateQuoteTier(quoteModel, quoteLineModels, conn); // LEM-13257 DPEI Tier Calculation
    }
    let existingLinesFamily = [];
    let existingStorefrontLines = [];

    quoteLines.filter(ql => ql.SBQQ__Existing__c).filter(ql => ql.SBQQ__RequiredBy__c == null).forEach(line => {
        if (line.SBQQ__ProductName__c.includes('Storefront')) {
            existingStorefrontLines.push(line.SBQQ__ProductName__c);
        }
        else {
            existingLinesFamily.push(line.SBQQ__ProductFamily__c);
        }
    });
    quoteLines.filter(ql => !ql.SBQQ__Existing__c).forEach(line => {
        if (
            (
                (
                    line.SBQQ__ProductName__c.includes('Storefront')
                    || (
                        line.Package__c != null
                        && line.Package__c.includes('Storefront')
                    )
                )
                && existingStorefrontLines.length > 0
            )
            ||
            (
                (
                    !line.SBQQ__ProductName__c.includes('Storefront')
                    || (
                        line.Package__c != null
                        && !line.SBQQ__RequiredBy__r.SBQQ__ProductName__c.includes('Storefront')
                    )
                )
                &&
                (
                    existingLinesFamily.includes(line.SBQQ__ProductFamily__c)
                    ||
                    (
                        line.Package__c != null && !line.SBQQ__RequiredBy__r.SBQQ__ProductName__c.includes('Storefront')
                        && existingLinesFamily.includes(line.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c)
                    )
                )
            )
        ) {
            line.Is_It_A_New_Product__c = false;
        }
        else {
            line.Is_It_A_New_Product__c = true;
        }
    });

    return Promise.resolve();
}

/**
* @description : It set the Trial Period Mismatch field on quote lines.
* @param {lines}
*/
export function setTrialPeriodMismatch(lines) {
    let productToTrialPeriod = new Map();
    lines.forEach(line => {
        line.Trial_Period_Mismatch__c = false;
        //Logic to populate a map with 'Printer Fee','Tablet Fee' and their Trial Periods
        if ((line.SBQQ__ProductCode__c === '10025' || line.SBQQ__ProductCode__c === '10053') && line.SBQQ__Quantity__c > 0) {
            productToTrialPeriod.set(line.SBQQ__ProductCode__c, line.Trial_Period__c);
        }
    });
    if (productToTrialPeriod.size === 2) {
        lines.forEach(line => {
            if ((line.SBQQ__ProductCode__c === '10025' || line.SBQQ__ProductCode__c === '10053' && line.SBQQ__Quantity__c > 0) &&
                (productToTrialPeriod.get('10025') !== productToTrialPeriod.get('10053'))) {
                line.Trial_Period_Mismatch__c = true;
            }
        });
    }
}

/**
* @description : The calculator calls this method after it evaluates price rules.
*/
export function onAfterPriceRules(quoteModel, quoteLineModels) {
    if (quoteModel.record.Segment__c === 'SMB') {
        const quoteLines = quoteLineModels.map(quoteLineModel => quoteLineModel.record);
        const parentQLs = quoteLines.filter(ql => ql.Parent_Package_Id__c == null);
        //LEM-15491
        const existingQuoteLineOptions = quoteLines.filter(ql => ql.SBQQ__Existing__c).filter(ql => ql.Package__c != null).filter(ql => ql.SBQQ__Quantity__c === 0);
        const newOrClonedQuoteLineOptions = quoteLines.filter(ql => !ql.SBQQ__Existing__c).filter(ql => ql.Package__c != null).filter(ql => ql.SBQQ__Quantity__c > 0);
        validateDuplicateProducts(parentQLs, quoteModel);
        validateMissingProducts(existingQuoteLineOptions, newOrClonedQuoteLineOptions, quoteModel);
        quoteLines.forEach((line) => {
            if (line.Fee_Type__c == 'Commission') {
                line.SBQQ__SpecialPrice__c = null;
                line.SBQQ__ListPrice__c = 0;
                line.Original_Commission__c = line.Default_Commission__c == null ? 0 : line.Default_Commission__c;
            } else if (line.Fee_Type__c == 'Fee') {
                line.Requested_Commission__c = null;
                line.Original_Commission__c = 0;
                line.Final_Commission__c = 0;
                line.SBQQ__ListPrice__c = line.Default_Fee__c == null ? 0 : line.Default_Fee__c;
                //line.Final_Fee__c = line.SBQQ__SpecialPrice__c == null ? line.SBQQ__ListPrice__c : line.SBQQ__SpecialPrice__c;
            } else if (line.Fee_Type__c == 'Commission + Fee') {
                line.Original_Commission__c = line.Default_Commission__c == null ? 0 : line.Default_Commission__c;
                line.SBQQ__ListPrice__c = line.Default_Fee__c == null ? 0 : line.Default_Fee__c;
                //line.Final_Fee__c = line.SBQQ__SpecialPrice__c == null ? line.SBQQ__ListPrice__c : line.SBQQ__SpecialPrice__c;
            }
            // LEM-14521 - Setting Trial Period based on Trial Period Quote
            mapTrialfields(quoteModel, line);
        });
    }
    return Promise.resolve();
}
/**
 * @description It is used to check whether validate Missing Products in the package exists
 * @param {existingQuoteLineOptions}
 * @param {newOrClonedQuoteLineOptions}
 * @param {quoteModel}
 */
export function validateMissingProducts(existingQuoteLineOptions, newOrClonedQuoteLineOptions, quoteModel) {
    let existingProductwithCount = new Map();
    let productFrequency = {};
    let existingProductwithCountWithPackage = new Map();

    existingQuoteLineOptions.forEach(ql => {
        existingProductwithCountWithPackage.set(ql.SBQQ__ProductName__c, ql.Package__c);
        let productName = ql.SBQQ__ProductName__c;
        if (productFrequency[productName]) {
            productFrequency[productName]++;
        } else {
            productFrequency[productName] = 1;
        }
        existingProductwithCount.set(productName, productFrequency[productName]);
    });
    let allProductwithCount = new Map();
    let allProductFrequency = {};
    let allProductwithCountWithPackage = new Map();

    newOrClonedQuoteLineOptions.forEach(ql => {
        allProductwithCountWithPackage.set(ql.SBQQ__ProductName__c, ql.Package__c);

        let newProductName = ql.SBQQ__ProductName__c;
        const existingPackagesArray = Array.from(existingProductwithCountWithPackage.values());
        const existingPackageOptionsArray = Array.from(existingProductwithCount.keys());
        const newPackagesArray = Array.from(allProductwithCountWithPackage.values());


        if (!existingPackagesArray.includes('Self-Delivery') && newPackagesArray.includes('Self-Delivery')
            && existingPackageOptionsArray.includes('Cx Delivery Fee') && ql.Package__c == 'Self-Delivery') {
            allProductFrequency['Cx Delivery Fee'] = 1;
            allProductwithCount.set('Cx Delivery Fee', allProductFrequency['Cx Delivery Fee']);
        }

        if (existingPackagesArray.includes('Self-Delivery') && !newPackagesArray.includes('Self-Delivery')
            && ql.Package__c !== 'Self-Delivery' && ql.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == 'Marketplace') {

            if (existingPackageOptionsArray.includes('Mx Delivery Fee')) {
                allProductFrequency['Mx Delivery Fee'] = 1;
                allProductwithCount.set('Mx Delivery Fee', allProductFrequency['Mx Delivery Fee']);
            }
            if (existingPackageOptionsArray.includes('Fulfillment Fee')) {
                allProductFrequency['Fulfillment Fee'] = 1;
                allProductwithCount.set('Fulfillment Fee', allProductFrequency['Fulfillment Fee']);
            }
            if (existingPackageOptionsArray.includes('Regulatory Fee')) {
                allProductFrequency['Regulatory Fee'] = 1;
                allProductwithCount.set('Regulatory Fee', allProductFrequency['Regulatory Fee']);
            }
        }
        if (allProductFrequency[newProductName]) {
            allProductFrequency[newProductName]++;
        } else {
            allProductFrequency[newProductName] = 1;
        }
        allProductwithCount.set(newProductName, allProductFrequency[newProductName]);
    });

    let mismatchedKeys = [];
    existingProductwithCount.forEach((value, key) => {
        if (!allProductwithCount.has(key) || allProductwithCount.get(key) < value) {
            mismatchedKeys.push(key);
        }
    });
    if (mismatchedKeys.length > 0) {
        quoteModel.record.Quote_Line_Mismatch_Type__c = 'Missing Product Option';
    } else {
        quoteModel.record.Quote_Line_Mismatch_Type__c = '';
    }
}

/**
 * @description It is used to check whether the package is associated with different store account or not
 * and updates a flag to true if it finds a duplicate. The flag is further used in Product Rules to
 * display a validation message on the QLE.
 */
export function validateDuplicateProducts(parentQuoteLines, quoteModel) {
    let productNameCompare = [];
    quoteModel.record.Duplicate_Package_Product__c = false;


    if (quoteModel.record.Segment__c !== 'SMB') {
        parentQuoteLines.forEach(ql => {
            if (quoteModel.record.SBQQ__Type__c !== 'Amendment') {
                if (productNameCompare.includes((ql.SBQQ__ProductName__c))) {
                    quoteModel.record.Duplicate_Package_Product__c = true;
                }
                else {
                    productNameCompare.push((ql.SBQQ__ProductName__c));
                }
            }
        });
    } else {
        parentQuoteLines.forEach((line) => {
            if (line.SBQQ__Quantity__c != 0) {
                if (productNameCompare.includes((line.SBQQ__ProductName__c))) {
                    quoteModel.record.Duplicate_Package_Product__c = true;
                }
                else {
                    productNameCompare.push((line.SBQQ__ProductName__c));
                }
            }
        });
    }

}

/**
 * @description : It is used to set the flag on the original line to indicate that the line is cloned.
 * The flag is used to determine whether the line should be deleted or not.
 * @param {lines}
 * @param {quoteModel}
 */
export function setClonedLineFlagOnOriginalLine(quoteModel, lines) {
    let lineIds = [];

    lines.forEach(line => {
        if (line.SBQQ__Source__c && !line.Is_Original_Line_Cloned__c) {
            lineIds.push(line.SBQQ__Source__c);
        }
    });
    lines.forEach(originalLine => {
        if (lineIds.length > 0 && lineIds.includes(originalLine.Id)) {
            originalLine.Is_Original_Line_Cloned__c = true;
        }
        else {
            originalLine.Is_Original_Line_Cloned__c = false;
        }
    });
}

export function mapTrialfields(quoteModel, line) {
    if (
        line.Trialable__c &&
        (line.SBQQ__ProductName__c === 'Support As a Service' || line.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c != 'Drive')
    ) {
        line.Trial_Period__c = quoteModel.record.Trial_Period_Quote__c;
    }

    // condition to blank out Trial_Period__c and associated commission/fees for Drive Products except 'Support As a Service'
    if (
        line.Trialable__c &&
        line.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c === 'Drive' &&
        line.SBQQ__ProductName__c != 'Support As a Service'
    ) {
        line.Trial_Period__c = null;
        line.Trial_Commission__c = null;
        line.Trial_Fee__c = null;
    }
}

/**
 * @description : This function calculates the tiers for DPEI products on Quote Line.
 * @param (quoteModel, quoteLineModels, conn)
 */
function calculateQuoteTier(quoteModel, quoteLineModels, conn) {

    var scoreCardForQuoteLines = 0;
    var allTiersOnQuoteLines = [];
    var productNameAndTierCalculationDataMap = new Map();
    var tierCalculationMetaData = [];
    let productName;
    let tierMetaDataRecord;

    return conn.query('Select Id, Eligible_Products_for_Tier_Calculation__r.Product_Name__c, DeveloperName, Data_Type_Of_Field_On_Quote_Line__c, Quote_Line_Field_API_Name__c, Field_Value__c, Minimum_Value__c, Maximum_Value__c, Scorecard__c From Tier_Calculation_Data__mdt Where Active__c = TRUE And Eligible_Products_for_Tier_Calculation__r.Active__c = TRUE')
        .then(function (results) {
            results.records.forEach(function (record) {

                productName = record.Eligible_Products_for_Tier_Calculation__r.Product_Name__c;

                if (productNameAndTierCalculationDataMap.has(productName)) {
                    tierMetaDataRecord = productNameAndTierCalculationDataMap.get(productName);
                    tierMetaDataRecord.push(record);
                    productNameAndTierCalculationDataMap.set(productName, tierMetaDataRecord);
                } else {
                    productNameAndTierCalculationDataMap.set(productName, [record]);
                }
            });

            quoteLineModels.forEach(currentQuoteLine => {
                if (productNameAndTierCalculationDataMap.has(currentQuoteLine.record.SBQQ__ProductName__c)) {
                    scoreCardForQuoteLines = 0;

                    tierCalculationMetaData = productNameAndTierCalculationDataMap.get(currentQuoteLine.record.SBQQ__ProductName__c);

                    tierCalculationMetaData.forEach(currentTierCalculationMetaData => {

                        if (currentTierCalculationMetaData.Data_Type_Of_Field_On_Quote_Line__c == 'Multi Picklist') {

                            let quoteLineMultipicklistValues = currentQuoteLine.record[currentTierCalculationMetaData.Quote_Line_Field_API_Name__c];

                            if (quoteLineMultipicklistValues != null) {
                                if (quoteLineMultipicklistValues.includes(currentTierCalculationMetaData.Field_Value__c)) {

                                    scoreCardForQuoteLines = scoreCardForQuoteLines + currentTierCalculationMetaData.Scorecard__c;

                                }
                            }
                        }

                        if (currentTierCalculationMetaData.Data_Type_Of_Field_On_Quote_Line__c == 'Text') {
                            if (currentQuoteLine.record[currentTierCalculationMetaData.Quote_Line_Field_API_Name__c] != null) {
                                if (currentQuoteLine.record[currentTierCalculationMetaData.Quote_Line_Field_API_Name__c] == currentTierCalculationMetaData.Field_Value__c) {
                                    scoreCardForQuoteLines = scoreCardForQuoteLines + currentTierCalculationMetaData.Scorecard__c;
                                }
                            }
                        }

                        if (currentTierCalculationMetaData.Data_Type_Of_Field_On_Quote_Line__c == 'Currency') {
                            if (currentQuoteLine.record[currentTierCalculationMetaData.Quote_Line_Field_API_Name__c] != 0) {

                                let quoteLineFieldValue = currentQuoteLine.record[currentTierCalculationMetaData.Quote_Line_Field_API_Name__c];

                                if (currentTierCalculationMetaData.Maximum_Value__c != 0) {
                                    if (quoteLineFieldValue > currentTierCalculationMetaData.Minimum_Value__c && quoteLineFieldValue <= currentTierCalculationMetaData.Maximum_Value__c) {

                                        scoreCardForQuoteLines = scoreCardForQuoteLines + currentTierCalculationMetaData.Scorecard__c;

                                    }
                                } else if (quoteLineFieldValue > 1000000) {
                                    scoreCardForQuoteLines = scoreCardForQuoteLines + currentTierCalculationMetaData.Scorecard__c;
                                }
                            }
                        }

                    });

                    //Method call to calculate the Tier based on score card value for a individual quote line.
                    currentQuoteLine.record.Tier__c = checkScorecardAndAssignTierQuoteLine(currentQuoteLine, scoreCardForQuoteLines);

                    //Below is the list which will store Tiers from all quote lines
                    allTiersOnQuoteLines.push(currentQuoteLine.record.Tier__c);
                }
            });

            //Method call to get the Quote's tier after comapring it from other Tiers from quote line.
            if (allTiersOnQuoteLines.length > 0) {
                quoteModel.record.Tier__c = compareQuoteLineTiersForQuote(quoteModel, allTiersOnQuoteLines);
            }

        });

}

/**
 * @description : This function checks the scorecard's range and assigns a Tier to the quote line.
 * @param (currentQuoteLine, scoreCardForQuoteLines)
 */
function checkScorecardAndAssignTierQuoteLine(currentQuoteLine, scoreCardForQuoteLines) {

    if (scoreCardForQuoteLines >= 13) {
        currentQuoteLine.record.Tier__c = "Tier 1";
    } else if (scoreCardForQuoteLines > 10 && scoreCardForQuoteLines < 13) {
        currentQuoteLine.record.Tier__c = "Tier 2";
    } else if (scoreCardForQuoteLines > 5 && scoreCardForQuoteLines < 11) {
        currentQuoteLine.record.Tier__c = "Tier 3";
    } else {
        currentQuoteLine.record.Tier__c = "Tier 4";
    }
    return currentQuoteLine.record.Tier__c;
}

/**
 * @description : This function compares all quote line Tiers and assign the highest tier on Quote.
 * @param (quoteModel, allTiersOnQuoteLines)
 */
function compareQuoteLineTiersForQuote(quoteModel, allTiersOnQuoteLines) {

    if (allTiersOnQuoteLines.includes('Tier 1')) {
        quoteModel.record.Tier__c = 'Tier 1';
    } else if (allTiersOnQuoteLines.includes('Tier 2')) {
        quoteModel.record.Tier__c = 'Tier 2';
    } else if (allTiersOnQuoteLines.includes('Tier 3')) {
        quoteModel.record.Tier__c = 'Tier 3';
    } else {
        quoteModel.record.Tier__c = 'Tier 4';
    }

    return quoteModel.record.Tier__c;
}

/*-------------------------------------------------------------------------------------
Quote  Fields
-------------------------------------------------------------------------------------
Trial_Period_Quote__c
Segment__c
Account_Primary_Vertical__c
SBQQ__StartDate__
SBQQ__Type__c
Deck_Rank__c
Lead_Source__c
Mx_Attributes__c
*/

/*-------------------------------------------------------------------------------------
Quote line group Fields
-------------------------------------------------------------------------------------
Name
*/

/*-------------------------------------------------------------------------------------
Quote Line Fields
-------------------------------------------------------------------------------------
Original_Commission__c
Trial_Commission__c
SBQQ__EffectiveStartDate__c
SBQQ__StartDate__c
SBQQ__RequiredBy__c
SBQQ__PriceEditable__c
SBQQ__UpgradedSubscription__c
SBQQ__OptionLevel__c
SBQQ__ProductFamily__c
SBQQ__Product__c
Parent_Package_Id__c
CurrencyIsoCode
Pricing_Search_Complete__c
SBQQ__ListPrice__c
User_Manager_Commission_Threshold__c
Deal_Desk_Commission_Threshold__c
User_Manager_Fee_Threshold__c
Deal_Desk_Fee_Threshold__c
Minimum_Fee__c
Floor_Rate__c
Maximum_Fee__c
Ceiling_Rate__c
Target_Rate__c
Commission_Rate_Number__c
Pricing_Audit__c
SBQQ_OriginalPrice__c
CR_Modified_Date__c
Merchant_Deck_Rank__c
Dependent_Product__c
SBQQ__ProductName__c
Region__c
SBQQ__SpecialPrice__c
Default_Fee__c
Default_Commission__c
SBQQ__ProductCode__c
Trial_Period_Mismatch__c
Trial_Period__c
SBQQ__Quantity__c
SBQQ__ProductFamily__c
Tier__c
Estimated_Total_Investment__c
Item_Type__c
Social_Media_Mentions_for_DPEI_by_Mx__c
DPEI_Mentions_on_Mx_Owned_Channels_by_Mx__c
Will_Mx_Share_Long_Term_LTO_Calendar__c
SBQQ__OriginalPrice__c
Requested_Commission__c
Fee_Type__c
Is_Editable__c
*/

/*-------------------------------------------------------------------------------------
Quote Fields
-------------------------------------------------------------------------------------
Tier__c
Override_Tier__c
*/

/*-------------------------------------------------------------------------------------
Quote Line Group Fields
-------------------------------------------------------------------------------------
Name
*/