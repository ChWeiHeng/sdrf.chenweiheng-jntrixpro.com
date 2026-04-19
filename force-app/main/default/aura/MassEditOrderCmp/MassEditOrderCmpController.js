({
    doInit : function(component, event, helper) {
        component.set("v.isLoad",true);   
    },

	handleDestroy : function(component, event, helper) {
		component.set("v.isLoad",false); 
	}
})