
program Simulate;  {8-15-86; rev 1-21-89}

(*
This program may be used to simulate a second order lag system:

       Output/Input =  1/[(s/omega)^2) +(2*zeta/omega) * s + 1]

       where omega is natural frequency * 2 * pi, rad/sec
             zeta is damping ratio [0-1.0]

Or, a first order lag system:
       Output/Input =  1/[Tau * s + 1]

       where tau is corner frequency * 2 * pi, rad/sec
*)

var
   Output_o,       {The "_o" variables denote initial output conditions}
   Input_o,
   OutputDot_o,
   OutputDoubleDot_o,
   Tau,
   Corner,
   NaturalFreq,
   Zeta,
   Omega,
   DampCoef,
   MaxTime,
   Damping,
   a,b,c,d,
   tdd1,tdd2,td1,td2,t1,t2,
   DeltaTime,
   Output,OutputDot,OutputDoubleDot,
   duration,value,slope,frequency,
   Input, Error, Time, Signal, u    : real;

   i,n,count                        : integer;

   datafile                         : file of real;

   filespec                         : string[20];

   ArrayData                        : array [1..1000,1..2] of real;

   rows,
   j,k,m,
   MaxRows,
   ReadCycle,
   NoFileEntries,
   CompressFlag                     : integer;

   ch,select,choose,order,
   cd,ca                            : char;

procedure SecOrdCalc(tdd1, td1, t1, I : real);
begin
        tdd2:=sqr(Omega) * (I - (2 * Damping * td1) - t1);
        td2:=(tdd1 + tdd2) * DeltaTime/2 + td1;
        t2:=(td1 + td2) * DeltaTime/2 + t1;
end;

procedure FirstOrdCalc(td1, t1, I : real);
begin
        td2:=(I - td1 * DeltaTime - t1)/Tau;
        t2:=(td1 + td2) * DeltaTime/2 + t1;
end;

procedure step;
begin
     Input:=Input_o;
end;

procedure ramp;
begin
     Input:=Input_o + (slope * Time);
end;

procedure sine;
begin
     Input:=value * sin(frequency * Time * 2 * pi);
end;

procedure compound_ramp;
begin
     if Input < value then Input:=Input_o + (slope * Time)
     else Input:=value;
end;

procedure square_wave;
begin
     if Time < duration then Input:=Input_o
     else Input:=0;
end;

procedure InputCalc;     {place any time function of Input here}
begin
     case select of
          '0' : step;
          '1' : ramp;
          '2' : sine;
          '3' : compound_ramp;
          '4' : square_wave
     end;
end;

procedure Intro1;
begin
    writeln('This procedure simulates a first order lag system');
    writeln('     with user selectable input : ');
    writeln;
    writeln('       Output/Input =  1/[Tau * s + 1]');
    writeln;
    writeln('       where Tau is corner frequency * 2 * pi, rad/sec');
    writeln;
    Input_o:=0; Output_o:=0; OutputDot_o:=0;
    ch:=' ';
end;

procedure Intro2;
begin
    writeln('This procedure simulates a second order lag system');
    writeln('     with user selectable input : ');
    writeln;
    writeln('       Output/Input =  1/[(s/omega)^2) +(2*zeta/omega) * s + 1]');
    writeln;
    writeln('       where omega is natural frequency * 2 * pi, rad/sec');
    writeln('             zeta is damping ratio [0-1.0]');
    writeln;
    Input_o:=0; Output_o:=0; OutputDot_o:=0; OutputDoubleDot_o:=0;
    ch:=' ';
end;

procedure Compress;
begin
     CompressFlag:=1;
     MaxRows:=500;
     u:=(rows/MaxRows);
     if frac(u)<>0 then ReadCycle:=round(rows/MaxRows + 0.5)
        else ReadCycle:=round(rows/MaxRows);
end;

procedure ReadOut;
begin
     clrscr;
     gotoxy(30,10);writeln('STANDBY');
     for i:=1 to 500  do begin
         for k:=1 to 2 do begin
             ArrayData[i,k]:=0;
         end;
     end;
     i:=1;
     j:=0;
     c:=0;
     ReadCycle:=1;
     MaxRows:=500;
     CompressFlag:=0;
     ch:= ' ';
     cd:= ' ';
     ca:= ' ';
     reset(DataFile);
     NoFileEntries:=filesize(DataFile);
     rows:=round(NoFileEntries/2);
     if rows >500 then Compress;
     while not eof(DataFile) do begin
            read(DataFile,Time,Signal);
            if j mod(ReadCycle) = 0 then begin
                ArrayData[i,1]:=Time;   {structure data into array}
                ArrayData[i,2]:=Signal;
                i:=i + 1;
            end;
            j:=j + 1;
     end;
     close(DataFile);
     if CompressFlag = 1 then begin
           rows:=i - 1;
           rewrite(DataFile);
           clrscr;
           gotoxy(30,10);writeln('WRITING COMPRESSED FILE...STANDBY');
           for i:=1 to rows do write(DataFile,ArrayData[i,1],ArrayData[i,2]);
           close(DataFile);
     end;
