import ballerina/config;
import ballerina/io;
import ballerina/test;

@test:Config
function testsendEmail() {
    io:println("\n ---------------------------------Test------------------------------------------");
    log:printInfo("Gmail.sendEmail()");
    Gmail mail = new;
    string emailAddress = "nimanthalakmal@gmail.com";
    if (mail.sendMail(emailAddress, "test", "test")) {
        io:println("Successfully sent email to "+ emailAddress);
    }
    else {
        test:assertFail(msg = "Message sending failed for "+emailAddress);
    }
}

@test:Config
function testsendTwitterUpdate(){
    io:println("\n ---------------------------------Test------------------------------------------");
    log:printInfo("Twitter.sendTwitterUpdate()");
    
    Twitter tweet;
    string status = "test";
    var response  = tweet.sendTwitterUpdate(status);
    match response {
        twitter:Status twitterStatus => {
            //If successful, returns the tweet message or ID of the status.
            string tweetId = <string> twitterStatus.id;
            string text = twitterStatus.text;
            io:println("Tweet ID: " + tweetId);
            io:println("Tweet: " + text);
        }
        //Unsuccessful attempts return a Twitter error.
        boolean e => {
            test:assertFail(msg = "twitter publishing failed");
        }
    }
}