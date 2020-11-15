unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, Math, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, Vcl.StdCtrls,
  Vcl.ComCtrls, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs,
  VCLTee.Chart;

type
  arraydft= array [-10000..10000] of extended;
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Button1: TButton;
    Chart1: TChart;
    Series1: TLineSeries;
    Chart2: TChart;
    Series2: TLineSeries;
    Chart3: TChart;
    Series3: TLineSeries;
    Chart4: TChart;
    Series4: TLineSeries;
    Chart5: TChart;
    Chart6: TChart;
    Chart7: TChart;
    Chart8: TChart;
    ScrollBar1: TScrollBar;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series9: TLineSeries;
    Series10: TLineSeries;
    Series11: TLineSeries;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure SinyalInput;
    procedure MagMav;
    procedure PerbandinganMAV;
    procedure NoiseHilang;
    procedure DFT(datain:arraydft);
    procedure Button1Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  //sinyal input
  t,fs: integer;
  a1,a2,a3,f1,f2,f3,noise: extended;
  x: arraydft;
  //MAV
  i,j,m: integer;
  hf,hb,yf,yb,ynoise,output,youtput: arraydft;
  yt,k: extended;
  real1,imj1,magnitude1: arraydft;
implementation
const ndata=1000;

{$R *.dfm}

 //SINYALINPUT
procedure TForm1.SinyalInput;
begin

  a1:=strtofloat(Edit1.Text);
  a2:=strtofloat(Edit2.Text);
  a3:=strtofloat(Edit3.Text);
  f1:=strtofloat(Edit4.Text);
  f2:=strtofloat(Edit5.Text);
  f3:=strtofloat(Edit6.Text);
  fs:=strtoint(Edit7.Text);

  noise:=randg(0.5,1);

  for t := 0 to ndata-1 do
  begin
   x[t]:=(a1*sin(2*pi*t*(f1/fs)))+(a2*sin(2*pi*t*(f2/fs)))+(a3*cos(2*pi*t*(f3/fs)))+noise;
   Series1.AddXY(t,x[t]);
   series5.AddXY(t,x[t]);
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SinyalInput;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
var
  n: Integer;
begin
  series3.Clear; series4.Clear; series6.Clear; series7.Clear;
  //Series5.AddXY(t,x[t]);
  MagMav;
  PerbandinganMAV;
  //NoiseHilang;

  DFT(x);
  for n := 0 to (fs div 2) do
  begin
    series8.AddXY(n*fs/ndata,magnitude1[n]);
  end;
  DFT(yb);
  for n := 0 to (fs div 2) do
  begin
    series9.AddXY(n*fs/ndata,magnitude1[n]);
  end;
  DFT(ynoise);
  for n := 0 to (fs div 2) do
  begin
    series10.AddXY(n*fs/ndata,magnitude1[n]);
  end;
end;

procedure TForm1.MagMav;
begin
series2.Clear;
M:=ScrollBar1.Position;
fs:=1000;
K:=0.01;
while k<(fs/2)*0.001 do
  begin
    yt:=sqrt(sqr((sin(pi*k*M))/(M*sin(pi*k))));
    Series2.AddXY(k,yt);
    k:=k+0.01;
  end;
end;

procedure TForm1.PerbandinganMAV;
begin
series3.Clear; series6.Clear; series7.Clear;

M:=ScrollBar1.Position;

  for i := 0 to ndata do
    begin
    hf[-i]:=hf[0];
    hb[-i]:=hb[0];
    yf[-i]:=yf[0];
    yb[-i]:=yb[0];
    output[-i]:=output[0];
    youtput[-i]:=youtput[0];
    end;

  for i := 0 to ndata do
   begin
    hf[i] := 0;
    for j := 0 to M-1 do
    begin
      hf[i]:=hf[i]+x[i-j];
    end;
    yf[i]:=(1/M)*hf[i];

    series6.AddXY(i,yf[i]);
  end;

   for i := 0 to ndata do
   begin
    hb[i] := 0;
    for j := 0 to M-1 do
    begin
      hb[i]:=hb[i]+yf[i+j];
    end;

    yb[i]:=(1/M)*hb[i];
    ynoise[i]:=x[i]-yb[i];

    series4.AddXY(i,ynoise[i]);
    series3.AddXY(i,yb[i]);
    series7.AddXY(i,yb[i]);
  end;

  statictext1.Caption:='Order = ' + inttostr(M);

end;

procedure TForm1.NoiseHilang;
begin
{series4.Clear;
ynoise[i]:=0;
  for i := 0 to ndata do
    begin
    ynoise[i]:=x[i]-yb[i];
    series4.AddXY(i,ynoise[i]);
    end;}
end;

procedure TForm1.DFT(datain:arraydft);
var
k,n: integer;
begin
  for k := 0 to ndata-1 do
    begin
      real1[k]:=0;
      imj1[k]:=0;
      magnitude1[k]:=0;
      for n := 0 to ndata-1 do
        begin
          real1[k]:= real1[k] + (datain[n]*cos(2*pi*k*n/ndata));
          imj1[k]:= imj1[k] - (datain[n]*sin(2*pi*k*n/ndata));
          magnitude1[k]:= sqrt(sqr(real1[k])+sqr(imj1[k]))/ndata;
        end;
    end;
end;

end.
