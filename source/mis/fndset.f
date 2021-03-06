      SUBROUTINE FNDSET (GPID,X,IBUF,N)
C
C     GPID = GRID POINT TABLE FOR THIS SET
C
C     N  = 0 INPUT
C     FNDSET READS THE COORDINATES OF THE GRID POINTS IN THIS SET.
C     IF THE GRID POINT TABLE VALUE IS ZERO THE CORRESPONDING GRID
C     POINT IS NOT USED IN THIS SET AND ITS VALUES SKIPPED, OTHERWISE
C     THE XYZ COORDINDATE VALUES ARE READ FROM BGPDT AND PACKED INTO
C     X SPACE. TOTALLY THERE ARE NGPSET GRID DATA SAVED IN X.
C     CORE NEEDED FOR X = 3*NGPSET (PROVIDED BY CALLING ROUTINE)
C
C     N  = 1 INPUT/OUTPUT
C     FNDSET POSITIONS THE STRESS FILE TO THE SUBCASE/VALUE LAST
C     PROCESSED
C
      INTEGER         GPID(1),BGPDT,OES1,REW,SUBC
      REAL            X(3,1),U(3)
      COMMON /BLANK / NGP,SKP11(4),NGPSET,SKP12(4),SKP21(4),BGPDT,
     1                SKP22(8),OES1
      COMMON /NAMES / NIREW,INPREW,SKPN1(2),REW,NOREW
      COMMON /XXPARM/ SKPP(211),SUBC,FLAG,DATA
      EQUIVALENCE     (U(1),INSUB)
      DATA    TWOPI / 0.0 /
C
      IF (N .NE. 0) GO TO 30
      CALL GOPEN (BGPDT,GPID(IBUF),INPREW)
      J = 1
      DO 20 I = 1,NGP
      IF (GPID(I) .NE. 0) GO TO 10
      CALL FREAD (BGPDT,0,-4,0)
      GO TO 20
   10 CALL FREAD (BGPDT,0,-1,0)
      CALL FREAD (BGPDT,X(1,J),3,0)
      J = J + 1
   20 CONTINUE
      CALL CLOSE (BGPDT,REW)
      GO TO 110
C
C     POSITION OES1
C
   30 IF (TWOPI .LT. 6.2) TWOPI = 8.0*ATAN(1.0)
      CALL GOPEN (OES1,GPID(IBUF),INPREW)
   40 CALL READ  (*90,*90,OES1,J,1,0,I)
      CALL FREAD (OES1,0,-2,0)
      CALL FREAD (OES1,U,3,0)
      IF (SUBC .NE. INSUB) GO TO 70
      IF (FLAG-1.0) 100,60,50
   50 J = J/10
C
C     REAL EIGENVALUE ANALYSIS - CONVERT TO FREQUENCY
C
      IF (J .EQ. 2) U(3) = SQRT(ABS(U(3)))/TWOPI
      IF (DATA-U(3) .GT. 1.0E-6) GO TO 70
      GO TO 100
   60 IF (DATA-U(2)) 70,100,70
C
C     WRONG CASE
C
   70 CALL FWDREC (*90,OES1)
      CALL FWDREC (*90,OES1)
      GO TO 40
   90 N = N + 1
  100 CALL BCKREC (OES1)
      CALL CLOSE  (OES1,NOREW)
C
  110 RETURN
      END
