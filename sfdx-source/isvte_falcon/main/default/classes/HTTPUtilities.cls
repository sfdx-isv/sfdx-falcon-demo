/**
 * Utilities class to make HTTP Callouts and return
 */
public with sharing class HTTPUtilities {

    //HTTPRequest
    HttpRequest request = new HttpRequest();

    //HTTPRequest endpoint
    public void setEndpoint(String endpoint){
        request.setEndpoint(endpoint);
    }

    //HTTPRequest setMethod()
    //GET or POST
    public void setMethod(String method){
        request.setMethod(method);
    }

    //HTTRequest setHeader
    //key='Content-Type'
    //value='Application/json'
    public void setHeader(String key, String value){
        request.setHeader(key, value);
    }

    public void setBody(String body){
        request.setBody(body);
    }


    //Use try/catch in the calling method
    public HTTPResponse sendRequest(){
        Http http = new Http();
        HTTPResponse res = http.send(request);

        Util.log('HTTPUtilities:sendRequest():request: ' + request);
        Util.log('HTTPUtilities:sendRequest():res: ' + res);
        Util.log('HTTPUtilities:sendRequest():res.getBody(): ' + res.getBody());

        return res;
    }
}