/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-16-2025   Gerry   Initial Version
**/
public without sharing class MonthlyBudgetTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isbefore && (Trigger.isinsert || Trigger.isupdate))
        {
            // Set<String> duplicateExterl=new Set<String>();
            // for(Monthly_Budget__c mb:[SELECT Id,ExteralId__c,Campaign_Budget__c,Sales_Rep__c,Month__c FROM Monthly_Budget__c WHERE ExteralId__c != null])
            // {
            //     duplicateExterl.add(mb.ExteralId__c);
            // }
            for(Monthly_Budget__c monthBudget :(List<Monthly_Budget__c>)Trigger.new)
            {
                monthBudget.ExteralId__c=monthBudget.Campaign_Budget__c+'_'+monthBudget.Sales_Rep__c+'_'+monthBudget.Month__c;
                // if(duplicateExterl != null && duplicateExterl.contains(monthBudget.ExteralId__c)){
                //     //monthBudget.addError('Current Sales Rep Select Month Exist Same Budget');
                //     monthBudget.addError(System.Label.ExistSameBudgetError);
                // }
            }
        }
        /*if (Trigger.isafter && (Trigger.isinsert ||  Trigger.isupdate))
        {
            Set<String> userSet=new Set<String>();
            Map<String,User> userMap=new Map<String,User>();
            for(Monthly_Budget__c mb :(List<Monthly_Budget__c>)Trigger.new){
               userSet.add(mb.Sales_Rep__c);
            }
            for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c,Name FROM User WHERE Id IN:userSet])
            {
                userMap.put(user.Id,user);
            }
            for(Monthly_Budget__c monthBudget :(List<Monthly_Budget__c>)Trigger.new)
            {
                system.debug('monthBudget.Budgeted_Amount__c:'+monthBudget.Budgeted_Amount__c);
                system.debug('monthBudget.Month_Remaining_Budget__c:'+monthBudget.Month_Remaining_Budget__c);
                if(monthBudget.Budgeted_Amount__c != null && monthBudget.Budgeted_Amount__c>monthBudget.Month_Remaining_Budget__c	){
                    User saleUser=userMap.get(monthBudget.Sales_Rep__c);
                    monthBudget.addError(saleUser.Name+' '+monthBudget.Month__c+ ' Month Total Budget  Greater Year Budget');
                }
            }
        }*/
        if (Trigger.isbefore && (Trigger.isinsert ||  Trigger.isupdate))
        {
            Set<String> userSet=new Set<String>();
            Set<String> monthBudgetSet=new Set<String>();
            Set<String> camBudgetSet=new Set<String>();
            Map<String,User> userMap=new Map<String,User>();
            Map<String,Decimal> camBudgetMap=new Map<String,Decimal>();
            for(Monthly_Budget__c mb :(List<Monthly_Budget__c>)Trigger.new){
               userSet.add(mb.Sales_Rep__c);
               monthBudgetSet.add(mb.Id);
               camBudgetSet.add(mb.Campaign_Budget__c);
            }
            Map<String,Decimal> calBudgetSpent=new Map<String,Decimal>();
            Map<String,Decimal> calBudgetRemaining=new Map<String,Decimal>();
            for(AggregateResult agg:[SELECT Campaign_Budget__c,SUM(Budgeted_Amount__c) budgetAmount FROM Monthly_Budget__c WHERE Campaign_Budget__c IN:camBudgetSet   GROUP BY  Campaign_Budget__c])
            {
                calBudgetSpent.put((String)agg.get('Campaign_Budget__c'),(Decimal)agg.get('budgetAmount'));
            }
            System.debug('calBudgetSpent=>'+calBudgetSpent);
            for(Campaign_Budget__c cb:[SELECT Id,Budgeted_Amount__c,Name FROM Campaign_Budget__c WHERE Id IN:camBudgetSet])
            {
                camBudgetMap.put(cb.Id,cb.Budgeted_Amount__c);
            }
            System.debug('camBudgetMap=>'+camBudgetMap);
            for(String cbStr:camBudgetMap.keySet())
            {
                Decimal remainAmout=camBudgetMap.get(cbStr);
                if(calBudgetSpent.get(cbStr) != null){
                    remainAmout=remainAmout-calBudgetSpent.get(cbStr);
                }
                calBudgetRemaining.put(cbStr,remainAmout);
            }
            System.debug('calBudgetRemaining=>'+calBudgetRemaining);
            for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c,Name FROM User WHERE Id IN:userSet])
            {
                userMap.put(user.Id,user);
            }
            Map<Id,Monthly_Budget__c> oldMap = (Map<Id,Monthly_Budget__c>)Trigger.oldMap;
            Map<String,Decimal> sumMonthBudget=new Map<String,Decimal>();
            for(Monthly_Budget__c monthBudget :(List<Monthly_Budget__c>)Trigger.new)
            {
                system.debug('monthBudget.Budgeted_Amount__c:'+monthBudget.Budgeted_Amount__c);
                if(!monthBudget.Is_Import__c &&  (Trigger.isinsert || (Trigger.isupdate && oldMap.get(monthBudget.Id).Budgeted_Amount__c  != monthBudget.Budgeted_Amount__c))  &&  monthBudget.Budgeted_Amount__c != null){
                    if(sumMonthBudget.get(monthBudget.Campaign_Budget__c) != null){
                        Decimal sumBudget=sumMonthBudget.get(monthBudget.Campaign_Budget__c);
                        if(Trigger.isinsert){
                            sumBudget=sumBudget+monthBudget.Budgeted_Amount__c;
                        }else{
                            sumBudget=sumBudget+monthBudget.Budgeted_Amount__c-oldMap.get(monthBudget.Id).Budgeted_Amount__c;
                        }
                        sumMonthBudget.put(monthBudget.Campaign_Budget__c,sumBudget);
                    }else{
                        if(Trigger.isinsert){
                            sumMonthBudget.put(monthBudget.Campaign_Budget__c,monthBudget.Budgeted_Amount__c);
                        }else{
                            sumMonthBudget.put(monthBudget.Campaign_Budget__c,monthBudget.Budgeted_Amount__c-oldMap.get(monthBudget.Id).Budgeted_Amount__c);
                        }
                        
                    }
                    if(sumMonthBudget.get(monthBudget.Campaign_Budget__c)>calBudgetRemaining.get(monthBudget.Campaign_Budget__c)){
                    User saleUser=userMap.get(monthBudget.Sales_Rep__c);
                    //monthBudget.addError(saleUser.Name+' '+monthBudget.Month__c+' Month Total Budget  Greater Year Budget');
                    monthBudget.addError(saleUser.Name+' '+monthBudget.Month__c+System.Label.BudgetGreaterYearBudgetError);
                }}
                if(monthBudget.Is_Import__c){
                    monthBudget.Is_Import__c=false;
                }
                    
            }
        }
        if (Trigger.isbefore && Trigger.isupdate)
        {
            Set<String> userSet=new Set<String>();
            Map<String,User> userMap=new Map<String,User>();
            for(Monthly_Budget__c mb :(List<Monthly_Budget__c>)Trigger.new){
               userSet.add(mb.Sales_Rep__c);
            }
            for(User user:[SELECT Id,Profile.Name,Delivery_Plant__c,Sales_Org__c,Name FROM User WHERE Id IN:userSet])
            {
                userMap.put(user.Id,user);
            }
            Map<Id,Monthly_Budget__c> oldMap = (Map<Id,Monthly_Budget__c>)Trigger.oldMap;
            for(Monthly_Budget__c monthBudget :(List<Monthly_Budget__c>)Trigger.new)
            {
                if(oldMap.get(monthBudget.Id).Budgeted_Amount__c  != monthBudget.Budgeted_Amount__c && monthBudget.Budgeted_Amount__c < monthBudget.Amount_Spent__c){
                    User saleUser=userMap.get(monthBudget.Sales_Rep__c);
                    //monthBudget.addError(saleUser.Name+' '+monthBudget.Month__c+' Budget Amount Less Than Amount Spent');
                    monthBudget.addError(saleUser.Name+' '+monthBudget.Month__c+System.Label.BudgetLessSpentError);
                }
            }
        }
}
}