      SUBROUTINE PLA2
C*****
C THIS ROUTINE IS THE SECOND FUNCTIONAL MODULE UNIQUE TO THE PIECE-WISE
C LINEAR ANALYSIS (PLA) RIGID FORMAT FOR THE DISPLACEMENT APPROACH.
C
C DMAP CALL...
C
C PLA2   DELTAUGV,DELTAPG,DELTAQG/UGV1,PGV1,QG1/V,N,PLACOUNT/ $
C
C CONCERNING DELTAUGV AND UGV1, THE ROUTINE WORKS AS FOLLOWS...
C DELTAUGV IS THE CURRENT INCREMENTAL DISPLACEMENT VECTOR IN THE PLA
C RIGID FORMAT LOOP AND UGV1 IS AN APPENDED FILE OF DISPLACEMENT VECTORS
C IF PLACOUNT .EQ. 1, THAT IS, THIS IS THE FIRST TIME PLA2 HAS BEEN
C CALLED IN THE PLA LOOP, THEN DELTAUGV IS COPIED ONTO UGV1.  IF
C PLACOUNT .GT. 1, THE PREVIOUS, OR LAST, DISPLACEMENT VECTOR IS READ
C INTO CORE FROM THE UGV1 DATA BLOCK, AND THE UGV1 FILE IS CLOSED WITH-
C OUT REWIND, THEN OPENED WITHOUT REWIND TO WRITE.  THE DELTAUGV VECTOR
C IS READ AN ELEMENT AT A TIME USING SUBROUTINE ZNTPKI AND ADDED TO
C THE VECTOR IN CORE.  THEN THE NEW DISPLACEMENT VECTOR IS WRITTEN ONTO
C THE UGV1 FILE.
C
C THEN THE PLA DMAP LOOP COUNTER PLACOUNT IS INCREMENTED.
C
C DELTAPG IS THE CURRENT INCREMENTAL LOAD VECTOR AND PGV1 IS THE
C CORRESPONDING MATRIX OF RUNNING SUM LOAD VECTORS.  PROCESSING IS
C SIMILAR TO THE ABOVE.  NOTE THAT NEITHER DATA BLOCK, LIKE THE TWO
C DISCUSSED ABOVE, CAN BE PURGED.
C
C DELTAQG IS THE CURRENT INCREMENTAL VECTOR OF SINGLE POINT CONSTRAINT
C FORCES AND QG1 IS THE APPENDED FILE OF VECTORS OF SPCF.  THESE TWO
C DATA BLOCKS ARE PROCESSED IDENTICALLY TO DELTAUGV AND UGV1 EXCECT
C THAT NO FATAL ERROR EXISTS IF ONE OR THE OTHER HAS BEEN PURGED.
C*****
C
      INTEGER
     1                   BUFSZ
     2,                  BUFFR1             ,BUFFR2
     3,                  OFILE              ,PLACNT
     4,                  EOR                ,CLSRW
     5,                  CLSNRW             ,OUTRW
     6,                  EOL                ,TYPEA
     7,                  TYPEB              ,OUTNRW
      INTEGER INBLK(15),OUBLK(15)
C
      DIMENSION
     1                   NAME(2)            ,DUMMY(2)
     2,                  MCB(7)
      COMMON /BLANK/PLACNT
      COMMON   /SYSTEM/  BUFSZ
      COMMON   /ZZZZZZ /  Z(1)
      COMMON   /ZNTPKX/
     1                   A(4)               ,INDEX
     2,                  EOL                ,IDUMMY
      COMMON   /PACKX /
     1                   TYPEA              ,TYPEB
     2,                  IPACK              ,JPACK
     3,                  INCPK
      COMMON   /UNPAKX/
     1                   IUNPKB             ,IUNPK
     2,                  JUNPK              ,INCUPK
C
      DATA               NAME /4HPLA2,4H    /
      DATA               INRW,OUTRW,OUTNRW,CLSRW,CLSNRW,EOR/0,1,3,1,2,1/
C
C INITIALIZE
C
      IZMAX = KORSZ (Z)
      BUFFR1 = IZMAX - BUFSZ
      BUFFR2 = BUFFR1 - BUFSZ
      LEFT = BUFFR2 - 1
      ILOOP = 1
      IFILE = 101
      OFILE = 201
