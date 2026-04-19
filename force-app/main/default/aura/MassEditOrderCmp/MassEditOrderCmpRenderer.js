({
    // Your renderer method overrides go here
    unrender: function (component,helper) {
        this.superUnrender();
        component.set("v.isLoad",false);
    }
})