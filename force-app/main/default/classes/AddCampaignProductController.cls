/**************************************************************************************************
 * Name: AddCampaignProductController
 * Object: Campaign_Product__c
 * Purpose: Add Campaign Product Controller - Simplified version following AddOrderItemController pattern
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Agentforce        2026-04-15         Created             
***************************************************************************************************/
public without sharing class AddCampaignProductController {
    
    @AuraEnabled
    public static Output initData(String campaignRecordId) {
        try {
            Output out = new Output();
            Campaign campaign = [SELECT Id, Sales_Org__c,Approval_Status__c,RecordType_Name__c FROM Campaign WHERE Id=:campaignRecordId];
            if (campaign.Approval_Status__c == 'Approved') {
                out.isSucess = false;
                out.errorMsg = 'This data has been approved; products cannot be added.';
                return out;
            }
            if (campaign.RecordType_Name__c == 'Field_Demo' || campaign.RecordType_Name__c == 'Sample') {
                out.isFreeOrder = true;
            }else{
                out.isFreeOrder = false;
            }
            out.isSucess = true;
            out.campaignProductList = new List<CampaignProduct>();
            
            // Load existing Campaign Products (include lookup to Product_Unit__c)
            List<Campaign_Product__c> existingProducts = [
                SELECT 
                    Id,
                    Product_Name__c,
                    Product_Name__r.Name,
                    Product_Name__r.Product__r.Name,
                    Product_Name__r.Product__r.Description_User__c,
                    Quantity__c,
                    Unit__c,
                    Product_Unit_Lookup__c,
                    Product_Unit_Lookup__r.Product_Sales_Unit__c,
                    Delivery_Date__c,
                    Observation__c
                FROM 
                    Campaign_Product__c
                WHERE 
                    Campaign__c =: campaignRecordId
                ORDER BY CreatedDate
            ];
            
            Set<String> productIdSet = new Set<String>();
            for (Campaign_Product__c cp : existingProducts) {
                productIdSet.add(cp.Product_Name__r.Product__c);
            }
            
            Map<String, List<Product_Unit__c>> proUnitMap = getMap(productIdSet);
            
            Integer index = 1;
                for (Campaign_Product__c cp : existingProducts) {
                    CampaignProduct cpItem = new CampaignProduct();
                    // Prepare campaignProductData with helpful display fields
                    cpItem.campaignProductData = cp;
                    // If the record has a Product_Unit_Lookup, prefer that as the Unit__c value for the UI combobox
                    if (cp.Product_Unit_Lookup__c != null) {
                        cpItem.campaignProductData.Unit__c = cp.Product_Unit_Lookup__c;
                        // Keep human-readable Unit__c text as well (from Product_Unit_Lookup__r)
                        cpItem.campaignProductData.Unit__c = cp.Product_Unit_Lookup__r != null ? cp.Product_Unit_Lookup__r.Product_Sales_Unit__c : cp.Unit__c;
                    }
                    cpItem.indexNum = String.valueOf(index * 10);
                    cpItem.opList = new List<Option>();
                    
                    if (proUnitMap.containsKey(cp.Product_Name__r.Product__c)) {
                        for (Product_Unit__c proUnit : proUnitMap.get(cp.Product_Name__r.Product__c)) {
                            Option op = new Option();
                            op.label = proUnit.Product_Sales_Unit__c;
                            op.value = proUnit.Id;
                            cpItem.opList.add(op);
                        }
                    }
                    out.campaignProductList.add(cpItem);
                    index++;
                }
            
            // Search for available products
            Output search = searchDataMe(campaignRecordId, '');
            if (!search.isSucess) {
                out.isSucess = false;
                out.errorMsg = search.errorMsg;
                return out;
            }
            out.productNameList = search.productNameList;
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';'+e.getLineNumber();
            return out;
        }
    }
    
    public static Map<String, List<Product_Unit__c>> getMap(Set<String> productIdSet) {
        Map<String, List<Product_Unit__c>> proUnitMap = new Map<String, List<Product_Unit__c>>();
        for (Product_Unit__c variable : [
            SELECT 
                TOLabel(Product_Sales_Unit__c),
                Id,
                Name,
                Product__c,
                Conversion_Coefficient__c 
            FROM 
                Product_Unit__c 
            WHERE 
                Product__c IN:productIdSet
        ]) {
            if (proUnitMap.containsKey(variable.Product__c)) {
                proUnitMap.get(variable.Product__c).add(variable);
            } else {
                proUnitMap.put(variable.Product__c, new List<Product_Unit__c>{variable});
            }
        }
        return proUnitMap;
    }
    
    @AuraEnabled
    public static Output searchDataMe(String campaignRecordId, String searchData) {
        try {
            Output out = new Output();
            out.isSucess = true;
            Campaign campaign = [SELECT Id, Sales_Org__c FROM Campaign WHERE Id=:campaignRecordId];
            out.productNameList = new List<ProductName>();
            
            String org = campaign.Sales_Org__c;
            
            // Query Product_Name__c filtered by Sales Org
            String query = 
                'SELECT '+
                    'Id, '+
                    'Name, '+
                    'Product__c, '+
                    'Product__r.Name, '+
                    'Product__r.Description_User__c, '+
                    'Product_Sales_Info__r.Default_Sales_Unit__c, '+
                    'Product_Sales_Info__r.Product_Unit__c '+
                'FROM '+
                    'Product_Name__c '+
                'WHERE '+
                    'Product_Sales_Info__r.Status__c=\'On Shelves\' AND '+
                    'Product_Sales_Info__r.Sales_Organization__c =:org AND '+
                    'Is_Delete__c=false ';
                    
            if (String.isNotBlank(searchData)) {
                query += ' AND (Name=:searchData OR Product__r.Name=:searchData';
                String likeQuery = '%'+searchData+'%';
                query += ' OR Product__r.Description_User__c Like: likeQuery)';
            }
            
            query += ' LIMIT 100'; // Load initial 100 records
            
            Set<String> productIdSet = new Set<String>();
            List<Product_Name__c> proNameList = Database.query(query);
            
            for (Product_Name__c proName : proNameList) {
                productIdSet.add(proName.Product__c);
            }
            
            Map<String, List<Product_Unit__c>> proUnitMap = getMap(productIdSet);
            
            for (Product_Name__c proName : proNameList) {
                ProductName pn = new ProductName();
                pn.materialCode = proName.Product__r.Name;
                pn.productDescription = proName.Product__r.Description_User__c;
                pn.productName = proName.Name;
                pn.productNameId = proName.Id;
                pn.salesUnitName = proName.Product_Sales_Info__r.Default_Sales_Unit__c;
                pn.opList = new List<Option>();
                
                if (proUnitMap.get(proName.Product__c) != null) {
                    for (Product_Unit__c proUnit : proUnitMap.get(proName.Product__c)) {
                        Option op = new Option();
                        op.label = proUnit.Product_Sales_Unit__c;
                        op.value = proUnit.Id;
                        pn.opList.add(op);
                        if (pn.salesUnitName == proUnit.Product_Sales_Unit__c) {
                            pn.salesUnitValue = proUnit.Id;
                        }
                    }
                }
                out.productNameList.add(pn);
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
    
    @AuraEnabled
    public static Output saveData(
        List<CampaignProduct> campaignProductListData,
        List<String> deleteList
    ) {
        SavePoint sp = Database.setSavePoint();
        try {
            Output out = new Output();
            out.isSucess = true;
            
            if (deleteList.size() > 0) {
                Database.delete(deleteList);
            }
            
            if (campaignProductListData.size() > 0) {
                List<Campaign_Product__c> cpList = new List<Campaign_Product__c>();
                Set<String> productNameIdSet = new Set<String>();
                Set<String> unitIdSet = new Set<String>();
                
                for (CampaignProduct cp : campaignProductListData) {
                    productNameIdSet.add(cp.campaignProductData.Product_Name__c);
                    unitIdSet.add(cp.campaignProductData.Unit__c);
                }
                
                // Get Product Name details
                Map<String, Product_Name__c> productNameMap = new Map<String, Product_Name__c>();
                for (Product_Name__c pn : [
                    SELECT 
                        Id,
                        Name,
                        Product__r.Name,
                        Product__r.Description_User__c
                    FROM 
                        Product_Name__c 
                    WHERE 
                        Id IN:productNameIdSet
                ]) {
                    productNameMap.put(pn.Id, pn);
                }
                
                // Get Unit details
                Map<String, Product_Unit__c> unitMap = new Map<String, Product_Unit__c>();
                for (Product_Unit__c pu : [
                    SELECT 
                        Id,
                        Product_Sales_Unit__c,
                        Conversion_Coefficient__c
                    FROM 
                        Product_Unit__c 
                    WHERE 
                        Id IN:unitIdSet
                ]) {
                    unitMap.put(pu.Id, pu);
                }
                
                for (CampaignProduct cp : campaignProductListData) {
                    // If a Product_Unit__c Id is provided, store it in the new lookup field (Product_Unit_Lookup__c)
                    // and also keep the textual sales unit in Unit__c for backward compatibility.
                    if (String.isNotBlank(cp.campaignProductData.Unit__c) && unitMap.containsKey(cp.campaignProductData.Unit__c)) {
                        // Set lookup to Product_Unit__c record
                        cp.campaignProductData.Product_Unit_Lookup__c = cp.campaignProductData.Unit__c;
                        // Also set the human-readable sales unit text
                        cp.campaignProductData.Unit__c = unitMap.get(cp.campaignProductData.Unit__c).Product_Sales_Unit__c;
                    } else {
                        // If Unit__c is blank or not an Id, clear lookup to avoid invalid references
                        cp.campaignProductData.Product_Unit_Lookup__c = null;
                    }
                    cpList.add(cp.campaignProductData);
                }
                
                Database.upsert(cpList);
            }
            
            out.errorMsg = '';
            return out;
        } catch (Exception e) {
            Database.rollback(sp);
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+';Line:'+e.getLineNumber();
            return out;
        }
    }
    
    public class Output {
        @AuraEnabled
        public Boolean isSucess {get;set;}
        
        @AuraEnabled
        public String errorMsg {get;set;}
        
        @AuraEnabled
        public List<CampaignProduct> campaignProductList {get;set;}
        
        @AuraEnabled
        public List<ProductName> productNameList {get;set;}

        @AuraEnabled
        public Boolean isFreeOrder {get;set;}
    }
    
    public class CampaignProduct {
        @AuraEnabled
        public String indexNum {get;set;}
        
        @AuraEnabled
        public Campaign_Product__c campaignProductData {get;set;}
        
        @AuraEnabled
        public List<Option> opList {get;set;}
    }
    
    public class Option {
        @AuraEnabled
        public String label {get;set;}
        
        @AuraEnabled
        public String value {get;set;}
    }
    
    public class ProductName {
        @AuraEnabled
        public String materialCode {get;set;}
        
        @AuraEnabled
        public String productDescription {get;set;}
        
        @AuraEnabled
        public String productName {get;set;}
        
        @AuraEnabled
        public String productNameId {get;set;}
        
        @AuraEnabled
        public String salesUnitName {get;set;}
        
        @AuraEnabled
        public String salesUnitValue {get;set;}
        
        @AuraEnabled
        public List<Option> opList {get;set;}
    }
}