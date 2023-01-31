import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";


  // *******************************
  // NOTE: - START HERE

  ///// This Module contains the Types and Function needed for ICArchive Integration. 
  // Copy the following lines to the main.mo actor file to implement availble types and interfaces in your canister code

  // *******************************
  // before the actor:
  // import ICArchiveUtils "icArchiveUtils"; // the module from ICArchive (icArchiveUtils.mo)
    
  // *******************************
  // inside the actor:

  // // ICARCHIVE TYPES - BEGIN

  // type Archive =ICArchiveUtils.Archive;
  // type SetArchiveResponse = ICArchiveUtils.SetArchiveResponse;
  // type RestoreArchiveResponse = ICArchiveUtils.RestoreArchiveResponse;
  // type ArchiveListResponse = ICArchiveUtils.ArchiveListResponse;
  // type ArchiveCanisterResponse = ICArchiveUtils.ArchiveCanisterResponse;
  // type ArchiveChunk = ICArchiveUtils.ArchiveChunk ;
  // type ArchiveResponse = ICArchiveUtils.ArchiveResponse  ;
  // type ArchiveChunkResponse = ICArchiveUtils.ArchiveChunkResponse ;

  // // ICARCHIVE TYPES - END 
  
  // ////////////////////////////////// ARCHIVE SETTINGS

  // var archiveCanisterId : Text = "rdmx6-jaaaa-aaaaa-aaadq-cai";

  
  // // number of bytes (Nat8) 
  // var archiveChunkSize: Int = 3072; // 3k chunk

  // if you want to change the archive without deployment or want to add the archive later you can add this interface:

      // public shared({caller})  func setArchiveCanisterMain ( newArchiveCanisterId : Text, replace : Bool) : async  SetArchiveResponse {


      //   if ( Principal.fromText(icpmCanisterId) != caller and Principal.fromText(archiveCanisterId) != caller) {
      //     assert(false);
      //   };// end if we need to assert

      //     if (replace == true and Principal.fromText(newArchiveCanisterId)  ) {
      //       // if we are asked to replace and it is a valid principal we add it.
      //       archiveCanisterId := newArchiveCanisterId ;

      //     };
      //   var tempSetArchiveResponse : SetArchiveResponse = {
      //       currentArchiveCanisterId = archiveCanisterId ;
      //   };
      //   return tempSetArchiveResponse;

      // } // end setArchiveCanisterMain 
      
  // Now Example Functions that should be added and

  // *******************************


