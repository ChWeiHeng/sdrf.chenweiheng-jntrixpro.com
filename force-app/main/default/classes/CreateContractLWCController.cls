/**************************************************************************************************
 * Name: CreateContractLWCController
 * Object: 
 * Purpose: 通过报价创建合同
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0           noel            2024-10-28         Created             
***************************************************************************************************/
public without sharing class CreateContractLWCController {
    @AuraEnabled
    public static Output createContract(String quoteId, String contractTypeMe,String downPayment) {
        System.debug('contractTypeMe=>'+contractTypeMe);
    	SavePoint sp = Database.setSavepoint();
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            List<Quote__c> quoteList = [
                                SELECT 
                                    Id,
                                    Sales_Org__c,
                                    Sales_Office__c,
                                    Sales_Group__c,
                                    Sales_District__c,
                                    Customer__c,
                                    Currency__c,
                                    Distr_Channel__c,
                                    Deliver_Plant__c,
                                    Business_Model__c,
                                    Payment_Term__c,
                                    Payment_Term_Cost_Rate__c,(
                                    SELECT
                                        Id,
                                        Item_Cost__c,
                                        Item_Price__c,                                     
                                        Unit__c,
                                        Order_Qnty__c,
                                        CIF_90_Days_Without_Margin__c,
                                        CIF_90_Days__c,
                                        Packing_Size__c,
                                        Packing_Cost__c,
                                        FOB_Price__c,
                                        Freight_Cost__c,
                                        Clearance_Cost_Percentage__c,
                                        Inland_Cost_Including_Insurance__c,
                                        Pallet__c,
                                        Delivery_Time__c,
                                        Commission__c,
                                        Commission_Percent__c
                                    FROM Quote_Detail_Child__r) FROM Quote__c WHERE Id =:quoteId];
            Quote__c quote = quoteList[0];
            if(contractTypeMe=='Subsidiary' || contractTypeMe=='Final Customer')
            {
                Contracts__c newContract = new Contracts__c();
                newContract.recordTypeId = Schema.SObjectType.Contracts__c.getRecordTypeInfosByDeveloperName().get('Headquarters').getRecordTypeId();
                newContract.Status__c = 'Draft';
                newContract.Sales_Org__c = quote.Sales_Org__c;
                newContract.Sales_Office__c = quote.Sales_Office__c;
                newContract.Sales_Group__c = quote.Sales_Group__c;
                newContract.Final_Customer__c = quote.Customer__c;
                newContract.Customer__c = quote.Customer__c;
                newContract.Currency__c = quote.Currency__c;
                newContract.Transaction_Mode__c=contractTypeMe;
                if(contractTypeMe=='Subsidiary'){
                    string mdgCode='000000'+quote.Sales_Org__c;
                    System.debug('mdgCode==>'+mdgCode);
                    List<Account> accList=[SELECT Id,MDG_Customer_Code__c FROM Account WHERE MDG_Customer_Code__c=:mdgCode];
                    if(accList.size()>0){newContract.Customer__c = accList[0].Id;}
                }
                newContract.Payment_Term_Cost_Rate__c = quote.Payment_Term_Cost_Rate__c;
                newContract.Final_Customer_Payment_Terms__c = quote.Payment_Term__c;
                newContract.Quote__c = quoteId;
                newContract.Distribution_Channel__c = quote.Distr_Channel__c;
                newContract.Delivery_Plant__c = quote.Deliver_Plant__c;
                newContract.Business_Model__c = quote.Business_Model__c;
                newContract.Sales_District__c = quote.Sales_District__c;
                Insert newContract;
                List<Contracts_Detail__c> conDetailList = new List<Contracts_Detail__c>();
                for (Quote_Detail__c quoteDeatil : quote.Quote_Detail_Child__r) 
                {
                    Contracts_Detail__c newContractDetail = new Contracts_Detail__c();
                    newContractDetail.recordTypeId = Schema.SObjectType.Contracts_Detail__c.getRecordTypeInfosByDeveloperName().get('Headquarters').getRecordTypeId();
                    newContractDetail.Contracts__c = newContract.Id;
                    newContractDetail.BU_Sales_Price__c = quoteDeatil.CIF_90_Days__c;
                    newContractDetail.Unit__c = quoteDeatil.Unit__c;
                    newContractDetail.Qnty__c = quoteDeatil.Order_Qnty__c;
                    newContractDetail.Total_Amount__c = quoteDeatil.Item_Cost__c;
                    newContractDetail.Packing_Size__c = quoteDeatil.Packing_Size__c;
                    newContractDetail.Packing_cost__c = quoteDeatil.Packing_Cost__c;
                    newContractDetail.FOB_Price__c = quoteDeatil.FOB_Price__c;
                    newContractDetail.Freight_Cost__c = quoteDeatil.Freight_Cost__c;
                    //newContractDetail.Clearance_Cost_Percentage__c = 0;
                    newContractDetail.Inland_Cost_Including_Insurance__c = quoteDeatil.Inland_Cost_Including_Insurance__c;
                    newContractDetail.Pallet_Cost__c = quoteDeatil.Pallet__c;
                    newContractDetail.Delivery_Time__c = quoteDeatil.Delivery_Time__c;
                    newContractDetail.Commission_Unit_Price__c = quoteDeatil.Commission__c;
                    newContractDetail.Commission_Ratio__c = quoteDeatil.Commission_Percent__c;
                    newContractDetail.Quote_Detail__c=quoteDeatil.Id;
                    Decimal sumCost=0;
                    if(newContractDetail.FOB_Price__c != null)
                    {
                        sumCost=sumCost+newContractDetail.FOB_Price__c;
                    }
                    if(newContractDetail.Packing_cost__c != null)
                    {
                        sumCost=sumCost+newContractDetail.Packing_Cost__c;
                    }
                    if(newContractDetail.Pallet_Cost__c != null)
                    {
                        sumCost=sumCost+newContractDetail.Pallet_Cost__c;
                    }
                    if(newContractDetail.Freight_Cost__c != null)
                    {
                        sumCost=sumCost+newContractDetail.Freight_Cost__c;
                    }
                    if(newContractDetail.Inland_Cost_Including_Insurance__c != null)
                    {
                        sumCost=sumCost+newContractDetail.Inland_Cost_Including_Insurance__c;
                    }
                    if(newContractDetail.Commission_Unit_Price__c != null)
                    {
                        sumCost=sumCost+newContractDetail.Commission_Unit_Price__c;
                    }
                    System.debug('sumCost----'+sumCost);
                    newContractDetail.Unit_Price__c=sumCost.setScale(5);
                    if(newContractDetail.Unit_Price__c != null && newContract.Payment_Term_Cost_Rate__c != null)
                    {
                        newContractDetail.Unit_Price__c=(newContractDetail.Unit_Price__c*newContract.Payment_Term_Cost_Rate__c).setScale(5);
                    }
                    if(newContractDetail.Unit_Price__c  != null && newContractDetail.Qnty__c != null)
                    {
                        newContractDetail.Total_Amount__c = (newContractDetail.Unit_Price__c*newContractDetail.Qnty__c).setScale(5);
                    }
                    //newContractDetail.HQ_Contract_Unit_Price__c=newContractDetail.Unit_Price__c;
                    conDetailList.add(newContractDetail);
                }
                Database.Insert(conDetailList);
                out.contractId = newContract.Id;
            }
            else
            {
                Order__c newOrder = new Order__c();
                newOrder.recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('Model_B').getRecordTypeId();
                newOrder.Status__c = 'Draft';
                newOrder.Sales_Org__c = quote.Sales_Org__c;
                newOrder.Sales_Office__c = quote.Sales_Office__c;
                newOrder.Sales_Group__c = quote.Sales_Group__c;
                newOrder.Customer__c = quote.Customer__c;
                newOrder.Currency__c = quote.Currency__c;
                newOrder.Terms_Of_Payment__c = quote.Payment_Term__c;
                newOrder.Quotes__c = quoteId;
                newOrder.Down_Payment__c =downPayment;
                newOrder.Order_type__c=contractTypeMe;
                newOrder.Distr_Channel__c = quote.Distr_Channel__c;
                newOrder.Deliver_Plant__c = quote.Deliver_Plant__c;
                newOrder.Business_Model__c = quote.Business_Model__c;
                newOrder.Sales_District__c = quote.Sales_District__c;
                Insert newOrder;
                List<Order_Item__c> orderItemList = new List<Order_Item__c>();
                Integer indexNum=10;
                for (Quote_Detail__c quoteDeatil : quote.Quote_Detail_Child__r) 
                {
                    Order_Item__c newOrderItem = new Order_Item__c();
                    newOrderItem.IsCreate__c = true;
                    newOrderItem.Order__c = newOrder.Id;
                    newOrderItem.Product_Cost__c = quoteDeatil.CIF_90_Days_Without_Margin__c;
                    newOrderItem.Original_Product_Cost__c=newOrderItem.Product_Cost__c;
                    newOrderItem.Price__c = quoteDeatil.CIF_90_Days__c;
                    newOrderItem.SAP_Item_Num__c=String.valueOf(indexNum);
                    indexNum=indexNum+10;
                    if(newOrderItem.Price__c != null)
                    {
                        newOrderItem.Price__c =newOrderItem.Price__c.setScale(2);
                    }
                    newOrderItem.Quote_Price__c=newOrderItem.Price__c;
                    newOrderItem.Sales_Unit_Text__c = quoteDeatil.Unit__c;
                    newOrderItem.Quantity__c = quoteDeatil.Order_Qnty__c;
                    newOrderItem.Amount_per_item__c = quoteDeatil.Item_Price__c;
                    newOrderItem.Quote_Detail__c=quoteDeatil.Id;
                    orderItemList.add(newOrderItem);
                }
                Database.Insert(orderItemList);
                out.contractId = newOrder.Id;
            }
            Quote__c needQuote=new Quote__c();
            needQuote.Id=quoteId;
            needQuote.Is_Customer_Confirmed__c=true;
            update needQuote;
        } catch (Exception e) {
        	if(sp != null)
        	{
        		Database.rollback(sp);
        	}
            out.isSucess = false;
            system.debug('185Line'+e.getMessage()+e.getLineNumber());
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(', ')+1);
            return out;
        }
        return out;
        
    }

    @AuraEnabled
    public static Output init(String quoteId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        out.optionList = new List<Option>();
        Option op5 = new Option();
        op5.label = '';
        op5.value = '';
        out.optionList.add(op5);
        try{
        Quote__c quote = [SELECT Id,Sales_Org__c,Quotation_Type__c,Approval_Status__c FROM Quote__c WHERE Id=:quoteId];
        List<Quote_Detail__c> qdList = [SELECT Id FROM Quote_Detail__c WHERE Quote__c=:quoteId AND Price_List__c=null];
        // if(quote.Quotation_Type__c != 'Tolling' && qdList.size()>0) {
        //     out.isSucess = false;
        //     out.errorMsg = 'Please supplementary product english name';
        //     return out;
        // }
        if (quote.Sales_Org__c == '3010') {
            out.isDisplayOrder=true;
        }
        else{out.isDisplayOrder=false;
            }
        if (quote.Quotation_Type__c == 'Tolling') {
            Option op = new Option();
            op.label = 'ZAR1 Pedido Venta Arg';
            op.value = 'ZAR1';
            out.optionList.add(op);
        }else if(quote.Sales_Org__c=='5070')
        {
            Option op = new Option();
            op.label = 'ZAR1 Pedido Venta Arg';
            op.value = 'ZAR1';
            out.optionList.add(op);
        }
        else if(quote.Sales_Org__c=='3010'){
            Option op = new Option();
            op.label = 'ZMX1 Standard order MX';
            op.value = 'ZMX1';
            out.optionList.add(op);

            Option op1 = new Option();
            op1.label = 'ZMX6 Down Payment MX';
            op1.value = 'ZMX6';
            out.optionList.add(op1);

            
        }
        } catch (Exception e) {
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
           
        }
        return out;
    }

    
    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}
        
        @AuraEnabled
        public Boolean isDisplayOrder {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String contractId {get;set;}
        
        @AuraEnabled
        public List<Option> optionList {get;set;}
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }
}