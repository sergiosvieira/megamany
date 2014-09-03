unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXClass, DXSprite, DXInput, DXDraws,UConstantes, UClasses, UFuncoes;

type
  TFmMain = class(TForm)
    DXDraw1: TDXDraw;
    DXImageList1: TDXImageList;
    DXInput1: TDXInput;
    DXSpriteEngine1: TDXSpriteEngine;
    DXTimer1: TDXTimer;
    procedure DXDraw1Initialize(Sender: TObject);
    procedure DXTimer1Timer(Sender: TObject; LagCount: Integer);
    procedure DXDraw1Finalize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmMain: TFmMain;

implementation

{$R *.DFM}

procedure TFmMain.DXDraw1Initialize(Sender: TObject);
var
  i,ii: integer;
begin
  // Teclado
//  with DXInput1.Keyboard do
//  begin
//    //FillChar(KeyAssigns, SizeOf(KeyAssigns), 0);
//    AssignKey(KeyAssigns, isButton1, [VK_RETURN]);
///    AssignKey(KeyAssigns, isButton2, [Ord('Z')]);
//    AssignKey(KeyAssigns, isButton3, [);
//    AssignKey(KeyAssigns, isButton4, [BUTTON1_SELECT]);
//  end;
  // Organizando Paleta
  DXImageList1.Items.MakeColorTable;
  DXDraw1.ColorTable   := DXImageList1.Items.ColorTable;
  DXDraw1.DefColorTable:= DXImageList1.Items.ColorTable;
  DXDraw1.UpdatePalette;
  // Personagem
  MegaMan:= TPlayer.Create(DXSpriteEngine1.Engine);
  // Carregando Fase
  CarregarMapa('Mapa.dat');
  CriarFase;
  //Criando Fundo do Cenário
  with TBackGroundSprite.Create(DXSpriteEngine1.Engine) do
       begin
         SetMapSize(COLUNAS+1,LINHAS+1);
         Z:= -10;
         Image:= DXImageList1.Items.Find('bg');
         Collisioned:= False;
         for i:= 0 to COLUNAS-1 do
             for ii:= 0 to LINHAS-1 do
                 begin
                   if Fase[ii,i]<4 then
                      Chips[i,ii]:=Fase[ii,i]
                   else
                      Chips[i,ii]:= 0;
                   CollisionMap[ii,i]:= False;
                 end;
         Tile:= False;
       end;
  DXDraw1.Cursor:= crNone;
end;

procedure TFmMain.DXTimer1Timer(Sender: TObject; LagCount: Integer);
var
  v: Integer;
begin
  DXInput1.Update;
  DXDraw1.Surface.Fill(0);
  DXSpriteEngine1.Dead;
  DXSpriteEngine1.Draw;
//  v:= Trunc(LagCount / 2);
  DXSpriteEngine1.Move(5);
  DXDraw1.Surface.Canvas.TextOut(10,10,FloattoStr(MegaMan.X));
  DXDraw1.Surface.Canvas.TextOut(10,35,FloattoStr(DXSpriteEngine1.Engine.X));
  DXDraw1.Surface.Canvas.Release;
  DXDraw1.Flip;
end;

procedure TFmMain.DXDraw1Finalize(Sender: TObject);
begin
  DXDraw1.Cursor:= crDefault;
end;

end.
