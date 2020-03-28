program  FAMILY;  {03-10-90}
                  {04-25-90; revised to include Sort}
                  {05-16=90; improved format and remarks proced}
                  {07-12-90; adapted Remarks.Pas into code}
                  {07-17-90; improved print format}

(* This code enables the tracking of family genealogy *)

type
    Remarks = array[1..400] of char;
    DataSet = record
            Name,
            Father,
            Mother,
            BirthDate,
            DeceasedDate,
            Profession,
            BirthPlace    : string[30];
            Sex,
            Deceased      : char;
            NoOfWives,
            NoOfHusbands,
            NoOfSons,
            NoOfDaughters : integer;
            NoChar        : integer;
            Husband,
            Wife,
            Son,
            Daughter      : array[1..5] of string[30];
            Lines         : Remarks;
    end;

    Matrix = array[1..50,1..2] of string[20];

var
    i,j,k,
    Sequence,
    LastEntry,
    a,b,n,nn,x,y,m,
    InitialY,
    LineNo,
    CharactersOnLine,
    Place,
    FirstLine,
    LastLine,
    NoOfRecords        : integer;
    DataFile,
    DummyRecFile,
    DiscardFile,
    DummyFile          : file of DataSet;
    TitleFile,
    DummyTitleFile,
    MatrixFile,
    DummyMatrixFile    : file of string[20];
    ReviseString       : string[80];
    NumberFile         : file of integer;
    period             : array[1..150] of integer;
    DataRecord         : DataSet;
    ErasedAccnt,
    NameSearch,
    ShortenedName,
    date               : string[20];
    ReviseFlag,
    RepeatFlag,
    SearchFlag,
    EraseFlag,
    SortFlag,
    TitleFlag,
    result,
    EarliestPeriod,
    StringPos, digits  : integer;
    ca,cb,ch,cr,cs,
    Select             : char;
    FileSpec           : string[20];
    CompressPrint      : string[20];
    c,d,e,f,g,h        : integer;   {used for randomizing name data}
    NameFlag           : integer;
    code               : string[8];
    FileName           : string[20];
    DummyName          : string[20];
    TitleName          : string[20];

