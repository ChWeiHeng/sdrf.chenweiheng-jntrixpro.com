/**
 * @description       : 商品名称trigger
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-09-2025   Gerry   Initial Version
**/
public without sharing class ProductNameTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore && (Trigger.isUpdate || Trigger.isInsert)) {
            for (Product_Name__c pn : (List<Product_Name__c>)Trigger.new) {
                if (pn.Customer__c!=null) {
                    pn.External_Id__c = pn.Material_Code__c+'_'+pn.Sales_Org__c+'_'+pn.Distr_Channel__c+'_'+pn.Plan__c+'_'+pn.Name+'_'+pn.Customer__c;
                }else{
                    pn.External_Id__c = pn.Material_Code__c+'_'+pn.Sales_Org__c+'_'+pn.Distr_Channel__c+'_'+pn.Plan__c+'_'+pn.Name+'_';
                }
                
            }
        }

        if (Trigger.isafter && Trigger.isInsert) {
            Set<String> salesOrgSet = new Set<String>();
            Set<String> plantSet = new Set<String>();
            for (Product_Name__c pn : (List<Product_Name__c>)Trigger.new) {//获取销售组织和工厂
                if (pn.Sales_Org__c!='5070') {//排除AR Model B
                    salesOrgSet.add(pn.Sales_Org__c);
                    plantSet.add(pn.Plan__c);
                }
            }
            System.debug('salesOrgSet====>'+salesOrgSet);
            System.debug('plantSet====>'+plantSet);
            Map<String,List<Price_Book__c>> pbMap = new Map<String,List<Price_Book__c>>();//获取价格书,销售组织+工厂维度下有多个数据
            for (Price_Book__c pb : [SELECT Id,Name,Sales_Org__c,Delivery_Plant__c FROM Price_Book__c WHERE Sales_Org__c IN :salesOrgSet AND Delivery_Plant__c IN :plantSet]) {
                if (pbMap.containsKey(pb.Sales_Org__c+'_'+pb.Delivery_Plant__c)) {
                    pbMap.get(pb.Sales_Org__c+'_'+pb.Delivery_Plant__c).add(pb);
                }else{
                    pbMap.put(pb.Sales_Org__c+'_'+pb.Delivery_Plant__c,new List<Price_Book__c>{pb});
                }
            }
            List<Price_Book_Item__c> pbiList = new List<Price_Book_Item__c>();

            for (Product_Name__c pn : (List<Product_Name__c>)Trigger.new) {//创建价格手册明细
                if (pn.Sales_Org__c == '5070') {
                    continue;
                }
                if (pn.Is_Delete__c) {
                    continue;
                }
                if( pbMap.get(pn.Sales_Org__c+'_'+pn.Plan__c)!=null) {
                    for(Price_Book__c pb : pbMap.get(pn.Sales_Org__c+'_'+pn.Plan__c)) {
                        Price_Book_Item__c pbi = new Price_Book_Item__c();
                        pbi.Product_Name__c = pn.Id;
                        pbi.Price_Book__c = pb.Id;
                        pbiList.add(pbi);
                    }
                }
                
            }
            if (pbiList.size()>0) {
                insert pbiList;
            }
        }
    }
}