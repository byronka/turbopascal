program  REMARKS;   {7/10/90}

{demo of creating & changing text derived from FAMILY.PAS}

type
    Remarks = array[1..400] of char;
    DataSet = record
            NoChar        : integer;
            Lines         : Remarks;
    end;

var
    i,j,k,
    LastEntry,
    a,b,n,nn,x,y,m,
    InitialY,
    FirstLine,
    LastLine,
    LineNo,
    Place,
    NoOfRecords,
    CharactersOnLine      : integer;
    DataFile              : file of DataSet;
    TitleFile,
    MatrixFile            : file of string[20];
    DataRecord            : DataSet;
    NameSearch            : string[20];
    ReviseString          : string[255];
    ReviseFlag,
    RepeatFlag,
    EraseFlag,
    TitleFlag,
    StringPos             : integer;
    ca,cb,ch,cr,cs        : char;
    FileSpec              : string[20];
    CompressPrint         : string[20];
    c,d,e,f,g,h           : integer;   {used for randomizing name data}
    NameFlag              : integer;
    code                  : string[8];
    FileName              : string[20];
    DummyName             : string[20];
    TitleName             : string[20];


procedure WordWrap;
begin
     with DataRecord do begin
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
                until ((m > 9) and (ch = #32)) or (ch = #13)
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
            writeln;
            writeln('Record #',i + 1,' for ',FileName);
            writeln;
            WordWrap;
            ch:=' ';
            write(DataFile,DataRecord);
            i:=i + 1;
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
      writeln('Information for File: ',FileName);
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
{writeln('n   Lines[n]  ',n,'  ',Lines[n]);}
{writeln('Press any key to continue');}
{repeat until keypressed;}
              if ((x > 9) and (Lines[n] = #32)) or (x = 80) then begin
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
     writeln('Record  #',i);
     writeln;
     WriteRemarks;
     gotoxy(1,LastLine + 2);
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
      writeln('Information for File: ',FileName,'; Number of Records = ',NoOfRecords);
      writeln;
      writeln('Press any key to continue');
      repeat until keypressed;
      while not eof(DataFile) do begin
            clrscr;
            read(DataFile,DataRecord);
            i:=FilePos(DataFile);
            WriteData;
            writeln('Press any key to continue');
            repeat until keypressed;
      end;
      close(DataFile);
end;

procedure AppendRecord;
begin
      reset(DataFile);
      seek(DataFile,FileSize(DataFile));
      NoOfRecords := filesize(DataFile);
      i:=NoOfRecords;      {"NoOfRecords" is filesize, beginning with "0"}
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
         if (ca = #9) and (x < 9) then begin    {allow faster movement through line}
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
     WriteRemarks;
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
     WriteRemarks;
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
      WriteRemarks;
end;

procedure EraseRemarks;
begin
     with DataRecord do for n:=1 to 400 do Lines[n] := ' ';
     WordWrap;
end;

procedure ReviseRecord;
begin
      ReviseFlag:=1;
      RepeatFlag:=0;
      repeat
            writeln;
            ch:=' ';
            reset(DataFile);
            seek(DataFile,FileSize(DataFile));
            NoOfRecords := filesize(DataFile);
            if RepeatFlag <> 1 then begin
               write('Input record # to be revised:  ');
               readln(i);
               if (i > NoOfRecords) or (i < 1) or (i > 1E3)  then begin
                  writeln('Record # ',i,' does not exist for this file');
                  writeln('Program halted; begin again');
                  halt;
               end;
               seek(DataFile,i - 1);       {adjust for beginning of file = "0"}
               read(DataFile,DataRecord);
               clrscr;
            end;
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
            gotoxy(1,22);write('Enter "c" to continue revising these remarks');
            gotoxy(1,24);write('Enter SpaceBar to quit');
            read(kbd,ch);
            if ch = 'c' then RepeatFlag:=1;
            clrscr;
            close(DataFile);
      until ch = ' ';
      RepeatFlag:=0;
      ReviseFlag:=0;
      clrscr;
end;

procedure CreateFileName;

(* This is a technique for writing 20-character file names which are
   correlated with randomly generated 8-character filespecs *)

begin
     ch:=' ';
     writeln('You chosen to create a new File Name: ',FileName);
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
      assign(TitleFile, 'FileList.txt');
      {$I-} reset(TitleFile) {$I+}; {check for existence of FileList.txt}
      if IOresult <> 0 then begin
            gotoxy(1,15);writeln('FileList.txt [file of record names] now created on disk');
            rewrite(TitleFile);
            write(TitleFile,FileName);
      end
      else begin
            reset(TitleFile);
            clrscr;
            gotoxy(1,1);writeln('********************************************************************************');
            gotoxy(20,2);writeln('These are File Names On File....');
            j:=5;
            k:=3;
            while not eof(TitleFile) do begin
                  read(TitleFile,FileName);
                  gotoxy(j,k);writeln(FileName);    {make columns of record names}
                  if k = 18 then begin
                     j:=j + 22;
                     k:=3;
                  end;
                  k:=k + 1;
            end;
            gotoxy(1,19);writeln('You may call any of these record names [up to 20 char] or create new names');
            gotoxy(1,21);writeln('********************************************************************************');
      end;
      writeln;
      write('Enter record name you wish to create, process or erase : ');
      readln(FileName);
      if (FileName = '') or (FileName = ' ') then begin
        writeln('Code is halted; you must input a record name');
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
    