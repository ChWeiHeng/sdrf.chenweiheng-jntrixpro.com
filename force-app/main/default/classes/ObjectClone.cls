/**
 * 测试类：CloneEvaluateControllerTest、CloneAccountTermInfoControllerTest
 */
public without sharing class ObjectClone {
    private static Map<Id, Id> oldIDToNewID = new Map<Id, Id>();
    private static String errorThrown;
    @TestVisible private static final String TOMANYTYPES = 'Multiple Object Types were detected in the initial records';
    @TestVisible private static final String NORECORDS = 'No Records to clone';


    public class Object_Clone_Exception extends Exception {

    }

    public class NeedCloneFieldValue {
        public String FieldUpdate1;//预留字段1
        public String FieldUpdate2;//预留字段2
    }

    public class ResponseParam {
        @AuraEnabled public Boolean code;
        @AuraEnabled public String message;
        @AuraEnabled public String returnUrl;
        @AuraEnabled public Map<Id, Id> oldIdToNewId;
    }

    /*****************************************************************************
    *   List of Objects to not clone
    ******************************************************************************/

    @TestVisible private static Set<String> excludedObjects {
        get {
            if (excludedObjects == null) {
                return new Set<String>();
            } else {
                return excludedObjects;
            }
        }
    }


    @AuraEnabled
    public static ResponseParam cloneObjectSingle(Id oId, Boolean withChildren, String needCloneFieldJson, String needChildObject, String needRemoveField) {
        NeedCloneFieldValue needCloneFieldValue;
        List<String> needChildObjectList = new List<String>();
        List<String> needRemoveFieldList = new List<String>();
        if (String.isNotBlank(needCloneFieldJson)) {
            //因为JSON转换的原因 需要去掉符号 []
            if (needCloneFieldJson.startsWith('[') && needCloneFieldJson.endsWith(']')) {
                needCloneFieldJson = needCloneFieldJson.substring(1, needCloneFieldJson.length() - 1);
            }
            System.debug('needCloneFieldJson===' + needCloneFieldJson);
            needCloneFieldValue = (NeedCloneFieldValue) JSON.deserialize(needCloneFieldJson, NeedCloneFieldValue.class);
        }
        if (String.isNotBlank(needChildObject)) {
            needChildObjectList = needChildObject.split(';');
        }
        if (String.isNotBlank(needRemoveField)) {
            needRemoveFieldList = needRemoveField.split(';');
        }

        ResponseParam responseParam = cloneObjectWithExclude(new Set<Id>{
                oId
        }, withChildren, null, needCloneFieldValue, needChildObjectList, needRemoveFieldList);
        responseParam.returnUrl = new PageReference('/' + oldIDToNewID.get(oId)).getUrl();
        return responseParam;

    }

    /*****************************************************************************
    *   Execute Clone Method - SET OF IDs
    *       NOT specifying Child Objects to Exclude if cloning children
    ******************************************************************************/

    public static ResponseParam cloneObjectSet(Set<Id> oId, Boolean withChildren) {
        return cloneObjectWithExclude(oId, withChildren, null, null, null, null);
    }


    /*****************************************************************************
    *   Execute Clone Method - SET OF IDs
    *       Specifying Child Objects to Exclude if cloning children
    ******************************************************************************/

    public static ResponseParam cloneObjectWithExclude(Set<Id> oIds, Boolean withChildren, Set<String> objectsToExclude,
            NeedCloneFieldValue needCloneFieldValue, List<String> needChildObjectList, List<String> needRemoveFieldList) {
        ResponseParam responseParam = new ResponseParam();
        try {
            responseParam.code = true;
            responseParam.message = '';

            //Reset Error
            errorThrown = null;

            //Remove nulls in case they were added to a set from above methods
            oIds.remove(null);

            //Ensure that we at least have some records
            if (oIds == null || oIds.isEmpty()) {
                throw new Object_Clone_Exception(NORECORDS);
            }

            //Populate the Excluded Object Type with Force exclude as well as User Specified
//            setexcludedObjects(objectsToExclude);

            //Collection of Types to clone
            Map<Schema.SObjectType, Set<Id>> types = new Map<Schema.SObjectType, Set<Id>>();

            //Build up the collection of types to Records
            for (Id oId : oIds) {
                Set<Id> existingIDsInMap = types.get(oId.getSobjectType());
                if (existingIDsInMap == null) existingIDsInMap = new Set<Id>();
                existingIDsInMap.add(oId);
                types.put(oId.getSobjectType(), existingIDsInMap);
            }

            //For each type clone the records
            for (Schema.SObjectType objType : types.keySet()) {
                //Start the process cloning the parent with the desired options
                cloneObjects(queryForRecords(types.get(objType), null, needRemoveFieldList),
                        (withChildren == null ? false : withChildren), true,
                        needCloneFieldValue, needChildObjectList, needRemoveFieldList);
            }
            responseParam.oldIdToNewId = oldIDToNewID;
            return responseParam;

        } catch (Exception e) {
            //We had an error so return nothing
            System.debug(LoggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            errorThrown = e.getMessage();
            responseParam.code = false;
            responseParam.message = e.getMessage();
            return responseParam;
        }
    }

    /*****************************************************************************
    *   MAIN CLONE ENTRY METHOD
    *       Executed from one of the cloneObject Methods
    ******************************************************************************/

    private static Map<Schema.SObjectType, SObject[]> cloneObjects(SObject[] oObjs, Boolean withChildren, Boolean doInsert,
            NeedCloneFieldValue needCloneFieldValue, List<String> needChildObjectList, List<String> needRemoveFieldList) {

        //new Records to Return
        Map<Schema.SObjectType, SObject[]> results = new Map<Schema.SObjectType, SObject[]>();

        //Collection of Related Objects and their Parent Fields
        Map<Schema.SObjectType, Schema.SObjectField[]> childRelationships;

        Map<Id, SObject> oldRecToNewRec = new Map<Id, SObject>();

        //For each record for this sObjectType
        for (SObject oldObj : oObjs) { //queryForRecords(oIds, flds)) {
            Schema.SObjectType objType = oldObj.getSObjectType();
            System.debug('oldObj'+oldObj);
            if (objType.getDescribe().getName() == 'Customer_Sales_Info__c') {//只复制阿根廷的销售视图
                // System.debug('进入逻辑'+oldObj.get('Sales_Org__c'));
                if (oldObj.get('Delivering_Plant__c') != '5130' && oldObj.get('Delivering_Plant__c') != '5070') {
                    continue;
                }
            }
            

            //Create a new Object
            SObject newObj = oldObj.clone(false, true);

            

            if (objType.getDescribe().getName() == 'Account') {
                //User u = [SELECT Id,Country__c FROM User WHERE Id =:System.UserInfo.getUserId()];
                Account acc=[SELECT Id,MDG_Customer_Code__c,Tax_Number__c,Name,Tax_Numbe_No_Bar__c FROM Account WHERE Id=:oldObj.Id];
                List<Account> accList=[SELECT Id,Tax_Number__c FROM Account WHERE Original_Customer__c=:oldObj.Id order by Tax_Number__c desc];
                Integer CurrentNumber;
                if(accList != null && accList.size()>0)
                {
                    CurrentNumber=Integer.valueOf(accList[0].Tax_Number__c.split('_')[1]);
                    System.debug('CurrentNumber=>'+CurrentNumber);
                    newObj.put('Tax_Number__c',acc.Tax_Number__c+'_'+String.valueOf(CurrentNumber+1));
                    //if(u.Country__c == 'AR') {//阿根廷特殊逻辑，名称前面加'Retira'
                        //newObj.put('Name','Retira '+acc.Name+'_'+String.valueOf(CurrentNumber+1));
                    //}else{
                        newObj.put('Name',acc.Name+'_'+String.valueOf(CurrentNumber+1));
                    //}
                    newObj.put('Tax_Numbe_No_Bar__c',acc.Tax_Numbe_No_Bar__c+String.valueOf(CurrentNumber+1));
                }else{
                    newObj.put('Tax_Number__c',acc.Tax_Number__c+'_'+'0');
                    //if(u.Country__c == 'AR') {//阿根廷特殊逻辑，名称前面加'Retira'
                        //newObj.put('Name','Retira '+acc.Name+'_'+'0');
                    //}else{
                        newObj.put('Name',acc.Name+'_'+'0');
                    //}
                    newObj.put('Tax_Numbe_No_Bar__c',acc.Tax_Numbe_No_Bar__c+'0');
                    
                }
                newObj.put('MDG_Customer_Code__c',null);	
                newObj.put('Customer_Short_Name__c',acc.MDG_Customer_Code__c);
                newObj.put('Sync_Status__c','Unsynchronized');
                newObj.put('Customer_Approval_Status__c','Draft');
                newObj.put('Sync_Failure_Reasons__c',null);
                
                newObj.put('Original_Customer__c', oldObj.Id);
                newObj.put('recordtypeId', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipTo_Account').getRecordTypeId());
                newObj.put('OwnerId', System.UserInfo.getUserId());
            }
            if (objType.getDescribe().getName() == 'Customer_Sales_Info__c') {
                //newObj.put('Customer_Record_Type__c','ShipTo_Account');	
                newObj.put('isSync__c',false);
            }


            //Populate the map with the Old Id as a key and the new Record as the value
            oldRecToNewRec.put(oldObj.Id, newObj);

            if (doInsert) {
                System.debug('oldRecToNewRec==='+oldRecToNewRec);
                insert oldRecToNewRec.values();
//                List<Database.SaveResult> saveResults = Database.insert(oldRecToNewRec.values());
                System.debug('插入成功后的Id:' + newObj.get('Id'));
                //Store the old to new IDs
                for (Id i : oldRecToNewRec.keySet()) {
                    oldIDToNewID.put(i, oldRecToNewRec.get(i).Id);
                }

                if (withChildren) {
                    //Get the related Objects
                    childRelationships = getRelatedObjects(objType, needChildObjectList);

                    //Fire off the clone children which will call this method in a cyclic fashion
                    //until all children and their children are cloned
                    cloneChildren(oldRecToNewRec.keySet(), childRelationships, needRemoveFieldList);
                }
            }

            //Add the record to the final results by Object type
            results.put(objType, oldRecToNewRec.values());


        }

        return results;
    }

    /******************************************************************************
    *
    *   Get children of object and clone them as well
    *
    *******************************************************************************/

    private static void cloneChildren(Set<Id> pIds, Map<Schema.SObjectType, Schema.SObjectField[]> pFields, List<String> needRemoveFieldList) {

        /*
            Currently no checks on limits
            This method will do 1 query and 1 dml for each group of child objects
            If those objects have children it will continue to add to the counts
         */

        //Each child relationship field has its own type so we will need to go through each type and attempt to clone the records
        for (Schema.SObjectType cObjType : pFields.keySet()) {
            Schema.DescribeSObjectResult objTypeDescribe = cObjType.getDescribe();

            if (objTypeDescribe.isCreateable() == false ||
                    objTypeDescribe.getName().endsWithIgnoreCase('share') ||
                    excludedObjects.contains(objTypeDescribe.getName())) {
                continue;
            }

            String[] pFieldNames = new String[]{
            };

            //Get a List of Fields related to Parent Object
            for (Schema.SObjectField pFld : pFields.get(cObjType)) {
                pFieldNames.add(pFld.getDescribe().getName());
            }


            //build the where clause - Just in case there are multiple fields related to the same SObjectType
            String pFieldWhere = '';
            for (String pFld : pFieldNames) {
                if (pFieldWhere != '') pFieldWhere += ' OR ';
                pFieldWhere += pFld + ' IN :rIds';
            }

            //Query for values - using rIds in the Where clause as the method uses that variable name for pIds here
            Map<Id, SObject> childRecords = new Map<Id, SObject>(queryForRecords(cObjType, pIds, pFieldWhere, needRemoveFieldList));

            if (!childRecords.isEmpty()) {
                Map<Schema.SObjectType, SObject[]> newChildren = cloneObjects(childRecords.values(), true, false, null, null, null);

                for (SObject newChild : newChildren.get(cObjType)) {
                    for (String pField : pFieldNames) {
                        System.debug(pField);
                        Object oPid = newChild.get(pField);
                        System.debug(oPid);
                        if (oPid != null && oldIDToNewID.get((Id) oPid) != null) {
                            newChild.put(pField, oldIDToNewID.get((Id) oPid));
                        }
                    }
                }

                insert newChildren.get(cObjType);
            }
        }
    }


    /******************************************************************************
    *
    *   Query for Records to Clone
    *       Getting the ObjectType from the Id Set
    *       Ensuring that there is only one ObjectType
    *
    *******************************************************************************/

    @TestVisible private static SObject[] queryForRecords(Set<Id> rIds, String customWhereClause, List<String> needRemoveFieldList) {
        if (rIds == null || rIds.isEmpty()) {
            return new SObject[]{
            };
        }

        Schema.SObjectType oType;

        //Just a double check to ensure that once we get here there is only 1 object type to query
        for (Id rId : rIds) {
            if (oType == null) {
                oType = rId.getSobjectType();
            } else {
                if (rId.getSobjectType() != oType) {
                    throw new Object_Clone_Exception(TOMANYTYPES);
                }
            }
        }

        return queryForRecords(oType, rIds, customWhereClause, needRemoveFieldList);
    }

    /******************************************************************************
    *
    *   Query for Records to Clone - Main Method
    *       Requires Single Known ObjectType
    *
    *******************************************************************************/

    private static SObject[] queryForRecords(Schema.SObjectType oType, Set<Id> rIds, String customWhereClause, List<String> needRemoveFieldList) {
//        System.debug(logginglevel.error, oType);


        if (rIds == null || rIds.isEmpty()) {
            return new SObject[]{
            };
        }

        String[] fldsToClone = getCreateableFields(oType, needRemoveFieldList);
        System.debug(LoggingLevel.ERROR, fldsToClone);

        String query = 'Select Id, ';

        query += String.join(fldsToClone, ',');


        query += ' From ' + oType; // + ' Where Id IN :rIds';

        if (customWhereClause != null) {
            query += ' Where ' + customWhereClause;
        } else {
            query += ' Where Id IN :rIds';
        }
        System.debug(LoggingLevel.ERROR, query);
        return Database.query(query);

    }


    /******************************************************************************
    *
    *   Gets Creatable Fields
    *
    *******************************************************************************/
    public static String[] getCreateableFields(Schema.SObjectType obj, List<String> needRemoveFieldList) {
        String[] results = new String[]{
        };

        System.debug('needRemoveFieldList===' + needRemoveFieldList);
        
        for (Schema.SObjectField fld : obj.getDescribe().fields.getMap().values()) {
            
            Schema.DescribeFieldResult dfr = fld.getDescribe();
            System.debug('dfr.getName()'+dfr.getName());
            System.debug('dfr.isUnique()'+dfr.isUnique());
            System.debug('dfr.isCreateable'+dfr.isCreateable());
            System.debug('dfr.isUpdateable()'+dfr.isUpdateable());
            if (!dfr.isUnique() && (dfr.isCreateable() || dfr.isUpdateable())) {
                
                if (needRemoveFieldList == null || needRemoveFieldList.size() == 0) {
                    results.add(dfr.getName());
                } else if (!needRemoveFieldList.contains(dfr.getName())) {
                    results.add(dfr.getName());
                }
            }
        }
        System.debug(results);
        return results;

    }

    /******************************************************************************
    *
    *   Gets Relationship Fields
    *       - Returning the SobjectType and the Relationship Field on that object
    *
    *******************************************************************************/


    public static Map<Schema.SObjectType, Schema.SObjectField[]> getRelatedObjects(Schema.SObjectType obj, List<String> needChildObjectList) {

        Map<Schema.SObjectType, Schema.SObjectField[]> results = new Map<Schema.SObjectType, Schema.SObjectField[]>();

        System.debug('needChildObjectList===' + needChildObjectList);

        for (ChildRelationship r : obj.getDescribe().getChildRelationships()) {
            if (needChildObjectList != null && needChildObjectList.size() > 0
                    && needChildObjectList.contains(r.getChildSObject() + '')) {
                Schema.SObjectField[] tmp = results.get(r.getChildSObject());
                if (tmp == null) {
                    tmp = new Schema.SObjectField[]{
                    };
                }
                tmp.add(r.getField());
                System.debug(r.getField());
                results.put(r.getChildSObject(), tmp);
            }
        }

        return results;

    }
}