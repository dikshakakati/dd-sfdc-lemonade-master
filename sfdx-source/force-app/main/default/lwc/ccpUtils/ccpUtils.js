/**
 * @author Deloitte
 * @date 06/02/2024
 * @description A service component (library) for maintaining JavaScript utility methods for Corporate Cherry Picking.
 */

/**
 * @description To stamp json when manage package is skipped
 * @param result
 */
const getEntitlementSelectionDeselectionWhenCCPSkipped = (result) => {
  let finalData = {
    selected: [],
    deselected: []
  };
  let packageChildDetailList = {};
  let allPackList = [];

  if (result !== null) {
    result.forEach(function (products) {
      let requiredById = products.SBQQ__RequiredById__c;
      let rootId = products.SBQQ__RootId__c;
      if (requiredById != null && rootId != null) {
        let isDirectChild = requiredById === rootId ? true : false;
        let productDetails = {};
        productDetails.productId = products.Id;
        productDetails.productName = products.SBQQ__ProductName__c;
        let productSelected = isDirectChild ? requiredById : rootId;

        if (
          //Add all products as default selected in json
          Object.prototype.hasOwnProperty.call(
            packageChildDetailList,
            requiredById
          ) ||
          Object.prototype.hasOwnProperty.call(packageChildDetailList, rootId)
        ) {
          let valueAtIndex2 = isDirectChild
            ? packageChildDetailList[requiredById]
            : packageChildDetailList[rootId];
          valueAtIndex2.push(productDetails);
          packageChildDetailList[productSelected] = valueAtIndex2;
        } else {
          packageChildDetailList[productSelected] = [productDetails];
        }
      } else if (requiredById == null) {
        //Add all packages as default selected in json
        allPackList.push(products);
      }
    });
  }

  for (let i = 0; i < allPackList.length; i++) {
    finalData.selected.push({
      packageId: allPackList[i].Id,
      packageName: allPackList[i].SBQQ__ProductName__c,
      productSubId:
        packageChildDetailList[allPackList[i].Id] !== undefined
          ? packageChildDetailList[allPackList[i].Id]
          : []
    });
    //deselected part will be empty in case of ccp skipped
    finalData.deselected = [];
  }
  return finalData;
};

/**
 * @description To stamp json when manage package is not skipped
 * @param result
 */
const getEntitlementSelectionDeselectionWhenCCPApplied = (
  result,
  selectedPackages,
  selectedProductIds,
  allProductIds
) => {
  let finalData = {
    selected: [],
    deselected: []
  };
  let packageChildDetailList = {};
  let packageChildDeselectedList = {};
  let allPackList = [];
  let deSelectedProdList = [];
  deSelectedProdList = allProductIds
    .filter((x) => !selectedProductIds.includes(x))
    .concat(selectedProductIds.filter((x) => !allProductIds.includes(x)));
  result.forEach((products) => {
    let requiredById = products.SBQQ__RequiredById__c;
    let rootId = products.SBQQ__RootId__c;
    if (
      requiredById != null &&
      rootId != null
    ) {
      let isDirectChild =
        requiredById === rootId
          ? true
          : false;
      if (
        //check if a product is deselected then add it for deselected section in json
        !selectedProductIds.includes(products.Id) &&
        products.SBQQ__ProductOption__r.Product_Eligible_For_Entitlement__c !==
        false
      ) {
        if (
          Object.prototype.hasOwnProperty.call(
            packageChildDeselectedList,
            requiredById
          )
        ) {
          let valueAtIndex2 =
            packageChildDeselectedList[requiredById];
          valueAtIndex2.push(products.Id);
          packageChildDeselectedList[requiredById] =
            valueAtIndex2;
        } else {
          packageChildDeselectedList[requiredById] =
            [products.Id];
        }
      } else if (deSelectedProdList.includes(requiredById)) {
        //Don't process child products if there parent is deselected
      } else {
        let productSelected = isDirectChild
          ? requiredById
          : rootId;
        let productDetails = {};
        productDetails.productId = products.Id;
        productDetails.productName = products.SBQQ__ProductName__c;
        if (
          // if a Package is selected then add all it's child products for selected part of json
          Object.prototype.hasOwnProperty.call(
            packageChildDetailList,
            requiredById
          ) ||
          Object.prototype.hasOwnProperty.call(
            packageChildDetailList,
            rootId
          )
        ) {
          let valueAtIndex2 = isDirectChild
            ? packageChildDetailList[requiredById]
            : packageChildDetailList[rootId];
          valueAtIndex2.push(productDetails);
          packageChildDetailList[
            productSelected
          ] = valueAtIndex2;
        } else {
          packageChildDetailList[
            productSelected
          ] = [productDetails];
        }
      }
    } else if (
      //If a package is selected or it's a default package then add it in selected part of json
      requiredById == null &&
      (selectedPackages.includes(products.Id) ||
        products.SBQQ__Product__r.Package_Eligible_For_Entitlement__c === false)
    ) {
      allPackList.push(products);
    }
  });
  //Loop over selected and default packages and add their all child products in json
  for (let i = 0; i < allPackList.length; i++) {
    finalData.selected.push({
      packageId: allPackList[i].Id,
      packageName: allPackList[i].SBQQ__ProductName__c,
      productSubId:
        packageChildDetailList[allPackList[i].Id] !== undefined
          ? packageChildDetailList[allPackList[i].Id]
          : []
    });
    finalData.deselected.push({
      selectedPackageId: allPackList[i].Id,
      productDeselected:
        packageChildDeselectedList[allPackList[i].Id] !== undefined
          ? packageChildDeselectedList[allPackList[i].Id]
          : []
    });
  }
  return finalData;
};

/**
 * @description To handle product selection/deselection
 * @param preSelectedRows
 * @param eachTableSelections
 */
const handleRowSelection = (
  preSelectedRows,
  eachTableSelections
) => {

  var preSelectedRowsLocal = [...preSelectedRows];
  var listProducts = [];
  var deSelection = true;

  eachTableSelections.forEach(function (products) {
    products.forEach((prod) => {
      listProducts.push(prod.Id)
    });
  });

  preSelectedRows.forEach(function (products) {
    if (!listProducts.includes(products)) {
      const index = preSelectedRowsLocal.indexOf(products);
      preSelectedRowsLocal.splice(index, 1);
      deSelection = false;
    }
  });

  if (deSelection) {
    listProducts.forEach(function (products) {
      if (!preSelectedRowsLocal.includes(products)) {
        preSelectedRowsLocal = preSelectedRowsLocal.concat(products);
      }
    });
  }

  return preSelectedRowsLocal;
}

/**
 * @description To handle package selection/deselection
 * @param event
 * @param preSelectedRows
 * @param wrapperList
 */
const handleCheckboxChange = (
  event,
  preSelectedRows,
  wrapperList
) => {
  var selectList;
  var listProducts = [];

  wrapperList.forEach(function (eachkey) {
    eachkey.packageList.forEach(function (eachPack) {
      eachPack.subsList.forEach(function (eachChildSub) {
        if (eachChildSub.SBQQ__RequiredById__c === event.target.value) {
          listProducts.push(eachChildSub.Id);
        }
      });
    });
  });

  if (event.target.checked === false) {
    selectList = preSelectedRows.filter((el) => !listProducts.includes(el));
    preSelectedRows = selectList;
  } else {
    preSelectedRows = preSelectedRows.concat(listProducts);
  }

  return preSelectedRows;
}

export { getEntitlementSelectionDeselectionWhenCCPSkipped, getEntitlementSelectionDeselectionWhenCCPApplied, handleCheckboxChange, handleRowSelection };
