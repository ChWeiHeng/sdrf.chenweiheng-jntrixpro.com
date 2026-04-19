import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { readAsBinaryString, get_header_row, saveAs, s2ab } from './readFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs';
import getInitData from '@salesforce/apex/BatchImportMonthBudgetController.getInitData';
import saveData from '@salesforce/apex/BatchImportMonthBudgetController.saveData';
import { isEmpty, isGtZero, calculateMargin, getDitigal,isGtTwoDigitals } from './batchImportUnit';
import { LightningMessageService } from 'lightning/messageService';
import Sales_Forcast_Imp_Tem from '@salesforce/label/c.Sales_Forcast_Imp_Tem';
import Sales_Forcast_Imp_Save from '@salesforce/label/c.Sales_Forcast_Imp_Save';
import Sales_Forcast_Imp_Del from '@salesforce/label/c.Sales_Forcast_Imp_Del';
import Sales_Forcast_Imp_Result from '@salesforce/label/c.Sales_Forcast_Imp_Result';
import Sales_Forcast_Imp_Success from '@salesforce/label/c.Sales_Forcast_Imp_Success';
import Sales_Forcast_Imp_Failures from '@salesforce/label/c.Sales_Forcast_Imp_Failures';
import Sales_Forcast_Imp_Number from '@salesforce/label/c.Sales_Forcast_Imp_Number';
import Sales_Forcast_Imp_List from '@salesforce/label/c.Sales_Forcast_Imp_List';
import Sales_Forcast_Imp_Enclosure from '@salesforce/label/c.Sales_Forcast_Imp_Enclosure';
import Sales_Forcast_Imp_Excel_Rows from '@salesforce/label/c.Sales_Forcast_Imp_Excel_Rows';
import Sales_Forcast_Imp_Reason_Failure from '@salesforce/label/c.Sales_Forcast_Imp_Reason_Failure';
import Sales_Forcast_Imp_File from '@salesforce/label/c.Sales_Forcast_Imp_File';
import Sales_Forcast_Imp_SalesOrg from '@salesforce/label/c.Sales_Forcast_Imp_SalesOrg';
import Import_Quote_Detail_Header from '@salesforce/label/c.Import_Quote_Detail_Header';
import BatchImportMonthlyBudgetHeader from '@salesforce/label/c.BatchImportMonthlyBudgetHeader';
import BatchImportError1 from '@salesforce/label/c.BatchImportError1';
import BatchImportError2 from '@salesforce/label/c.BatchImportError2';
import BatchImportError3 from '@salesforce/label/c.BatchImportError3';
import BatchImportError4 from '@salesforce/label/c.BatchImportError4';

const varifiTableColumns = [
	{ label: Sales_Forcast_Imp_Excel_Rows, fieldName: 'execlNum', type: 'text', hideDefaultActions: true, wrapText: true },
	{ label: Sales_Forcast_Imp_Reason_Failure, fieldName: 'FailedReason', type: 'text', hideDefaultActions: true, wrapText: true}
];

export default class BatchImportMonthBudgetLWC extends LightningElement {
	@api recordId;

	label = {
        Sales_Forcast_Imp_Tem,
        Sales_Forcast_Imp_Save,
        Sales_Forcast_Imp_Del,
        Sales_Forcast_Imp_Result,
        Sales_Forcast_Imp_Success,
        Sales_Forcast_Imp_Failures,
        Sales_Forcast_Imp_Number,
        Sales_Forcast_Imp_List,
        Sales_Forcast_Imp_Enclosure,
        Import_Quote_Detail_Header,
		BatchImportMonthlyBudgetHeader,
		BatchImportError1,
		BatchImportError2,
		BatchImportError3,
		BatchImportError4
    };

	@track isShowSpinner;
	@track errorMsgArray = [];
	@track hasError;

	@track fileName;
	@track file;
	@track isSuccessInsert;

	@track salesDownloadLink;        //模板下载路径
	@track verifiSuccessString;      //
	@track verifiFailedString;
	@track importSuccessString;
	
