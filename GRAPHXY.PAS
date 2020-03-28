


Program GraphXY;     {5-4-87; revised 1-23-88}
                     {revised 9-7-92 to incl defaults}
(*************************************************************************
This code was written by Ellis Katz, tel (818) 783-1318, to retrieve Y vs X
data (in an array of up to 500 x 2), to graph the function, to caption the
axes and title the graph.  The code may be used effectively in combination
with Filing.pas/com.
 *************************************************************************)


{$I typedef.sys}                {include graphics system}
{$I graphix.sys}
{$I kernel.sys}



var

   data : array[1..500, 1..10] of real; { data[1,1]=x[1]; data[1,2]=y[1]; etc}
   i,                               {index for world and window and counter}
   j,k,l,m,                         {indicies for reading data from datafile}
   iDataMax : integer;              {maximum index for x,y function}
   datafile : file of real;
   xmin,
   ymin,
   xmax,
   ymax     : real;                  {max and min values of x,y in datafile}

   xValue,
   yValue,         {values of x and y derived from pixel count}
   xValuePerPixel,
   yValuePerPixel, {incremental values of x,y per pixel}
   xTic,
   yTic,           {incremental values of x, y between tic marks}
   value,          {value from which to make whole number}
   mantissa,       {mantissa of "value"}
   exponent,       {exponent of "value"}
   number,         {re-formed "value"}
   xCap,
   yCap,           {summation of xTic; used to caption axis tic marks}
   xCap0,
   yCap0,          {most negative caption for negative axes}
   xCap1,
   yCap1,          {most positive caption for positive axes}
   xMinScale,
   yMinScale,      {minimum integer values of x and y at lower left hand }
   xMaxScale,
   yMaxScale,      {maximum integer values of x and y at upper right hand }
   xRange,
   yRange,         {x,y maxscale - x,y minscale}
   xPixel,
   yPixel,         {pixel coordinates in screen space}
   xPixel1,
   yPixel1,        {lower left hand corner of graph space}
   xDeltaPix,
   yDeltaPix,      {no pixels between x,y tic marks on axes}
   xPixel0,
   yPixel0,        {screen locations of X and Y axes}
   xPix1,
   xPix2,
   yPix1,
   yPix2,          {screen locations of x,y function data}
   xMainTitlePixel,
   yMainTitlePixel,
   xSubTitlePixel,
   ySubTitlePixel, {pixel locations for beginning titles}
   xTicDensity,
   yTicDensity,     {number of tics on positive or negative X,Y axes,
                     whichever is the greater}
   a,b             {intermediate variables, real}
   : real;

   NoXtics,
   NoYtics,        {total number of tics on X,Y axes}
   NegFlag,        {flag to denote negative value}
   n               {counter}
   :integer;

   CapString : string[10];
   xCapString,
   yCapString : array[1..50] of string[10];
   xTitle,
   yTitle,
   MainTitle,
   SubTitle   : string[100];
   filespec   : string[20];  {provides inputting filespec}
   c,ch,cq    : char;


Procedure Intro;
begin

writeln('(*************************************************************************)');
writeln('This code was written by Ellis Katz, tel (818) 783-1318, to retrieve Y vs X');
writeln('  data (in an array of up to 500 x 2), to graph the function, to caption the');
writeln('  axes and title the graph.  The code may be used effectively in combination');
writeln('  with Filing.pas/com.');
writeln;
writeln('The code will call an x,y data file you previously wrote to disk.');
writeln('  It will then ask that you set the scale of the axes, title the captions,');
writeln('  and title the graph.  It will then plot the data on the screen.  You can');
writeln('  print out using the shift-PrtSc command.');
writeln;
writeln('To terminate the program, enter "q" after forming the graph.');
writeln('(*************************************************************************)');
gotoxy(1,24);writeln('Press any key to continue');
repeat until keypressed;
end;

Procedure WholeNumber(var value:real);

begin
NegFlag:=0;
exponent:=0;
     if value<>0 then begin;
     if (value)<0 then NegFlag:=1;   {set flag to 1 if value negative}
     a:=ln(abs(value))/ln(10);   {take log of value}
     exponent:=trunc(a);
     mantissa:=a - exponent;
     value:=exp(mantissa) * exp(mantissa * (ln(10)-1));   {take invlog
                                                          of mantissa}
     if NegFlag=1 then value:= -value;
     number:=exp(exponent * ln(10))* value; {this is value raised to exponent}
     end;
