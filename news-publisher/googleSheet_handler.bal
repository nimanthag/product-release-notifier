import ballerina/config;
import ballerina/io;
import ballerina/log;
import wso2/gsheets4;
@final
public string  EMPTY_STRING= "";
endpoint gsheets4:Client googleSheetClient {
    clientConfig: {
        auth:{
            accessToken: config:getAsString("ACCESS_TOKEN"),
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }

};

type GoogleSheet object {

 gsheets4:Spreadsheet spreadSheet ;
 gsheets4:Sheet[] sheetList;
    function init(){
        var response = getSpreadsheetById();
        match response {
            gsheets4:Spreadsheet res=> {
                spreadSheet = res;
                var list = spreadSheet.getSheets();
                match list {
                    gsheets4:Sheet[] listRes=> {
                        sheetList = listRes;    
                    }
                    gsheets4:SpreadsheetError err => {
                        log:printInfo(err.message);                       
                    }
                }
            }
            boolean => {
                io:print("Spread Sheet Initialization error ["+ config:getAsString("SPREADSHEET_ID")+"]");
            }
        }

    }

    function getSpreadsheetById() returns (gsheets4:Spreadsheet|boolean){
        //Open a spreadsheet.
        var response = googleSheetClient->openSpreadsheetById(config:getAsString("SPREADSHEET_ID"));
        match response {
        //If successful, returns the Spreadsheet object.
        gsheets4:Spreadsheet spreadsheetRes => {
            //io:println(spreadsheetRes);
            return spreadsheetRes;
        }
        //Unsuccessful attempts return a SpreadsheetError.
        gsheets4:SpreadsheetError err => {
                log:printInfo(err.message);
                return false;    
            } 
        }
    }

    function addNewGSheet(string sheetName) returns (gsheets4:Sheet|boolean){
    var spreadsheetId = config:getAsString("SPREADSHEET_ID");
    var spreadsheetResponse  = googleSheetClient->addNewSheet(spreadsheetId, sheetName);

        match spreadsheetResponse {
        gsheets4:Sheet vals => {
            //io:println(vals.properties.sheetId);
            //io:println(vals);
            return vals;
        }
        gsheets4:SpreadsheetError e => {
            
            if (e.statusCode == 400) {
                log:printInfo("Sheet already available");
                var response = spreadSheet.getSheetByName(sheetName);
                match response {
                    gsheets4:Sheet sheet => {
                         return sheet;
                        }
                    gsheets4:SpreadsheetError err => {
                        io:println(err);
                        return false;    
                        }
                }
            }else{
                log:printInfo(e.message);
                log:printInfo(""+e.statusCode);
                log:printInfo("Add new Google Sheet failed");
                return false;  
            }
              
        } 
    }
}

function getDetailsFromGSheet (string sheetName) returns (string[][]|boolean) {
    //Read all the values from the sheet.
    var spreadsheetId = config:getAsString("SPREADSHEET_ID");

    var spreadsheetRes =  googleSheetClient->getSheetValues(spreadsheetId, sheetName, EMPTY_STRING, EMPTY_STRING);
    match spreadsheetRes {
        string[][] vals => {
            log:printInfo("Retrieved details from spreadsheet id:" + spreadsheetId + " ; sheet name: "
                    + sheetName);
            return vals;
        }
        gsheets4:SpreadsheetError e => {
            log:printInfo(e.message);
            return false;    
        } 
    }

    
}
};