	@track importSuccessString;
	@track varifiFailedDetails;

	@track mustFillValueFields;      //必填字段
	@track excelHeaderMap = new Map();
	@track excelHeaderKeyToLabelMap = new Map();

	@track varifiFailed;

	@track salesType;

	@track userFlag = true;


	varifiFailedTableColumns = varifiTableColumns;
	validationResult = {
		ifSuccess: false,
		errorItemCount: 0,
		successItemCount: 0
	};

	constructor() {
		super();
		loadScript(this, SHEETJS_ZIP + '/xlsx.full.min.js')
	}

	//初始化方法
	connectedCallback(event){
		console.log('this.recordId:',this.recordId);
		this.isShowSpinner = true;
		this.verifiSuccessString = Sales_Forcast_Imp_Success + '0';
		this.verifiFailedString = Sales_Forcast_Imp_Failures + '0';
		this.importSuccessString = Sales_Forcast_Imp_Number + '0';

		getInitData({id: this.recordId})
		.then(result => {
			console.log('resultInit==>'+JSON.stringify(result));
			this.salesDownloadLink = result.salesDownloadLink;                  //模板链接
			this.excelHeaderMap = result.excelHeaderMap;                        //label-->Api
			this.excelHeaderKeyToLabelMap = result.excelHeaderKeyToLabelMap;    //Api--->label
			this.mustFillValueFields = result.mustFillValueFields;              //必填字段
			this.salesType = result.salesType;
			if(result.userFlag == '1'){
				this.hasError = true;
				this.errorMsgArray.push(Sales_Forcast_Imp_SalesOrg);
				this.userFlag = false;
			}
			
			this.isShowSpinner = false;
		})
		.catch(error => {
			this.isShowSpinner = false;
			this.hasError = true;
			this.errorMsgArray.push(error.body.message);
		});
	}

	//下载
	handleDownload(event) {
        event.preventDefault(); // 阻止默认的按钮行为
        const link = this.template.querySelector('a');
        link.click(); // 触发a标签的点击事件，开始下载
    }

	//上传文件
	handleFilesChange(event) {
		this.file = event.target.files[0];
		this.fileName = event.target.files[0].name;
		this.hasError = false;
		this.errorMsgArray = [];
		this.isSuccessInsert = false;
		this.verifiSuccessString = Sales_Forcast_Imp_Success + '0';
		this.verifiFailedString = Sales_Forcast_Imp_Failures + '0';
		this.importSuccessString = Sales_Forcast_Imp_Number + '0';
		this.varifiFailedDetails = null;
		console.log('this.file==>'+this.file);
		console.log('this.fileName==>'+this.fileName);
	}

