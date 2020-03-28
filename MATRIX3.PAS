program matrix3; {11-19-86}

type
   matrix = array[1..3,1..3,1..3] of real;
   column = array[1..3] of real;

var
   MajorElement,
   CoFactorElement,
   Minor             : matrix;
   CoFactorSign,
   Multiplier        : column;
   determinant       : real;
   x,y               : real;
   j,k,                       {row and column of major matrix}
   m,n,                       {row and column of minor matrix}
   p                          {index number of minor matrix}
                     : integer;
   filespec          : string[30];
   start             : string[2];
   ch,cd,cp          : char;
   MajorDim          : integer;
   MinorDim          : integer;
   sign              : integer;
   datafile          : file of real;
   tempfile          : file of real;

procedure ReadOut;
begin
     clrscr;
     cp:= ' ';
     cd:= ' ';
     assign(datafile, filespec);
     reset(datafile);
     writeln;
     writeln('If you wish to display data, enter "d"');
     read(kbd,cd);
     writeln('Do you want printout of data ? Enter "p" if so');
     read(kbd,cp);
     j:=0;
     k:=0;
     clrscr;
     writeln('             ',filespec);   {screen label for filespec}
     writeln;
     writeln('Remember...all elements readout as element[j,k] where ');
     writeln('     j is row # and k is col #');
     writeln;
     while not eof(datafile) do begin;
           for j:=1 to MajorDim do begin        {j is row #}
               for k:=1 to MajorDim do begin    {k is column #}
                        read(datafile, MajorElement[j,k,1]);
                        if cd='d' then writeln(j,' ',k,' ',MajorElement[j,k,1]);
                        if cp='p' then writeln(lst,j,' ',k,' ',MajorElement[j,k,1]);
                end;
                 if cd='d' then writeln;
                 if cp='p' then writeln(lst,' ');
           end;
           (*    end of datafile readout            *)
     end;
     close(datafile);
     writeln('Press any key to continue');
     repeat until keypressed;
end;


procedure Generate_CoFactors;
begin
(*

Cofactor = Minor * (-1)^(j + k)

If we select a21 as the major element (multiplier) of the following matrix:

               a11   a12  a13  a14       a12  a13  a14
The minor of   a21   a22  a23  a24    =  a32  a33  a34
               a31   a32  a33  a34       a42  a43  a44
               a41   a42  a43  a44

And the cofactor = (-1)^(2+1) * Minor = -1 * Minor

*)
     {create temporary file to hold minors on default drv}
     assign(tempfile,'tempdata');
     rewrite(tempfile);

     {We will always use the elements of the first column, e.g., a21,  as the
      multipliers of the cofactors}
     for j:=1 to MajorDim do begin
         for k:=1 to MajorDim do begin
               p:=j;    {p is index no of minor/cofactor}
               if (j + k) mod 2 <> 0 then CoFactorSign[p] := -1
                  else CoFactorSign[p] := 1;
               Multiplier[p]:=MajorElement[j,1,1]; {multiplier is major
                                                  element in first column}
         end;
     end;
     (* now generate minors *)

     m:=0;
     for p:=1 to MajorDim do begin;
         m:=m + 1;  {row # of minor}
         for j:=1 to MajorDim do begin
             n:=0;
             for k:=1 to MajorDim do begin
                 if (m<>j) and (k<>1) then begin
                 {i.e., do not include row and column of multiplier element}
                    n:=n + 1;  {column # of minor}
                    Minor[p,m,n]:=MajorElement[j,k,1];
                    write(tempfile,Minor[p,m,n]);
                 end;
             end;
         end;
     end;
(*
     writeln('Press any key to continue');
     repeat until keypressed;
*)
     clrscr;

     (* now read temp data out in sequence and renumber/relabel bins *)

     reset(tempfile);
     for p:=1 to MajorDim do begin;
         for j:=1 to MinorDim do begin;
             for k:=1 to MinorDim do begin;
                 read(tempfile,Minor[p,j,k]);
                 CoFactorElement[p,j,k]:=Minor[p,j,k] * CoFactorSign[p];
                 writeln('CoFactorElement[',p,',',j,',',k,'] = ',
                     CoFactorElement[p,j,k]);
             end;
             writeln;
         end;
     end;
     close(tempfile);
     writeln;
end;


begin  {MAIN PROGRAM}

     clrscr;
     writeln('Enter the number of rows/columns in your matrix');
     readln(MajorDim);
     clrscr;
     writeln('If you wish to read matrix from an existing disk file, enter "y"');
     writeln('    else you must input matrix data');
     read(kbd,ch);
     clrscr;
     writeln('Enter filespec for datafile');
     readln(filespec);
     if ch = 'y' then begin
        ReadOut;
     end
     else begin
          start:=' ';
          clrscr;
          writeln('ARE YOU SURE YOU WANT TO ENTER NEW DATA ? IF SO, TYPE "go"');
          readln(start);
          if start <> 'go' then begin
              gotoxy(20,24);writeln('Re-run code to avoid erasing input file');
              halt;
          end;
          clrscr;
          writeln('Remember...we enter all elements in row 1 first; then row 2; etc');
          writeln;
          assign(datafile, filespec);
          rewrite(datafile);
          j:=0;
          ch:=' ';
          for j:=1 to MajorDim do begin  {j = rows; k = columns}
              for k:=1 to MajorDim do begin
                  writeln('enter element[',j,' ',k,']');
                  readln(MajorElement[j,k,1]);
                  write(datafile,MajorElement[j,k,1]);
              end;
           end;
           close(datafile);
           assign(datafile, filespec);
           reset(datafile);
           clrscr;
           writeln('             ',filespec);
           writeln;
           while not eof(datafile) do begin;
                 for j:=1 to MajorDim do begin
                     for k:=1 to MajorDim do begin
                         read(datafile, MajorElement[j,k,1]);
                         writeln('Major Element[',j,' ',k,'] = ',MajorElement[j,k,1]);
                     end;
                  end;
                  writeln;
                  writeln('Press any key to continue');
                  repeat until keypressed;
           end;
           close(datafile);
     end;

     (* now to create cofactors and minors *)
     MinorDim := MajorDim - 1;
     Generate_CoFactors;
     if MinorDim = 2 then begin
        determinant:=0;
        for p:=1 to MajorDim do begin
                    x:=CoFactorElement[p,1,1] * CoFactorElement[p,2,2];
                    y:=CoFactorElement[p,2,1] * CoFactorElement[p,1,2];
                    determinant:=(x - y) *  Multiplier[p] * CoFactorSign[p]
                                   + determinant ;
        end;
        gotoxy(20,23);writeln('Value of determinant is ', determinant);
     end;
end.

