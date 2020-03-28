program files; {generalized procedures for reading in and
                     reading out all types of files} {12/27/88}

(* 12/25/88; see program ArrayInFile below for technique of handling arrays
   in files *)

(* This code illustrates and exercises some types of TP files *)

TYPE
    data    =      real;
    type1   =      file of data;

    strings =      string[20];
    type2   =      file of strings;

    DataSet =      record
          name  :     string[20];
          value :     integer;
                   end;
    type3   =      file of DataSet;

    type4   =      text;   {textfile; note that a textfile uniquely
                                      generates ascii characters}

    type5   =      array[1..20,1..2] of real;

VAR
   {type1}
      x              : data;
      DataFile       : type1;
      DataFileSpec   : string[20];

   {type2}
      title          : strings;
      StringFile     : type2;
      StringFileSpec : string[20];

   {type3}
      DataRecord     : DataSet;
      RecordFile     : type3;
      RecordFileSpec : string[20];

   {type4}
      I              : string[255];    {may be integer, real, char, or string}
      TextFile       : type4;
      TextFileSpec   : string[20];

   {type5}
      ArrayFile      : file of type5;
      arrays           : type5;
      j,k,n          : integer;
      ArrayFileSpec  : string[20];



      NoColumns,MaxRows : integer;
      StartFlag,
      m                 : integer;
      ch                : char;
      menu              : char;


(******  READ IN PROCEDURES ********)

PROCEDURE ReadInDataFile;

begin
     clrscr;
     writeln('Enter filespec for DataFile');
     readln(DataFileSpec);
     assign(DataFile, DataFileSpec);
     rewrite(DataFile);
     NoColumns:=1;
     writeln;
     writeln('If data in form of array, enter the number of columns for data structure');
     writeln('   The default value is 1');
     readln(NoColumns);
     writeln('Enter the max number of rows of data');
     readln(MaxRows);
     for n:=1 to MaxRows do begin
       for m:=1 to NoColumns do begin
         writeln('Enter value of x[',n,',',m,']');
         readln(x);
         write(DataFile,x);  {note that 'write', not 'writeln' is used
                              for writing to file of reals}
       end;
     end;
     close(DataFile);
end;


PROCEDURE ReadInStringFile;
begin
     clrscr;
     writeln('Enter filespec for StringFile');
     readln(StringFileSpec);
     assign(StringFile,StringFileSpec);
     rewrite(StringFile);
     writeln;
     writeln('Enter the max number of rows of data');
     readln(MaxRows);
     for n:=1 to MaxRows do begin
         writeln('Enter title[',n,']');
         readln(title);
         write(StringFile,title);
     end;
     close(StringFile);
end;

PROCEDURE ReadInRecordFile;
begin
     clrscr;
     writeln('Enter filespec for RecordFile');
     readln(RecordFileSpec);
     assign(RecordFile,RecordFileSpec);
     rewrite(RecordFile);
     writeln;
     writeln('Enter the max number of rows of data');
     readln(MaxRows);
     with DataRecord do begin
          for n:=1 to MaxRows do begin
              writeln('Enter caption[',n,']');
              readln(name);
              writeln('Enter value of caption[',n,']');
              readln(value);
              write(RecordFile,DataRecord);
          end;
     end;
end;

PROCEDURE ReadInTextFile;
begin
     clrscr;
     writeln('Enter filespec for TextFile');
     readln(TextFileSpec);
     assign(TextFile,TextFileSpec);
     rewrite(TextFile);
     writeln;
     writeln('Enter the max number of rows of data');
     readln(MaxRows);
     for n:=1 to MaxRows do begin
         writeln('Enter input[',n,']');
         readln(I);
         writeln(TextFile,I);   {note that 'writeln', not 'write' used
                                 for writing file of text}
     end;
     close(TextFile);
end;

procedure ReadInArrayFile;
begin
     clrscr;
     writeln('Enter filespec for ArrayFile');
     readln(ArrayFileSpec);
     assign(ArrayFile,ArrayFileSpec);
     writeln('Enter max no of rows in array');
     readln(MaxRows);
     rewrite(ArrayFile);
     for j:=1 to MaxRows do begin
         write('Enter data[',j,', 1]  ');
         readln(arrays[j,1]);
         write('Enter data[',j,', 2]  ');
         readln(arrays[j,2]);
         write(ArrayFile,arrays);
     end;
     close(ArrayFile);
end;

(******  READ OUT PROCEDURES ********)

PROCEDURE ReadOutDataFile;

