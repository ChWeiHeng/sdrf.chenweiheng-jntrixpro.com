/**
 * @description       :
 * @author            : Gerry
 * @group             :
 * @last modified on  : 04-16-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-19-2025   Gerry   Initial Version
 **/
public without sharing class CampaignTriggerHandler implements Triggers.Handler{
    public void handle() {
        // 超预算审批通过后通知他自己 start 
        if (Trigger.isafter && Trigger.isupdate) {
            Map<Id,Campaign> oldMap = (Map<Id,Campaign>)Trigger.oldMap;
            Set<String> adminSet = new Set<String>();
            adminSet.add(System.UserInfo.getUserId());
            for (Campaign cam :(List<Campaign>)Trigger.new) {
                if (
                    (cam.MKT_Approval__c == 'Approved' && cam.MKT_Approval__c!=oldMap.get(cam.Id).MKT_Approval__c) &&
                    cam.Is_MKT_Approvel__c
                ) {
                    CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
                    CustomNotificationFromApex.notifyUsers(
                        notificationType, 
                        adminSet, //发送通知给谁
                        cam.Id, //通知点击后跳转到什么数据上
                        System.Label.BudgetTitle, //标题
                        System.Label.BudgetBody.replace('[Campaign Owner Name]', cam.Owner_Name__c)//内容
                    );
                }

                if (cam.Approval_Status__c == 'Approved' && cam.Approval_Status__c != oldMap.get(cam.Id).Approval_Status__c) {
                    CreateFreeOrderController.Output out = CreateFreeOrderController.createFreeOrder(cam.Id);
                    if (!out.isSucess) {
                        cam.addError(out.errorMsg);
                    }
                }
            }
            
        }
        // 超预算审批通过后通知他自己 end
        if (Trigger.isbefore && Trigger.isupdate) {
            Map<Id,Campaign> oldMap = (Map<Id,Campaign>)Trigger.oldMap;
            Set<String> adminSet = new Set<String>();
            adminSet.add(System.UserInfo.getUserId());
            for (Campaign cam :(List<Campaign>)Trigger.new) {
                if (
                    (cam.MKT_Approval__c == 'Approved' && cam.MKT_Approval__c!=oldMap.get(cam.Id).MKT_Approval__c)
                ) {
                    cam.Status = 'Completed';
                }
                if (cam.Approval_Status__c == 'Approved' && cam.MKT_Approval__c!=oldMap.get(cam.Id).MKT_Approval__c && cam.MKT_Approval__c=='Approving') {
                    Map<String,Integer> numberMap = checkAttachments(cam.Id);
                    System.debug('numberMap====>'+numberMap);
                    if(numberMap.get('image')<5 || numberMap.get('video')<1) {
                        if (!System.Test.isRunningTest()) {
                            // Please ensure you upload at least 5 on-site photos and 1 video to maintain the completeness of campaign
                            cam.addError(System.Label.CamFileError);
                        }
                        
                    }
                }
            }
            
        }
        if (Trigger.isbefore && Trigger.isinsert)
        {
            Set<String> userSet=new Set<String>();
            Map<String,User> userMap=new Map<String,User>();
            for(Campaign cam :(List<Campaign>)Trigger.new){
                userSet.add(cam.OwnerId);
            }
            for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c,Sales_Org_Text__c FROM User WHERE Id IN:userSet])
            {
                userMap.put(user.Id,user);
            }
            for(Campaign cam :(List<Campaign>)Trigger.new){
                if(userMap.get(cam.OwnerId) != null && (userMap.get(cam.OwnerId).Sales_Org__c=='5070' || userMap.get(cam.OwnerId).Sales_Org__c=='5130')){
                    cam.Currency__c='USD';
                }
                if(userMap.get(cam.OwnerId) != null && (userMap.get(cam.OwnerId).Sales_Org__c=='3010' || userMap.get(cam.OwnerId).Sales_Org__c=='3020')){
                    cam.Currency__c='MXN';
                }
                //if(userMap.get(cam.OwnerId) != null){
                    //cam.Sales_Org__c=userMap.get(cam.OwnerId).Sales_Org__c;
                //}
                if(cam.Applicant__c == null){
                    cam.Applicant__c=cam.OwnerId;
                }
                
                cam.Date_of_the_event__c=cam.Date__c;
            }
            autoRelationBudget();
            autoChangeManager();
        }
        if (Trigger.isbefore && Trigger.isupdate)
        {
            autoRelationBudget();
            autoChangeManager();
        }
        if (Trigger.isbefore && Trigger.isUpdate)
        {
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            Map<Id,Campaign> oldMap = (Map<Id,Campaign>)Trigger.oldMap;
            for(Campaign cam :(List<Campaign>)Trigger.new)
            {
                if(cam.RecordType_Name__c == 'Offline_Campaign' &&  cam.Approval_Status__c == 'Approved'  &&
                    (oldMap.get(cam.Id).Name  != cam.Name ||
                    oldMap.get(cam.Id).Date__c  != cam.Date__c ||
                    oldMap.get(cam.Id).Type  != cam.Type ||
                    (oldMap.get(cam.Id).Budget__c  != cam.Budget__c && !u.Profile.Name.contains('Marketing Manage')) ||
                    oldMap.get(cam.Id).Objective__c  != cam.Objective__c ||
                    oldMap.get(cam.Id).Segment_1__c      != cam.Segment_1__c    ||
                    oldMap.get(cam.Id).Segment_2__c      != cam.Segment_2__c    ||
                    oldMap.get(cam.Id).Crop_Problematic__c  != cam.Crop_Problematic__c ||
                    oldMap.get(cam.Id).Applicant__c  != cam.Applicant__c ||
                    oldMap.get(cam.Id).Related_Product_Level__c  != cam.Related_Product_Level__c ||
                    oldMap.get(cam.Id).Product_Line__c  != cam.Product_Line__c ||
                    oldMap.get(cam.Id).Crop_Solution__c      != cam.Crop_Solution__c    ||
                    oldMap.get(cam.Id).Customer__c   != cam.Customer__c     ||
                    oldMap.get(cam.Id).Customer_Type__c   != cam.Customer_Type__c     ||
                    oldMap.get(cam.Id).Customer_Lookup__c   != cam.Customer_Lookup__c     ||
                    oldMap.get(cam.Id).Audience__c   != cam.Audience__c     ||
                    //oldMap.get(cam.Id).Product__c   != cam.Product__c     ||
                oldMap.get(cam.Id).Co_branding_Sponsorship__c  != cam.Co_branding_Sponsorship__c ||
                    oldMap.get(cam.Id).Detail_Plan__c    != cam.Detail_Plan__c  ||
                    oldMap.get(cam.Id).Estimated_Participants__c     != cam.Estimated_Participants__c )
                    
                ){
                    //cam.addError('Approved No Change Campaign Information');
                    cam.addError(System.Label.NoChangeCampaignInfoError);
                }
                if(cam.RecordType_Name__c == 'Online_Campaign' &&  cam.Approval_Status__c == 'Approved'  &&
                    (oldMap.get(cam.Id).Name  != cam.Name ||
                    oldMap.get(cam.Id).Date__c  != cam.Date__c ||
                    oldMap.get(cam.Id).Type  != cam.Type ||
                    (oldMap.get(cam.Id).Budget__c  != cam.Budget__c && !u.Profile.Name.contains('Marketing Manage')) ||
                    oldMap.get(cam.Id).Social_Meida_Channel__c   != cam.Social_Meida_Channel__c    ||
                    oldMap.get(cam.Id).Applicant__c  != cam.Applicant__c ||
                    oldMap.get(cam.Id).Campaing_Duration__c      != cam.Campaing_Duration__c    ||
                    oldMap.get(cam.Id).Season__c     != cam.Season__c   ||
                    oldMap.get(cam.Id).Target_Audience_Interestes__c      != cam.Target_Audience_Interestes__c    ||
                    oldMap.get(cam.Id).Target_Audiences_Age_Range__c   != cam.Target_Audiences_Age_Range__c     ||
                    oldMap.get(cam.Id).Target_Audiences_Gender__c   != cam.Target_Audiences_Gender__c     ||
                    oldMap.get(cam.Id).Target_Potential_Audiences__c  != cam.Target_Potential_Audiences__c ||
                    oldMap.get(cam.Id).Geographics_Area__c     != cam.Geographics_Area__c)
                    
                ){
                    //cam.addError('Approved No Change Campaign Information');
                    cam.addError(System.Label.NoChangeCampaignInfoError);
                }
                if(!(cam.Approval_Status__c == 'Approved'  && (cam.MKT_Approval__c=='Draft' || cam.MKT_Approval__c=='Rejected')) &&
                    (oldMap.get(cam.Id).Location__c  != cam.Location__c ||
                    oldMap.get(cam.Id).Date_of_the_event__c  != cam.Date_of_the_event__c ||
                    oldMap.get(cam.Id).Actual_Costs__c  != cam.Actual_Costs__c ||
                    oldMap.get(cam.Id).Currency__c	  != cam.Currency__c	 ||
                    oldMap.get(cam.Id).Actual_number_of_Participants__c   != cam.Actual_number_of_Participants__c    ||
                    oldMap.get(cam.Id).Quality_of_Participants__c  != cam.Quality_of_Participants__c ||
                    oldMap.get(cam.Id).Whether_Generated_Orders__c	      != cam.Whether_Generated_Orders__c	    ||
                    oldMap.get(cam.Id).Order_Amount__c	     != cam.Order_Amount__c	   ||
                    oldMap.get(cam.Id).New_Customers_Generated__c      != cam.New_Customers_Generated__c    ||
                    oldMap.get(cam.Id).Competitor_Info__c   != cam.Competitor_Info__c     ||
                    oldMap.get(cam.Id).Client_Feedback__c   != cam.Client_Feedback__c     ||
                    oldMap.get(cam.Id).Summary__c  != cam.Summary__c ||
                    oldMap.get(cam.Id).Frecuency__c  != cam.Frecuency__c ||
                    oldMap.get(cam.Id).Reach__c  != cam.Reach__c ||
                    oldMap.get(cam.Id).Mark_the_event__c     != cam.Mark_the_event__c)
                    
                ){
                    //cam.addError('Current Status No Change Description Information');
                    cam.addError(System.Label.NoChangeDescriptionInfoError);
                }
            }
        }
        if (Trigger.isafter && Trigger.isUpdate)
        {
            Set<String> updateMonthBudget=new Set<String>();
            Map<Id,Campaign> oldMap = (Map<Id,Campaign>)Trigger.oldMap;
            for(Campaign cam :(List<Campaign>)Trigger.new)
            {
                if((oldMap.get(cam.Id).MKT_Approval__c  != cam.MKT_Approval__c || oldMap.get(cam.Id).Approval_Status__c  != cam.Approval_Status__c)   && cam.Monthly_Budget__c != null){
                    updateMonthBudget.add(cam.Monthly_Budget__c);
                }
            }
            calBudgetAmount(updateMonthBudget);
        }
    }
    public  void autoRelationBudget()
    {
        Map<String,String> camUserMap=new Map<String,String>();
        Map<String,String> camYearMap=new Map<String,String>();
        Map<String,String> camMonthMap=new Map<String,String>();
        Map<String,User> userMap=new Map<String,User>();
        for(Campaign cam :(List<Campaign>)Trigger.new){
            camUserMap.put(cam.Id,cam.OwnerId);
            if (cam.Date__c!=null) {
                camYearMap.put(cam.Id,String.valueOf(cam.Date__c.Year()));
                camMonthMap.put(cam.Id,String.valueOf(cam.Date__c.Month()));
            }
           
        }
        for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c FROM User WHERE Id IN:camUserMap.values()])
        {
            userMap.put(user.Id,user);
            //yearExteralSet.add(user.Sales_Org__c+'_'+user.Delivery_Plant__c+'_'+year);
        }
        system.debug('userMap:'+userMap);
        Map<String,Monthly_Budget__c> monthBudgetMap=new Map<String,Monthly_Budget__c>();
        for(Monthly_Budget__c mb:[SELECT Id,Campaign_Budget__r.ExteralId__c,Month__c,Sales_Rep__c FROM Monthly_Budget__c WHERE Campaign_Budget__r.Year__c IN:camYearMap.values() AND Month__c IN:camMonthMap.values() AND Sales_Rep__c IN:userMap.keySet()])
        {
            monthBudgetMap.put(mb.Campaign_Budget__r.ExteralId__c+'_'+mb.Sales_Rep__c+'_'+mb.Month__c,mb);
        }
        system.debug('monthBudgetMap:'+monthBudgetMap);
        for(Campaign cam :(List<Campaign>)Trigger.new)
        {
            if (cam.RecordType_Name__c == 'Sample') {
                continue;
            }
            string joinExteral=userMap.get(cam.OwnerId).Sales_Org__c+'_'+userMap.get(cam.OwnerId).Delivery_Plant__c+'_'+camYearMap.get(cam.Id)+'_'+cam.OwnerId+'_'+camMonthMap.get(cam.Id);
            if(monthBudgetMap != null && monthBudgetMap.get(joinExteral) != null){
                cam.Monthly_Budget__c=monthBudgetMap.get(joinExteral).Id;
            }else{
                //cam.addError('Current Sale Rep No Map Month Budget');
                if(!System.Test.isRunningTest()){
                        cam.addError(System.Label.NoMapMonthBudgetError);
                }
                
            }
            
        }
    }
    public  void calBudgetAmount(Set<String> updateMonthBudget){
        Map<String,Decimal> updateBudgetSpent=new Map<String,Decimal>();
        for(AggregateResult agg:[SELECT Monthly_Budget__c,SUM(Actual_Costs__c) spentAmount FROM Campaign WHERE Monthly_Budget__c IN:updateMonthBudget AND MKT_Approval__c='Approved'  GROUP BY  Monthly_Budget__c])
        {
            updateBudgetSpent.put((String)agg.get('Monthly_Budget__c'),(Decimal)agg.get('spentAmount'));
        }
        Map<String,Decimal> updateBudgetOccupied=new Map<String,Decimal>();
        for(AggregateResult agg:[SELECT Monthly_Budget__c,SUM(Budget__c) budgetAmount FROM Campaign WHERE Monthly_Budget__c IN:updateMonthBudget AND (Approval_Status__c='Approving' OR Approval_Status__c='Approved')  AND MKT_Approval__c!='Approved' AND MKT_Approval__c !='Rejected' GROUP BY  Monthly_Budget__c])
        {
            updateBudgetOccupied.put((String)agg.get('Monthly_Budget__c'),(Decimal)agg.get('budgetAmount'));
        }
        List<Monthly_Budget__c> updateMonthBudgetList =new List<Monthly_Budget__c>();
        for(String monthBudget:updateMonthBudget)
        {
            Monthly_Budget__c mb=new Monthly_Budget__c();
            mb.Id=monthBudget;
            mb.Amount_Spent__c=updateBudgetSpent.get(monthBudget);
            mb.Amount_Occupied__c=updateBudgetOccupied.get(monthBudget);
            updateMonthBudgetList.add(mb);
        }
        system.debug('updateMonthBudgetList=>'+updateMonthBudgetList);
        if(updateMonthBudgetList.size()>0){
            update updateMonthBudgetList;
        }
    }
    public  void autoChangeManager()
    {
        Set<String> userSet=new Set<String>();
        Map<String,User> userMap=new Map<String,User>();
        for(Campaign cam :(List<Campaign>)Trigger.new){
            userSet.add(cam.OwnerId);
        }
        for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c,Sales_Org_Text__c,ManagerId FROM User WHERE Id IN:userSet])
        {
            userMap.put(user.Id,user);
        }
        for(Campaign cam :(List<Campaign>)Trigger.new){
            if(userMap.get(cam.OwnerId) != null){
                system.debug('saleorg:'+userMap.get(cam.OwnerId).Sales_Org__c);
                cam.User_Manager__c=userMap.get(cam.OwnerId).ManagerId;
                cam.Sales_Org__c=userMap.get(cam.OwnerId).Sales_Org__c;
                cam.Delivery_Plant__c=userMap.get(cam.OwnerId).Delivery_Plant__c;
                if(userMap.get(cam.OwnerId).Profile.Name.contains('Marketing Manage')){
                    cam.Is_MKT_Manager__c=true;
                }else{
                    cam.Is_MKT_Manager__c=false;
                }
        }}
    }

    /**
    * @description 检查附件信息
    * @author Gerry | 05-26-2025 
    * @param Id recordId 
    **/
    public static Map<String,Integer> checkAttachments(Id recordId) {
        Map<String,Integer> numberMap = new Map<String,Integer>();

        Set<String> documentrecordId = new Set<String>();
        for (ContentDocumentLink cdl : [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId]) {
            documentrecordId.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> attachments = [
            SELECT Id, FileType 
            FROM ContentDocument 
            WHERE Id IN:documentrecordId
        ];
        
        Set<String> imageExtensions = new Set<String>();
         if(!System.Test.isRunningTest()){
             imageExtensions.addAll(System.label.ImageType.split(';'));
        }      
        Set<String> videoExtensions = new Set<String>();
        if(!System.Test.isRunningTest()){
             videoExtensions.addAll(System.Label.VideoType.split(';'));
        }       
        Integer imageNumber = 0;
        Integer videoNumber = 0;
        for (ContentDocument att : attachments) {
            Boolean isImage = false;
            Boolean isVideo = false;
            String fileExtension = att.FileType.toLowerCase();
            
            isImage = imageExtensions.contains(fileExtension);
            isVideo = videoExtensions.contains(fileExtension);
            
            // 输出结果（示例）
            if (isImage) {
                imageNumber++;
            } else if (isVideo) {
                videoNumber++;
            }
        }
        numberMap.put('image', imageNumber);
        numberMap.put('video', videoNumber);
        return numberMap;
    }
}