/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 06-05-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-05-2025   Gerry   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import getApprovalHistory from '@salesforce/apex/ApprovalHistoryController.getApprovalHistory';

export default class ApprovalHistory extends LightningElement {
    @api recordId; // 从记录页面传入的ID
    approvalHistories;
    error;

    // 状态图标映射
    statusIcons = {
        'Approved': 'action:approval',
        'Rejected': 'action:close',
        'Pending': 'action:pending',
        'Started': 'action:user'
    };

    // 状态颜色映射
    statusClasses = {
        'Approved': 'slds-icon-custom-custom20 slds-text-color_success',
        'Rejected': 'slds-icon-custom-custom27 slds-text-color_error',
        'Pending': 'slds-icon-custom-custom53 slds-text-color_warning',
        'Started': 'slds-icon-standard-approval slds-text-color_default'
    };

    connectedCallback() {
        getApprovalHistory({
            recordId : this.recordId
        }).then(result => {
            this.approvalHistories = [];
            console.log('进入逻辑',JSON.stringify(result));
            for (let index = 0; index < result.length; index++) {
                var his = {};
                his = JSON.parse(JSON.stringify(result[index]));
                his.indexNumber = index+'';
                his.icon = this.getStatusIcon(his.status);
                his.statusClass = this.getStatusClass(his.status);
                this.approvalHistories.push(his);
            }
            console.log('this.approvalHistories',JSON.stringify(this.approvalHistories));
        }).catch(error => {
            this.error = 'Unable to load the approval history: ' + JSON.stringify(error);
        });
                
    }

    getStatusIcon(status) {
        return this.statusIcons[status] || 'standard:approval';
    }

    getStatusClass(status) {
        return this.statusClasses[status] || 'slds-text-color_default';
    }
}