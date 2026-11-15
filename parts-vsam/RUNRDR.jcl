//PARTRDRJ JOB ,'READ PARTS',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*------------------------------------------------------------------
//* Compile + link PARTRDR, then run it against the parts KSDS.
//* >>> replace ZXUSER with your HLQ <<<
//*------------------------------------------------------------------
//* --- step 1: compile + link the COBOL program ---
//COMPILE  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=ZXUSER.AUTOPART.SOURCE(PARTRDR),DISP=SHR
//LKED.SYSLMOD DD DSN=ZXUSER.AUTOPART.LOAD(PARTRDR),DISP=SHR
//* --- step 2: run it; PARTSDD = the KSDS the program reads ---
//RUN      EXEC PGM=PARTRDR
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PARTSDD  DD DSN=ZXUSER.AUTOPART.PARTS,DISP=SHR
//SYSOUT   DD SYSOUT=*