end;

procedure Retrieve;       {retrieve data file and read out data}

begin
     gotoxy(20,10);writeln('Retrieving data from file');
     assign(datafile, filespec);
     reset(datafile);
     i:=0;
     while not eof(datafile) do
        begin
             i:=i + 1;
             if i>500 then begin
                clrscr;
                writeln('NO. ENTRIES EXCEED MAX ALLOWABLE (500)');
                halt;
             end;
             read(datafile, data[i,1], data[i,2]);
             iDataMax:=i;
        end;

     xmin:=0;
     ymin:=0;
     xmax:=0;
     ymax:=0;
     for i:=1 to iDataMax do
         begin
             if data[i,1]<=xmin then xmin:=data[i,1];
             if data[i,1]>xmax then xmax:=data[i,1];
             if data[i,2]<=ymin then ymin:=data[i,2];
             if data[i,2]>ymax then ymax:=data[i,2];
         end;

     close(datafile);
     clrscr;
end;

procedure Integers;
begin
     clrscr;
{ the enclosed lines are to be used in the event of a broad matrix
     gotoxy(10,1);writeln('You must identify the integers which identify the x and y data');
     gotoxy(12,2);writeln('columns in data matrix stored in drv b.');
     gotoxy(10,4);writeln('Input x  integer identifier for data from file');
     readln(j);
     gotoxy(10,6);writeln('Input y  integer identifier for data from file');
     readln(k);
}
     j:=1; k:=2;
     clrscr;
end;

procedure AxesInputs;

          {We establish a working screen (window) area of 600 x 200
          pixels which is the total available graphing space}
          {xPixel1, yPixel1 are the lower left coord of frame for graphing;
          i.e, xPixel1=>0 and yPixel1=<200 }
          {We define each x position between 0 and 600 as "xPixel" and each
          y position between 0 and 200 as "yPixel" }
          {we define value of x (e.g., -1.5E-2) or y as "x" or "y"}

begin

     c:=' ';
     xPixel1:=100; yPixel1:=30;  {we have up to 500 pixels in x and
                                  up to 170 pixels in y within graph space;

                                  margins are for captions}
