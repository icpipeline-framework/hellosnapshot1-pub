import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

actor {
    // add comment for new module hashs 

    stable var theHistoryStable : [Text] = [];

    var theHistoryBuffer : Buffer.Buffer<Text> = Buffer.Buffer(0);

    public shared({caller}) func greet(name : Text) : async Text {

       theHistoryBuffer.add(name);

        let newBuffer : Buffer.Buffer<Text> = Buffer.Buffer(0);
        for (x in theHistoryStable.vals()) {
            
            newBuffer.add(x);
            
        };
        newBuffer.add (name);
        
       theHistoryStable := newBuffer.toArray();
       

        return "Hello Pipeline, " # name # "!";
    };
    public query func getHistoryBuffer() : async [Text] {
        
        return theHistoryBuffer.toArray() ;
    };
    public query func getHistoryStable() : async [Text] {
        
        return theHistoryStable ;
    };
};
