import Prim "mo:prim";
import StableMemory "mo:base/ExperimentalStableMemory";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";

actor {
    /////////////////////////////////
    /// ICPIPELINE SUPPORT BEGIN ////
    /////////////////////////////////

    /// ICPIPELINE VARS

    //prod
    var icpipeline_manager_canister: Principal =  (Principal.fromText("c4fg7-saaaa-aaaah-abkta-cai"));
    //dev
    //var icpipeline_manager_canister: Principal =  (Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai"));
    

    /// ICPIPELINE TYPES

    public type CanisterInfo = {
        rts_version : Text;
        rts_memory_size: Nat;
        rts_heap_size: Nat;
        rts_total_allocation: Nat;
        rts_reclaimed : Nat;
        rts_max_live_size : Nat;
        cycleBalance : Nat;
        cycleAvailable : Nat;
    };


    /////////////////////////////////
    /// ICPIPELINE SUPPORT END //////
    /////////////////////////////////
    

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



  // ********************************************* 
  // ************* Memory Functions **************
  // *********************************************

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public shared({caller}) func getICPipelineCanisterInfo () : async  CanisterInfo {
    
    // if ( icpipeline_manager_canister != caller ) {
    //   assert(false);
    // };// end if we need to assert

      return {
          rts_version = Prim.rts_version();
          rts_memory_size = Prim.rts_memory_size();
          rts_heap_size = Prim.rts_heap_size();
          rts_total_allocation = Prim.rts_total_allocation();
          rts_reclaimed = Prim.rts_reclaimed();
          rts_max_live_size = Prim.rts_max_live_size();
          cycleBalance = Cycles.balance() ;
          cycleAvailable = Cycles.available();

      };
    
  }; // end getCanisterInfo 

    
};
