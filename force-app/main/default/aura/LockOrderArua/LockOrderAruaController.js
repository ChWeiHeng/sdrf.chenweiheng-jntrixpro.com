({
	refreshview : function(component,event,helper) {
    	console.log("edit refreshview fire...");
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})