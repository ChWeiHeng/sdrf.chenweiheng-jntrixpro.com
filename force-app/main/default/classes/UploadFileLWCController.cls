/**
 * @description       : 上传文件控制类
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-27-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-08-2025   Gerry   Initial Version
**/
public without sharing class UploadFileLWCController {
    // 获取与记录关联的所有文件
    // @AuraEnabled(cacheable=true)
    // public static List<ContentDocument> getAttachments(String recordId) {
    //     System.debug('recordId:'+recordId);
    //     List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
    //     Set<String> cdIdSet = new Set<String>();
    //     for (ContentDocumentLink cdl : cdlList) {
    //         cdIdSet.add(cdl.ContentDocumentId);
    //     }
    //     System.debug('cdIdSet:'+cdIdSet);

    //     List<ContentDocument> cdList = [
    //         SELECT Id, Title, FileType, ContentSize, CreatedDate 
    //         FROM ContentDocument 
    //         WHERE Id IN :cdIdSet
    //         ORDER BY CreatedDate DESC
    //     ];
    //     System.debug('cdList:'+cdList);
    //     return cdList;
    // }

    @AuraEnabled
    public static OutPut saveAttachment(String contentDocumentId,String contentVersionId){
        SavePoint sp = Database.setSavepoint();
        try{
            OutPut out = new OutPut();
            out.isSucess = true;
            ContentDocument cd = [SELECT Id,ContentSize,FileType,Title FROM ContentDocument WHERE Id = :contentDocumentId];
            out.fileType = cd.FileType;
            out.sizeKb = String.valueOf(cd.ContentSize);
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = contentVersionId;
            cdl.Name = 'PublicShare';
            cdl.PreferencesAllowViewInBrowser= true;
            cdl.PreferencesLinkLatestVersion=true;
            cdl.PreferencesNotifyOnVisit=false;
            cdl.PreferencesPasswordRequired=false;
            cdl.PreferencesAllowOriginalDownload= true;
            cdl.PreferencesNotifyRndtnComplete = false;
            insert cdl;
            // out.fileUrl = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdl.Id LIMIT 1].DistributionPublicUrl; 
            out.fileUrl = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdl.Id LIMIT 1].ContentDownloadUrl;
            return out;
        }catch(Exception e){
            Database.rollback(sp);
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = e.getMessage()+e.getLineNumber();
            return out;   
        }
    }
    
    // 删除指定文件
    // @AuraEnabled
    // public static Output deleteAttachment(String documentId) {
    //     Output out = new Output();
    //     out.isSucess = true;
    //     delete [SELECT Id FROM ContentDocument WHERE Id = :documentId];
    //     return out;
    // }

    public class Output{
        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public String fileUrl {get;set;}

        @AuraEnabled
        public String fileType {get;set;}

        @AuraEnabled
        public String sizeKb {get;set;}
    }
}