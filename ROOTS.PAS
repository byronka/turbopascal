program recurssive ;   {6/1/86; rev 2-7-89}
{$U+}
{This procedure allows fast root determination using a modified "secant"
 technique}

var
   xx,
   yy,
   intercept,
   slope
               : array[1..500] of real;

   DeltaX,
   ord,
   absc,
   y1,
   y2,
   root,
   spec
               : real;

   count,
   repeats,
   number,i    : integer;

   ch          : char;

procedure expression (absc : real);   {insert expression requiring root determination}

var
   a,b,c :real;

begin
   a:= 0.1;  {enter coefficients of expression here}
   b:= -2;
   c:= 3;

(************************  expression goes here: *******************************)

                    ord:= a * sqr(absc) + (b * absc) + c;
                   {ord:= a * sin(absc);}

(********************************************************************************)
end;

begin               {MAIN}
   clrscr;
   writeln('Enter the number of roots you wish to derive');
   readln(number);
   spec:=1e-4;    {accuracy required}
   count:=0;
   root:=1e-24;   {avoid indeterminate}
   repeats:=0;

repeat
   DeltaX:=1e-1;
   repeats:=repeats + 1;
   i:=1;
   xx[1]:=root;
   absc:=xx[1];
   expression(absc);
   yy[1]:=ord;
   repeat
      repeat
         i:=i + 1;
         xx[i]:=xx[i-1] + DeltaX;
         absc:=xx[i];
         expression(absc);
         yy[i]:=ord;
         y1:=yy[i-1];
         y2:=yy[i];
         if yy[i] = 0 then begin
            root := xx[i];
         end;
      until yy[i-1]/yy[i]<0 ;
      count:=count + 1;
      slope[count]:=(yy[i] - yy[i-1])/DeltaX;
      intercept[count]:=xx[i-1] - (yy[i-1]/slope[count]);
      DeltaX:=DeltaX/10;
      xx[1]:=xx[i-1];
      yy[1]:=yy[i-1];
      y1:=yy[i-1];
      y2:=yy[i];
      i:=1;
   until (count>=2) and (abs((intercept[count]-intercept[count-1]))<spec);
   root:=intercept[count];
   writeln('root [',repeats,'] = ',root);
   absc:=root;
   expression(absc);
   writeln('value of ord at root = ',ord);
   writeln;writeln;
until (repeats>=number) or ((root - intercept[count-1])/intercept[count-1] < 1e-3);

end.
*************
