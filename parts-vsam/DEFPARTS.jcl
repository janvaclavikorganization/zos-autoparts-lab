//PARTDEF  JOB ,'DEFINE PARTS',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*------------------------------------------------------------------
//* Define the parts master as a VSAM KSDS (key-sequenced data set).
//* Key = part number = first 10 bytes of each 42-byte record
//* (matches PART-NO / record length in copybook/PARTREC.cpy).
//*
//* >>> replace ZXUSER with your own HLQ (your Z Xplore user id) <<<
//* CLASS / MSGCLASS may differ on your system - adjust if needed.
//*------------------------------------------------------------------
//DEFINE   EXEC PGM=IDCAMS
//*        IDCAMS = the VSAM utility; writes its report to SYSPRINT
//SYSPRINT DD SYSOUT=*
//*        SYSIN = IDCAMS control statements, inline until /*
//SYSIN    DD *
  DEFINE CLUSTER ( -
    NAME(ZXUSER.AUTOPART.PARTS) -
    INDEXED -
    KEYS(10 0) -
    RECORDSIZE(42 42) -
    TRACKS(1 1) )
/*
