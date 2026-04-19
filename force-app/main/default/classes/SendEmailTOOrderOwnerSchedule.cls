/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-23-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-15-2025   Gerry   Initial Version
**/
global class SendEmailTOOrderOwnerSchedule implements Schedulable,Database.AllowsCallouts{
    public String orderId;
    global SendEmailTOOrderOwnerSchedule(String orderId) {
        this.orderId = orderId;
    }
    global void execute(SchedulableContext sc) {
        System.debug('OrderId=====>'+orderId);
        SendEmailContract.sendemTiming(orderId);
    }
}