repeat        {enables recycling of program}
     clrscr;
     gotoxy(20,1);writeln('******** INPUT DATA *********');

     gotoxy(10,2);writeln('xmin ',xmin:8,' ','ymin ',ymin:8,' ','xmax ',xmax:8,' ','ymax ',ymax:8);
     gotoxy(1,4);writeln('The above are the min and max values of the data you have called from');
     gotoxy(1,5);writeln(filespec,'  You may now set the scales for the axes.  In order to have');
     gotoxy(1,6);writeln('well-ordered axes, you should use rounded-off values (e.g. 200; not 220)');
     gotoxy(1,7);writeln('such that the total range from min to max on an axis evenly divides into');
     gotoxy(1,8);writeln('an integer of 10 or less.  If you dont like the resulting inputs or');
     gotoxy(1,9);writeln('graph, you can replay the code with revised inputs.');

     xMinScale:=0;
     yMinScale:=0;
     xMaxScale:=xmax;
     yMaxScale:=ymax;   {default values}
     gotoxy(10,11);write('Input minimum integer value of X scale; if >0 enter 0:  ');
     readln(xMinScale);
     gotoxy(10,13);write('Input minimum integer value of Y scale; if >0 enter 0:  ');
     readln(yMinScale);
     gotoxy(10,15);write('Input maximum integer value of X scale:  ');
     readln(xMaxScale);
     gotoxy(10,17);write('Input maximum integer value of Y scale:  ');
     readln(yMaxScale);
     clrscr;
     gotoxy(1,8);writeln('You have input the following scale limits on the X and Y axes');
     gotoxy(20,10);writeln('Maximum X scale limit = ',xMaxScale:8);
     gotoxy(20,11);writeln('Maximum Y scale limit = ',yMaxScale:8);
     gotoxy(20,12);writeln('Minimum X scale limit = ',xMinScale:8);
     gotoxy(20,13);writeln('Minimum Y scale limit = ',yMinScale:8);
     gotoxy(10,15);writeln('In order to evenly space tics on axes and get rounded captions,');
     gotoxy(12,16);writeln('you should set the number of tics per axis so that the scale');
     gotoxy(12,17);writeln('divided by the input no. of tics is a rounded caption');
     gotoxy(10,19);writeln('The X scale range is ',(xMaxScale-xMinScale):10);
     gotoxy(10,20);writeln('The Y scale range is ',(yMaxScale-yMinScale):10);
     gotoxy(1,1);write('If satisfied with inputs, enter "y":  ');
     read(kbd,c);
  until (c='y') or (c='Y');
     xTicDensity:=1;
     yTicDensity:=1;  {default values}
     gotoxy(20,3);write('input number of tics on  * X * axes:  ');
     readln(xTicDensity);
     gotoxy(20,5);write('Input number of tics on  * Y * axes:  ');
     readln(yTicDensity);
     ch:=' ';
     clrscr;
     gotoxy(10,15);write('Enter "t" if you wish to enter or change titles on chart:  ');
     read(kbd,ch);
     if ch='t' then begin
        writeln;
        write('Enter title for X axis:  ');
        readln(xTitle);
        write('Enter title for Y axis:  ');
        readln(yTitle);
        write('Enter main title for graph:  ');
        readln(mainTitle);
        write('Enter sub title for graph:  ');
        readln(subTitle);
     end;
     ch:=' ';
     xMainTitlePixel:=150;yMainTitlePixel:=190;xSubTitlePixel:=150;ySubTitlePixel:=180;
     clrscr;
     gotoxy(10,15);write('Enter "p" if you wish to enter or change locations of titles:  ');
     read(kbd,ch);
     if ch='p' then begin
        writeln;
        write('Enter xPixel loc to begin Main Title; "1" is far left..."600 far right:  ');
        readln(xMainTitlePixel);
        write('Enter yPixel location to begin Main Title; "1" is bottom..."200" is top:  ');
        readln(yMainTitlePixel);
        write('Enter xPixel location to begin Sub Title:  ');
        readln(xSubTitlePixel);
        write('Enter yPixel location to begin Sub Title:  ');
        readln(ySubTitlePixel);
     end;

              {avoid zero values; can cause log hangups}

     if xMinScale = 0 then xMinScale := xMaxScale/1E6;
     if xMaxScale = 0 then xMaxScale := xMinScale/1E6;
     if yMinScale = 0 then yMinScale := yMaxScale/1E6;
     if yMaxScale = 0 then yMaxScale := yMinScale/1E6;

             {if all values are negative, reverse signs
              and label axes appropriately}

     if xMaxScale<0 then
     begin
        xMinScale:=-xMinScale;
        xMaxScale:=-xMaxScale;
     end;
     if yMaxScale<0 then
     begin
        yMinScale:=-yMinScale;
        yMaxScale:=-yMaxScale;
     end;

    {establish axes locations in world frame}

     xCap0:=xMinScale;
     value:=xCap0;
     WholeNumber(value);
     xCap0:=(number);

     xCap1:=xMaxScale;
     value:=xCap1;
     WholeNumber(value);
     xCap1:=(number);

     yCap0:=yMinScale;
     value:=yCap0;
     WholeNumber(value);
     yCap0:=(number);

     yCap1:=yMaxScale;
     value:=yCap1;
     WholeNumber(value);
     yCap1:=(number);

        {definitions}

     xRange:=xCap1-xCap0;
     yRange:=yCap1-yCap0;
     xValuePerPixel:=xRange/(550-xPixel1);
     yValuePerPixel:=yRange/(190-yPixel1);

        {establish number of pixels per tic}

     xDeltaPix:=((550-xPixel1)/xTicDensity);
     yDeltaPix:=((190-yPixel1)/yTicDensity);

         {establish screen locations of X,Y axes}

     if xCap0>=0 then xPixel0:=xPixel1
     else begin
          xPixel:=100;
          n:=0;
          xValue:=xCap0;
          while xValue<0 do begin;
                n:=n + 1;
                xPixel:=xPixel + 1;
                xPixel0:=xPixel;
                xValue:=xCap0 + (n * xValuePerPixel);
          end;
     end;

     if yCap0>=0 then yPixel0:=yPixel1
     else begin
          yPixel:=30;
          n:=0;
          yValue:=yCap0;
          while yValue<0 do begin;
                n:=n + 1;
                yPixel:=yPixel + 1;
                yPixel0:=yPixel;
                yValue:=yCap0 + (n * yValuePerPixel);
          end;
     end;

        {We have now located the X and Y axes in world frame and we
        have established the lower left hand captions (e.g., yCap0)
        to mark initial tics.  Now to determine the captions that denote
        the value per tic for each axis}


     if abs(xMaxScale)>=abs(xMinScale) then begin
        xCap:=xCap0;
        i:=1;                           {create array to be read
                                        from graphics for captions}
        CapString:=' ';
        repeat
            value:=xCap;
            if abs(value)<abs(xCap1/1E3) then value:=0;       {avoid "real"
                                                               residuals}
            str(value:8,CapString);       {convert value to string for
                                           captioning graphs}
            xCapString[i]:=CapString;   {store caption strings in array}
            xCap:=(xCap + (xValuePerPixel * xDeltaPix));
            NoXtics:=i;
            i:=i + 1;
        until (xCap)>(xCap1);
     end
     else begin
        xCap:=xCap0;
        i:=1;                           {create array to be read
                                        from graphics for captions}
        repeat
            value:=xCap;
            if abs(value)<abs(xCap1/1E3) then value:=0;       {avoid "real"
                                                               residuals}
            str(value:8,CapString);       {convert manissa to string for
                                           captioning graphs}
            xCapString[i]:=CapString;     {store caption strings in array}
            xCap:=(xCap + (xValuePerPixel * xDeltaPix));
            NoXtics:=i;
            i:=i + 1;
        until (xCap)>(xCap1);
     end;
     if abs(yMaxScale)>=abs(yMinScale) then begin
        yCap:=yCap0;
        i:=1;                           {create array to be read
                                         from graphics for captions}
        CapString:=' ';
        repeat
            value:=yCap;
            if abs(value)<abs(yCap1/1E3) then value:=0;       {avoid "real"
                                                               residuals}
            str(value:8,CapString);       {convert value to string for
                                           captioning graphs}
            yCapString[i]:=CapString;     {store caption strings in array}
            yCap:=(yCap + (yValuePerPixel * yDeltaPix));
            NoYtics:=i;
            i:=i + 1;
        until (yCap)>(yCap1);
     end
     else begin
        yCap:=yCap0;
        i:=1;                           {create array to be read
                                        from graphics for captions}
        repeat
            value:=yCap;
            if abs(value)<abs(yCap1/1E3) then value:=0;       {avoid "real"
                                                               residuals}
            str(value:8,CapString);       {convert value to string for
                                           captioning graphs}
            yCapString[i]:=CapString;     {store caption strings in array}
            yCap:=(yCap + (yValuePerPixel * yDeltaPix));
            NoYtics:=i;
            i:=i + 1;
        until (yCap)>(yCap1);
     end;

