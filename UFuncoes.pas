unit UFuncoes;

interface

uses
  SysUtils,UConstantes,DXClass, DXDraws, DIB, DXSprite,
  DXInput, DXSounds;

procedure LimparFase;
procedure CarregarMapa(Nome: String);
procedure CriarFase;
procedure AssignKey(var KeyAssignList: TKeyAssignList; State: TDXInputState;
  const Keys: array of Integer);

implementation

uses
  UMain,Uclasses;

procedure AssignKey(var KeyAssignList: TKeyAssignList; State: TDXInputState;
  const Keys: array of Integer);
var
  i, i2: Integer;
  KeyAssign: PKeyAssign;
begin
  KeyAssign := @KeyAssignList[State];
  FillChar(KeyAssign^, SizeOf(TKeyAssign), 0);

  i2 := 0;
  for i:=LOW(Keys) to HIGH(Keys) do
  begin
    if i2<3 then
      KeyAssign^[i2] := Keys[i]
    else
      Exit;
    Inc(i2);
  end;
end; { AssignKey }

procedure LimparFase;
var
  i: integer;
begin
  for i:= 0 to FmMain.DXSpriteEngine1.Engine.AllCount - 1 do
      if FmMain.DXSpriteEngine1.Engine.Items[i] is TMapa then
         TMapa(FmMain.DXSpriteEngine1.Engine.Items[i]).Dead;
end;

procedure CarregarMapa;
var
  Arquivo: TextFile;
  Idx: char;
  x,y: Integer;
  Temp: string;
begin
  x:=0;y:=0;
  AssignFile(Arquivo,Nome);
  Reset(Arquivo);
  while not EOF(Arquivo) do
        begin
          Read(Arquivo,Idx);
          if Idx in ['0','1','2','3','4','5','6','7','8','9'] then
             begin
               Temp:= Temp + Idx;
             end;
          if Idx='|' then
             begin
               Fase[Y,X]:= StrtoInt(Temp);
               Inc(y);
               X:=0;
               Temp:='';
             end;
          if Idx=',' then
             begin
               Fase[Y,X]:= StrtoInt(Temp);
               Inc(x);
               Temp:='';
             end;
        end;
  CloseFile(Arquivo);
end;

procedure CriarFase;
var
  i,ii: integer;
begin
  for i:= 0 to COLUNAS-1 do
      for ii:= 0 to LINHAS-1 do
      if Fase[ii,i]>4 then
         with TMapa.Create(FmMain.DXSpriteEngine1.Engine) do
              begin
                Inc(Numero_Blocos);
                Index:= Fase[ii,i]-5;
                Image:= FmMain.DXImageList1.Items.Find('Map');
                Collisioned:= True;
                //Width := Image.Width;
                //Height:= Image.Height;
                Z:= -4;
                X:= i  * 32;
                Y:= ii * 32;
                Tile:= False;
              end;
end;

end.
