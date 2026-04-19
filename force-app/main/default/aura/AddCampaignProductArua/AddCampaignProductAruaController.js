/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-15-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-15-2026   Gerry   Initial Version
**/
({
	refreshview : function(component,event,helper) {
    	console.log("edit refreshview fire...");
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})