procedure WordWrap;
begin
     with DataRecord do begin
          clrscr;
          writeln;
          if ReviseFlag = 0 then begin
             writeln;
             writeln('Enter Remarks [limit: 5 lines]; hit Enter when done. ');
             for n:=1 to 400 do Lines[n] := ' ';
          end
          else begin
             writeln;
             writeln('Enter revised remarks; limit 5 lines; hit Enter when done.');
             writeln('  Note: You may cancel rewrite action with Ctrl-Brk');
             writeln;
          end;
          y:=WhereY;          {vertical position of ine on pg}
          InitialY:=y;
          NoChar:=0;
          n:=1;           {total no characters}
          m:=0;           {no characters on line}
          repeat          {for new line until remarks complete}
                ch:=' ';
                x:=0;     {initialize positions of characters on line}
                repeat    {for each character until next line}
                      read(kbd,ch);

                      if ch <> #8 then begin    {#8 is backspace}
                          x:=x + 1;
                          gotoxy(x,y);
                          Lines[n]:=ch;
                          write(Lines[n]);
                          m:=m + 1;
                          n:=n + 1;
                          NoChar:=NoChar + 1;  {remember total no characters
                                               in Remarks}
                      end;

                      if ch = #8 then begin      {backspace routines}
                         n:=n - 1;
                         NoChar:=NoChar - 1;

                         if x = 1 then begin    {move up one line}
                            gotoxy(x,y);
                            write(' ');
                            y:=y - 1;
                            x:=CharactersOnLine;
                            m:=CharactersOnLine;
                            gotoxy(x,y);
                         end

                         else begin
                            gotoxy(x,y);
                            write(' ');
                            m:=m - 1;
                            x:=x - 1;
                         end;

                      end;

                      if (y = InitialY + 4) and (m = 60)  then begin
                         write(^G);   {sound bell}
                         gotoxy(1,24);write('Only 20 characters left for message');
                      end;
                until ((m > 70) and (ch = #32)) or (ch = #13)
                      or (m = 80);      {#32 is space; #13 is enter}

                if m < 80 then CharactersOnLine:=m + 1;
                NoChar:=NoChar + 1;
                y:=y + 1;   {drop down one line}
                m:=0;
          until (ch = #13) or (y = InitialY + 5);
          NoChar:=NoChar - 1;   {but deduct 1 for Enter character}
          writeln;
          writeln;
          writeln('Remarks complete');
     end;
end;

procedure InputData;

label Start;
label Stop;

begin
      if ReviseFlag = 1 then GoTo Start;
      repeat
Start:
        with DataRecord do begin
            NoOfWives:=0;          {default values}
            NoOfHusbands:=0;
            NoOfSons:=0;
            NoOfDaughters:=0;
            writeln;
            writeln('Record #',i + 1,' for ',FileName);
            writeln;
            write('Enter Name                        :  '); readln(Name);
            if Name = '' then begin
               writeln('You cannot enter blank record');
               writeln;
               writeln('You may repeat inputing or enter "q" to quit inputs');
               n:=n - 1;
               read(kbd,ch);
               If (ch = 'q') or (ch = 'Q') then GoTo Stop
               else GoTo Start;
            end;
            write('Enter sex, m or f                 :  '); readln(Sex);
            if Sex <> 'm' then begin
               if Sex <> 'f' then begin
                  writeln('You must enter "m" or "f"; please repeat entry');
                  write('Enter sex, m or f                 :  '); readln(Sex);
               end;
            end;
            write('Enter Birth Date [mm/dd/yyyy]     :  '); readln(BirthDate);
            if (SortFlag = 0) and (length(BirthDate) <> 10) then begin
               writeln;
               writeln('You have not used the form, mm/dd/yyyy; this is acceptable,');
               writeln('  however, you will not be able to sort your records by birthdate');
               writeln('  using the "sort" option.  If you wish to sort by birthdate');
               writeln('  then enter revised birthdate below.  If you dont care to sort');
               writeln('  then simply his the enter key when asked for revised birthdate');
               write('Enter Birth Date [mm/dd/yyyy]     :  '); readln(BirthDate);
               if length(Birthdate) <> 10 then SortFlag:=1 else SortFlag:=0;
               writeln;
            end;
            ch:=' ';
            write('Deceased ?; y or n                :  '); readln(Deceased);
            if Deceased = 'y' then begin
               write('Enter Death [mm/dd/yyyy]          :  '); readln(DeceasedDate);
            end;
            write('Enter Profession/Vocation         :  '); readln(Profession);
            write('Enter Birth Place                 :  '); readln(BirthPlace);
            write('Enter Father                      :  '); readln(Father);
            write('Enter Mother                      :  '); readln(Mother);
            writeln;
            if DataRecord.Sex = 'm' then begin
               n:=0;
               write('Enter no. Wives [0 default]       :  '); {$I-} readln(NoOfWives) {$I+};
               if IOresult <> 0 then begin
                  writeln('    You must enter integer number');
                  write('Enter no. Wives [0 default]       :  '); readln(NoOfWives);
               end;
               writeln;
               for n:=1 to NoOfWives do begin
                  write('Enter Wife [',n,'] & anniv date   :  '); readln(Wife[n]);
               end;
            end
            else begin
               n:=0;
               write('Enter no. Husbands [0 default]    :  '); {$I-} readln(NoOfHusbands) {$I+};
               if IOresult <> 0 then begin
                  writeln('    You must enter integer number');
                  write('Enter no. Husbands [0 default]    :  '); readln(NoOfHusbands);
               end;
               writeln;
               for n:=1 to NoOfHusbands do begin
                  write('Enter Husband [',n,'] & anniv date:  '); readln(Husband[n]);
               end;
            end;
            writeln;
            n:=0;
            write('Enter no. Sons [0 default]        :  '); {$I-} readln(NoOfSons) {$I+};
            if IOresult <> 0 then begin
               writeln('    You must enter integer number');
               write('Enter no. Sons [0 default]        :  '); {$I-} readln(NoOfSons) {$I+};
            end;
            writeln;
            for n:=1 to NoOfSons do begin
               write('Enter Son [',n,']                 :  ');
               readln(Son[n]);
            end;
            writeln;
            n:=0;
            write('Enter no. Daughters [0 default]   :  '); {$I-} readln(NoOfDaughters) {$I+};
            if IOresult <> 0 then begin
               writeln('    You must enter integer number');
               write('Enter no. Daughters [0 default]   :  '); {$I-} readln(NoOfDaughters) {$I+};
            end;
            writeln;
            for n:=1 to NoOfDaughters do begin
               write('Enter Daughter [',n,']            :  ');
               readln(Daughter[n]);
            end;
            WordWrap;
            ch:=' ';
            write(DataFile,DataRecord);
            i:=i + 1;
        end;
        writeln;
        if ReviseFlag = 1 then begin  {i.e., revise one record at time}
           ch:='q';
           GoTo Stop;
        end;
        writeln;
        writeln('press SpaceBar to continue -- or  "q" to quit file inputs');
        read(kbd,ch);
        clrscr;
      until (ch = 'q') or (ch = 'Q');
Stop:
      close(DataFile);
      ch:=' ';
      ReviseFlag:=0;
end;

procedure InputFile;  (* initial input to a file of records *)
begin
      rewrite(DataFile);
      writeln('Information for Family: ',FileName);
      writeln;
      i:=0;
      InputData;
end;

procedure WriteRemarks;
begin
     with DataRecord do begin
          writeln;
          y:=WhereY;
          if ReviseFlag = 0 then begin
             gotoxy(1,y);writeln('Remarks: ');
          end;
          x:=1;
          y:=y + 2;
          FirstLine:=y;
          for n:=1 to NoChar do begin
              gotoxy(x,y);
              write(Lines[n]);
              if ((x > 70) and (Lines[n] = #32)) or (x = 80) then begin
                      x:=1;
                      y:=y + 1;
              end
              else x:=x + 1;
          end;
     end;
     LastLine:=y;
end;

procedure WriteData;
begin
     With DataRecord do begin
          writeln('Record  #',i);
          writeln;
          writeln('Name                 :  ',Name);
          writeln('Birth Date           :  ',BirthDate);
          writeln('Deceased ?; y or n   :  ',Deceased);
          if Deceased = 'y' then begin
             writeln('Died                 :  ',DeceasedDate);
          end;
          writeln('Profession/Vocation  :  ',Profession);
          writeln('Birth Place          :  ',BirthPlace);
          writeln('Father               :  ',Father);
          writeln('Mother               :  ',Mother);
          if Sex = 'm' then begin
             for n:=1 to NoOfWives do
                writeln('Wife [',n,']             :  ',Wife[n]);
          end
          else begin
               for n:=1 to NoOfHusbands do
                 writeln('Husband [',n,']          :  ',Husband[n]);
          end;
          for n:=1 to NoOfSons do begin
              writeln('Son [',n,']              :  ',Son[n]);
          end;
          for n:=1 to NoOfDaughters do begin
              writeln('Daughter [',n,']         :  ',Daughter[n]);
          end;
          WriteRemarks;
     end;
     if ReviseFlag <> 1 then begin
          cs:=' ';
          gotoxy(1,LastLine + 2);
          writeln('Enter "s" to search a name; "q" to quit file; any other key to continue');
          read(kbd,cs);
     end;
     writeln;
end;

procedure Search;
begin
     repeat
           clrscr;
           SearchFlag:=0;
           cs:=' ';
           ch:=' ';
           writeln;
           writeln('Enter a name to search on:   ');
           writeln('      You may enter the first several characters of the full name');
           writeln('      or the full name, but whichever you choose must be capatilized');
           writeln('      as originally entered into the data base.');
           writeln;
           writeln('Or you may quit search by hiting Enter');
           writeln;
           write('Name:    ');
           readln(NameSearch);
           clrscr;
           if Namesearch = '' then begin
               ch:='q';
           end
           else begin
               a:=length(NameSearch);  {search only for beginning of string}
               writeln;
               reset(DataFile);
               While not eof(DataFile) do begin
                     read(DataFile,DataRecord);
                     ShortenedName:=copy(DataRecord.Name,1,a);
                     if ShortenedName =  NameSearch then begin
                        i:=FilePos(DataFile);
                        SearchFlag:=1;    {found name}
                        WriteData;
                     end;
               end;
               if SearchFlag = 0 then begin
                  writeln('Sorry, no Family named: ',NameSearch,' found');
                  writeln;
                  writeln('Enter "q" to quit search or SpaceBar to continue search');
                  read(kbd,ch);
                  clrscr;
               end;
           end;
      until ch = 'q';
      ch:=' ';
end;

procedure ReadFile; (* reads a file of records *)
begin
      clrscr;
      reset(DataFile);
      NoOfRecords := filesize(DataFile);
      if NoOfRecords = 0 then begin
            clrscr;
            writeln('There are no entries in this file; begin again');
            erase(DataFile);
            halt;
      end;
      if SortFlag <> 1 then begin
         writeln('Information for Family: ',FileName,'; Number of Records = ',NoOfRecords);
         writeln;
         writeln('Press any key to continue');
         repeat until keypressed;
      end;
      while not eof(DataFile) do begin
            clrscr;
            read(DataFile,DataRecord);
            i:=FilePos(DataFile);
            if SortFlag <> 1 then begin
               WriteData;
               if cs = 's' then Search;
               if cs = 'q' then seek(DataFile,FileSize(DataFile));
            end;
      end;
      close(DataFile);
end;

procedure SeekRecord;
begin
      seek(DataFile,i-1);
      read(DataFile,DataRecord);
      date := copy(DataRecord.BirthDate,StringPos,digits);
      val(date, period[i], result);
end;

procedure Sort;
begin
      SortFlag:=1;
      ReadFile;
      clrscr;
      assign(DummyFile,'dummy.dat');
      assign(DiscardFile,'discard.dat');
      rewrite(DiscardFile);
      rewrite(DummyFile);
      reset(DataFile);
      n:=FileSize(DataFile);

(*
      DataFile contains original input records; DiscardFile collects records
        corresponding to earliest period bithrdates and is eventually converted
        into a new DataFile with records in order of early dates first; late
        dates last; DummyFile loses the earliest period record each pass and
        eventually has no records remaining when procedure is complete
*)
      repeat
            EarliestPeriod:=2000;
            StringPos:=7;
            digits:=4;
            reset(DummyFile);
            reset(DiscardFile);
            for i:=1 to n do begin     {firt, determine earliest period}
                 gotoxy(36,13);writeln('SORTING');
                 SeekRecord;
                 if period[i] < EarliestPeriod then EarliestPeriod := period[i];
            end;
            rewrite(DummyFile);
            for i:=1 to n do begin       {second, write earliest yr record
                                                        to DiscardFile}
                 SeekRecord;
                 if period[i] = EarliestPeriod then begin
                    writeln('period ',period[i]);
                    seek(DiscardFile,FileSize(DiscardFile));
                    write(DiscardFile,DataRecord);
                 end
                 else begin
                    seek(DummyFile, FileSize(DummyFile));
                    write(DummyFile,DataRecord);
                 end;
            end;
            rewrite(DataFile);
            reset(DummyFile);
            while not eof(DummyFile) do begin
                 read(DummyFile,DataRecord);
                 write(DataFile,DataRecord);
            end;
            n:=FileSize(DataFile);
      until FileSize(DummyFile) = 0;
      reset(DataFile);
      reset(DiscardFile);
      while not eof(DiscardFile) do begin
         read(DiscardFile,DataRecord);
         write(DataFile,DataRecord);
      end;
      close(DataFile);
      close(DummyFile);
      close(DiscardFile);
      SortFlag:=0;
end;

procedure EraseTitle;
begin
      assign(DummyTitleFile, 'Dummy.txt');
      rewrite(DummyTitleFile);
      {$I-}reset(TitleFile){$I+};
      a:=FileSize(TitleFile);
      while not eof(TitleFile) do begin
            read(TitleFile,FileName);
            if (FileName <> ErasedAccnt) then write(DummyTitleFile,FileName);
      end;
      close(DummyTitleFile);
      flush(TitleFile);
      rewrite(TitleFile);
      reset(DummyTitleFile);
      b:=FileSize(DummyTitleFile);
      if (b <> a - 1) and (NameFlag = 1) then begin
            writeln('You have not entered identical character case for family name');
            writeln('Press any key to continue');
            repeat until keypressed;
      end;
      while not eof(DummyTitleFile) do begin
            read(DummyTitleFile,FileName);
            write(TitleFile,FileName);
      end;
      close(DummyTitleFile);
      close(TitleFile);
end;

procedure EraseMatrixData;
begin
      reset(MatrixFile);
      assign(DummyMatrixFile,'Matrix.txt');
      rewrite(DummyMatrixFile);
      {$I-}reset(MatrixFile){$I+};
      a:=FileSize(MatrixFile);
      while not eof(MatrixFile) do begin
            read(MatrixFile,FileName,FileSpec);
            if (FileName <> ErasedAccnt) then write(DummyMatrixFile,FileName,FileSpec);
      end;
      close(DummyMatrixFile);
      flush(MatrixFile);
      rewrite(MatrixFile);
      reset(DummyMatrixFile);
      b:=FileSize(DummyMatrixFile);
      if (b <> a - 2) and (NameFlag = 1) then begin
            writeln('You have not entered identical character case for family name');
            writeln('Press any key to continue');
            repeat until keypressed;
      end;
      while not eof(DummyMatrixFile) do begin
            read(DummyMatrixFile,FileName,FileSpec);
            write(MatrixFile,FileName,FileSpec);
      end;
      close(DummyMatrixFile);
      close(MatrixFile);
end;

procedure EraseFile;
begin
      writeln;
      writeln('Are you sure you want to erase the existing file for ',FileName,' ?');
      TextColor(15 + blink);
      writeln;
      writeln('   y or SpaceBar');
      TextColor(15);
      read(kbd,ch);
      if (ch = 'y') or (ch = 'Y') then begin
            clrscr;
            ErasedAccnt:=FileName;
            EraseTitle;
            EraseMatrixData;
            {$I-} erase(DataFile) {$I+};
            if IOresult = 1 then begin
               writeln('Data File does not exist. Start over');
               halt;
            end;
            EraseFlag:=1;
            close(DataFile);
            clrscr;
      end;
end;

procedure AppendRecord;
begin
      reset(DataFile);
      seek(DataFile,FileSize(DataFile));
      n := filesize(DataFile);
      i:=n;      {"n" is filesize, beginning with "0"}
      InputData;
end;

procedure ClearLines;
begin
     gotoxy(1,21);clreol;
     gotoxy(1,22);clreol;
     gotoxy(1,23);clreol;
     gotoxy(1,24);clreol;
     gotoxy(1,25);clreol;
end;

procedure ArrowKeys;
begin
     ClearLines;
     n:=0;
     x:=0;
     y:=FirstLine;
     gotoxy(x,y);
     LineNo:=0;
     ca:=' ';
     cb:=' ';
     gotoxy(1,22);
     if cr = 'd' then write('Use arrow or/and tab keys to move to right of character to be deleted.');
     if cr = 'i' then write('Use arrow or/and tab keys to move to left of character where insert to be made.');
     if cr = 'c' then write('Use arrow or/and tab keys to move to character to be changed.');
     gotoxy(1,23);write('To revise lower lines you must cursor to last character on line ');
     gotoxy(1,24);write('   then prss down key.  Hit Enter when at desired character');
     repeat
         gotoxy(x,y);
         read(kbd,ca);
         if (ca <> #13) and (ca <> #9) then read(kbd,cb);   {#13 is Enter key}
         if (ca = #27) and (cb=#77) then begin   {rt arrow}
            x:=x + 1;
            n:=n + 1;
         end;
         if (ca = #9) and (x < 70) then begin    {allow faster movement through line}
            x:=x + 10;
            n:=n + 10;
         end;
         if (ca = #27) and (cb=#75) then begin   {lf arrow}
            x:=x - 1;
            n:=n - 1;
         end;
         if (ca = #27) and (cb=#80) then begin   {dn arrow}
            y:=y + 1;
            LineNo:=LineNo + 1;
            x:=1;
            n:=n + 2     {allow for space character}
         end;
         if x < 0 then begin
            x:=1;
            n:=n + 2;
            LineNo:=LineNo + 1;
            m:=m - 1;
         end;
     until ca = #13;
end;

procedure Delete;
begin
     ArrowKeys;
     ClearLines;
     ReviseString:=' ';
     gotoxy(1,22);write('Deleting character(s) to left of cursor');
     gotoxy(1,23);write('Hit Enter key to quit');
     Place:=n;
     nn:=1;
     repeat
           with DataRecord do begin
                seek(DataFile,i-1);
                ch:=' ';
                gotoxy(1,24);write('Hit "d" to delete  ');
                read(kbd,ch);
                if ch = #100 then begin      {#100 = "d"}
                   write('No deletions = ',nn);
                   for n:=(Place - nn) to NoChar do lines[n]:=lines[n + 1];
                   lines[NoChar]:=' ';
                   NoChar:=NoChar - 1;
                   write(DataFile,DataRecord);
                end;
            end;
            nn:=nn + 1;  {create additional deletion for each pass}
     until ch = #13;
     gotoxy(1,FirstLine - 3);
     clreol;
end;

procedure Insert;
begin
     ArrowKeys;
     ClearLines;
     ReviseString:=' ';
     gotoxy(1,22);write('Inserting character(s) to right of cursor');
     gotoxy(1,23);write('Hit Enter key to quit');
     Place:=n;
     nn:=1;    {keep track of no of inserts}
     repeat
           with DataRecord do begin
                seek(DataFile,i-1);
                ch:=' ';
                gotoxy(1,24);write('Enter insert character(s)  :  ');
                read(kbd,ch);
                if ch <> #13 then begin
                   NoChar:=NoChar + 1;
                   for n:=NoChar downto (Place + nn) do lines[n]:=lines[n - 1];
                   ReviseString:=ReviseString + ch;
                   write(ReviseString);
                   lines[Place + nn]:=ch;
                   write(DataFile,DataRecord);
                end;
            end;
            nn:=nn + 1;  {create additional insert for each pass}
     until ch = #13;
     gotoxy(1,FirstLine - 3);
end;

procedure OverWrite;     {this is over-write routine}
begin
     ArrowKeys;
     ClearLines;
     ReviseString:=' ';
     gotoxy(1,22);write('Changing character(s)');
     gotoxy(1,23);write('Hit End key to quit');
     nn:=n;
     repeat
           ch:=' ';
           gotoxy(1,24);write('Enter the altered character(s) :   ');
           read(kbd,ch);
           if ch <> #27 then begin
              ReviseString:=ReviseString + ch;
              write(ReviseString);
           end;
           with DataRecord do begin
             seek(DataFile,i-1);
             if ch <> #13 then lines[nn]:=ch;
             write(DataFile,DataRecord);
           end;
           nn:=nn + 1;
      until ch = #13;
      gotoxy(1,FirstLine - 3);
end;

procedure EraseRemarks;
begin
     with DataRecord do for n:=1 to 400 do Lines[n] := ' ';
     WordWrap;
end;


procedure ReviseRemarks;
begin
      repeat
            clrscr;
            WriteRemarks;
            ch:=' ';
            cr:=' ';
            gotoxy(1,21);write('Enter "d" to delete character(s)');
            gotoxy(1,22);write('Enter "i" to insert character(s)');
            gotoxy(1,23);write('Enter "c" to change character(s)');
            gotoxy(1,24);write('Enter "x" to erase & retype remarks');
            gotoxy(1,25);write('Enter "q" to quit revising text');
            read(kbd,cr);
            if cr = 'd' then Delete;
            if cr = 'i' then Insert;
            if cr = 'c' then OverWrite;
            if cr = 'x' then EraseRemarks;
            ch:=' ';
            ClearLines;
            clrscr;
      until cr ='q';
      RepeatFlag:=0;
      clrscr;
end;

procedure IntegerLimit;
begin
     repeat
           n:=0;
           {$I-}readln(n) {$I+};
           if IOresult <> 0 then begin  {if n not integer}
              write('You must enter integer no  :  ');
              readln(n);
           end;
     until IOresult = 0;
end;

procedure ReviseRecord;
begin
      ReviseFlag:=1;
      RepeatFlag:=0;
      repeat
            ch:=' ';
            reset(DataFile);
            seek(DataFile,FileSize(DataFile));
            NoOfRecords := filesize(DataFile);
            if RepeatFlag <> 1 then begin
               writeln('Last record revised was # ',i);
               write('Input record # to be revised:  ');
               readln(i);
               if (i > NoOfRecords) or (i < 1) or (i > 1E3) then begin
                  writeln('Record # ',i,' does not exist for this file');
                  writeln('Program halted; begin again');
                  halt;
               end;
               seek(DataFile,i - 1);       {adjust for beginning of file = "0"}
               read(DataFile,DataRecord);
               clrscr;
            end;
            WriteData;
            Select:=' ';
            writeln;
            if WhereY > 18 then begin
               writeln('Press any key to read Revision menu');
               repeat until keypressed;
            end;
            writeln('Enter following characters to revise record');
            writeln;
            writeln('"n" : Name;       "f" : Father;     "m" : Mother;     "b" : Birth Date');
            writeln('"p" : Birth Place "w" : Wife(s);    "h" : Husband(s); "s" : Son(s) ');
            writeln('"d" : Daughters;  "r" : Remarks;    "v" ; Profession; "x" : Deceased ?');
            writeln('"y" : Death Date; "q" : Quit');
            writeln;
            read(kbd,Select);
            case Select of
                 'n' : begin
                            write('Enter revised Name:   ');
                            readln(DataRecord.Name);
                       end;
                 'f' : begin
                            write('Enter revised Father:   ');
                            readln(DataRecord.Father);
                       end;
                 'm' : begin
                            write('Enter revised Mother:   ');
                            readln(DataRecord.Mother);
                       end;
                 'b' : begin
                            write('Enter revised Birth Date:   ');
                            readln(DataRecord.BirthDate);
                       end;
                 'x' : begin
                            write('If Deceased, enter "y" :   ');
                            readln(DataRecord.Deceased);
                       end;
                 'y' : begin
                            write('Enter Date of Death:   ');
                            readln(DataRecord.DeceasedDate);
                       end;
                 'v' : begin
                            write('Enter revisied Profession/Vocation:   ');
                            readln(DataRecord.Profession);
                       end;
                 'p' : begin
                            write('Enter revised Birth Place:   ');
                            readln(DataRecord.BirthPlace);
                       end;
                 'w' : begin
                            write('Enter Wife No:   ');
                            IntegerLimit;
                            write('Enter revised Wife No[',n,']:   ');
                            readln(DataRecord.Wife[n]);
                       end;
                 'h' : begin
                            write('Enter Husband No:  ');
                            IntegerLimit;
                            write('Enter revised Husband No[',n,']:   ');
                            readln(DataRecord.Husband[n]);
                       end;
                 's' : begin
                            write('Enter Son No:  ');
                            IntegerLimit;
                            write('Enter revised Son No[',n,']:   ');
                            readln(DataRecord.Son[n]);
                       end;
                 'd' : begin
                            write('Enter Daughter No:  ');
                            IntegerLimit;
                            write('Enter revised Daughter No[',n,']:   ');
                            readln(DataRecord.Daughter[n]);
                       end;
                 'r' : begin
                            ReviseRemarks;
                       end;

            end;
            reset(DataFile);
            seek(DataFile,i-1);
            with DataRecord do begin
               write(DataFile,DataRecord);
            end;
            writeln;
            ch:=' ';
            writeln;
            write('Do you wish to continue to revise records ?  "y" or SpaceBar  ');
            read(kbd,ch);
            clrscr;
            close(DataFile);
      until ch = ' ';
      ReviseFlag:=0;
      clrscr;
end;

procedure CreateFileName;

(* This is a technique for writing 20-character file names which are
   correlated with randomly generated 8-character filespecs *)

begin
     ch:=' ';
     writeln('You chosen to create a new Family Name: ',FileName);
     writeln;
     writeln('   Enter "n" if you do not wish to continue; else hit SpaceBar');
     read(kbd,ch);
     clrscr;
     if ch = 'n' then begin
        clrscr;
        writeln('Program halted');
        halt;
     end;
     ch:=' ';
     k:=1;
     clrscr;
     seek(MatrixFile,FileSize(MatrixFile));
     ch:=' ';
     randomize;  {randomize initial seed}
     a:= random(26) + 65 ; b:= random(26) + 65 ; c:= random(26) + 65 ;
     d:= random(26) + 65 ; e:= random(26) + 65 ; f:= random(26) + 65 ;
     g:= random(26) + 65 ; h:= random(26) + 65;
     Code := chr(a) + chr(b) + chr(c) + chr(d) + chr(e) + chr(f)
                + chr(g) + chr(h);
     FileSpec:=Code +'.dat';
     write(MatrixFile,FileName,FileSpec);
     close(MatrixFile);
     assign(DataFile,FileSpec);
     writeln;
end;

procedure CurrentFiles;  {display list of existing files}
begin
            ch:=' ';
            cb:=' ';
            cs:=' ';
            NameSearch := ' ';      {null all chars}
            FileName:=' ';
            FileSpec:=' ';
            SearchFlag:=0;
            TitleFlag:=0;
            ReviseFlag:=0;
            EraseFlag:=0;
            SortFlag:=0;
            i:=0;
            n:=0;
            cb:=' ';
            clrscr;
      assign(TitleFile, 'FileList.txt');
      {$I-} reset(TitleFile) {$I+}; {check for existence of FileList.txt}
      if IOresult <> 0 then begin
            gotoxy(1,15);writeln('FileList.txt [file of family names] now created on disk');
            rewrite(TitleFile);
            write(TitleFile,FileName);
      end
      else begin
            reset(TitleFile);
            clrscr;
            gotoxy(1,1);writeln('********************************************************************************');
            gotoxy(20,2);writeln('These are Family Names On File....');
            j:=5;
            k:=3;
            while not eof(TitleFile) do begin
                  read(TitleFile,FileName);
                  gotoxy(j,k);writeln(FileName);    {make columns of family names}
                  if k = 18 then begin
                     j:=j + 22;
                     k:=3;
                  end;
                  k:=k + 1;
            end;
            gotoxy(1,19);writeln('You may call any of these family names [up to 20 char] or create new names');
            gotoxy(1,21);writeln('********************************************************************************');
      end;
      writeln;
      write('Enter family name you wish to create, process or erase : ');
      readln(FileName);
      if (FileName = '') or (FileName = ' ') then begin
        writeln('Code is halted; you must input a family name');
        halt;
      end;
      NameFlag:=0;
      reset(TitleFile);
      while not eof(TitleFile) do begin
            read(TitleFile,TitleName);
            if TitleName = FileName then NameFlag:=1;
      end;
      close(TitleFile);
      clrscr;
      assign(MatrixFile,'names.dat');
      {$I-} reset(MatrixFile);{$I+}
      if IOresult <> 0 then begin
        rewrite(MatrixFile);
      end;
      if NameFlag = 0 then CreateFileName else begin
         while not eof(MatrixFile) do begin
             read(MatrixFile,DummyName,FileSpec);
             if DummyName = FileName then assign(DataFile,FileSpec);
         end;
      end;
      close(MatrixFile);
      writeln;
      ch:=' ';
end;

procedure AddTitle;  {Create or Append list of Titles}
begin
      reset(TitleFile);
      n:=FileSize(TitleFile);
      seek(TitleFile, n);
      write(TitleFile,FileName);
      close(TitleFile);
      clrscr;
end;

procedure CompressedPrint; {reset Epson FX printer with compressed print for 11" form}
begin
      writeln('Reset printer for top of form');
      writeln('Press any key to continue');
      repeat until keypressed;
      CompressPrint:= chr(27) + chr(64) + chr(27) + chr(106) + chr(35) +
                        chr(27) + chr(15)  +           {set compressed mode}
                        chr(27) + chr(65) + chr(9) +   {set line spacing}
                        chr(27) + chr(108) + chr(4) +  {left margin}
                        chr(27) + chr(81) + chr( 137) +  {right margin}
                        chr(27) + chr(66) + chr(0) + chr(11) + {reset printer to top of form}
                        chr(27) + chr(78) + chr(88) +  {skip perforations}
                        chr(27) + chr(12);  {form feed}
      writeln(lst,CompressPrint);
end;

procedure PrintRecords; (* prints a file of records *)
begin
      clrscr;
      reset(DataFile);
      i:=0;  {first record in file is always numbered zero}
      n := filesize(DataFile);
      writeln(lst,'Genealogy for Family:  ',FileName);
      writeln(lst,'    File Size = ',n);
      writeln(lst);
      while not eof(DataFile) do begin
            seek(DataFile,i);
            read(DataFile,DataRecord);
            With DataRecord do begin
                 writeln(lst, 'Record  #',i + 1);
                 writeln(lst);
                 writeln(lst, 'Name                 :  ',Name);
                 writeln(lst, 'Sex, m or f          :  ',Sex);
                 writeln(lst, 'Birth Date           :  ',BirthDate);
                 writeln(lst, 'Deceased ?; y or n   :  ',Deceased);
                 if Deceased = 'y' then begin
                    writeln(lst, 'Died                 :  ',DeceasedDate);
                 end;
                 writeln(lst, 'Profession/Vocation  :  ',Profession);
                 writeln(lst, 'Birth Place          :  ',BirthPlace);
                 writeln(lst, 'Father               :  ',Father);
                 writeln(lst, 'Mother               :  ',Mother);
                 if Sex = 'm' then begin
                    for n:=1 to NoOfWives do
                        writeln(lst, 'Wife [',n,']             :  ',Wife[n]);
                 end
                 else begin
                    for n:=1 to NoOfHusbands do
                        writeln(lst, 'Husband [',n,']          :  ',Husband[n]);
                 end;
                 for n:=1 to NoOfSons do begin
                     writeln(lst, 'Son [',n,']              :  ',Son[n]);
                 end;
                 for n:=1 to NoOfDaughters do begin
                     writeln(lst, 'Daughter [',n,']         :  ',Daughter[n]);
                 end;
                 writeln(lst);
                 y:=WhereY;
                 gotoxy(1,y + 1);
                 writeln(lst, 'Remarks              : ');
                 writeln(lst);
                 x:=1;
                 for n:=1 to NoChar do begin
                     write(lst,Lines[n]);
                     if ((x > 70) and (Lines[n] = #32)) or (x = 80) then begin
                        x:=1;
                        write(lst,#13);
                        write(lst,#10);
                     end
                     else x:=x + 1;
                 end;
            end;
            i:= i + 1;
            writeln(lst);
            writeln(lst);
      end;
      close(DataFile);
      i:=i-1;      {compensate for final pass}
end;

procedure DeleteRecord; {delete specified record}
begin
      writeln;
      write('Identify record number to be deleted :  ');
      readln(i);
      reset(DataFile);
      seek(DataFile,i - 1);
      read(DataFile,DataRecord);
      clrscr;
      WriteData;
      writeln;
      writeln('Are you sure you want to delete record no. ',i,' ?');
      TextColor(15 + blink);
      writeln;
      writeln('   y or SpaceBar');
      TextColor(15);
      read(kbd,ch);
      if (ch = 'y') or (ch = 'Y') then begin
         assign(DummyRecFile,'dummy.dat');
         rewrite(DummyRecFile);
         {$I-}reset(DataFile){$I+};
         if IOresult <> 0 then begin
            writeln('File does not exist; cant be read');
            halt;
         end;
         a:=FileSize(DataFile);
         for n:=1 to a do begin
               seek(DataFile,n - 1);  {1st entry is number zero}
               with DataRecord do
               read(DataFile,DataRecord);
               if n <> i
                   then write(DummyRecFile,DataRecord);
         end;
         close(DummyRecFile);
         close(DataFile);
         reset(DummyRecFile);
         rewrite(DataFile);
         while not eof(DummyRecFile) do begin
               read(DummyRecFile,DataRecord);
               write(DataFile,DataRecord);
         end;
         close(DataFile);
         close(DummyRecFile);
         clrscr;
      end
      else
end;

procedure Instructions;
begin
     clrscr;
     writeln('This program is intended to track family members through the male lines of');
     writeln('descendants.  Therefore, the family names are those that continue through');
     writeln('the male line.');
     writeln;
     writeln('Thus, records for the descendants of daughters are  mainly found in the family');
     writeln('name of the husbands of the daughters, and biographical "Remarks" having');
     writeln('to do with married daughters are mainly found in records of the family name');
     writeln('of the husband.  However, the program allows easy access between family names.');
     writeln;
     writeln('This code allows a limited ability to edit the Remarks for each record.');
     writeln('The editing instructions are included in a self-prompting mode.  But you will');
     writeln('probably need a few trys and errors to get the hang of editing.');
     writeln;
     writeln('From the DOS prompt, you may call NAMES.COM to do the following:');
     writeln('       * Revise any family names');
     writeln('       * Erase any family names');
     writeln('       * Compress the family names files, FILESLIST.TXT & NAMES.DAT');
     writeln;
     writeln('Press any key to continue');
     repeat until keypressed;
end;

begin              {MAIN PROGRAM}
      clrscr;
      repeat
            CurrentFiles;
            writeln;
            gotoxy(1,10);writeln('********************************************************************************');
            gotoxy(22,12);writeln('Selected Family Name : ');
            TextColor(15 + blink);
            gotoxy(45,12);writeln(FileName);
            TextColor(15);
            gotoxy(1,14);writeln('********************************************************************************');
            delay(1000);
            clrscr;
            writeln;
            clrscr;
            {$I-} reset(DataFile) {$I+}; {check for existence of FileSpec}
            if IOresult = 0 then begin  {"0" means files exists}
            repeat
               if EraseFlag = 0 then begin
                  clrscr;
                  ch:=' ';
                  writeln('Enter desired action for ',FileName,' family file :');
                  writeln;
                  writeln('Read File of Records    : f     Read Instructions   : i');
                  writeln('Add Record(s) to File   : a     Revise Data in File : r');
                  writeln('Delete a Record in File : d     Print this File     : p');
                  writeln('Search a Name in File   : s     Sort by BirthDate   : b');
                  writeln('Erase this File         : e     Search another Name : n');
                  writeln('Quit this File          : q');
                  writeln;
                  read(kbd,ch);
                  if ch = 'f' then ReadFile;
                  if ch = 'i' then Instructions;
                  if ch = 'e' then EraseFile;
                  if ch = 'a' then AppendRecord;
                  if ch = 'r' then ReviseRecord;
                  if ch = 'd' then DeleteRecord;
                  if ch = 's' then Search;
                  if ch = 'b' then Sort;
                  if ch = 'n' then CurrentFiles;
                  if ch = 'p' then begin
                     CompressedPrint;
                     PrintRecords;
                  end;
                end
                else ch:='q';
            until ch = 'q';
            end
            else begin  {if file does not exist, create one}
               i:=0;
               TitleFlag:=1;
               InputFile;
            end;
            if TitleFlag = 1 then AddTitle;
            writeln;
            ch:=' ';
            writeln('Enter "q" to quit program or SpaceBar to continue ');
            read(kbd,ch);
      until (ch = 'q') or (ch ='Q');
end.
(*****************************************************************************)