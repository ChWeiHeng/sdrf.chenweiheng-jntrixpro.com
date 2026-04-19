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
public class TestHttpMock {
    public class CustomerInfoSyncToSap implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"S","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"usmd_crequest":"4706","partner":"0001004420","nameorg1":"Customer test2","msgty":"S","msgtx":"业务伙伴处理成功","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[]}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class CustomerInfoSyncToSapErr implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"E","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"usmd_crequest":"4706","partner":"0001004420","nameorg1":"Customer test2","msgty":"S","msgtx":"业务伙伴处理成功","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[]}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class GetCustomerlimitFROMSAPW implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"W","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"usmd_crequest":"4706","partner":"0001004420","nameorg1":"Customer test2","msgty":"S","msgtx":"业务伙伴处理成功","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[]}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class ProductSalesInfoSyncToSAP implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"S","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"KUNNR":"1111","VERPR":"10","CLABS":"10","MATNR":"12341234","LGORT":"111","CHARG":"111","WERKS":"5130","ATWRT":"111","KTOPL":"AED","MEINS":"L","CSPEM":"10","CINSM":"10","CRETM":"10","LWEDT":"111","KULAB":"10"}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class ProductSalesInfoSyncToSAPE implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"E","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"KUNNR":"1111","VERPR":"10","CLABS":"10","MATNR":"12341234","LGORT":"111","CHARG":"111","WERKS":"5130","ATWRT":"111","KTOPL":"AED","MEINS":"L","CSPEM":"10","CINSM":"10","CRETM":"10","LWEDT":"111","KULAB":"10"}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class ProductSalesInfoSyncToSAPW implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"W","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"KUNNR":"1111","VERPR":"10","CLABS":"10","MATNR":"12341234","LGORT":"111","CHARG":"111","WERKS":"5130","ATWRT":"111","KTOPL":"AED","MEINS":"L","CSPEM":"10","CINSM":"10","CRETM":"10","LWEDT":"111","KULAB":"10"}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    
    // 新增Mock类：测试returnstatus为'W'且resultinfo为空的情况
    public class ProductSalesInfoSyncToSAPWEmpty implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"W","returncode":"W001","returnmsg":"No data found","attr1":"","attr2":"","attr3":""},"resultinfo":[]}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    
    // 新增Mock类：测试returnstatus不为'W'且resultinfo为空的情况
    public class ProductSalesInfoSyncToSAPOtherEmpty implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"E","returncode":"E001","returnmsg":"Error occurred","attr1":"","attr2":"","attr3":""},"resultinfo":[]}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class OrderSyncToSAP500 implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"W","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"KUNNR":"1111","VERPR":"10","CLABS":"10","MATNR":"12341234","LGORT":"111","CHARG":"111","WERKS":"5130","ATWRT":"111","KTOPL":"AED","MEINS":"L","CSPEM":"10","CINSM":"10","CRETM":"10","LWEDT":"111","KULAB":"10"}]}'); 
            res.setStatusCode(500);
            return res;
        }
    }

    public class OrderSyncToSAPNull implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{},"resultinfo":[]}'); 
            res.setStatusCode(500);
            return res;
        }
    }
    public class OrderSyncToSAPSucesssNull implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"resultinfo":[]}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    
    // 新增Mock类：模拟订单同步成功的响应
    public class OrderSyncToSAPSuccess implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"S","returncode":"S001","returnmsg":"订单同步成功","attr1":"0000046659","attr2":"","attr3":""},"resultinfo":[{"bstkd":"O-2411-003294|1111","vbeln":"0000046659","vbeln2":"","kunnr":"0001003223","vkorg":"3010","vtweg":"10","spart":"10","msgty":"S","msgtx":"订单0000046659创建成功","iex01":"","iex02":"","iex03":"","iex04":"","iex05":"","iex06":"","items":[{"status":"A","posnr":"10","taxamount":"","netwr":"11.00","ieps":"","optax":""}]}]}'); 
            res.setStatusCode(200);
            return res;
        }
    }
     public class ContractSyncToBPMSucesssNull implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"resultinfo":{}}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    public class ContractSyncToBPMSucesss implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{},resultinfo":{}}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    public class ContractSyncToBPMError implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"instid":"TWRnTXVsZUVTQi9NZGdDdXNJbmZvU3ZjQ29uZmlnRmxvdzIwMjQtMDUtMjggMTE6Mjg6MTUuNTA3","requesttime":"","responsetime":"2024-05-28 11:28:27.000","returnstatus":"W","returncode":"S001","returnmsg":"创建成功","attr1":"0001004420","attr2":"","attr3":""},"resultinfo":[{"KUNNR":"1111","VERPR":"10","CLABS":"10","MATNR":"12341234","LGORT":"111","CHARG":"111","WERKS":"5130","ATWRT":"111","KTOPL":"AED","MEINS":"L","CSPEM":"10","CINSM":"10","CRETM":"10","LWEDT":"111","KULAB":"10"}]}'); 
            res.setStatusCode(500);
            return res;
        }
    }
    public class ContractSyncToBPMSuccessCon implements System.HttpCalloutMock {
        public HTTPResponse respond(System.HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('{"esbinfo":{"returnstatus":"E"},"resultinfo":{}}'); 
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponse implements System.HttpCalloutMock {
        String conId;
        public MockHttpResponse(String contractIds) {
            conId = contractIds;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"esbinfo":{"instid":"","requesttime":"2025-09-08 17:27:52","responsetime":"2025-09-08 17:27:52","returnstatus":"S","returncode":"S001","returnmsg":"取回草稿成功"},"resultinfo":[{"crmId":"'+conId+'","msgty":"S","msgtx":"未找到对应数据"}]}');
            return res;
        }
    }
    public class MockHttpResponse1 implements System.HttpCalloutMock {
        String conId;
        public MockHttpResponse1(String contractIds) {
            conId = contractIds;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"esbinfo":{"instid":"","requesttime":"2025-09-08 17:27:52","responsetime":"2025-09-08 17:27:52","returnstatus":"S","returncode":"S001","returnmsg":"取回草稿成功"},"resultinfo":[{"crmId":"'+conId+'","msgty":"E","msgtx":"未找到对应数据"}]}');
            return res;
        }
    }

    public class HttpCalloutMock500 implements System.HttpCalloutMock {
        String conId;
        public HttpCalloutMock500(String contractIds) {
            conId = contractIds;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"esbinfo":{"instid":"","requesttime":"2025-09-08 17:27:52","responsetime":"2025-09-08 17:27:52","returnstatus":"S","returncode":"S001","returnmsg":"取回草稿成功"},"resultinfo":[{"crmId":"'+conId+'","msgty":"S","msgtx":"未找到对应数据"}]}');
            return res;
        }
    }

    public class HttpCalloutMocke implements System.HttpCalloutMock {
        String conId;
        public HttpCalloutMocke(String contractIds) {
            conId = contractIds;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"esbinfo":{"instid":"","requesttime":"2025-09-08 17:27:52","responsetime":"2025-09-08 17:27:52","returnstatus":"E","returncode":"S001","returnmsg":"取回草稿成功"},"resultinfo":[{"crmId":"'+conId+'","msgty":"S","msgtx":"未找到对应数据"}]}');
            return res;
        }
    }

    public class HttpCalloutMocke1 implements System.HttpCalloutMock {
        String conId;
        public HttpCalloutMocke1(String contractIds) {
            conId = contractIds;
        }
        public HttpResponse respond(HttpRequest req) {
            // 创建一个虚拟的HTTPResponse对象
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"esbinfo":,"resultinfo":[{"crmId":"'+conId+'","msgty":"S","msgtx":"未找到对应数据"}]}');
            return res;
        }
    }
}