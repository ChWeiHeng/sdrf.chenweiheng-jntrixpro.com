/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-09-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-09-2025   Gerry   Initial Version
**/
@isTest
private class UploadFileLWCControllerTest {


    @IsTest
    static void testSaveAttachment() {
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentVersion contentVersion = new ContentVersion(
                                    Title = 'Penguins',
                                    PathOnClient = 'Penguins.jpg',
                                    VersionData = Blob.valueOf('Test Content'),
                                    IsMajorVersion = true
        );
        insert contentVersion;    

        ContentVersion c = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id];
        System.debug('c'+c.ContentDocumentId);
        ContentDistribution cdl = new ContentDistribution();
        cdl.ContentVersionId = contentVersion.Id;
        cdl.Name = 'PublicShare';
        cdl.PreferencesAllowViewInBrowser= true;
        cdl.PreferencesLinkLatestVersion=true;
        cdl.PreferencesNotifyOnVisit=false;
        cdl.PreferencesPasswordRequired=false;
        cdl.PreferencesAllowOriginalDownload= true;
        cdl.PreferencesNotifyRndtnComplete = false;
        insert cdl; 

        Test.startTest();
        UploadFileLWCController.OutPut result = UploadFileLWCController.saveAttachment(c.ContentDocumentId, c.Id);
        Test.stopTest();
    }
}