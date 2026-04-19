global class SyncAccountSalesInfoSchedule implements Schedulable,Database.AllowsCallouts {
    public String csiId;
    global SyncAccountSalesInfoSchedule(String csiId) {
        this.csiId = csiId;
    }
    global void execute(SchedulableContext sc) {
        CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csiId,'I');
    }
}