	//导入记录
	importFileChange(event) {
		this.hasError = false;
		this.errorMsgArray = [];
		this.varifiFailedDetails = null;

		if(this.file == null) {
			this.hasError = true;
			if(this.errorMsgArray.indexOf(Sales_Forcast_Imp_File) < 0){
				this.errorMsgArray.push(Sales_Forcast_Imp_File);
			}
			return ;
		}
		this.varifiFailed = null;
		var excelDataJson;
		var importDataContent;
		Promise.resolve(this.file)
			.then(files => {
				return readAsBinaryString(files);
			})
			.then(blob => {
				this.isShowSpinner = true;
				try {
					let workbook = window.XLSX.read(blob, {type: 'binary', cellDates: true, dateNF:'yyyy-mm-dd'});
					
					var labelHeaders = get_header_row(workbook.Sheets[workbook.SheetNames[0]]);        
					console.log("105105105    :"+labelHeaders);
					var tempLabelHeaders = labelHeaders; 
					console.log('tempLabelHeaders==>'+tempLabelHeaders); 

					for(let curHeader in tempLabelHeaders) {
						labelHeaders[labelHeaders.indexOf(tempLabelHeaders[curHeader])] = this.excelHeaderMap[tempLabelHeaders[curHeader]];
					}
					
					excelDataJson = JSON.stringify(XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]],
						{header : labelHeaders}));
					console.log('excelDataJson===>'+excelDataJson);

					var importData = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]],
						{header : labelHeaders});
					console.log('importData===>'+JSON.stringify(importData));
					// Remove the  two rows (Head Row, Description Row)
					importData.slice(3);
					console.log('importData22===>'+JSON.stringify(importData));
					importDataContent = importData.slice(3);
					console.log("importDataContent", JSON.stringify(importDataContent)+'      size()  '+importDataContent.length);
					//前端校验
					if(importDataContent.length == 0){
						this.isShowSpinner = false;
						this.hasError = true;
						//this.errorMsgArray.push("Please add at least one record!");
						this.errorMsgArray.push(this.label.BatchImportError1);
						return;
					}

				} catch (error) {
					this.isShowSpinner = false;
					this.hasError = true;
					//this.errorMsgArray.push('Error parsing Execl file, please try again! If multiple failures occur, please contact the administrator!');
					this.errorMsgArray.push(this.label.BatchImportError2);
					return ;
				}
				console.log("124124124lsf    :"+excelDataJson);
			   
				//调用后台方法 保存数据到系统
				saveData({TargetJson: JSON.stringify(importDataContent), excelHeaderKeyToLabelMap: this.excelHeaderKeyToLabelMap, mustFillValueFields: this.mustFillValueFields,recordId: this.recordId})
				.then((result) => {
					if(result.lResult == 'tooManyRecord') {
						this.isShowSpinner = false;
						this.hasError = true;
						//this.errorMsgArray.push('Import no more than' + result.excelMaxRow + 'pieces of data at once！');
						this.errorMsgArray.push(this.label.BatchImportError3 + result.excelMaxRow +this.label.BatchImportError4);
						this.file = null;
						this.fileName = null;
						return ;
					}

					if(result.lResult == 'Error' || result.lResult == 'NoPB' || result.lResult == 'NoPBE') {
						console.log('143143143lsf');
						this.isShowSpinner = false;
						this.hasError = true;
						this.errorMsgArray.push(result.errMsg);
						this.file = null;
						this.fileName = null;
						return ;
					}

					this.file = null;
					this.fileName = null;

					if(result.failedValiAmount > 0) {
						console.log('存在验证失败的数据');
						this.varifiFailedDetails = result.valiriFailedSalesTarget;
						console.log('失败数据==》'+JSON.stringify(this.varifiFailedDetails));
					}

					this.verifiSuccessString = Sales_Forcast_Imp_Success + result.successValiAmount;
					this.verifiFailedString = Sales_Forcast_Imp_Failures + result.failedValiAmount;
					if(result.failedValiAmount > 0) {
						console.log('163163163lsf');
						this.importSuccessString = Sales_Forcast_Imp_Number + '0';
					} else {
						//eval("$A.get('e.force:refreshView').fire();");
						console.log('166166166lsf');
						this.importSuccessString = Sales_Forcast_Imp_Number + result.successValiAmount;
						this.isSuccessInsert = true;
						this.dispatchEvent(new ShowToastEvent({
		                    title: 'Success',
		                    message: 'Success',
		                    variant: 'Success',
		                }));
		                //this.dispatchEvent(new CustomEvent('refreshview'));
		                //this.dispatchEvent(new CustomEvent('closemodal'));
						window.location.reload();
					}
					this.isShowSpinner = false;
				})
				.catch((error) => {
					this.isShowSpinner = false;
					console.log('selectedResult error: ' + error + '    '+JSON.stringify(error));
				});
				
			})
			
	}

	//删除上传的文件
	deleteFileChange(event){
		if(this.file == null){
			this.hasError = true;
			if(this.errorMsgArray.indexOf('请先上传文件！') < 0){
				this.errorMsgArray.push('请先上传文件！');
			}
			return ;
		}
		this.file = null;
		this.fileName = null;
	}
}