end;         {of procedure AxesInputs}


Procedure InputData;     {2-7-86}
        {This file may be used to create data file for graphing}
var
   data            : array [1..1000,1..2] of real;
   datafile        : file of real;
   x,y,number      : integer;
   ch              : char;

begin
     clrscr;
     assign(datafile, filespec);
     rewrite(datafile);
     x:=0;
     ch:=' ';
     while ch<>'q' do begin;
             x:=x + 1;
             for y:=1 to 2 do begin;
                 writeln; writeln('input column ',y,' data for row  ',x);
                 readln(data[x,y]);
                 write(datafile, data[x,y]);
                 if y=2 then begin;
                    writeln('Satisfied with input? If not enter "n"');
                    read(kbd,ch);
                    if ch='n' then begin
                       x:=x-1; y:=y-1;
                       writeln('Reenter your data');
                    end;
                 writeln('To quit input, enter "q"; otherwise press space bar ');
                 end;
             end;
             read(kbd,ch);
     end;
     close(datafile);
end; {of procedure InputData}

begin                                   {MAIN PROGRAM}
  clrscr;
  c:=' ';
  intro;
  clrscr;
  gotoxy(7,15);write('Enter filespec for retrieving data from disk:  ');
  readln(filespec);
  Integers;
  Retrieve;                             {get data from disk file}
  xTitle:=' ';yTitle:=' ';mainTitle:=' ';subTitle:=' ';   {default titles}
  repeat;                                  {creates "input loop"}
  clrscr;
  cq:=' ';
  gotoxy(10,15);write('Enter "q" to quit code following graph presentation:  ');
  read(cq);
  AxesInputs;                           {input parameters to form axes}



  InitGraphic;                    {initialize the graphics system}
  DefineWorld(1,0,0,600,200);     {make world equal to screen pixel count}
  SelectWorld(1);
  SelectWindow(1);

  for i:=1 to NoXtics  do
  begin                           {draw X axis}
       xPixel:=(xPixel1 + ((i-1) * xDeltaPix));
       yPixel:=yPixel0 - 5;        {create 5 pixel tic marks}
       DrawLine(xPixel1,yPixel0,xPixel1,yPixel);  {make 1st tic mark}
       DrawLine(xPixel1,yPixel,xPixel1,yPixel0);  {tic mark made}
       if (yPixel0<35) or (abs(xPixel-xPixel0)>5) then begin {avoid caption
                                                              interference}
              DrawTextW(xPixel-30,yPixel0-10,1,xCapString[i]);
       end;
       DrawLine(xPixel1,yPixel0, xPixel, yPixel0);
       DrawLine(xPixel,yPixel0,xPixel,yPixel);    {make added tick marks}
       DrawLine(xPixel,yPixel,xPixel,yPixel0);
  end;

  for i:=1 to NoYtics  do
  begin                           {draw Y axis}
       yPixel:=(yPixel1 + ((i-1) * yDeltaPix));
       xPixel:=xPixel0 - 5;        {create 5 pixel tic marks}
       DrawLine(xPixel0,yPixel1,xPixel,yPixel1);  {make 1st tic mark}
       DrawLine(xPixel,yPixel1,xPixel0,yPixel1);  {tic mark made}
       if (xPixel0<105) or (abs(yPixel-yPixel0)>5) then begin
              DrawTextW(xPixel0-55,yPixel,1,yCapString[i]);
       end;
       DrawLine(xPixel0,yPixel1, xPixel0, yPixel);
       DrawLine(xPixel0,yPixel,xPixel,yPixel);    {make added tick marks}
       DrawLine(xPixel,yPixel,xPixel0,yPixel);
  end;

      {draw intermediate tic marks}

  for i:=1 to (2* NoXtics)-1  do
  begin                           {draw X axis}
       xPixel:=(xPixel1 + ((i-1) * xDeltaPix/2));
       yPixel:=yPixel0 - 3;        {create 3 pixel tic marks}
       DrawLine(xPixel1,yPixel0,xPixel1,yPixel);  {make 1st tic mark}
       DrawLine(xPixel1,yPixel,xPixel1,yPixel0);  {tic mark made}
       DrawLine(xPixel1,yPixel0, xPixel, yPixel0);
       DrawLine(xPixel,yPixel0,xPixel,yPixel);    {make added tick marks}
       DrawLine(xPixel,yPixel,xPixel,yPixel0);
  end;

  for i:=1 to (2 * NoYtics)-1  do
  begin                           {draw Y axis}
       yPixel:=(yPixel1 + ((i-1) * yDeltaPix/2));
       xPixel:=xPixel0 - 3;        {create 3 pixel tic marks}
       DrawLine(xPixel0,yPixel1,xPixel,yPixel1);  {make 1st tic mark}
       DrawLine(xPixel,yPixel1,xPixel0,yPixel1);  {tic mark made}
       DrawLine(xPixel0,yPixel1, xPixel0, yPixel);
       DrawLine(xPixel0,yPixel,xPixel,yPixel);    {make added tick marks}
       DrawLine(xPixel,yPixel,xPixel0,yPixel);
  end;

       {draw function curves}

  for i:=2 to iDataMax do
  begin
       xPix1:=xPixel1 + (data[i-1,j] -  xMinScale) / xValuePerPixel;
       xPix2:=xPixel1 + (data[i,j] - xMinScale) / xValuePerPixel;
       yPix1:=yPixel1 + (data[i-1,k] -  yMinScale) / yValuePerPixel;
       yPix2:=yPixel1 + (data[i,k] - yminScale) / yValuePerPixel;
       Drawline(xPix1,yPix1,xPix2,yPix2);
 end;

       {draw titles for X and Y axes and for main and sub titles}

  DrawTextW(200,10,1,xTitle);
  DrawTextW(1,150,1,yTitle);
  DrawTextW(xMainTitlePixel,yMainTitlePixel,1,MainTitle);
  DrawTextW(xSubTitlePixel,ySubTitlePixel,1,SubTitle);

  repeat until keypressed;        {wait until a key is pressed}
  LeaveGraphic;                   {leave the graphics system}



  until cq= 'q';                 {recycle input loop until satisfied
                                  with inputs}

end.                              {of program}


