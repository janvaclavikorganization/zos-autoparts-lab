//DAILYRUN JOB ,'DAILY PRICING FLOW',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*==================================================================
//* A mainframe "application" is not one program - it is a PIPELINE
//* of steps, with data flowing between them through datasets:
//*
//*   raw orders --[SORT]--> sorted --[PRICE]--> priced --[...]-->
//*
//* Each step is one job step; the output dataset of one step is the
//* input of the next. Job-step order + these datasets ARE the
//* "architecture" / "data flow" the role talks about.
//*
//* >>> replace ZXUSER with your HLQ <<<
//*==================================================================
//*
//* --- STEP 1: sort the raw orders by country, then part number ---
//*     Output goes to a TEMPORARY dataset &&SORTED: it lives only
//*     for this job (PASS) and is handed to the next step.
//SORT     EXEC PGM=SORT
//SORTIN   DD DSN=ZXUSER.AUTOPART.ORDERS,DISP=SHR
//SORTOUT  DD DSN=&&SORTED,DISP=(NEW,PASS),
//            SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=25)
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
  SORT FIELDS=(9,2,CH,A,11,10,CH,A)
/*
//*
//* --- STEP 2: price the sorted orders against the catalogue ---
//*     ORDERSDD now reads &&SORTED passed from STEP 1 (data flow).
//*     The step consumes it (OLD,DELETE) once priced.
//PRICE    EXEC PGM=ORDPROC
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//ORDERSDD DD DSN=&&SORTED,DISP=(OLD,DELETE)
//PARTSDD  DD DSN=ZXUSER.AUTOPART.PARTS,DISP=SHR
//SYSOUT   DD SYSOUT=*
//*
//* --- further steps in a full flow (not built yet) ---
//*   STEP 3 REPORT : ORDRPT -> country sales report
//*   STEP 4 EXTRACT: build an interface file and hand it to a
//*                   downstream system (e.g. SAP for invoicing).
//*                   THAT hand-off file IS the "integration
//*                   interface" / data flow between systems.
