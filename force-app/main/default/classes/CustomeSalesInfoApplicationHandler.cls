/**
 * @description       : 客户销售信息handler
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-17-2025   Gerry   Initial Version
**/
public without sharing class CustomeSalesInfoApplicationHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isAfter && Trigger.isupdate) {
            Map<Id,Customer_Sales_Info_Change_Application__c> oldMap = (Map<Id,Customer_Sales_Info_Change_Application__c>)Trigger.oldMap;
            List<Customer_Sales_Info__c> csiList = new List<Customer_Sales_Info__c>();
            List<Customer_Tax_Category__c> ctcList = new List<Customer_Tax_Category__c>();
            List<String> csicaIdList = new List<String>();
            for (Customer_Sales_Info_Change_Application__c csca : (List<Customer_Sales_Info_Change_Application__c>)Trigger.new) {
                if (csca.Approve_Status__c == 'Approved' && csca.Approve_Status__c != oldMap.get(csca.Id).Approve_Status__c) {
                    Boolean flag = false;
                    Customer_Sales_Info__c csi = new Customer_Sales_Info__c();

                    if (csca.New_Payment_term__c!=null) {
                        csi.Terms_Of_Payment__c = csca.New_Payment_term__c;
                        flag = true;
                    }

                    if (csca.New_Customer_Group__c!=null) {
                        csi.Payment_method__c = csca.New_Customer_Group__c;
                        flag = true;
                    }

                    if (csca.New_Shipping_Conditions__c!=null) {
                        csi.Shipping_Conditions__c = csca.New_Shipping_Conditions__c;
                        flag = true;
                    }

                    if (csca.New_Currency__c!=null) {
                        csi.Currency__c = csca.New_Currency__c;
                        flag = true;
                    }
                    if (csca.New_Account_Assessment__c!=null) {
                        csi.Acct_Assmt_Grp_Cust__c = csca.New_Account_Assessment__c;
                        flag = true;
                    }
                    
                    csi.Id = csca.Customer_Sales_Info__c;

                    if (flag) {
                        csiList.add(csi);
                    }
                    if (csca.Sales_Org__c!='5130' && csca.Sales_Org__c!='5070') {
                        csicaIdList.add(csca.Id);
                    }
                }
            }
            

            if (csicaIdList.size()>0) {
                for (Customer_Tax_Category_Application__c ctca : [SELECT Customer_Tax_Category__c,ID,New_Tax_Category__c FROM Customer_Tax_Category_Application__c WHERE Customer_Sales_Info_Change_Application__c IN:csicaIdList]) {
                    if (ctca.New_Tax_Category__c!=null) {
                        Customer_Tax_Category__c ctc = new Customer_Tax_Category__c();
                        ctc.Id = ctca.Customer_Tax_Category__c;
                        ctc.Tax_Category__c = ctca.New_Tax_Category__c;
                        ctcList.add(ctc);
                    }
                    
                }
                if (ctcList.size()>0) {
                    Update ctcList;
                }
            }

            if (csiList.size()>0) {
                Update csiList;
            }
        }

        if (Trigger.isBefore && Trigger.isupdate) {
            Map<Id,Customer_Sales_Info_Change_Application__c> oldMap = (Map<Id,Customer_Sales_Info_Change_Application__c>)Trigger.oldMap;
           
            for (Customer_Sales_Info_Change_Application__c csca : (List<Customer_Sales_Info_Change_Application__c>)Trigger.new) {
                if (csca.Approve_Status__c == 'Approving' && csca.Approve_Status__c != oldMap.get(csca.Id).Approve_Status__c) {
                    if (csca.Sales_Org__c!='5130' && csca.Sales_Org__c!='5070') {
                        if (!csca.Is_Change__c && csca.Change_Item__c==0) {
                            csca.adderror(System.Label.NoChanged);
                        
                        }
                    }else{
                        if (!csca.Is_Change__c ) {
                            csca.adderror(System.Label.NoChanged);
                        
                        }
                    } 
                }
            }
        }
    }
}