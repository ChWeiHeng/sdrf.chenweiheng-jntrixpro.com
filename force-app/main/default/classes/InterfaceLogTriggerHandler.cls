public without sharing class InterfaceLogTriggerHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isafter && Trigger.isInsert ) {
            Profile adminPro = [SELECT Id FROM Profile WHERE Name='系统管理员' OR Name='System Administrator' or Name = 'Administrador del sistema' limit 1];
            List<User> userList = [SELECT Id,ProfileId  FROM User WHERE ProfileId =: adminPro.Id AND IsActive =true];
            Set<String> uSet = new Set<String>();
            for(User u : userList){
                uSet.add(u.Id);
            }
            for (Interface_Log__c il : (List<Interface_Log__c>)Trigger.new) {
                if (il.Is_Success__c == false) {
                    Utility.notificationUserTitle(uSet,il.Id,'log fail',il.Apex_Class_Name__c+' ; '+il.Dml_Option__c);
                }
                
            }
        }
    }
}