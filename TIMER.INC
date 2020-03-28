(* This procedure taken from PC, 24 Nov 87 on 27 Dec 87.
   Procedure may be called from within any .pas code to time any
   section or routines of the code...see, e.g., TIMER.PAS
*)


type OnOrOff = (on,off);
var start,time : real;

procedure timer(o : OnOrOff);
type
    registers = record
    case integer of
         1 : (ax, bx, cx, dx, bp, si, di, ds, es, flags : integer);
         2 : (al, ah, bl, bh, cl, ch, dl, dh : byte);
    end;

var
   r : registers;
   hour, min,sec,hun : integer;
   begin
     r.ah:=$2c;
     intr($21,r);
     with r do begin
          hour:= ch;
          min:= cl;
          sec:=dh;
          hun:=dl;
     end;
     if o = on then begin
        start:=hour * 3600 + min * 60 + sec + hun/100;
        time:=0;
     end
     else begin
        time:=hour * 3600 + min * 60 + sec + hun/100 - start;
        start:=0;
        writeln('Elapsed time = ',time:8,' sec');
     end;
end;           {of procedure time.inc}
