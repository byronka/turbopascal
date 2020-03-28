Program whole; {rev 11-5-87; 2-3-89}

(* This code will disect any real number and round it into a whole number
   and its exponent.  Used for graph codes *)

var
RealNumber,
Exponent,
a,
mantissa,
WholeNumber,
number : real;
NegFlag : integer;



begin
clrscr;
writeln('This code will disect any real number and round it into a whole number');
writeln('   and its exponent.  Used for graph codes');
writeln;
writeln('input RealNumber  ');
readln(RealNumber);
NegFlag:=0;
Exponent:=0;
if RealNumber<>0 then begin;
     if (RealNumber)<0 then NegFlag:=1;   {set flag to 1 if RealNumber negative}
     a:=ln(abs(RealNumber))/ln(10);   {take log of RealNumber}
     Exponent:=trunc(a);
     mantissa:=a - Exponent;
     WholeNumber:=exp(mantissa) * exp(mantissa * (ln(10)-1));   {take invlog
                                                          of mantissa}
     WholeNumber:=round(WholeNumber);      {this is rounded RealNumber between 1 and 10}
     if NegFlag=1 then WholeNumber:= -WholeNumber;
     number:=exp(Exponent * ln(10))* WholeNumber; {this is RealNumber raised to Exponent}
end;
clrscr;
writeln('RealNumber ',RealNumber:12);
writeln('Mantissa = ',WholeNumber:4);
writeln('Exponent = ',Exponent:4);
writeln('Final Display =  ',number:6);
end.



