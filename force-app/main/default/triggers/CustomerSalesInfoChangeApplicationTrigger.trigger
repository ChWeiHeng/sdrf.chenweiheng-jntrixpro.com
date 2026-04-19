/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-01-2025   Gerry   Initial Version
**/
trigger CustomerSalesInfoChangeApplicationTrigger on Customer_Sales_Info_Change_Application__c (after update,before update) {
	new Triggers()
	.bind(Triggers.Evt.afterupdate, new CustomeSalesInfoApplicationHandler())
	.bind(Triggers.Evt.beforeupdate, new CustomeSalesInfoApplicationHandler())
    .manage();
}