/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-20-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-20-2025   Gerry   Initial Version
**/
@isTest
public class PriceBookChangeTriggerHandlerTest {
    
    
    
    @isTest
    static void testPriceBookStatusChange() {
        Price_Book__c pb = new Price_Book__c();
        pb.Sales_Org__c = '5130';
        pb.Name = '111';
        pb.Currency__c = 'USD';
        pb.Status__c = 'Draft';
        insert pb;

        Price_Book_Item__c pbi = new Price_Book_Item__c();
        pbi.Price_Book__c = pb.Id;
        // pbi.Product_Name__c = pn.Id;
        pbi.Price__c = 1;
        insert pbi;

        pb.Status__c = 'Approved';
        update pb;
    }
    
   
}