/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-08-2025   Gerry   Initial Version
**/
// attachmentManager.js
import { LightningElement, api, wire,track } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveAttachment from '@salesforce/apex/UploadFileLWCController.saveAttachment';
import FileName from '@salesforce/label/c.FileName';
import FileType from '@salesforce/label/c.FileType';
import ContentSize  from '@salesforce/label/c.ContentSize';
import CreatedDate  from '@salesforce/label/c.Created_Date';
import link  from '@salesforce/label/c.Link';
import deleteLabel from '@salesforce/label/c.deleteLabel';
import Success  from '@salesforce/label/c.Success';
import FileDeleted from '@salesforce/label/c.FileDeleted';
import UploadedSuccessfully from '@salesforce/label/c.UploadedSuccessfully';
import DeleteError  from '@salesforce/label/c.DeleteError';
import Upload  from '@salesforce/label/c.Upload';
import ErrorLoading from '@salesforce/label/c.ErrorLoading';

// 列定义包括删除按钮
const COLUMNS = [
    { label: FileName, fieldName: 'Name', type: 'text', 
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    { label: FileType, fieldName: 'File_Type__c', type: 'text' },
    { label: ContentSize, fieldName: 'Size_Kb__c', type: 'fileSize' },
    { label: CreatedDate, fieldName: 'CreatedDate', type: 'date' },
    { label: link, fieldName: 'Link__c', type: 'url' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: deleteLabel, name: 'delete', iconName: 'utility:delete' }
            ]
        }
    }
];


export default class AttachmentManager extends LightningElement {
    @track showDataTable = false;
    @track isLoading;
    @api recordId; // 父组件传入的记录ID
    @api attachments; // 存储附件数据
    @track attachmentsData;
    columns = COLUMNS;
    @track deleteFileId = [];
    acceptedFormats = ['.pdf','.png','.jpg','.jpeg','.doc','.docx','.xls','.xlsx','.txt'];
    isLoading = false;
    @track isPC;
    customLabel = {
        FileName,
        FileType,
        ContentSize,
        CreatedDate,
        link
    }
    // 使用wire获取附件列表
    // @wire(getAttachments, { recordId: '$recordId' })
    // wiredAttachments(result) {
    //     this.attachments = result;
    //     console.log('result',result);
    //     if (result.data) {
    //         // 为文件名生成预览URL
    //         result.data = result.data.map(file => ({
    //             ...file,
    //             link: `/sfc/servlet.shepherd/document/download/${file.Id}`,
    //             CreatedDate: file.CreatedDate.split('T')[0] // 简化日期格式
    //         }));
    //     }
    // }
    connectedCallback() {
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        this.attachmentsData = JSON.parse(JSON.stringify(this.attachments));
    }


    // 处理文件上传完成事件
    handleUploadFinished(event) {
        this.isLoading = true;
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles===>'+JSON.stringify(uploadedFiles.length));
        saveAttachment({
            contentDocumentId : uploadedFiles[0].documentId,
            contentVersionId : uploadedFiles[0].contentVersionId 
        }).then(result => {
            if (result.isSucess) {       
                this.isLoading = false; 
                this.showToast(Success, `${uploadedFiles.length}`+UploadedSuccessfully, Success); 
                console.log('uploadedFiles',JSON.stringify(uploadedFiles));
                var filedata = {
                    Link__c: result.fileUrl,
                    Name: uploadedFiles[0].name,
                    File_Type__c: result.fileType,
                    Size_Kb__c: result.sizeKb,
                    CreatedDate: new Date()
                }
                this.attachmentsData.push(filedata);
                console.log('this.attachmentsData',JSON.stringify(this.attachmentsData));
                this.showDataTable = !this.showDataTable;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
                this.isLoading = false; 
            }
        }).catch(error => {
            this.isLoading = false; 
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
        });
    }

    // 处理行操作（删除）
    async handleRowAction(event) {
        if (event.detail.action.name === 'delete') {
            const row = event.detail.row;
            this.isLoading = true;
            if(row.Id){
                this.deleteFileId.push(row.Id);
                this.attachmentsData = this.attachmentsData.filter(item => item.Id !== row.Id);
            }else{
                this.attachmentsData = this.attachmentsData.filter(item => item.link !== row.link);
            }
            this.isLoading = false;
        }
    }

    deleteData(event) {
        const indexToDelete = parseInt(event.currentTarget.dataset.index, 10);
        const itemToDelete = this.attachmentsData[indexToDelete];

        if (itemToDelete && itemToDelete.Id) {
            this.deleteFileId.push(itemToDelete.Id);
        }
        
        this.attachmentsData = this.attachmentsData.filter((item, index) => index !== indexToDelete);
    }

    // 处理Contracts_Detail__c记录的附件关联
    // handleContractDetailAttachment(event) {
    //     const { contractDetailId, contentDocumentId, contentVersionId } = event.detail;
        
    //     // 调用Apex方法处理附件关联
    //     handleFileUpload({
    //         contractDetailId: contractDetailId,
    //         contentDocumentId: contentDocumentId,
    //         contentVersionId: contentVersionId
    //     }).then(result => {
    //         if (result.isSucess) {
    //             this.showToast('Success', '附件关联成功', 'success');
    //             // 刷新附件列表
    //             this.refreshAttachments();
    //         } else {
    //             this.showToast('Error', result.errorMsg, 'error');
    //         }
    //     }).catch(error => {
    //         this.showToast('Error', '附件关联失败: ' + error.message, 'error');
    //     });
    // }
    
    // 刷新附件列表
    // refreshAttachments() {
    //     if (this.recordId) {
    //         getAttachments({ contractDetailId: this.recordId })
    //             .then(result => {
    //                 this.attachmentsData = result;
    //             })
    //             .catch(error => {
    //                 console.error('获取附件列表失败:', error);
    //             });
    //     }
    // }

    // 刷新附件列表
    // async refreshAttachmentList() {
    //     await refreshApex(this.attachments);
    // }

    // 显示Toast消息
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    @api
    uploadData() {
        let sendObject = {"fileData":this.attachmentsData,"deleteData":this.deleteFileId};
        return sendObject;
    }
}