module {
  


  ///////////////////////////////////  ICARCHIVE GENERIC

  public type SetArchiveResponse = {
      currentArchiveCanisterId : Text;
  } ;


  public type Archive = {
    id: Int;
    chunkCount: Int;
    archiveType: Text; // user defined type that will separate archive objects
    archiveMsg: Text;
    sourceCanister: Text;
    created: Int;
    lastUpdated: Int;
  }; // end Archive

  public type ArchiveResponse = {
    archive: Archive;
    msg : Text;
    timeStamp : Int;
    responseStatus : Text;
  };

  public type ArchiveListResponse = {
    archiveObjects: [Archive];
    msg : Text;
    timeStamp : Int;
    responseStatus : Text;
  };
  
  public type ArchiveChunk = {
    archiveId : Int ;
    chunkNum : Int ;
    chunk : [Nat8];
    created : Int;
    lastUpdated : Int;
  }; // end Archive Chunk


  public type ArchiveChunkResponse = {
    archiveChunk : ArchiveChunk ;
    msg : Text;
    timeStamp : Int;
    responseStatus : Text;
  }; // ArchiveChunkResponse

  
  public type RestoreArchiveResponse =  
  {
    msg: Text;
    timeStamp: Int;
    responseStatus: Text;
  };

  public type ArchiveCanisterResponse =  
  {
    msg: Text;
    timeStamp: Int;
    responseStatus: Text;
  };



  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


   public func doArchive (archiveCanisterId: Text, archiveChunkSize: Int,tempBlobArchive : Blob, tempArchiveType : Text, tempArchiveMsg : Text ) : async ArchiveResponse { 
      // internal function to take any object, chop it to chunks and send to archive canister

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

      var tempArchiveChunk : ArchiveChunk = {
        archiveId = 0 ;
        chunkNum = 0 ;
        chunk = [];
        created = 0 ;
        lastUpdated = 0 ;
        };
    
      var tempArchiveChunkResponse : ArchiveChunkResponse = {
        archiveChunk  = tempArchiveChunk ;
        msg  = "";
        timeStamp  = 0;
        responseStatus = "" ;
      }; // ArchiveChunkResponse

      let archiveCanisterActor = actor(archiveCanisterId): actor { 
        createArchiveMain :(Text, Text) -> async ArchiveResponse ;
        addChunkToArchive :(Int, ArchiveChunk) -> async ArchiveChunkResponse ;
        getArchiveMain :(Int) -> async ArchiveResponse ;
      };

      // create a new archive object on the archive canister

      var tempCreateArchiveResponse : ArchiveResponse = await archiveCanisterActor.createArchiveMain (tempArchiveType, tempArchiveMsg);

      tempArchive := tempCreateArchiveResponse.archive ;

      if (tempArchive.id > 0 ) {


        var tempBlobArchiveArray : [Nat8] =  Blob.toArray(tempBlobArchive);
        // get the size
        var tempBlobSize : Nat = tempBlobArchive.size() ;

            //Debug.print("INSIDE MAIN tempBlobArchive.size: ");
            //Debug.print(debug_show());
            
        // estimate chunks 
        //var tempEstimatedChunkNum : Int = 0 ;

        // track how much was sent
        var tempTotalSizeSent : Int = 0;
        // count the chunks
        var tempChunkCounter : Int = 0 ;
        // maintain chunkNums
        var tempChunkNum : Int = 0 ;
        
        
              

        // based on the size loop through the backup and send chunks

        var doneAllChunks : Bool = false ;
        
        var tempChunkBuffer : Buffer.Buffer<Nat8> = Buffer.Buffer(0);
      
      

        /// Could not find a way to "chunk" the array so we will map our way through it for every chunk 
        // (there has to be a better way to do it but this will work)

        while (doneAllChunks == false ) {
        
          //reset the buffer
          tempChunkBuffer := Buffer.Buffer(0);


          //Debug.print("DOARCHIVE Before loop through tempChunkNum: " # Int.toText(tempChunkNum));
          tempChunkCounter := 0 ;


          let tempBlobArrayNew: [Nat8] = Array.map<Nat8, Nat8>(
            tempBlobArchiveArray,
            func (origBlobNat : Nat8) : Nat8 {
            
                tempChunkCounter +=1 ;

                if  (tempChunkCounter > (archiveChunkSize * tempChunkNum ) and tempChunkCounter <= ((archiveChunkSize * tempChunkNum ) + archiveChunkSize ))  {
                    
                    tempChunkBuffer.add (origBlobNat);
                };
              
                origBlobNat
            } // end generic subfunction
          ); // end Array Map

            

            if (tempChunkBuffer.size() > 0 ) {
              
              // increase the chunk number before sending

              tempChunkNum += 1 ;
              //Debug.print("DOARCHIVE Before sending chunk through tempChunkNum: " # Int.toText(tempChunkNum));
              tempArchiveChunk := {
                archiveId = tempArchive.id;
                chunkNum = tempChunkNum ;
                chunk = Buffer.toArray(tempChunkBuffer);
                created = 0 ;
                lastUpdated = 0 ;
                };
            

              tempArchiveChunkResponse := await archiveCanisterActor.addChunkToArchive(tempArchive.id, tempArchiveChunk);
        
            } else {
              
              doneAllChunks := true;

            }; // end if there is an more chunks 

        }; // end while we are doing the chunks



        var tempArchiveUpdated : ArchiveResponse = await archiveCanisterActor.getArchiveMain (tempArchive.id);

        //Debug.print("DO ARCHIVE - while loop for chunks complete and we can verify the chunk numbers made it to the archive: " # Int.toText(tempArchiveUpdated.archive.chunkCount));
        if (tempArchiveUpdated.archive.chunkCount == tempChunkNum ) {

          tempArchive := tempArchiveUpdated.archive ;

        } else {

          tempMsg := "We sent a number of Chunks: " # Int.toText(tempChunkNum) # " but for some reason there were :" # Int.toText(tempArchiveUpdated.archive.chunkCount );
          tempResponseStatus := "Red" ;
          // Debug.print("DO ARCHIVE - RED  " # tempMsg);
    
        };  // end if the number of chunks equals the num we esitmated. 

      } else {

        tempMsg := "There was no archive created" ;
        tempResponseStatus := "Red" ;

      }; // then we know we got an archive
       

    var tempArchiveResponse: ArchiveResponse = 
    {
      archive = tempArchive;
      msg = tempMsg;
      timeStamp = now;
      responseStatus = tempResponseStatus;
    };
    return tempArchiveResponse;

   };  // end doArchive func


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

   public func restoreArchive (archiveCanisterId: Text,  tempArchive : Archive) : async Blob { 



        // so we need to get the chunks
          var tempChunkCounter : Int = 0 ;
          
          var tempArchiveChunks : Buffer.Buffer<Nat8> = Buffer.Buffer(0);
          
          Debug.print("RESTORE ARCHIVE - tempArchiveRestore.chunkNum  " # Int.toText (tempArchive.chunkCount));

          while (tempChunkCounter < tempArchive.chunkCount ) {

            tempChunkCounter += 1;

            var tempArchiveChunk : ArchiveChunk = await getArchiveChunk (archiveCanisterId, tempArchive.id, tempChunkCounter);
            
            

            // now we loop through the elements in the chunk array

            for (x in tempArchiveChunk.chunk.vals()) {
              
                tempArchiveChunks.add(x);
              
            };

            

          }; // end while through chunks

            
        // now we take these chunks and create a blob 

        var tempBlob : Blob  = Blob.fromArray (Buffer.toArray(tempArchiveChunks)) ;
        //Debug.print("RESTORE ARCHIVE - tempBlob.size()  " # debug_show(tempBlob.size()));
    
        return tempBlob;


}; // end restoreArchive
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


  public func getArchivebById (archiveCanisterId:Text, tempArchiveId: Int ) : async Archive  {
    // now we get the archive list from the archive canister

      var tempArchive : Archive = {
        id = 0;
        archiveType = ""; 
        archiveMsg =  "";
        sourceCanister = "" ;
        chunkCount = 0 ;
        created = 0;
        lastUpdated = 0;
      };


      let archiveCanisterActor = actor(archiveCanisterId): actor { 
        getArchiveMain :( Int) -> async ArchiveResponse ;
      };

      var tempArchiveResponse : ArchiveResponse = await archiveCanisterActor.getArchiveMain(tempArchiveId);

    return tempArchiveResponse.archive;
    
  };// end getArchivesbByType

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func getArchivesbByType (archiveCanisterId:Text, tempArchiveType: Text ) : async [Archive]  {
    // now we get the archive list from the archive canister

      
      var theseArchives : [Archive] = [];

      let archiveCanisterActor = actor(archiveCanisterId): actor { 
        getListOfArchivesByTypeMain :(Text) -> async ArchiveListResponse ;
      };

      var tempArchiveListResponse : ArchiveListResponse = await archiveCanisterActor.getListOfArchivesByTypeMain(tempArchiveType);
      theseArchives := tempArchiveListResponse.archiveObjects ;

    return theseArchives
    
  };// end getArchivesbByType

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func getArchiveChunk (archiveCanisterId:Text, tempArchiveId: Int, tempChunkNum : Int ) : async ArchiveChunk  {
    // now we get the archive list from the archive canister

    var tempArchiveChunk : ArchiveChunk = {
      archiveId = 0;
      chunkNum = 0 ;
      chunk = [] ;
      created = 0;
      lastUpdated = 0;
    };

      
      let archiveCanisterActor = actor(archiveCanisterId): actor { 
        getArchiveChunkMain :( Int, Int) -> async ArchiveChunkResponse ;
      };
        

      var tempArchiveChunkResponseFromArchive : ArchiveChunkResponse = await archiveCanisterActor.getArchiveChunkMain (tempArchiveId, tempChunkNum);
      
      tempArchiveChunk := tempArchiveChunkResponseFromArchive.archiveChunk ;

    return tempArchiveChunk
    
  };// end getArchivesbByType

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


  } // end module for ICArchive
