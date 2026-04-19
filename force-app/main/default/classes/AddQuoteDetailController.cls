/**************************************************************************************************
 * Name: AddQuoteDetailController
 * Object: 
 * Purpose: 添加报价产品控制类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Noel             2024-10-14         Created             
***************************************************************************************************/
public without sharing class AddQuoteDetailController {
    @AuraEnabled
    public static Output initData(String quoteRecordId) {
        try {
            system.debug('quoteRecordId:'+quoteRecordId);
            Quote__c quote = [SELECT Name,Id,Quotation_Type__c,Exchange__c,Is_Retrograde__c,Payment_Term_Cost_Rate__c,Incoterms__c,Sales_Org__c  FROM Quote__c WHERE Id=:quoteRecordId];
            Output out = new Output();
            out.isSucess = true;
            out.quoteDetailList = new List<QuoteDetail>();
            if ((quote.Incoterms__c == 'DAP' || quote.Incoterms__c == 'DDP') && quote.Sales_Org__c == '3010') {
                out.isMXDAPORDDP = true;
            }else{
                out.isMXDAPORDDP = false;
            }
            if(quote.Quotation_Type__c=='HQ_Purchase' )
            {
                out.isHQSubClient=true;
            }
            else
            {
                out.isHQSubClient=false;
            }
            out.exchangeRate=quote.Exchange__c;
            if(quote.Is_Retrograde__c)
            {
                out.isRetrograde=false;
            }
            else
            {
                out.isRetrograde=true;
            }
            
            out.paymentTermCostRate=quote.Payment_Term_Cost_Rate__c;
            
            List<Quote_Detail__c> quoteDetailList = [
                                    SELECT 
                                        Id, Price_List__c,Is_Hand_Add__c,Inland_Cost_Including_Insurance__c,Clearance_Cost_Percentage__c,Packing_Size__c,Commission_Percent__c,Quote__c,FOB_Price__c,Order_Qnty__c,Packing_Cost__c,Pallet__c,Freight_Cost__c,Payment_Terms__c,CIF_90_Days__c,CIF_90_Days_Without_Margin__c,Cost__c,Contract_Processing_Product__c,Process_Cost__c,Commission__c,Item_Cost__c,Item_Price__c,BU_Profit_Rate__c,Delivery_Time__c,CIF_Price_Include_Commission__c,Quote_Product_Name__c,Unit__c
                                    FROM 
                                        Quote_Detail__c 
                                    WHERE Quote__c	 =: quoteRecordId];

            Integer index = 0;
            List<String> productNameList=new List<String>();
            for (Quote_Detail__c quoteDetail : quoteDetailList) {
                QuoteDetail qd = new QuoteDetail();
                qd.quoteDetailData = quoteDetail;
                qd.index=index;
                out.quoteDetailList.add(qd);
                index++;
                if(quoteDetail.Price_List__c != null)
                {
                    productNameList.add(quoteDetail.Price_List__c);
                    qd.isNotEdit=true;
                }else{
                    qd.isNotEdit=false;
                }
                if(quoteDetail.Contract_Processing_Product__c != null)
                {
                    productNameList.add(quoteDetail.Contract_Processing_Product__c);
                }
            }

            out.productNameList=productNameList;
            SearchProduct search = searchDataMe('',out.isHQSubClient);
            out.priceListList = search.priceListList;
            out.errorMsg = '';
            system.debug('out:'+out);
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
        
    
    }

    @AuraEnabled
    public static SearchProduct searchDataMe(String searchData,boolean isHQSubClient) {
        try {
            System.debug('isHQSubClient===>'+isHQSubClient);
            SearchProduct searchPro = new SearchProduct();
            searchPro.isSucess = true;
            searchPro.priceListList=new List<PriceList>();
            String query;
            if(isHQSubClient)
            {
                query = 'SELECT Id,Name,FOB_Price__c,Currency__c,Unit__c FROM Price_List__c WHERE Is_Delete__c=false';
                if (String.isNotBlank(searchData)) 
                {
                    query += ' AND (Name=:searchData OR Name LIKE \'%' + searchData + '%\')';
                }
            }
            else
            {
                query = 'SELECT Id,Name FROM Contract_Processing_Product__c';
                if (String.isNotBlank(searchData)) 
                {
                    query += ' WHERE Name=:searchData OR Name LIKE \'%' + searchData + '%\'';
                }
            }
            query +=' limit 100';
            Integer index=1;
            if(isHQSubClient)
            {
                List<Price_List__c> priceList = Database.query(query);
                System.debug('priceList===>'+priceList.size());
                for (Price_List__c priList : priceList) 
                {
            	    PriceList PL = new PriceList();
                    PL.priceListData=priList; 
                    PL.index=index;
                    index++;
                    searchPro.priceListList.add(PL);
                }  
            }
            else
            {
                List<Contract_Processing_Product__c> productList = Database.query(query);
                System.debug('productList===>'+productList.size());
                for (Contract_Processing_Product__c product : productList) 
                {
                    PriceList PL = new PriceList();
                    PL.productData=product; 
                    PL.index=index;
                    index++;
                    searchPro.priceListList.add(PL);
                }
            }
            System.debug('searchPro====>'+searchPro);
            searchPro.errorMsg = '';
            return searchPro;
        } catch (Exception e) {
            SearchProduct searchPro = new SearchProduct();
            searchPro.isSucess = false;
            searchPro.errorMsg = e.getMessage()+';'+e.getLineNumber();
            System.debug('out====>'+searchPro);
            return searchPro;
        }
    }

    @AuraEnabled
    public static Output saveData(
        List<QuoteDetail> quoteDetailList,
        List<String> deleteList
    ) {
        try {
            Output out = new Output();
            out.isSucess = true;
            if (deleteList.size()>0) {
                Database.delete(deleteList);
            }
            System.debug('quoteDetailList:'+quoteDetailList);
            if (quoteDetailList.size()>0) 
            {
                List<Quote_Detail__c> upsertQuoteDetailList = new List<Quote_Detail__c>();
                String orderId;
                for (QuoteDetail  qd: quoteDetailList) 
                {
                	Quote_Detail__c quoteDetail=new Quote_Detail__c();
                	quoteDetail=qd.quoteDetailData;
                    quoteDetail.Id=qd.quoteDetailData.Id;
                    /*if(quoteDetail.Price_List__c != null)
                    {
                        quoteDetail.External_Id__c=quoteDetail.Quote__c+'_'+quoteDetail.Price_List__c;
                    }
                    if(quoteDetail.Quote_Product_Name__c != null)
                    {
                        quoteDetail.External_Id__c=quoteDetail.Quote__c+'_'+quoteDetail.Quote_Product_Name__c;
                    }
                    if(quoteDetail.Contract_Processing_Product__c != null)
                    {
                        quoteDetail.External_Id__c=quoteDetail.Quote__c+'_'+quoteDetail.Contract_Processing_Product__c;
                    }*/
                	upsertQuoteDetailList.add(quoteDetail);
                }
                Database.upsert(upsertQuoteDetailList);
                //Database.upsert(upsertQuoteDetailList,Quote_Detail__c.fields.External_Id__c);
            }
            
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';Line:'+e.getLineNumber();
            return out;
        }
        
    
    }

    public class Output{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public Boolean isHQSubClient {get;set;}

        @AuraEnabled
        public Boolean isRetrograde {get;set;}

        @AuraEnabled
        public Decimal exchangeRate {get;set;}

        @AuraEnabled
        public Decimal paymentTermCostRate {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public List<QuoteDetail> quoteDetailList {get;set;}

        @AuraEnabled
        public List<PriceList> priceListList {get;set;}

        @AuraEnabled
        public List<String> productNameList {get;set;}

        @AuraEnabled
        public Boolean isMXDAPORDDP {get;set;}

    }


     public class QuoteDetail {

        @AuraEnabled
        public Quote_Detail__c quoteDetailData {get;set;}

        @AuraEnabled
        public Boolean isNotEdit {get;set;}

         @AuraEnabled
        public Integer index {get;set;}
    
    }

     public class SearchProduct{

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public List<PriceList> priceListList {get;set;}
 
    }
    public class PriceList {

        @AuraEnabled
        public Price_List__c priceListData {get;set;}

        @AuraEnabled
        public Contract_Processing_Product__c productData {get;set;}

        @AuraEnabled
        public Integer index {get;set;}
    
    }
}