C
C OPEN INPUT FILE TO READ AND OUTPUT FILE TO WRITE (IF PLACNT .EQ. 1)
C OR TO READ (IF PLACNT .GT. 1)
C
   10 JFILE = IFILE
      INBLK(1) = IFILE
      OUBLK(1) = OFILE
      DO 15 I = 2,7
   15 MCB(I) = 0
      MCB(1) = OFILE
      IF (PLACNT .EQ. 1) MCB(1) = IFILE
      CALL RDTRL (MCB)
      CALL OPEN(*100,IFILE,Z(BUFFR1),INRW)
      CALL FWDREC(*9020,IFILE)
      IOPT = INRW
      IF (PLACNT .EQ. 1) IOPT = OUTRW
      CALL OPEN(*110,OFILE,Z(BUFFR2),IOPT)
      IF (PLACNT .NE. 1) GO TO 30
C
C THIS IS THE FIRST TIME THROUGH THE PLA LOOP.  COPY THE VECTOR ON THE
C INPUT FILE ONTO THE OUTPUT FILE.
C
      CALL FNAME (OFILE,DUMMY)
      CALL WRITE (OFILE,DUMMY,2,EOR)
      CALL CPYSTR(INBLK,OUBLK,0,0)
      CALL CLOSE (OFILE,CLSRW)
      CALL CLOSE(IFILE,CLSRW)
      GO TO 70
C
C THIS IS NOT THE FIRST PASS
C
   30 JFILE = OFILE
      CALL FWDREC(*9020,OFILE)
      NRECS = PLACNT - 2
      IF (NRECS .LE. 0) GO TO 50
      DO 40 I = 1,NRECS
   40 CALL FWDREC(*9020,OFILE)
   50 MCB(1) = OFILE
      CALL RDTRL (MCB)
      MCB(6) = 0
      MCB(7) = 0
      IF (LEFT .LT. MCB(3)) CALL MESAGE (-8,0,NAME)
      IUNPKB = 1
      IUNPK  = 1
      JUNPK  = MCB(3)
      INCUPK = 1
      CALL UNPACK(*9030,OFILE,Z)
      CALL CLOSE (OFILE,CLSNRW)
      CALL OPEN(*9010,OFILE,Z(BUFFR2),OUTNRW)
C
C READ THE INCREMENTAL VECTOR.  INTPK INITIALIZES AND ZNTPKI RETURNS
C ONE ELEMENT AT A TIME
C
      KTYPE = 1
      CALL INTPK(*9040,IFILE,0,KTYPE,0)
C
C READ AND ADD LOOP.
C
   60 CALL ZNTPKI
      Z(INDEX) = Z(INDEX) + A(1)
      IF (EOL .EQ. 0) GO TO 60
C
C ADDITION HAS BEEN COMPLETED
C
      CALL CLOSE (IFILE,CLSRW)
C
C WRITE VECTOR ON OUTPUT FILE IN PACKED FORMAT.
C
      TYPEA = 1
      TYPEB = 1
      IPACK = 1
      JPACK = MCB(3)
      INCPK = 1
      CALL PACK(Z,OFILE,MCB)
      CALL CLOSE (OFILE,CLSRW)
C
C WRITE TRAILER
C
   70 MCB(1) = OFILE
      CALL WRTTRL (MCB)
   90 ILOOP = ILOOP + 1
      IF (ILOOP .GT. 3) GO TO 200
      IFILE = IFILE + 1
      OFILE = OFILE + 1
      GO TO 10
  100 IF (ILOOP .EQ. 1  .OR.  ILOOP .EQ. 2) CALL MESAGE (-30,127,IFILE)
      GO TO 90
  110 IF (ILOOP .EQ. 1  .OR.  ILOOP .EQ. 2) CALL MESAGE (-30,128,OFILE)
      GO TO 90
C
C INCREMENT THE PLA DMAP LOOP COUNTER
C
  200 PLACNT = PLACNT + 1
      RETURN
C
C FATAL ERRORS
C
 9010 CALL MESAGE (-1,JFILE,NAME)
 9020 CALL MESAGE (-2,JFILE,NAME)
 9030 CALL MESAGE (-30,129,ILOOP+200)
 9040 CALL MESAGE (-30,130,ILOOP+100)
      RETURN
      END
