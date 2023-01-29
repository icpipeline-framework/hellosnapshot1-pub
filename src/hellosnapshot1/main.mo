import Prim "mo:prim";
import StableMemory "mo:base/ExperimentalStableMemory";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Int "mo:base/Int";

import ICArchiveUtils "icArchiveUtils"; // the module from ICArchive (icArchiveUtils.mo)


actor Self {
    /////////////////////////////////
    /// ICPIPELINE SUPPORT BEGIN ////
    /////////////////////////////////

    /// ICPIPELINE VARS

    //prod
    // var icpmCanisterId: Text = "c4fg7-saaaa-aaaah-abkta-cai";
    // var archiveCanisterId: Text =  "c4fg7-saaaa-aaaah-abkta-cai";
    //dev
    stable var icpmCanisterId: Text = "3qtpz-mbcpc-q7cp7-d5x3u-s6ot5-bmg4p-2rrez-p7tcg-jcx5l-tanzf-3ae";
    stable var archiveCanisterId: Text =  "s55qq-oqaaa-aaaaa-aaakq-cai";
    

    public type IC = actor {
    canister_status : { canister_id : canister_id } -> async canister_status;
    };
    let ic : IC = actor("aaaaa-aa");

    /// ICPIPELINE TYPES


    public type SetICPipelineResponse = {
        currentICPipelineCanister : Text;
    } ;



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
      
    public type canister_id = Principal;

    public type definite_canister_settings = {
      freezing_threshold : Nat;
      controllers : [Principal];
      memory_allocation : Nat;
      compute_allocation : Nat;
    };

    public type canister_status = {
      status : { #stopped; #stopping; #running };
      memory_size : Nat;
      cycles : Nat;
      settings : definite_canister_settings;
      module_hash : ?[Nat8];
    };

    public type ICPMCanisterInfo = {
        canisterInfoObject : CanisterInfo;
        canister_statusObject: canister_status ;
    };


    // ICARCHIVE TYPES - BEGIN

    type Archive =ICArchiveUtils.Archive;
    type SetArchiveResponse = ICArchiveUtils.SetArchiveResponse;
    type RestoreArchiveResponse = ICArchiveUtils.RestoreArchiveResponse;
    type ArchiveListResponse = ICArchiveUtils.ArchiveListResponse;
    type ArchiveCanisterResponse = ICArchiveUtils.ArchiveCanisterResponse;
    type ArchiveChunk = ICArchiveUtils.ArchiveChunk ;
    type ArchiveResponse = ICArchiveUtils.ArchiveResponse  ;
    type ArchiveChunkResponse = ICArchiveUtils.ArchiveChunkResponse ;

    // ICARCHIVE TYPES - END 


    
    // number of bytes (Nat8) 
    var archiveChunkSize: Int = 3072; // 3k chunk
    
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public shared({caller})  func setICPipelineCanisterMain ( newICPipelineCanisterId : Text, replace : Bool) : async  SetICPipelineResponse {


    if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      assert(false);
    };// end if we need to assert

      if (replace == true  ) {
        // if we are asked to replace and it is a valid principal we add it.
        var checkPrincipal :Principal  = Principal.fromText(newICPipelineCanisterId);
        
        icpmCanisterId := newICPipelineCanisterId ;

      };
    var tempSetICPipelineResponse : SetICPipelineResponse = {
        currentICPipelineCanister = icpmCanisterId ;
    };
    return tempSetICPipelineResponse;

  }; // end setICPipelineCanisterMain 

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////
    /// ICPIPELINE SUPPORT END //////
    /////////////////////////////////
    

    stable var theHistoryStable : [Text] = [];

    var theHistoryBuffer : Buffer.Buffer<Text> = Buffer.Buffer(0);

    // public type MyArchiveObject = {
    //     historyBufferObject :  Buffer.Buffer<Text>;
    // } ; // end the backup object
    public type MyArchiveObject = {
        historyArrayObject : [Text];
    } ; // end the backup object




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
  // ************* ICArchive Functions **************
  // *********************************************

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public shared({caller})  func setArchiveCanisterMain ( newArchiveCanisterId : Text, replace : Bool) : async  SetArchiveResponse {


    if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      assert(false);
    };// end if we need to assert

      if (replace == true  ) {
        // if we are asked to replace and it is a valid principal we add it.
        var checkPrincipal :Principal  = Principal.fromText(newArchiveCanisterId);
        
        archiveCanisterId := newArchiveCanisterId ;

      };
    var tempSetArchiveResponse : SetArchiveResponse = {
        currentArchiveCanisterId = archiveCanisterId ;
    };
    return tempSetArchiveResponse;

  }; // end setArchiveCanisterMain 

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared({caller}) func doICArchiveMain () : async ArchiveResponse {
    
    if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      assert(false);
    };// end if we need to assert

    var tempMsg: Text = "";
    var tempResponseStatus: Text = "Green" ;
    let now = Time.now();
    
      
    var tempArchive : Archive = {
      id = 0;
      archiveType = ""; 
      archiveMsg =  "";
      sourceCanister = "";
      chunkCount = 0 ;
      created = 0;
      lastUpdated = 0;
    };

  

      
            // create object for archive 
            var tempArchiveObject : MyArchiveObject = {
                historyArrayObject = theHistoryStable;
              };

            var tempArchiveType : Text = "My History Archive";
            var tempArchiveMsg : Text = "User Requested Archive";

            // convert archive to blob and send to archive func 

            var tempBlobArchive : Blob = to_candid(tempArchiveObject);  

            var tempDoArchiveResponse : ArchiveResponse = await ICArchiveUtils.doArchive(archiveCanisterId, archiveChunkSize, tempBlobArchive, tempArchiveType, tempArchiveMsg) ;

            tempArchive := tempDoArchiveResponse.archive;


    var tempArchiveResponse: ArchiveResponse = 
    {
      archive = tempArchive;
      msg = tempMsg;
      timeStamp = now;
      responseStatus = tempResponseStatus;
    };
    return tempArchiveResponse;
    
  }; // end doICArchiveMain


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared({caller})  func restoreICArchiveMain ( tempArchiveId : Int, archiveFirst : Bool) : async  RestoreArchiveResponse {


    if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      assert(false);
    };// end if we need to assert

    var tempMsg: Text = "";
    var tempResponseStatus: Text = "Green" ;
    let now = Time.now();


    var tempArchiveObjectRestored : MyArchiveObject = {
        historyArrayObject =[] ;
    };

    var tempArchiveFirst : Archive = {
      id = 0;
      archiveType = ""; 
      archiveMsg =  "";
      sourceCanister= "";
      chunkCount = 0 ;
      created = 0;
      lastUpdated = 0;
    };
    var tempArchiveRestore : Archive = {
      id = 0;
      archiveType = ""; 
      archiveMsg =  "";
      sourceCanister = "" ;
      chunkCount = 0 ;
      created = 0;
      lastUpdated = 0;
    };

    var tempArchiveChunk : ArchiveChunk = {
      archiveId = 0;
      chunkNum = 0 ;
      chunk = [] ;
      created = 0;
      lastUpdated = 0;
    };


      tempArchiveRestore := await ICArchiveUtils.getArchivebById(archiveCanisterId, tempArchiveId);

      // ok so we now have an archive and we want to update the local variables ... but we want to archive the existing ones first

      if (tempArchiveRestore.id > 0 ) {
        
        
        if (archiveFirst == true) {

            // create object for archive 
            var tempArchiveObject : MyArchiveObject = {
                historyArrayObject = theHistoryStable;
              };

            var tempArchiveType : Text = "My History Archive";

            var tempArchiveMsg : Text = "User Requested Archive";

            // convert archive to blob and send to archive func 

            var tempBlobArchive : Blob = to_candid(tempArchiveObject);  

            var tempDoArchiveResponse : ArchiveResponse = await ICArchiveUtils.doArchive(archiveCanisterId, archiveChunkSize, tempBlobArchive, tempArchiveType, tempArchiveMsg) ;

            tempArchiveFirst := tempDoArchiveResponse.archive;


        }; // end if archive first

        // now we need to get the archive from the archive canister 
        
        var tempRestoredBlob : Blob = await ICArchiveUtils.restoreArchive(archiveCanisterId,tempArchiveRestore ) ;

        // then we convert the blob back to the candid ArchiveICPM
        
        var tempBlobReturned : ?MyArchiveObject = from_candid(tempRestoredBlob); 

       switch tempBlobReturned {
         case (?val) {
            //Debug.print("RESTORE ARCHIVE - have a value" ) ;
            tempArchiveObjectRestored:=val ;

          };
         case null {
            //Debug.print("RESTORE ARCHIVE - have no value " ) ;
          };
       };// end switch
        
        
        //Debug.print("RESTORE ARCHIVE - tempArchiveObjectRestore  " # debug_show(tempArchiveObjectRestore));

        // now we restore the one we just recieved. 
        

        theHistoryStable := tempArchiveObjectRestored.historyArrayObject ;



        tempResponseStatus := "Green" ;
        
      } else {
        
        tempMsg := "We expected a Archive but did not recieve one from the archive canister with id: "#Int.toText(tempArchiveId);
        tempResponseStatus := "Red" ;

      
      };// end if archive is there  
      


    var tempRestoreArchiveResponse: RestoreArchiveResponse = 
    {
      msg = tempMsg;
      timeStamp = now;
      responseStatus = tempResponseStatus;
    };

    return tempRestoreArchiveResponse;
    
  }; // end restoreICArchiveMain



  // ********************************************* 
  // ************* Memory Functions **************
  // *********************************************

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public shared({caller}) func getICPipelineCanisterInfo () : async  ICPMCanisterInfo {
    
    if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      assert(false);
    };// end if we need to assert

    var tempCanisterInfo : CanisterInfo =  {
          rts_version = Prim.rts_version();
          rts_memory_size = Prim.rts_memory_size();
          rts_heap_size = Prim.rts_heap_size();
          rts_total_allocation = Prim.rts_total_allocation();
          rts_reclaimed = Prim.rts_reclaimed();
          rts_max_live_size = Prim.rts_max_live_size();
          cycleBalance = Cycles.balance() ;
          cycleAvailable = Cycles.available();

      };

      let tempCanisterPrincipal = Principal.fromActor(Self);
      var tempCanisterStatus : canister_status =  await ic.canister_status({canister_id = tempCanisterPrincipal }) ;

      var tempICPMCanisterInfo: ICPMCanisterInfo =  { 
        canisterInfoObject = tempCanisterInfo;
        canister_statusObject = tempCanisterStatus ;
      };

      return tempICPMCanisterInfo ;
      
    
  }; // end getCanisterInfo 

    
}; // end actor Self
