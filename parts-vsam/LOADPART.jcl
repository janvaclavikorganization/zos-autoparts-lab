//PARTLOAD JOB ,'LOAD PARTS',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*------------------------------------------------------------------
//* Load parts.dat (flat file) into the parts KSDS.
//* REPRO = copy every record from INFILE into OUTFILE.
//*
//* >>> replace ZXUSER with your HLQ; upload parts.dat to z/OS first <<<
//*------------------------------------------------------------------
//LOAD     EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//*        INFILE  = the flat data file you uploaded
//INFILE   DD DSN=ZXUSER.AUTOPART.PARTS.DAT,DISP=SHR
//*        OUTFILE = the KSDS we defined earlier
//OUTFILE  DD DSN=ZXUSER.AUTOPART.PARTS,DISP=SHR
//SYSIN    DD *
  REPRO INFILE(INFILE) OUTFILE(OUTFILE)
/*
