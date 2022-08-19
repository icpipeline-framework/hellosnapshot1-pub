import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

actor {

    stable var theHistoryStable : [Text] = [];

    var theHistoryBuffer : Buffer.Buffer<Text> = Buffer.Buffer(0);

    public query func greet(name : Text) : async Text {

        theHistoryBuffer.add(name);
        return "Hello Pipeline, " # name # "!";
    };
    public query func getHistory() : async [Text] {
        
        return theHistoryBuffer.toArray();
    };
};
