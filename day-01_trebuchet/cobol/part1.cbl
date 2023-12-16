       IDENTIFICATION DIVISION.
       PROGRAM-ID. AOC-DAY1-PART1.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PC.
       OBJECT-COMPUTER. IBM-PC.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT INPUTFILE ASSIGN TO '../input.txt'
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS IS SEQUENTIAL
               FILE STATUS IS FS.

       DATA DIVISION.

       FILE SECTION.
       FD INPUTFILE.
       01 INPUT-FILE.
           05 INPUT-LINE PIC X(100).

       WORKING-STORAGE SECTION.
       77 FS PIC X(2).
       77 NUMBER-FIND-STATUS PIC x.
           88 FOUND-NUMBER     VALUE "Y".
           88 NOT-FOUND-NUMBER VALUE "N".

       01 RUNNING-SUM PIC 9(8).
       01 DISPLAY-SUM PIC z(8).
       01 LAST-SUM PIC 9(8).
       01 TEMP-NUM PIC 99.

       01 INSPECT-IDX PIC 9(3).

       01 LINE-VALUE.
           05 FIRST-LINE-VALUE PIC 9.
           05 SECOND-LINE-VALUE PIC 9.
       01 LINE-VALUE-NUM PIC 99.

       01 DISP-LINE PIC X(50).

       PROCEDURE DIVISION.
           OPEN INPUT INPUTFILE.
           READ INPUTFILE.
           PERFORM UNTIL FS IS GREATER THAN ZERO
               PERFORM FIND-NUMBERS
               MOVE RUNNING-SUM TO LAST-SUM
               MOVE LINE-VALUE TO LINE-VALUE-NUM
               ADD LINE-VALUE-NUM TO RUNNING-SUM

               READ INPUTFILE
           END-PERFORM.
           MOVE RUNNING-SUM TO DISPLAY-SUM.
           DISPLAY DISPLAY-SUM.

           CLOSE INPUTFILE.
           STOP RUN.

       FIND-NUMBERS.

           MOVE "N" TO NUMBER-FIND-STATUS.
           MOVE 0 TO LINE-VALUE.
           PERFORM VARYING INSPECT-IDX FROM 1 BY 1
               UNTIL INSPECT-IDX >= 100
               OR INPUT-LINE(INSPECT-IDX:1) = " "

               EVALUATE INPUT-LINE(INSPECT-IDX:1)
                   WHEN "0" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "1" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "2" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "3" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "4" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "5" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "6" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "7" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "8" MOVE "Y" TO NUMBER-FIND-STATUS
                   WHEN "9" MOVE "Y" TO NUMBER-FIND-STATUS
               END-EVALUATE

               IF FOUND-NUMBER
                   MOVE INPUT-LINE(INSPECT-IDX:1)
                       TO SECOND-LINE-VALUE

                   IF FIRST-LINE-VALUE = 0
                       MOVE INPUT-LINE(INSPECT-IDX:1)
                           TO FIRST-LINE-VALUE
                   END-IF
               END-IF
               MOVE "N" TO NUMBER-FIND-STATUS
           END-PERFORM.