begin
     clrscr;
     writeln('Enter filespec for read out of DataFile');
     readln(DataFileSpec);
     assign(DataFile, DataFileSpec);
     {$I-}reset(DataFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
     n:=Filesize(DataFile);
     writeln('Size of data file is ',n,' entries');
     writeln;
     writeln('If data in form of array, enter the number of columns for data structure');
     writeln('   The default value is 1');
     readln(NoColumns);
     MaxRows:=round(n/NoColumns);
     ch:=' ';
     n:=0;
     writeln('If you wish to display data, enter "d"');
     read(kbd,ch);
     clrscr;
     writeln('          ',DataFileSpec);  {heading for data}
     writeln;
     while not eof(DataFile) and (n < MaxRows) do begin
           n:=n + 1;
           for m:= 1 to NoColumns do begin
                 read(DataFile,x);   {note that 'read', not 'readln' used
                                      for reading file of reals}
                 if ch = 'd' then writeln('x[',n,',',m,'] = ',x);
           end;
     end;
     close(DataFile);
end;

PROCEDURE ReadOutStringFile;
begin
     clrscr;
     writeln('Enter filespec for read out of StringFile');
     readln(StringFileSpec);
     assign(StringFile,StringFileSpec);
     {$I-}reset(StringFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
     n:=Filesize(StringFile);
     writeln('Size of string file is ',n,' entries');
     ch:=' ';
     n:=0;
     writeln('If you wish to display data, enter "d"');
     read(kbd,ch);
     clrscr;
     writeln('                    ',StringFileSpec);  {heading for data}
     while not eof(StringFile) do begin
                 n:= n + 1;
                 read(StringFile,title);
                 if ch = 'd' then writeln(n,' ',title);
     end;
     close(StringFile);
end;

PROCEDURE ReadOutRecordFile;
begin
     clrscr;
     writeln('Enter filespec for read out of RecordFile');
     readln(RecordFileSpec);
     assign(RecordFile,RecordFileSpec);
     {$I-}reset(RecordFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
     n:=Filesize(RecordFile);
     writeln('Size of record file is ',n,' entries');
     ch:=' ';
     writeln('If you wish to display data, enter "d"');
     read(kbd,ch);
     clrscr;
     writeln('          ',RecordFileSpec);  {heading for data}
     writeln;writeln;
     n:=0;
     while not eof(RecordFile) do begin
           read(RecordFile,DataRecord);
           with DataRecord do begin
                n:=n + 1;
                if ch = 'd' then begin
                   writeln('Name [',n,'] = ',DataRecord.name);
                   writeln('Value[',n,'] = ',DataRecord.value);
                   writeln;
                end;
           end;
     end;
     close(RecordFile);
end;

PROCEDURE ReadOutTextFile;
begin
     clrscr;
     writeln('Enter filespec for TextFile');
     readln(TextFileSpec);
     assign(TextFile,TextFileSpec);
     {$I-}reset(TextFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
     ch:=' ';
     n:=0;
     writeln('If you wish to display data, enter "d"');
     read(kbd,ch);
     clrscr;
     writeln('                    ',TextFileSpec);  {heading for data}
     while not eof(TextFile) do begin
                 n:= n + 1;
                 readln(TextFile,I);  {note that 'readln', not 'read', used
                                       for reading file of text}
                 if ch = 'd' then writeln('I[',n,'] = ',I);
     end;
     close(TextFile);
end;

procedure ReadOutArrayFile;
begin
     clrscr;
     writeln('Enter filespec for read out of ArrayFile');
     readln(ArrayFileSpec);
     assign(ArrayFile,ArrayFileSpec);
     j:=1;
     {$I-}reset(ArrayFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
     writeln('           X                          Y');
     writeln;
     while not eof(ArrayFile) do begin
           read(ArrayFile,arrays);
           writeln(arrays[j,1],'   ',arrays[j,2]);
           j:=j + 1;
     end;
     close(ArrayFile);
end;


begin     {MAIN PROGRAM}
     clrscr;
     ch:= ' ';

     StartFlag:=0;
     if StartFlag = 0 then begin
        writeln('This code was written by Ellis Katz (818) 783-0778 to illustrate the');
        writeln('use of and various types of TP files which are genrally of use in');
        writeln('engineering appications....1-23-88');
        writeln;
        writeln('The code will allow you to enter or read data (reals, strings, text, records,');
        writeln('or arrays) from files.  Since you may want to see the data in structured');
        writeln('display, you will be prompted to enter the number of columns and rows');
        writeln('for the data to be displayed...this is strictly an artifice for the');
        writeln('convenience of the user. The default for the number of columns is "1"');
        writeln;
        writeln('Press any key to continue');
        repeat until keypressed;
     end;
     repeat
           clrscr;
           writeln('Select from following options: ');
           writeln('    1 : Enter data into a data file');
           writeln('    2 : Enter strings into a string file');
           writeln('    3 : Enter captions and data into a record file');
           writeln('    4 : Enter data into a text file');
           writeln('          A text file may be made up of real, integer, char, or');
           writeln('          string data');
           writeln('    5 : Enter data into an array (of reals) file');
           writeln('    6 : Read out data from a data file');
           writeln('    7 : Read out strings from a string file');
           writeln('    8 : Read out captions and data from a record file');
           writeln('    9 : Read out data from a text file');
           writeln('    0 : Read out an array from an array file');
           writeln;
           writeln('    q : Quit code');
           StartFlag:=1;
           read(kbd,menu);
           case menu of
               '1' :  ReadInDataFile;
               '2' :  ReadInStringFile;
               '3' :  ReadInRecordFile;
               '4' :  ReadInTextFile;
               '5' :  ReadInArrayFile;
               '6' :  ReadOutDataFile;
               '7' :  ReadOutStringFile;
               '8' :  ReadOutRecordFile;
               '9' :  ReadOutTextFile;
               '0' :  ReadOutArrayFile;
          end;
          writeln;
          writeln('Press any key to continue');
          repeat until keypressed;
     until menu = 'q';
end.

**
