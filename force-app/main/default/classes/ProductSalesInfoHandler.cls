/**************************************************************************************************
* Name: ProductSalesInfoHandler
* Object: Product_Sales_Info__c
* Purpose: 
* ************************************************************************************************
* History
* --------
* VERSION     AUTHOR              DATE            DETAIL             Description
* 1.0         zach	            2025-7-16         Created
***************************************************************************************************/
public without sharing class ProductSalesInfoHandler implements Triggers.Handler{
	public void handle(){
        if (Trigger.isBefore && Trigger.isInsert){
            updateExternalId();
        }
    }
    
    /**
	* @Author   Zach
    * @DateTime 2025-7-8
    * @Description  当External_Id__c为空时  赋值：Product__r.Name+'_'+Sales_Organization__c+'_'+Distr_Channel__c  +'_'+Delivering_Plant__c
    */
    public static void updateExternalId(){
        Set<String> productIdSet = new Set<String>();
        for(Product_Sales_Info__c info : (List<Product_Sales_Info__c>)Trigger.new){
            if(String.isBlank(info.External_Id__c)){
                productIdSet.add(info.Product__c);
            }
        }    
        
        Map<Id,Product__c> productMap = new Map<Id,Product__c>([SELECT Id,Name FROM Product__c WHERE Id IN:productIdSet]);
        for(Product_Sales_Info__c info : (List<Product_Sales_Info__c>)Trigger.new){
            if(String.isBlank(info.External_Id__c)){
                info.External_Id__c = productMap.get(info.Product__c)?.Name + '_' + info.Sales_Organization__c + '_' + info.Distr_Channel__c + '_' + info.Delivering_Plant__c;
            }
        }    
    }
}