program OutputProcedure; {procedure library, 1-29-89}

var
   FileSpec:string[20];
   DataFile:file of real;


{*******************************************************************************}

procedure OutputFromFile;
begin
     clrscr;
     writeln('Enter FileSpec for DataFile');
     readln(FileSpec);
     assign(DataFile, FileSpec);
     {$I-}reset(DataFile) {$I+};
     if IOresult <> 0 then begin
        writeln;
        writeln('File does not exist; start over');
        halt;
     end;
{call file operations here}
     close(DataFile);
end;

{*******************************************************************************}

begin
     OutputFromFile;
end.
