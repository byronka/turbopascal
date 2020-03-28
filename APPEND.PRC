program append;  {1-30-89}
var
   FileSpec: string[20];
   DataFile: file of real;

{*****************************************************************************}

procedure AppendData;
begin
      writeln('File size = ',FileSize(DataFile));
      {$I-}reset(DataFile) {$I+};
      if IOresult <> 0 then begin
         writeln;
         writeln('File does not exist; start over');
         halt;
      end;
      seek(DataFile,FileSize(DataFile));
end;

{*****************************************************************************}

begin
     AppendData;
end.
