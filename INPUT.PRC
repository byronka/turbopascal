program InputProcedure;   {procedure library, 1-29-89}

var
   FileSpec:string[20];
   DataFile:file of real;

{*******************************************************************************}

procedure InputToFile;
begin
     clrscr;
     writeln('Enter FileSpec for DataFile');
     readln(FileSpec);
     assign(DataFile, FileSpec);
     rewrite(DataFile);
{call file operations here}
     close(DataFile);
end;

{*******************************************************************************}

begin
     InputToFile;
end.
