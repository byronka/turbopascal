program titles;  {10/08/88; rev 12/4/89}
                 {rev 5/14/90 to decode matrix}

(* This code, adapted from FILES.PAS may be used with FAMILY
   to revise list of titles in FileList.txt and Names.dat *)

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
    a,b,n,x,y,m,
    LastLine           : integer;
    DataFile,
    DummyRecFile,
    DiscardFile,
    DummyFile          : file of DataSet;
    TitleFile,
    DummyTitleFile,
    MatrixFile,
    DummyMatrixFile    : file of string[20];
    NumberFile         : file of integer;
    period             : array[1..150] of integer;
    DataRecord         : DataSet;
    ErasedAccnt,
    NameSearch,
    ShortenedName,
    date               : string[20];
    ReviseFlag,
    SearchFlag,
    EraseFlag,
    SortFlag,
    TitleFlag,
    result,
    EarliestPeriod,
    StringPos, digits  : integer;
    cb,ch,cs,
    Select             : char;
    FileSpec           : string[20];
    CompressPrint      : string[20];
    c,d,e,f,g,h        : integer;   {used for randomizing name data}
    NameFlag           : integer;
    code               : string[8];
    FileName           : string[20];
    DummyName          : string[20];
    TitleName          : string[20];


DummyStringFile       : file of string[20];
Title,Name            : string[20];
StartFlag             : integer;
menu                  : char;

procedure CompressFile;  {eliminate erasures}
begin

     assign(DummyStringFile,'dummy1.dat');
     assign(DummyMatrixFile,'dummy2.dat');
     rewrite(DummyStringFile);
     rewrite(DummyMatrixFile);
     reset(TitleFile);
     reset(MatrixFile);
     m:=0;
     while m < FileSize(MatrixFile) do begin
          writeln;
          seek(MatrixFile,m );
          read(MatrixFile,title,name);
          if title <> ' ' then begin
             write(DummyMatrixFile,title,name);
             write(DummyStringFile,title);
          end;
          m:=m + 2;
    end;
    reset(DummyStringFile);
    reset(DummyMatrixFile);
    rewrite(TitleFile);
    rewrite(MatrixFile);
    m:=0;
    while m < FileSize(DummyMatrixFile) do begin
          seek(DummyMatrixFile,m);
          read(DummyMatrixFile,title,name);
          write(TitleFile,title);
          write(MatrixFile,title,name);
          m:=m + 2;
    end;
    close(DummyStringFile);
    close(DummyMatrixFile);
end;

procedure CurrentFiles;  {display list of existing files}
begin
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
            gotoxy(1,19);writeln('You will have the opportunity to revise any of these names');
            gotoxy(1,21);writeln('********************************************************************************');
      end;
      writeln;
      writeln('Press any key to continue');
      repeat until keypressed;
      writeln;
      reset(TitleFile);
      while not eof(TitleFile) do begin
            read(TitleFile,TitleName);
            if TitleName = FileName then NameFlag:=1;
      end;
      close(TitleFile);

      assign(MatrixFile,'names.dat');
      {$I-} reset(MatrixFile);{$I+}
      if IOresult <> 0 then begin
        rewrite(MatrixFile);
      end;
               {use following routine for display of matrix}
      writeln('The following equates the file long name with the filespec');
      writeln;
      while not eof(MatrixFile) do begin
             read(MatrixFile,DummyName,FileSpec);
             writeln(DummyName,' = ',FileSpec);
             writeln('Press any key to continue');
             repeat until keypressed;
            if DummyName = FileName then assign(DataFile,FileSpec);
      end;
      close(MatrixFile);
      writeln;
      ch:=' ';
end;


procedure ReadOutFileList;
begin
     
     reset(TitleFile);
     reset(MatrixFile);
     n:=Filesize(TitleFile);
     writeln('Size of title file is ',n,' entries');
     ch:=' ';
     n:=0;
     m:=0;
     while m < FileSize(MatrixFile)do begin
          writeln;
          seek(MatrixFile,m );
          read(MatrixFile,title);
          writeln('Entry # ',n + 1,':   ',title);
          writeln;
          writeln('If you wish to revise title, enter "r":   ');
          writeln('If you wish to erase title, enter "e":   ');
          writeln('   Else hit Enter');
          read(kbd,ch);
          writeln;writeln;
          if ch = 'r' then begin
             seek(TitleFile,n);
             seek(MatrixFile,m);
             write('Enter revised title:   ');
             readln(title);
             write(TitleFile,title);
             write(MatrixFile,title);
          end;
          if ch = 'e' then begin
             seek(TitleFile,n);
             seek(MatrixFile,m);
             title:=' ';
             write(TitleFile,title);
             write(MatrixFile,title);
          end;
          n:= n + 1;
          m:= m + 2;  {two entries for MatrixFile for every one
                           in TitleFile}
     end;
     close(TitleFile);
     close(MatrixFile);
end;

begin     {MAIN PROGRAM}

     ch:= ' ';
     assign(TitleFile,'FileList.txt');
     assign(MatrixFile,'Names.dat');
     StartFlag:=0;

           CurrentFiles;
           ReadOutFileList;
           CompressFile;
end.

