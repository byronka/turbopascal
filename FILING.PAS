program filing;    {6-28-88} {format revised 9-7-92}

(* This code written by Ellis Katz (818) 783-0778 to do following:
           * Enter an array of real data into a diskfile
           * Read data from a diskfile, and structure the data
               into an array of up to 1000 rows x 5 columns
           * Compress a large data file into any desired size; e.g.,
               500 x 2 to fit the bit-mapped CGA screen for graphing
           * Alter/correct the filed array
           * Extract specified columns from the filed array
           * Spline an x,y (i.e., 2-column array) data array
           * Operate on the filed data (e.g. transform from g's to m/sec^2)
             [see end of code for math expressions which may be of use]
*)
var
   DataFile           : file of real;
   ArrayData          : array [1..1000,1..5] of real; {zero registers for
                                                       file ident}
   MinValue, MaxValue : array[1..5] of real;
   data,x1,x2,x3      : real;

   rows,columns,
   i,j,k,m,n,
   p,q,
   xColumn,
   yColumn,
   MaxRows,
   EndOfFileData,
   ReadCycle,
   NoFileEntries,
   b,c,
   DataEntries        : integer;

   FileSpec           : string[20];

   ch,cd,ca,co,
   select             : char;

   {following variables are unique to splining procedures}

   Xin, Yin                       : array[0..20] of real;
   Xout, Yout, deriv, s, g, work  : array[0..500] of real;
   integral, eps,
   XiM1, XiP1, X, h, YiP1, YiM1,
   Yi, Xi, M1, w, u, v, t, zz, ss : real;

procedure intro;
begin
     writeln('This code was written by Ellis Katz (818) 783-0778 to do following:');
     writeln;
     writeln('   * Enter an array of real data into a diskfile');
     writeln;
     writeln('   * Read data from a diskfile, and structure the data');
     writeln('         into an array of up to 1000 rows x 5 columns');
     writeln;
     writeln('   * Compress a large data file into any desired size; e.g.,');
     writeln('         500 x 2 to fit the CGA bit-mapped screen for graphing');
     writeln;
     writeln('   * Alter/correct a data array [up to 1000 x 5] file');
     writeln;
     writeln('   * Extract specified columns of data from the array');
     writeln;
     writeln('   * Operate upon the data array (e.g. change g s to m/sec^2)');
     writeln('      [You must modify the source code to enter your functions]');
     writeln;
     writeln('   * Manipulate any two columns of your array [e.g., product of');
     writeln('      columns 3 and 4]');
     writeln;
     writeln('   * Spline an x,y data file');
     writeln('****************************************************************');
     writeln('   Turn CAPS off; Press any key to continue');
     repeat until keypressed;
     clrscr;
end;

procedure revise;
begin
     ch:=' ';
     writeln('Do you want to store revised data in disk? if yes, enter "y"');
     read(kbd,ch);
     if ch='y' then begin
        write('Enter FileSpec for revised DataFile:  ');
        readln(FileSpec);
        assign(DataFile, FileSpec);
        rewrite(DataFile);
        for j:=1 to rows do begin
            for k:=1 to columns do begin
                write(DataFile,ArrayData[j,k]);
            end;
        end;
        close(DataFile);
     end;
end;

procedure correct;
begin
     clrscr;
     writeln('You may now correct the active file: ',FileSpec);
     ch:=' ';
     j:=0;
     while (ch <> 'q') and (j < rows) do begin
         j:= j + 1;
         k:=0;
         while k < columns do begin
             k:=k + 1;
             writeln(j,' ',k,' ',ArrayData[j,k]);
             ch:=' ';
             writeln('is data entry correct? if not, enter "n"');
             read(kbd,ch);
             if ch='n' then begin
                writeln('Enter correct value ');
                readln(ArrayData[j,k]);
                writeln;
                k:=k-1;
                clrscr;
             end;
         end;
         writeln('Enter "q" to quit');
         read(kbd,ch);
     end;
     revise;
end;

procedure extract;      {extract two columns of array for x,y graphing}
begin
     clrscr;
     writeln('This routine allows you to select any two columns in your array for xy graphing');
     writeln('You must specify the "x" and "y"  columns to be extracted from your array');
     writeln;
     writeln('Number of rows in array = ',rows);
     writeln('Number of columns in array = ',columns);
     writeln;
     write('Identify column no. representing  the abscissa "x":  ');
     readln(xColumn);
     writeln('Identify column no. representing the ordinate "y":  ');
     readln(yColumn);
     for j:=1 to rows do begin
         u:=ArrayData[j,xColumn];
         v:=ArrayData[j,yColumn];
         ArrayData[j,1]:=u;
         ArrayData[j,2]:=v;
     end;
     columns:=2;
     ch:=' ';
     writeln('Do you want to store revised data in disk? if yes, enter "y"');
     read(kbd,ch);
     if ch='y' then begin
        write('Enter FileSpec for revised DataFile:  ');
        readln(FileSpec);
        assign(DataFile, FileSpec);
        rewrite(DataFile);
        for j:=1 to rows do begin
                write(DataFile,ArrayData[j,1],ArrayData[j,2]);
        end;
        close(DataFile);
     end;
end;


procedure operate;
begin
     clrscr;
     writeln('This procedure is used to perform a math operation on any ');
     writeln('  selected column of your array to create a revised column which');
     writeln('  will replace the selected column.');
     writeln('  For example, you might wish to take the cosine of column 3');
     writeln('  and then plot the product vs column 5');
     writeln('  In that event, you would end up replacing column 3 by the its');
     writeln('  cosine.  The listed routine is for example only and demonstrates');
     writeln('  the taking of the cosine of any selected column');
     writeln('For any other operation (e.g., column 3 to the exponent 5,');
     writeln('  you must go to source code and revise algorithm listed below');
     writeln;
     writeln;
     writeln('Number of rows in array = ',rows);
     writeln('Number of columns in array = ',columns);
     writeln;
     writeln('Enter the column number to be selected');
     readln(q);
     writeln('If you wish to display data, enter "d"');
     read(kbd,cd);
     for j:=1 to rows do begin
       for k:=1 to columns do begin

{PLACE ALGORITHM HERE..see end of listing for other math algorithms}

             if k = q then ArrayData[j,k]:=cos(ArrayData[j,k]);
             if cd='d' then writeln(j,' ',k,' ',ArrayData[j,k]);
        end;
        if cd='d' then writeln;
     end;
     writeln;
     writeln('Press any key to continue');
     repeat until keypressed;
     revise;
end;

procedure manipulate;     {operate on any two columns}
begin
     clrscr;
     writeln('This procedure is used to manipulate any two columns of your j x k');
     writeln('  matrix and create a revised column replacing the first  column');
     writeln('  that you have selected.  For example, you might wish to multiply');
     writeln('  column 3 by column 4 and then plot the product vs column 5');
     writeln('  In that event, you would end up replacing column 3 by the product of');
     writeln('  columns 3 and 4.  The listed routine is for example only and');
     writeln('  simple divides the lower numbered column by the higher numbered column');
     writeln('For any other operation (e.g., column 3 to the exponent column 5,');
     writeln('  you must go to source code and revise algorithm listed below');
     writeln;
     writeln;
     writeln('Number of rows in array = ',rows);
     writeln('Number of columns in array = ',columns);
     writeln;
     write('Enter the lowest numbered column to be selected:  ');
     readln(p);
     write('Enter the second column to be selected:  ');
     readln(q);
     for j:=1 to rows do begin

{PLACE ALGORITHM HERE}

          ArrayData[j,p]:=ArrayData[j,p] * ArrayData[j,q];

     end;
     writeln('Press any key to continue');
     repeat until keypressed;
     revise;
end;

procedure Input;

begin
     clrscr;
     write('Enter the number of rows in your data array file:     ');
     readln(x1);
     write('Enter the number of columns in your data array file:  ');
     readln(x2);
     if (x1 > 1000) or (x2 > 5) then begin
           writeln('YOU HAVE EXCEEDED ALLOWABLE ARRAY SIZE: 1000 x 5; START OVER');
           halt;
        end;
     write('Enter FileSpec for DataFile:  ');
     readln(FileSpec);
     assign(DataFile, FileSpec);
     rewrite(DataFile);
     rows:=round(x1);
     columns:=round(x2);
     writeln;
     for j:=1 to rows do begin
         for k:=1 to columns do begin
             write('Enter ArrayData[',j,' ',k,']:  ');
             readln(data);
             write(DataFile,data);
         end;
     end;
     ch:=' ';
     writeln('Do you wish to insert identifiers at end of input file which');
     writeln('will identify the number of rows and columns of the input array?  If');
     writeln('so, enter "y".');
     read(kbd,ch);
     if ch = 'y' then
        write(DataFile,x1,x2,x3); {these data may be inserted at end of file to
                                  denote the no rows (x1), the no columns
                                  (x2), and a "flag" (x3) which is used
                                  by the ReadOut procedure to determine
                                  whether to look for and use these data}
     close(DataFile);
end;

procedure Compress;  {procedure chops or compresses the arrray to a number of
                      rows specified by MaxRows}
begin
     clrscr;
     MaxRows:=32000; {default}
     ch:=' ';
     writeln('You have your choice of (1) chopping the file to a specified number');
     writeln('of rows, or (2) compressing the file by reading only a specified');
     writeln('number of rows.');
     writeln;
     writeln('For CGA monitor, limit the number of rows to 500');
     writeln;
     writeln('If you want to compress the file (not chop); enter "1"');
     read(kbd,ch);
     if ch = '1' then writeln('You have elected to COMPRESS the file') else
        writeln('You have elected to CHOP the file');
     writeln;
     write('Enter the maximum number of rows to be read from the file:  ');
     readln(MaxRows);
     clrscr;
     writeln;
     if ch <> '1' then begin
        writeln('Chopping the file readout to ',MaxRows,' rows');
        rows:=MaxRows;
     end
     else begin
        writeln('Compressing the file readout to less than ',MaxRows,' rows');
        u:=(rows/MaxRows);
        if frac(u)<>0 then ReadCycle:=round(rows/MaxRows + 0.5)
           else ReadCycle:=round(rows/MaxRows);
        rows:= round(rows/Readcycle);
     end;
end;

procedure ReadOut;
begin
     clrscr;
     i:=0;
     j:=0;
     c:=0;
     DataEntries:=0;
     v:=0;
     ReadCycle:=1;   {i.e., read each row, unless "compress"}
     ch:= ' ';
     cd:= ' ';
     ca:= ' ';
     write('Enter FileSpec for DataFile:  ');
     readln(FileSpec);
     assign(DataFile, FileSpec);
     reset(DataFile);
     NoFileEntries:=filesize(DataFile);
                               {next group of lines create data at end of file
                               to represent the number of rows and columns
                               that may have been input from above procedure}
     seek(DataFile,NoFileEntries-1);  {"1" recognizes that first file entry is #0}
     read(DataFile,v);    {"v" is flag that end of file contains file ident data}
     if v = x3 then begin
        DataEntries:=NoFileEntries - 3;    {DataEntries is no of valid data entries}
        seek(DataFile,NoFileEntries-3);
        read(DataFile,x1,x2);
        rows:=round(x1);
        columns:=round(x2);
        writeln('Number of rows in array = ',rows);
        writeln('Number of columns in array = ',columns);
        seek(DataFile,0);
     end
     else begin
        DataEntries:=NoFileEntries;
        columns:=1;    {default value}
        NoFileEntries:=filesize(DataFile);
        writeln('File size = ',NoFileEntries);
        writeln('Enter the number of columns in your data array file');
        write('  .....The limit is 5; the default value is "1":  ');
        readln(columns);
        if columns > 5 then begin
           writeln('YOU HAVE EXCEEDED ALLOWABLE ARRAY SIZE: 1000 x 5; START OVER');
           halt;
        end;
        rows:=round(NoFileEntries/columns);
        seek(DataFile,0);
     end;
     if rows >1000 then begin
        writeln('Your number of rows,',rows,', exceeds limit, 1000');
        writeln('When prompted, you may chop or compress the file to =< 1000 rows to fit array limits.');
     end;
     writeln;
     writeln('If you wish to display data, enter "d"');
     read(kbd,cd);
     writeln('Do you want printout of data ? Enter "p" if so');
     read(kbd,ch);
     writeln;
     writeln('If you need to chop or compress the length of the data file ');
     writeln(' for the purpose of satisfying the array size limits or of');
     writeln(' fitting the screen for graphing (using GRAPHXY), then ');
     writeln(' enter "c" for chop or compress');
     writeln;
     read(kbd,co);
     if co = 'c' then compress;
     clrscr;
     gotoxy(30,12);writeln('READING FILE...STANDBY');
     delay(1000);
     clrscr;
     for k:= 1 to columns do begin
         MinValue[k]:=1e12;
         MaxValue[k]:=-1e12;
     end;
     while (c < DataEntries)  do begin
        j:=j + 1;   {j is no rows of data in file}
        for k:=1 to columns do begin
            if not eof(DataFile) then read(DataFile,data);
            c:=c + 1;  {no entries read from file; stop when c = DataEntries}
            if (j-1) mod(ReadCycle) = 0 then begin
                     {i.e., display only every ReadCycle}
                if k = 1 then i:= i + 1; {i = no rows read from file}
                if cd = 'd' then writeln('Array Data[',i,',',k,'] = ',data);
                if ch = 'p' then writeln(lst,'Array Data[',i,',',k,'] = ',data);
                if rows <= 1000 then ArrayData[i,k]:=data;
                       {structure data into array}
            end;
            if data > MaxValue[k] then MaxValue[k]:=data;
            if data <= MinValue[k] then MinValue[k]:=data;
        end;
        rows:=i;
     end;
     writeln;
     for k:=1 to columns do begin
            writeln('Minimum value for column ',k,' = ',MinValue[k]);
            writeln('Maximum value for column ',k,' = ',MaxValue[k]);
            writeln;
     end;
     if rows > 1000 then writeln('SINCE YOUR NUMBER OF ROWS > 1000, YOUR DATA HAVE NOT BEEN ARRAYED.');
     delay(2000);
     ch:= ' ';
     close(DataFile);
     if co = 'c' then begin
              writeln('The length of your array has been scaled to ',rows,' rows.');
              writeln;
              writeln('Do you want to file the scaled array to disk ? "y" or "n"');
              read(kbd,ch);
              writeln;
              if ch = 'y' then begin
                 write('Enter FileSpec for reduced array:  ');
                 readln(FileSpec);
                 assign(DataFile, FileSpec);
                 rewrite(DataFile);
                 gotoxy(30,25);writeln('WRITING FILE...STANDBY');
                 for j:=1 to rows do begin
                     for k:=1 to columns do begin
                         write(DataFile,ArrayData[j,k]);
                     end;
                 end;
                 close(DataFile);
              end;
     end;
end;

procedure proced_u;  {supports spline procedure}
begin
     repeat
     u:=0;
     for i:=2 to n-1 do begin
         t:=w*(-s[i]-work[i]*s[i-1]-(0.5-work[i])*s[i+1]+g[i]);
         h:=abs(t);
         if h>u then u:=h;
         s[i]:=s[i]+t;
     end;
     until u<=eps;
end;

procedure error;  {supports spline procedure}
begin
   writeln('error in procedure spline');
   writeln('argument out of bounds');
   writeln('Xin[1] = ',Xin[1],' Xin[nG] = ',
   Xin[n],' Xout[',j,'] =',Xout[j]);
   halt;
end;


procedure spline;

begin { MAIN ROUTINE spline }
    clrscr;
    if columns >2 then begin
       writeln('You cannot spline an array of more than two columns.  Restart');
       halt;
    end
    else
    writeln('The current active file is ',FileSpec);
    writeln('Number of data sets = ',round(DataEntries/2));
    writeln;
    reset(DataFile);
    c:=1;
    j:=1;
    writeln;
    while c <= (DataEntries/2) do begin;
          read(DataFile, ArrayData[j,1],ArrayData[j,2]);
          writeln(ArrayData[j,1],' ',ArrayData[j,2]);
          c:=c + 1;
          j:=j + 1;
          writeln;
    end;
    close(DataFile);
    n:=j-1;
    writeln;
    writeln('Enter the number of output data sets.....');
    write('......if you intend to use GraphXY routine, limit data sets to 500:  ');
    readln(m);
    clrscr;
    writeln;
    writeln ('                 SPLINE PROGRAM FOR INTERPOLATION');
    writeln('            INTEGRATION AND DIFFERENTIATION OF DATA POINTS');
    writeln('                  ADAPTED FROM H-P 9845 UTILITY');
    writeln ;
    writeln;writeln;
    write('Enter error tolerances:  ');
    readln(eps);
    clrscr;
    gotoxy(34,15);writeln('CALCULATING');
    for i:=1 to n do begin
        Xin[i]:=ArrayData[i,1];
        Yin[i]:=ArrayData[i,2];
    end;
    for i:=1 to m do begin
        Xout[i]:=((Xin[n]-Xin[1])/m)*(i-1)+Xin[1];
    end;
     {all parameters have been established; begin calculation of output data}
    for i:=2 to n-1 do begin
        Xi:=Xin[i];
        XiM1:=Xin[i-1];
        XiP1:=Xin[i+1];
        Yi:=Yin[i];
        YiM1:=Yin[i-1];
        YiP1:=Yin[i+1];
        X:=Xi-XiM1;
        h:=XiP1-XiM1;
        work[i]:=0.5*X/h;
        t:=((YiP1-Yi)/(XiP1-Xi)-(Yi-YiM1)/X)/h;
        s[i]:=2*t;
        g[i]:=2*t;
    end;
    s[1]:=0;
    s[n]:=0;
    w:=8-4*sqrt(3);
             {w is the relaxation factor for successive over-relaxation}
    proced_u;
    for i:=1 to n-1 do begin
        g[i]:=(s[i+1]-s[i])/(Xin[i+1]-Xin[i]);
    end;
                                    {calculate Yout and derivatives}
    for j:=1 to m do begin
        i:=1;                                     {corrector}
        t:=Xout[j];
        if t<Xin[1] then error;
        repeat
              i:=i+1;
              if i>n then error;
        until  t<=Xin[i];
        i:=i-1;
        h:=Xout[j]-Xin[i];
        t:=Xout[j]-Xin[i+1];
        X:=h*t;
        ss:=s[i]+h*g[i];
        zz:=1/6;
        u:=zz*(s[i]+s[i+1]+ss);
        w:=(Yin[i+1]-Yin[i])/(Xin[i+1]-Xin[i]);
        Yout[j]:=w*h+Yin[i]+X*u;
        deriv[j]:=w+(h+t)*u+zz*X*g[i];
    end;
         {calculate integral from Xin[1] to Xin[n]}
    integral:=0;
    for i:=1 to n-1 do begin
        h:=Xin[i+1]-Xin[i];
        integral:=integral+0.5*h*(Yin[i]+Yin[i+1])-1/24 * sqr(h) * h *(s[i]+s[i+1]);
    end;
    ch:=' ';
    writeln('Enter "y" if you want screen display of splined data; else hit any other key');
    read(kbd,ch);
    clrscr;
    writeln('Error tolerance= ',eps);
    writeln;
    if ch = 'y' then writeln ('         Xout ','                    Yout','             DERIVATIVE VALUE');
    writeln;
    for i:=1 to m do begin
       if ch = 'y' then writeln (Xout[i],' ',Yout[i],' ',deriv[i]);
       ArrayData[i,1]:=Xout[i];
       ArrayData[i,2]:=Yout[i];
    end;
    if ch = 'y' then writeln(Xin[n],' ',Yin[n]);
    writeln;
    writeln('integral from X = ',Xin[1]:8,' to X = ',Xin[n]:8,'=',integral);
    writeln;
    write('Enter FileSpec for splined data to be filed:  ');
    read(FileSpec);
    assign(DataFile, FileSpec);
    {$I-} rewrite(DataFile) {$I+};
    if IOresult <> 0 then begin
       writeln ('File not specified.  Program halted');
       halt;
    end;
    for j:=1 to m do begin
         write(DataFile,ArrayData[j,1],ArrayData[j,2]);
    end;
    close(DataFile);
    rows:=m;
    columns:=2;
    clrscr;
end;

begin         {MAIN PROGRAM}
   clrscr;
   ch:=' ';
   rows:=0;
   columns:=0;
   x3:=1e12;  {x3 is flag identifying file created by this code}
   intro;
   clrscr;
   repeat
   if columns <>0 then begin
        writeln('**********************************************************');
        writeln('You are working with an array of ',rows,' rows x ',columns,' columns');
        writeln;
        writeln('The active FileSpec is ',FileSpec);
        writeln('**********************************************************');
        writeln;
        writeln('Press any key to continue');
        repeat until keypressed;
   end;
   ch:=' ';
   clrscr;
   writeln;
   writeln('*******************************************************************');
   writeln('                               MENU');
   writeln('Input a data array ? Enter "i"');
   writeln;
   writeln('Read a data file ? This includes the option of chopping or compressing');
   writeln(' the file and structuring the data. Enter "r"');
   writeln;
   writeln('Correct/alter data ? [You must first input or readout the data file] Enter "c"');
   writeln;
   writeln('Extract specific columns from array for graphing? Enter "e"');
   writeln;
   writeln('Perform Math operations on any column of array? Enter "m"');
   writeln('      [If so, you should review source code procedure "operate"]');
   writeln;
   writeln('Cause one column to operate upon a second column of Array ? Enter "a"');
   writeln('      [If so, you should review source code procedure "manipulate"]');
   writeln;
   writeln('Spline x,y data ? [You must first input or readout the data file] Enter "s"');
   writeln;
   writeln('Enter "h" to halt/quit');
   read(kbd,select);

   case select of
        'c' : Correct;
        'e' : Extract;
        'm' : Operate;
        'r' : Readout;
        'i' : Input;
        's' : Spline;
        'a' : Manipulate;
   end;
   until select = 'h';
   clrscr;
end.

***************
[Potentially Useful Math Functions]

PROCEDURE tan;
              begin
                   y:=sin(x)/cos(x);
              end;


PROCEDURE arcsin;
               begin
                  y:=sqr(x);y:=1-y;y:=sqrt(y);
                  y:=x/y;y:=arctan(y);
               end;

PROCEDURE arccos;
               begin
                  y:=sqr(x);y:=1-y;y:=sqrt(y);
                  y:=y/x;y:=arctan(y);
               end;

PROCEDURE  log;
          begin
                 y:=ln(x)/ln(10);
           end;

PROCEDURE invlog;
           begin
                 y:=exp(x)*exp(x * (ln(10)-1));
           end;

PROCEDURE  ln;
           begin
                 y:=ln(x);
           end;

PROCEDURE  exp;
              begin
                   y:=exp(x);
              end;

PROCEDURE exponent(var x,y,n:real);
          begin
              y:=n*ln(x);y:=exp(y);    {y=x^expon}
          end;
*******************
