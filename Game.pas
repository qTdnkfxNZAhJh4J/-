uses GraphABC,ABCObjects,ABCButtons;
Const N = 10; 
      sz = 40; 
      d0 = 10; 
      zz = 2; 
      NMines = 10; 
      
Type OneSellField = record
        mine : boolean;
        fl : boolean; 
        neighbours : integer; 
        click : boolean; 
     end;
     
Var BtNewGame : ButtonABC;
    Sell : array[1..N, 1..N] of SquareABC;
    Field : array[1..N, 1..N] of OneSellField;
    c : shortint; 
    Opened : shortint; 
    Nfl : Integer; 
 
Procedure CreateField;
begin    
   for var y := 1 to N do
      for var x := 1 to N do begin
         Sell[x, y] := new SquareABC(d0+(x-1)*(sz+zz),d0+(y-1)*(sz+zz), sz, clLightSeaGreen);
         Sell[x, y].BorderColor := clGreen;
         Sell[x, y].BorderWidth := 2;
         Sell[x, y].TextScale := 0.7;
      end;    
end;
 
Procedure NewGame;
var Rx, Ry : integer;
begin
    for var j:=1 to N do
      for var i:=1 to N do begin
         Field[i, j].mine := false;
         Field[i, j].click := false;
         Field[i, j].fl := false;
         Field[i, j].neighbours := 0;
         Sell[i, j].BorderColor := clGreen;
         Sell[i, j].Text := '';
         Sell[i, j].Color := clLightSeaGreen;
      end;  
   
   
   for var i := 1 to NMines do begin
      Rx := Random(N)+1;
      Ry := Random(N)+1;
      
      while Field[Rx, Ry].mine do begin
          Rx := Random(N)+1;
          Ry := Random(N)+1;            
      end;
      Field[Rx, Ry].mine := true;
   end;  
      
   
   var ii, jj :shortint; 
   
   for var j:=1 to N do
      for var i:=1 to N do begin
         c := 0;
         for var dx := -1 to 1 do begin
            for var dy := -1 to 1 do 
               if not ((dx = 0) and (dy = 0)) then begin
                  ii := i + dx;
                  jj := j + dy;
                  if ((ii > 0) and (ii <= N) and (jj > 0) and (jj <= N)) then begin
                     c := c + Integer(Field[ii, jj].mine);
                  end;
               end;
         end;
         Field[i, j].neighbours := c;
      end; 
      Opened := 0; 
      Nfl := 0;
end;
 
Procedure OpenZero(fx, fy : integer);
var fl :boolean;
    step, ii, jj : integer;
begin
   Field[fx, fy].neighbours := -1;
   step := -1;
   repeat
      fl := true;
      for var x := 1 to N do begin
         for var y := 1 to N do begin
            if Field[x, y].neighbours < 0 then begin
              
               for var dx := -1 to 1 do begin
                  for var dy := -1 to 1 do 
                     if not ((dx = 0) and (dy = 0)) then begin 
                        ii := x + dx;
                        jj := y + dy;
                       
                        if ((ii > 0) and (ii <= N) and (jj > 0) and (jj <= N)) then begin
                           if Field[ii, jj].neighbours = 0 then begin
                              Sleep(30); 
                              Sell[ii, jj].Color := clLightYellow;
                              Field[ii, jj].click := true;
                              Field[ii, jj].neighbours := step;
                              fl := false; 
                           end;
                            if Field[ii, jj].neighbours > 0 then begin
                              Sell[ii, jj].Color := clLightGreen;
                              Sell[ii, jj].Text := IntToStr(Field[ii, jj].neighbours);
                              Field[ii, jj].click := true;
                           end;
                        end;
                     end;
                  end;
               
            end;
         end;
      end;
      step := step - 1;
   until fl;
end;
 
Procedure MouseDown(x, y, mb: integer);
begin
   if ObjectUnderPoint(x,y)=nil then 
    exit;
    
    var fx := (x-d0) div (sz+zz) + 1; 
    var fy := (y-d0) div (sz+zz) + 1;
    
    Field[fx, fy].click := true; 
    
    if mb = 1 then begin
      //Если щелкнули по мине
      if Field[fx, fy].mine then begin
         Sell[fx, fy].Text := 'M';
         Sell[fx, fy].Color := clRed;
         writeln('Проиграл!');
         
      end
      else begin
        
         if (Field[fx, fy].neighbours = 0) then begin
            Sell[fx, fy].Color := clLightYellow;
            if Field[fx, fy].fl then Sell[fx, fy].Text := '';
           
            OpenZero(fx, fy);
         end
         else 
            if Field[fx, fy].neighbours > 0 then begin
               Sell[fx, fy].Color := clLightGreen;
               Sell[fx, fy].Text := IntToStr(Field[fx, fy].neighbours);
            end;
      end;
    end;
   
    if mb = 2 then begin
            if Field[fx, fy].fl then begin 
                 Field[fx, fy].fl := False;
                 Sell[fx,fy].Text := '';
                 Sell[fx, fy].Color := clLightSeaGreen;
                 Nfl -= 1;
                 if (Opened = NMines) and (Nfl = NMines) then writeln('Победа!');
                
            end
            else begin 
               Field[fx, fy].fl := true;
               Sell[fx,fy].Text := 'F';
               Sell[fx, fy].Color := clBlue;
               Nfl += 1;
              
            end;
            
            if Field[fx, fy].mine then begin
                  if Field[fx, fy].fl then Opened += 1
                  else Opened -= 1;
                 
                  if (Opened = NMines) and (Nfl = NMines) then writeln('Победа!');
            end;
    end;
end;
 
 
Procedure MouseMove(x, y, mb: integer);
begin
   if ObjectUnderPoint(x,y)=nil then 
    exit;
    var fx := (x-d0) div (sz+zz) + 1; 
    var fy := (y-d0) div (sz+zz) + 1;
    
   
    for var j := 1 to N do
      for var i := 1 to N do begin
         if not Field[i,j].click then
            Sell[i,j].Color := clLightSeaGreen;
      end; 
    
   
    if not Field[fx, fy].click then
      Sell[fx,fy].Color := clLightGreen;
end;
 
BEGIN
   SetSmoothingOff;
   Window.Title := 'Сапёр';
   Window.IsFixedSize := True;
   
   CreateField;
   btNewGame := ButtonABC.Create(535, d0, 100, 'Новая игра', clSkyBlue);
   btNewGame.OnClick := NewGame;
   NewGame;
   
   OnMouseDown := MouseDown;
   OnMouseMove := MouseMove;
END.