program Read_Write; {generalized procedures for reading in and
                     reading out data files} {1-26-88; rev 1-30-89}
(* See truss.pas for example application *)

var
   Caption     : array[1..20] of string[50];  {names of parameters}
   InputData   : array[1..20] of real;        {values of parameters}
   textfile    : file of string[50];
   datafile    : file of real;
   CapFileSpec : string[30];
   DataFileSpec: string[30];
   n           : integer;
   ch,cd,cp    : char;


procedure Readin;

begin
     clrscr;
     writeln('Enter filespec for captions');
     readln(CapFileSpec);
     assign(textfile,CapFileSpec);
     rewrite(textfile);
     writeln('Enter filespec for datafile');
     readln(DataFileSpec);
     assign(datafile, DataFileSpec);
     rewrite(datafile);
     n:=0;
     while ch <> 'q' do begin
         n:=n + 1;
         writeln('Enter caption for parameter ',n);
         readln(Caption[n]);
         write(textfile,Caption[n]);
         writeln('Enter value of ',Caption[n]);
         readln(InputData[n]);
         write(datafile,InputData[n]);
         clrscr;
         writeln('To quit Readin, enter "q" ');
         read(kbd,ch);
     end;
     close(textfile);
     close(datafile);
end;

procedure ReadOut;
begin
     clrscr;
     writeln('Enter filespec for captions');
     repeat;
            readln(CapFileSpec);
            assign(textfile,CapFileSpec);
            {$I-}reset(textfile){$I+};
            if IOresult <> 0 then begin
               writeln;
               writeln('File named does not exist; enter different filespec or ctrl-brk');
           end;
           {$I-}reset(textfile){$I+};
     until IOresult = 0;
     writeln('Enter filespec for datafile');
     repeat
           readln(DataFileSpec);
           assign(datafile, DataFileSpec);
           {$I-}reset(datafile){$I+};
           if IOresult <> 0 then begin
              writeln;
              writeln('File named does not exist; enter different filespec or ctrl-brk');
           end;
           {$I-}reset(datafile){$I+};
     until IOresult = 0;
     ch:= ' ';
     cd:= ' ';
     writeln;
     writeln;
     writeln('If you wish to display data, enter "d"');
     read(kbd,cd);
     writeln('Do you want printout of data ? Enter "p" if so');
     read(kbd,ch);
     clrscr;
     writeln('  ',CapFileSpec,'/',DataFileSpec);   {screen label for filespec}
     writeln;
     while not eof(datafile) do begin;
                        read(datafile, InputData[n]);
                        read(textfile, Caption[n]);
                        if cd='d' then writeln(Caption[n],' =  ',InputData[n]:10);
                        if cd='p' then writeln(lst, Caption[n],' =  ',InputData[n]:10);
     end;
     if cd='d' then writeln;
     if ch='p' then writeln(lst,' ');
           (*    end of datafile readout            *)
     close(textfile);
     close(datafile);
     writeln('Press any key to continue');
     repeat until keypressed;
end;

begin     {MAIN PROGRAM}
     clrscr;
     writeln('Select from following options: ');
     writeln('    1 : Enter parameter captions and data onto disk');
     writeln('    2 : Readout parameter captions and data from disk');
     read(kbd,ch);
     if ch = '1' then Readin else Readout;
end.
