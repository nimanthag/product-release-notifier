import ballerina/config;
import ballerina/io;
import ballerina/log;
import wso2/twitter;
endpoint twitter:Client twitterClient {
    clientId:config:getAsString("TWITTER_CONSUMER_KEY"),
    clientSecret:config:getAsString("TWITTER_CONSUMER_SECRET"),
    accessToken:config:getAsString("TWITTER_ACCESS_TOKEN"),
    accessTokenSecret:config:getAsString("TWITTER_ACCESS_TOKEN_SECRET")
};

type Twitter object{
    function sendTwitterUpdate (string status) returns(twitter:Status|boolean) {
    var tweetResponse = twitterClient->tweet(status);
    match tweetResponse {
        twitter:Status twitterStatus => {
            //If successful, returns the tweet message or ID of the status.
            string tweetId = <string> twitterStatus.id;
            string text = twitterStatus.text;
            io:println("Tweet ID: " + tweetId);
            io:println("Tweet: " + text);
            return twitterStatus;
        }
        //Unsuccessful attempts return a Twitter error.
        twitter:TwitterError e => {
            io:println(e);
            return false;
        }
        
    }
}

};
