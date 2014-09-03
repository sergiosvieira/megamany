unit UClasses;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  DXClass, DXSprite, DXInput, DXDraws, UConstantes, UFuncoes;

type
  TMapa = class(TImageSprite)
    Index: integer;
  protected
    procedure DoDraw; override;
  end;
  TDirecao = (Direita,Esquerda);
  TPlayer = class(TImageSprite)
  protected
    Direcao: TDirecao;
    AnimCount: integer;
    Caindo, Saltando, Atirando, Rasteira: Boolean;
    procedure DoMove(MoveCount: integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TLaser = class(TImageSprite)
    Direcao: TDirecao;
  protected
    procedure DoMove(MoveCount: integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

var
  Mapa: TMapa;
  Contador: integer = 0;
  SaltoCount: integer = 1;
  RasteiraCount: integer = 1;
  LaserCount: integer = 1;
  NumeroBalas: integer = 1;
  MegaMan: TPlayer;
  Ac: Double = 0.1;

implementation

uses
  UMain;

var
  Accel: double = 0;

{ TLaser }

constructor TLaser.Create;
begin
  inherited;
  Image:= FmMain.DXImageList1.Items.Find('Laser');
end;

procedure TLaser.DoMove;
begin
  inherited DoMove(MoveCount);
  Inc(LaserCount);
  case Direcao of
       Direita:  X:= X + 1.3*MoveCount;
       Esquerda: X:= X - 1.3*MoveCount;
  end;
  if (X > MegaMan.X + Engine.Width - 50) or (X < MegaMan.X - Engine.Width - 50) then
     begin
       Dead;
       Dec(NumeroBalas);
       LaserCount:= 1;
     end;
end;

procedure TLaser.DoCollision;
begin
end;
{ TMapa }

procedure TMapa.DoDraw;
begin
  Image.Draw(FmMain.DXDraw1.Surface,Trunc(X+Engine.X),Trunc(Y+Engine.Y),Index);
end;

{ TPlayer }

constructor TPlayer.Create;
begin
  inherited Create(AParent);
  Direcao:= Direita;
  Animcount:= 0;
  Caindo:= False;
  Saltando:= False;
  Atirando:= False;
  Rasteira:= False;
  Image:= FmMain.DXImageList1.Items.Find('MegaRight');
  Height:= Image.Height;
  Width := Image.Width;
  X:= 150;
  Y:= 50;
  Z:= 2;
end;

procedure TPlayer.DoMove;
var
  i,ii: integer;
begin
  inherited DoMove(MoveCount);
  Inc(Contador);
  Caindo:= False;
  Atirando:= False;
  AnimPos:= 0;

  //Caindo
  if (not Saltando) then
     if (Fase[Trunc((Y+Height+Ac+1)/32),Trunc(X/32)]<5)  and
        (Fase[Trunc((Y+Height+Ac+1)/32),Trunc((X+32)/32)]<5) then
        begin
          Y:= Y + (0.6)*MoveCount+Ac;
          Caindo:= True;
          Ac:= Ac + 0.6;
          if Ac > 1.8 then
             Ac:= 1.8;
           if Atirando then
              AnimPos:= 14
           else
              AnimPos := 6;
        end
     else
        Ac:= 0.1;
  //Atirar
  if (isButton2 in FmMain.DXInput1.States) and (not Atirando) and (not Rasteira)then
     begin
       if (not Caindo) then
          AnimPos:= 7
       else
          AnimPos:= 14;
       if NumeroBalas < 4 then
          begin
           if Contador mod 6 = 0 then
           begin
           Atirando:= True;
           with TLaser.Create(FmMain.DXSpriteEngine1.Engine) do
                begin
                  Inc(NumeroBalas);
                  Direcao:= MegaMan.Direcao;
                  if Direcao = Direita then
                     begin
                       X:= MegaMan.X + 32;
                       Y:= MegaMan.Y + 17;
                     end
                  else
                     begin
                       X:= MegaMan.X;
                       Y:= MegaMan.Y + 17;
                     end;
                end;
           end;
          end;
     end;
  // Saltar
  if (isButton1 in FmMain.DXInput1.States) and (not Caindo) and (not Saltando) then
      begin
        Saltando:= True;
        if Atirando then
           AnimPos:= 14;
        //Accel:= 0;
      end;
  // Rasteira
  if (isDown in FmMain.DXInput1.States) and
     (isButton1 in FmMain.DXInput1.States) then
     begin
       Rasteira:= True;
       Saltando:= False;
     end;
  if Rasteira then
     begin
       Inc(RasteiraCount);
       if Image.Name = 'MegaRight' then
          begin
            if (Fase[Trunc(Y/32),Trunc((X+32+3)/32)]<5)  and
               (Fase[Trunc((Y+30)/32),Trunc((X+32+3)/32)]<5) then
               X:= X + (600/1000)*MoveCount;
            AnimPos:= 17;
          end
       else
          begin
            if (Fase[Trunc(Y/32),Trunc((X-3)/32)]<5)  and
               (Fase[Trunc((Y+30)/32),Trunc((X-3)/32)]<5) then
               X:= X - (600/1000)*MoveCount;
            AnimPos:= 17;
          end

     end;
  if RasteiraCount>36 then
     begin
       RasteiraCount:= 1;
       Rasteira:= False;
     end;

  // Saltando
  if Saltando then
    begin
      Inc(SaltoCount);
      if SaltoCount<20 then
         begin
           if (Fase[Trunc((Y-1)/32),Trunc(X/32)]<5)  and
              (Fase[Trunc((Y-1)/32),Trunc((X+32)/32)]<5) then
              begin
                Y := Y - (0.6*Ac)*MoveCount;
                Ac:= Ac + 0.8;
                if Ac > 1.8 then
                   Ac:= 1.8;
              end
           else
              SaltoCount:= 37;

                if Atirando then
                   AnimPos:= 14
                else
                   AnimPos := 5;

         end;
    end;
    if SaltoCount>20 then
       begin
         SaltoCount:= 1;
         Saltando:= False;
         //Accel:= 0;
       end;
  // Direita
  if isRight in FmMain.DXInput1.States then
     begin
       Direcao:= Direita;
       Image:= FmMain.DXImageList1.Items.Find('MegaRight');
       if (Fase[Trunc(Y/32),Trunc((X+32+3)/32)]<5)  and
          (Fase[Trunc((Y+30)/32),Trunc((X+32+3)/32)]<5) then
          X:= X + (600/1000)*MoveCount;
       if (Contador mod 6 = 0) then
          if Atirando then
             begin
               if (AnimCount < 13) and (AnimCount>7) then
                  Inc(AnimCount)
               else
                  AnimCount:=8;
             end
          else
             begin
               if AnimCount < 4 then
                  Inc(AnimCount)
               else
                  AnimCount:=1;
             end;
       if (not Caindo) and (not Saltando) and (not Rasteira) then
          AnimPos:= AnimCount;
     end;
  // Esquerda
  if isLeft in FmMain.DXInput1.States then
     begin
       Direcao:= Esquerda;
       Image:= FmMain.DXImageList1.Items.Find('MegaLeft');
       if (Fase[Trunc(Y/32),Trunc((X-3)/32)]<5)  and
          (Fase[Trunc((Y+30)/32),Trunc((X-3)/32)]<5) then
          X:= X - (600/1000)*MoveCount;
       if (Contador mod 6 = 0) then
          if Atirando then
             begin
               if (AnimCount < 13) and (AnimCount>7) then
                  Inc(AnimCount)
               else
                  AnimCount:=8;
             end
          else
             begin
               if AnimCount < 4 then
                  Inc(AnimCount)
               else
                  AnimCount:=1;
             end;
       if (not Caindo) and (not Saltando) and (not Rasteira)  then
          AnimPos:= AnimCount;
     end;
  Engine.X := ((X)* -1) + (Engine.Width) div 2 - (Width) div 2;
  Engine.Y := -Y+Engine.Height div 2-Height+115 div 2;
  if Engine.Y>0 then
     Engine.Y:= 0;
  if Engine.X>0 then
     Engine.X:= 0;
  if Engine.X<(COLUNAS - 7) * 32 * -1 then
     Engine.X:= (COLUNAS - 7) * 32 * -1;
end;

end.
