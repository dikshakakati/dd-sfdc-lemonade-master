/**
 * @author Deloitte
 * @date 11/02/2022
 * @description JavaScript controller for custom type datatable lightning web component.
 */
import LightningDatatable from "lightning/datatable";
import customTextTemplate from "./customText.html";
import picklistColumnTemplate from "./picklistColumn.html";

export default class CustomTypeDatatable extends LightningDatatable {
  static customTypes = {
    customText: {
      template: customTextTemplate,
      standardCellLayout: true,
      typeAttributes: ["customTextColumn"]
    },
    picklistColumn: {
      template: picklistColumnTemplate,
      standardCellLayout: true,
      typeAttributes: [
        "label",
        "placeholder",
        "options",
        "value",
        "context",
        "fieldName"
      ]
    }
  };
}