/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-13-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-13-2026   Gerry   Initial Version
**/
public with sharing class BatchEditOrderItemController {
    
    /**
     * Get all Order Items for a specific Order
     * @param orderId The Order record ID
     * @return List of Order Item records with related fields
     */
    @AuraEnabled(cacheable=true)
    public static List<Order_Item__c> getOrderItems(Id orderId) {
        try {
            return [
                SELECT Id, Name, 
                       Product__c, Product__r.Name,
                       Sales_Unit__c, Sales_Unit__r.Name,
                       Quantity__c,
                       Price__c,
                       Total_Price__c
                FROM Order_Item__c
                WHERE Order__c = :orderId
                ORDER BY CreatedDate ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching order items: ' + e.getMessage());
        }
    }
    
    /**
     * Get Product lookup options
     * @param searchTerm Search term for filtering products
     * @return List of Product records
     */
    @AuraEnabled(cacheable=true)
    public static List<Product__c> searchProducts(String searchTerm) {
        try {
            String searchPattern = '%' + searchTerm + '%';
            return [
                SELECT Id, Name
                FROM Product__c
                WHERE Name LIKE :searchPattern
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error searching products: ' + e.getMessage());
        }
    }
    
    /**
     * Get Product Unit lookup options
     * @param searchTerm Search term for filtering units
     * @return List of Product Unit records
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Unit__c> searchProductUnits(String searchTerm) {
        try {
            String searchPattern = '%' + searchTerm + '%';
            return [
                SELECT Id, Name
                FROM Product_Unit__c
                WHERE Name LIKE :searchPattern
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error searching product units: ' + e.getMessage());
        }
    }
    
    /**
     * Save batch edited Order Items
     * @param orderItems List of Order Items to update
     * @return Success message
     */
    @AuraEnabled
    public static String saveOrderItems(List<Order_Item__c> orderItems) {
        try {
            if (orderItems == null || orderItems.isEmpty()) {
                throw new AuraHandledException('No order items to save');
            }
            
            // Validate and calculate Total_Price__c for each item
            for (Order_Item__c item : orderItems) {
                if (item.Quantity__c != null && item.Price__c != null) {
                    item.Total_Price__c = item.Quantity__c * item.Price__c;
                }
            }
            
            update orderItems;
            return 'Successfully saved ' + orderItems.size() + ' order item(s)';
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving order items: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error saving order items: ' + e.getMessage());
        }
    }
}