end;

begin       {MAIN PROGRAM}

    ch:=' ';
    Output:=0; OutputDot:=0;OutputDoubleDot:=0;
    clrscr;
    gotoxy(1,12);writeln('        This program may be used to simulate either a 2nd order or');
    writeln('            a 1st order filter transient response');
    writeln;
    writeln('        Choose either the 1st order (1) or the 2nd order (2)');
    read(kbd,order);
    clrscr;
    if order='2' then Intro2 else Intro1;
    if order='2'then begin
       writeln('Enter natural frequencey, hz');
       readln(NaturalFreq);
       writeln('Enter damping fraction');
       readln(Zeta);
       Omega:=NaturalFreq * 2 * pi;
       Damping:=Zeta/Omega;
    end
    else begin
        writeln('Enter corner frequency, hz');
        readln(Corner);
        Tau:=1/(Corner * 2 * pi);
    end;
    writeln('Choose variable to be output vs time : Output (o) or Error (e)');
    read(kbd,choose);
    clrscr;
    if choose = 'o' then writeln('Enter filespec for storing output data; e.g, b: simulate.dat')
    else writeln('Enter filespec for storing error data; e.g. b: simulate.dat');
    readln(filespec);
    assign(datafile,filespec);
    rewrite(datafile);
    clrscr;

    writeln('Select the input function you wish to simulate');
    writeln;
    writeln('       0 is simple step input');
    writeln('       1 is simple ramp input');
    writeln('       2 is sine wave input');
    writeln('       3 is ramp to constant value input');
    writeln('       4 is square wave input');
    read(kbd,select);
    writeln;
    if select='0' then begin
       writeln('Enter step value of Input');
       readln(Input_o);
    end;

    if select='1' then begin
       writeln('Enter initial value of Input for simple ramp. Default is 0');
       readln(Input_o);
       writeln('Enter ramp slope, 1/sec');
       readln(slope);
    end;
    if select='2' then begin
       writeln('Enter amplitude of sine wave');
       readln(value);
       writeln('Enter frequency, Hz, of sine wave');
       readln(frequency);
    end;
    if select='3' then begin
       writeln('Enter initial value of Input for ramp to constant value. Default is 0');
       readln(Input_o);
       writeln('Enter ramp slope, per sec');
       readln(slope);
       writeln('Enter value at which ramp concludes');
       readln(value);
    end;
    if select='4' then begin
       writeln('Enter value of step input for square wave');
       readln(Input_o);
       writeln('Enter time duration, sec, of square wave');
       writeln('      Note: duration should be multiple of integration time steps');
       readln(duration);
    end;
    writeln('Enter inital value of Output. Default is 0.');
    readln(Output);
    writeln('Enter inital value of Output rate, per sec. Default is 0');
    readln(OutputDot);
    clrscr;
    writeln('Enter time increment, sec');
    readln(DeltaTime);
    writeln;
    writeln('Enter end time, sec');
    readln(MaxTime);
    Input:=Input_o;
    Time:=0;
    clrscr;
    gotoxy(30,10);writeln('ITERATING');
    repeat
        InputCalc;
        if order='2' then SecOrdCalc(OutputDoubleDot,OutputDot,Output,Input)
        else FirstOrdCalc(OutputDot,Output,Input);
        OutputDoubleDot:=tdd2;
        OutputDot:=td2;
        Output:=t2;
        Time:=Time + DeltaTime;
        Error:=Input - Output;
        if choose='e' then Signal:=Error
            else Signal:=Output;
        write(datafile,Time,Signal);
    until Time>=MaxTime;
    close(datafile);
    ReadOut;
    clrscr;
    If CompressFlag = 1 then
       writeln('Size of compressed file, ',filespec,' = ',rows);
    writeln;
    writeln('You may use the program GRAPHXY.PAS/COM to graph the file, ',filespec,',');
    writeln('for the Output or Error signal as a function of time.  If you do not have ');
    writeln('this code, you will find it on the bulletin board from which you found');
    writeln('SIMULATE.PAS/COM.');
end.
