public without sharing class AccountVisitSubmitController {
    @AuraEnabled
    public static Output NoticeManage(String accVisitId) {
        System.debug('accVisitId=>'+accVisitId);
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try {
            Account_Visit__c accVisit = [SELECT Id,Name,OwnerId,Plant__c FROM Account_Visit__c WHERE Id=:accVisitId];
            List<User> userList=[SELECT Id,ManagerId FROM  User WHERE Id =: accVisit.OwnerId];
            if(userList.size()>0)
            {
                Set<String> noticeUserSet = new Set<String>();
                if(userList[0].ManagerId==null)
                {
                     out.isSucess = false;out.errorMsg = System.Label.CustometVisitSubmitError;return out;
                }else{
                    noticeUserSet.add(userList[0].ManagerId);
                    if(accVisit.Plant__c=='5070'){
                        noticeUserSet.addAll(System.Label.CustometVisitSubmitNoticeUser.split(';'));
                    }
                    System.debug('noticeUserSet=>'+noticeUserSet);
                    CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
                    CustomNotificationFromApex.notifyUsers(
                        notificationType, 
                        noticeUserSet, //发送通知给谁
                        accVisit.Id, //通知点击后跳转到什么数据上
                        'Account Visist Sumbit', //标题
                        'Account Visist '+accVisit.Name+' '+System.Label.CustometVisitSubmitNoticeManager//内容
                    );
                    List<Account_Visit__Share> accountVisitShareList=new List<Account_Visit__Share>();
                    for(String userId:noticeUserSet)
                    {
                        Account_Visit__Share accountVisitShare = new Account_Visit__Share();
                        accountVisitShare.ParentId = accVisitId;
                        accountVisitShare.UserOrGroupId = userId;
                        if(userId==userList[0].ManagerId){
                            accountVisitShare.AccessLevel = 'Edit';
                        }else{
                            accountVisitShare.AccessLevel = 'Read';
                        }
                        
                        accountVisitShare.RowCause = 'Manual';
                        accountVisitShareList.add(accountVisitShare);
                    }
                    
                    system.debug('accountVisitShareList:'+accountVisitShareList);
                    upsert accountVisitShareList;

                    Account_Visit__c updateAccVisit=new Account_Visit__c();
                    updateAccVisit.Id=accVisitId;
                    updateAccVisit.status__c='Submited';
                    update updateAccVisit;
                }
            }
            
            
        } catch (Exception e) {
            out.isSucess = false;
            system.debug('185Line'+e.getMessage()+e.getLineNumber());
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(', ')+1);
            return out;
        }
        return out;
        
    }

    @AuraEnabled
    public static Output init(String accVisitId) {
        Output out = new Output();
        out.isSucess = true;
        out.errorMsg = 'Successful';
        try{
            Account_Visit__c accVisit = [SELECT Id,status__c FROM Account_Visit__c WHERE Id=:accVisitId];
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
        public String errorMsg {get;set;}

    }
}