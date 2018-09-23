import ballerina/config;
import ballerina/io;
import ballerina/log;
import wso2/gmail;
    endpoint gmail:Client gmailClient {
    clientConfig: {
        auth:{
            accessToken: config:getAsString("ACCESS_TOKEN"),
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }
};

type Gmail object{

    function sendMail(string customerEmail, string subject, string messageBody) returns boolean {
    //Create html message
    gmail:MessageRequest messageRequest;
    messageRequest.recipient = customerEmail;
    messageRequest.sender = config:getAsString("SENDER");
    messageRequest.subject = subject;
    messageRequest.messageBody = messageBody;
    messageRequest.contentType = gmail:TEXT_HTML;
    var userId = config:getAsString("USER_ID");

    //Send mail
    var sendMessageResponse = gmailClient->sendMessage(userId, untaint messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            log:printInfo("Sent email to " + customerEmail + " with message Id: " + messageId + " and thread Id:"
                    + threadId);
            return true;
        }
        gmail:GmailError e => {
            log:printInfo(e.message);
            return false;
        }
    }
}
};
