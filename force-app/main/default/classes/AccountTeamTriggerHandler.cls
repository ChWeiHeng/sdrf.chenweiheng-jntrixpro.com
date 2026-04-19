/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-12-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-27-2025   Gerry   Initial Version
**/
public without sharing class AccountTeamTriggerHandler  implements Triggers.Handler{
    public static void handle() {
        if (Trigger.isbefore && Trigger.isUpdate) {
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c,Country__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            // 判断当前用户是否在某个权限集下
            List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Country_Admin'];
            Boolean hasPermissionSet = !psaList.isEmpty();
            Map<Id,Account_Team__c> oldMap = (Map<Id,Account_Team__c>)Trigger.oldMap;
            // List<String> userList = System.Label.Customer_Team_User.split(';');
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                if (at.Is_Ruuning__c && !System.Test.isRunningTest()) {
                    //at.adderror('Cannot edit in shared processing');
                    at.adderror(System.Label.AccTeamEditError);
                }
                if (
                    u.Profile.Name != 'System Administrator' && 
                    at.Sales_Rep_Delivery_Plant__c != 
                    at.Customer_Owner_Plant__c && 
                    !System.Test.isRunningTest() &&
                    !hasPermissionSet
                ) {
                    //at.adderror('Cannot edit across factories data');
                    at.adderror(System.Label.AccTeamEditPlantError);
                }
                if (hasPermissionSet && at.Sales_Rep_Country__c != u.Country__c) {
                    at.adderror(System.Label.AccTeamEditPlantError);
                }
                if (at.Is_Ruuning__c == oldMap.get(at.Id).Is_Ruuning__c) {
                    at.Is_Ruuning__c = true;
                }
                if (at.Shared_Performance__c != oldMap.get(at.Id).Shared_Performance__c && at.Shared_Performance__c) {
                    at.Add_Operation_Date__c = System.today();
                }
            }
        }
        if (Trigger.isbefore && Trigger.isInsert) {
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                at.Add_Operation_Date__c = System.today();
            }
        }

        if (Trigger.isafter && Trigger.isUpdate ) {
            //调用数据共享
            Map<Id,Account_Team__c> oldMap = (Map<Id,Account_Team__c>)Trigger.oldMap;
          
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                if (!System.isBatch() && !System.isFuture() && !System.Test.isRunningTest()) {
                    Database.executeBatch(new ShareAccountDataBatch(at.Id,at.Customer__c,1), 100);
                }
                
            }
        }

        //自动生成销售预测 start
        if (Trigger.isafter && (Trigger.isUpdate || Trigger.isInsert )) {
            Map<Id,Account_Team__c> oldMap = (Map<Id,Account_Team__c>)Trigger.oldMap;

            Map<String,String> userMap = new Map<String,String>();
            Set<String> accSet = new Set<String>();
            Set<String> userSet = new Set<String>();
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                
                
                if(
                    (Trigger.isUpdate && oldMap.get(at.Id).Shared_Performance__c != at.Shared_Performance__c && at.Shared_Performance__c) ||
                    (Trigger.isinsert && at.Shared_Performance__c)
                ) {
                    accSet.add(at.Customer__c);
                    userSet.add(at.CreatedById );
                    userMap.put(at.CreatedById ,at.Sales_Rep__c);
                }

                
            }
            Map<String,List<Sales_Forcast__c>> salesForcastMap = new Map<String,List<Sales_Forcast__c>>();
            List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Sales_Forcast__c.FieldSets.QueryField.getFields();
            // 拼接需要复制得字段
            String orderQuery = 'SELECT ';
            String field = '';
            Date day = System.today();
            String year = String.valueOf(day.Year());
            for (Schema.FieldSetMember f : fieldSetMembers) {
                if (String.isNotBlank(field)) {
                    field += ','+f.getFieldPath();
                }else{
                    field += f.getFieldPath();
                }
                
            }
            orderQuery = orderQuery+field+' FROM Sales_Forcast__c WHERE Customer__c IN:accSet AND OwnerId IN:userSet AND Year__c=:year';
            List<Sales_Forcast__c> sfList = Database.query(orderQuery);
            
            Map<String,List<Sales_Forcast__c>> sfMap = new Map<String,List<Sales_Forcast__c>>();
            for(Sales_Forcast__c sf : sfList) {
                if(sfMap.containsKey(sf.Customer__c+'_'+sf.OwnerId)) {
                    sfMap.get(sf.Customer__c+'_'+sf.OwnerId).add(sf);
                }else{
                    sfMap.put(sf.Customer__c+'_'+sf.OwnerId,new List<Sales_Forcast__c>{sf});
                }
                
            }
            Map<String,Sales_Forcast__c> insertList = new Map<String,Sales_Forcast__c>();
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                //自动生成销售预测 start
                IF (
                    (Trigger.isUpdate && oldMap.get(at.Id).Shared_Performance__c != at.Shared_Performance__c && at.Shared_Performance__c) ||
                    (Trigger.isinsert && at.Shared_Performance__c)
                ){  
                    if(sfMap.get(at.Customer__c+'_'+at.CreatedById )!=null && at.Sales_Rep_Delivery_Plant__c==at.Create_Plant__c) {
                        for(Sales_Forcast__c sf : sfMap.get(at.Customer__c+'_'+at.CreatedById )) {
                            Sales_Forcast__c cloneSf = sf.clone();
                            cloneSf.Price_USD__c = 0;
                            cloneSf.Monthly_Forecast_USD__c = 0;
                            cloneSf.Monthly_Forecast_Local_Curreny__c = 0;
                            cloneSf.Volumn_Local__c = 0;
                            cloneSf.Price_Local__c = 0;
                            cloneSf.Rolling_Monthly_Forecast_USD__c = 0;
                            cloneSf.Rolling_Price_USD__c = 0;
                            cloneSf.Rolling_Volumn_USD__c = 0;
                            cloneSf.Rolling_Monthly_Forecast_Local_Currency__c = 0;
                            cloneSf.Rolling_Volumn_Local__c = 0;
                            cloneSf.Rolling_Price_Local__c = 0;
                            cloneSf.OwnerId = at.Sales_Rep__c;
                            cloneSf.External_Id__c = cloneSf.Year__c+cloneSf.Month__c+cloneSf.Product_Name__c+
                                                cloneSf.Customer__c+
                                                cloneSf.OwnerId;
                            insertList.put(cloneSf.External_Id__c,cloneSf);
                        }
                    }
                    
                }
            }
            Set<String> externalSet = new Set<String>();
            for(Sales_Forcast__c sf : [SELECT Id,External_Id__c FROM Sales_Forcast__c WHERE External_Id__c IN:insertList.keySet()]) {
                externalSet.add(sf.External_Id__c);
            }

            List<Sales_Forcast__c> iList = new List<Sales_Forcast__c>();
            for(Sales_Forcast__c sf : insertList.values()) {
                if(externalSet.contains(sf.External_Id__c)) {
                    continue;
                }
                iList.add(sf);
            }
            Insert iList;
            //自动生成销售预测 end
        }

        if (Trigger.isbefore && Trigger.isdelete) {
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c,Country__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            // 判断当前用户是否在某个权限集下
            List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Country_Admin'];
            Boolean hasPermissionSet = !psaList.isEmpty();
            Set<String> accSet = new Set<String>();
            // List<String> userList = System.Label.Customer_Team_User.split(';');
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.old) {
                accSet.add(at.Customer__c);
            }
            Map<String,String> accMap = new Map<String,String>();
            for (Account acc : [SELECT Id,OwnerId FROM Account WHERE Id IN:accSet]) {
                accMap.put(acc.Id, acc.OwnerId);
            }
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.old) {
                if (at.Is_Ruuning__c && !System.Test.isRunningTest()) {
                    //at.adderror('Cannot edit/delete in shared processing');
                    at.adderror(System.Label.AccTeamEditDelError);
                }
                if (at.Sales_Rep__c == accMap.get(at.Customer__c) && !System.Test.isRunningTest()) {
                    //at.adderror('Cannot delete account owner\'s data');
                    at.adderror(System.Label.AccTeamDelError);
                }
                if (
                    u.Profile.Name != 'System Administrator' && 
                    at.Sales_Rep_Delivery_Plant__c != at.Customer_Owner_Plant__c && 
                    !System.Test.isRunningTest() &&
                    !hasPermissionSet
                ) {
                    //at.adderror('Cannot delete across factories data');
                    at.adderror(System.Label.AccTeamDelPlantError);
                }

                if (hasPermissionSet && at.Sales_Rep_Country__c != u.Country__c) {
                    at.adderror(System.Label.AccTeamDelPlantError);
                }
            }
        }
        if (Trigger.isafter && Trigger.isdelete) {
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.old) {
                if (!System.isBatch() && !System.isFuture() &&  !System.Test.isRunningTest()) {
                    Database.executeBatch(new DeleteShareBatch(at.Customer__c,at.Sales_Rep__c,1), 100);
                }
            }
            
        }
        if (Trigger.isbefore && Trigger.isinsert) {
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                at.External_Id__c = at.Customer__c+'_'+at.Sales_Rep__c;
            }}
        if (Trigger.isafter && Trigger.isinsert) {
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c,Country__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            Set<String> accSet = new Set<String>();
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                accSet.add(at.Customer__c);
            }
            Map<String,String> accMap = new Map<String,String>();
            for (Account acc : [SELECT Id,OwnerId FROM Account WHERE Id IN:accSet]) {
                accMap.put(acc.Id, acc.OwnerId);
            }
            // 判断当前用户是否在某个权限集下
            List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Country_Admin'];
            Boolean hasPermissionSet = !psaList.isEmpty();
            // List<String> userList = System.Label.Customer_Team_User.split(';');
            for (Account_Team__c at : (List<Account_Team__c>)Trigger.new) {
                if (
                    u.Profile.Name != 'System Administrator' && 
                    u.Id != accMap.get(at.Customer__c) && 
                    at.Sales_Rep__c != accMap.get(at.Customer__c) && 
                    !System.Test.isRunningTest() &&
                    !hasPermissionSet
                ) {
                    //at.adderror('Customer Owner Can Insert account Team data');
                    at.adderror(System.Label.AccTeamOwnerInsertError);
                }
                system.debug('at.Sales_Rep_Delivery_Plant__c:'+at.Sales_Rep_Delivery_Plant__c);
                system.debug('u.Delivery_Plant__c:'+ u.Delivery_Plant__c);
                System.debug('hasPermissionSet'+hasPermissionSet);   
                if (
                    u.Profile.Name != 'System Administrator' && 
                    at.Sales_Rep_Delivery_Plant__c != u.Delivery_Plant__c && 
                    !System.Test.isRunningTest() &&
                    !hasPermissionSet
                ) {
                    //at.adderror('Only Can Insert Same Deliver Sale Rep account Team data');
                    System.debug('进入校验逻辑1');
                    at.adderror(System.Label.AccTeamInsertSameDeliveryError);
                }
                System.debug('at.Sales_Rep_Country__c'+at.Sales_Rep_Country__c);
                System.debug('u.Country__c'+u.Country__c);

                if (hasPermissionSet && at.Sales_Rep_Country__c != u.Country__c) {
                    System.debug('进入校验逻辑2');
                    at.adderror(System.Label.AccTeamInsertSameDeliveryError);
                }
                if (!System.isBatch() && !System.isFuture() && !System.Test.isRunningTest()) {
                    Database.executeBatch(new ShareAccountDataBatch(at.Id,at.Customer__c,1), 100);
                }
            }
        }
    }
}