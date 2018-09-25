import ballerina/io;
import ballerina/log;
import ballerina/config;
@final string MESSAGE_ADDRESS = "Hi ";
@final string MESSAGE_START = "\n We have released ";
@final string MESSAGE_MIDDILE = " Click on the link to download the latest version:";
@final string MESSAGE_END = " For the full list of improvements and feature additions, please refer to the release note. ";
@final int PRODUCT_COLUMN = 0;
@final int USERNAME_COLUMN = 1;
@final int EMAIL_COLUMN = 2;

type ReleaseDetail record {
    string product,
    string versionDownloadLink,
    string versionNumber,
    string releaseNote,
};
function printhelp(){
    io:println("Please use following format to initialize the program");
    io:println("ballerina run news-publisher/ [Product] [Version Number] [Version download link] [Release note]");
    io:println("Example - ballerina run news-publisher/ Ballerina 0.981.0 http://bit.ly/2MjPzrk Ballerinalang");
}
function main(string... args) {
    
    io:println("Argument count :"+ args.count());
    if(args.count() != 4){
        printhelp();
        return;
    }
    ReleaseDetail detail;
    detail.product = args[0];
    detail.versionNumber = args[1];
    detail.versionDownloadLink = args[2];
    detail.releaseNote = args[3];

    GoogleSheet sheet = new;
    sheet.init();

    var sheetDetail = sheet.getDetailsFromGSheet(config:getAsString("SHEET_NAME"));
    match sheetDetail {
            string[][] blnc => {
            sendEmails(detail, blnc);
            }   
        boolean => {
            log:printInfo("Retreiving information from Google sheet failed");    
        } 
    }

    Twitter tweet;
    string status = MESSAGE_START+detail.product+ " "+ detail.versionNumber+ 
                                   MESSAGE_MIDDILE+detail.versionDownloadLink+MESSAGE_END+detail.releaseNote;
    io:println(tweet.sendTwitterUpdate(status));
}

function sendEmails ( ReleaseDetail rdetail, string[][] sheet ) {

    Gmail mail = new;
    
    foreach entry in sheet {
        if (entry[PRODUCT_COLUMN] == rdetail.product) {
            string messageToSend = MESSAGE_ADDRESS+entry[USERNAME_COLUMN]+MESSAGE_START+rdetail.product+ " "+ rdetail.versionNumber+ 
                                   MESSAGE_MIDDILE+rdetail.versionDownloadLink+MESSAGE_END+rdetail.releaseNote;
            if (mail.sendMail(entry[EMAIL_COLUMN], entry[PRODUCT_COLUMN]+" new release", messageToSend)) {
                log:printInfo("Successfully sent email to "+entry[USERNAME_COLUMN]+" regarding latest version in "+ entry[PRODUCT_COLUMN]);
            }
            else {
                log:printInfo("Message sending failed for "+entry[1]);
            }
        }
    }
}
