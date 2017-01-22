{ Developed by Grégory Bersegeay for "Delphi for fun competition" : https://community.embarcadero.com/competitions/14-fun-with-delphi-nasa-api-mash-up
 This application was inspired by the demo of Marco Cantu : https://github.com/EmbarcaderoPublic/FunWithRADStudio/
 My site : http://www.gbesoft.fr
}

unit principale;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ExtCtrls, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter, REST.Client,
  Data.Bind.ObjectScope, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.Calendar, DateUtils, System.Actions,
  FMX.ActnList, FMX.Objects, FMX.MultiView, System.Threading,  System.JSON.Readers, System.JSON.Types, uCuriosityImg,
  System.Generics.Collections, FMX.Ani, FMX.ListBox, FMX.Effects, FMX.Filter.Effects, System.ImageList, FMX.ImgList,
  System.Math.Vectors, FMX.MaterialSources, FMX.Objects3D, FMX.Controls3D, FMX.Viewport3D;

type
  TfPrincipale = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    VisualiseurPrincipal: TImageViewer;
    NetHTTPClient1: TNetHTTPClient;
    ActionList1: TActionList;
    GetImageAction: TAction;
    StyleBook1: TStyleBook;
    MultiView1: TMultiView;
    Calendar1: TCalendar;
    ToolBar1: TToolBar;
    WorkingAnimation: TAction;
    BindSourceDB1: TBindSourceDB;
    Layout1: TLayout;
    LayoutInfo: TLayout;
    lInfo: TLabel;
    lNoPhoto: TLabel;
    LayoutHome: TLayout;
    FloatAnimation1: TFloatAnimation;
    bStart: TButton;
    FloatAnimation2: TFloatAnimation;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LayoutZoom: TLayout;
    TrackBar1: TTrackBar;
    PixelateEffect: TPixelateEffect;
    lUrl: TLabel;
    Pie2: TPie;
    Pie1: TPie;
    RoundRect1: TRoundRect;
    RoundRect2: TRoundRect;
    Image1: TImage;
    Image2: TImage;
    ShadowEffect1: TShadowEffect;
    layoutMars3D: TLayout;
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Mars: TSphere;
    TextureMaterialSource1: TTextureMaterialSource;
    FloatAnimation3: TFloatAnimation;
    layoutMain: TLayout;
    PathAnimation1: TPathAnimation;
    PaperSketchEffect1: TPaperSketchEffect;
    ShadowEffect2: TShadowEffect;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    SepiaEffect1: TSepiaEffect;
    CheckBox2: TCheckBox;
    InvertEffect1: TInvertEffect;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    PencilStrokeEffect1: TPencilStrokeEffect;
    IntroImage: TImage;
    lDelphiFun: TLabel;
    GlowEffect1: TGlowEffect;
    Image3: TImage;
    Layout2: TLayout;
    ComboBox1: TComboBox;
    lCamera: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure GetImageActionExecute(Sender: TObject);
    procedure Calendar1Change(Sender: TObject);
    procedure Pie1Click(Sender: TObject);
    procedure Pie2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FloatAnimation2Finish(Sender: TObject);
    procedure FloatAnimation2Process(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure VisualiseurPrincipalMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure Viewport3D1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
  private
    { Private declarations }
    Sr: TStringReader;
    Reader: TJsonTextReader;
    procedure CreateReader(Str: string);
    function ParseObject(jsonText : string): string;
  public
    { Public declarations }
    BaseURL: String;
    BaseDate: String;
    lstImage: TObjectList<TCuriosityImg>;
  end;
  const
   // get your key from https://api.nasa.gov/index.html#apply-for-an-api-key
   APIKey = 'DEMO_KEY';

var
  fPrincipale: TfPrincipale;

implementation

{$R *.fmx}

{ methods to parser JSON }
procedure TfPrincipale.CreateReader(Str: string);
begin
  if Reader <> nil then
    Reader.Free;
  if Sr <> nil then
    Sr.Free;
  Sr := TStringReader.Create(Str);
  Reader := TJsonTextReader.Create(Sr);
end;


function TfPrincipale.ParseObject(jsonText : string): string;
var
  id, sol, camera, cameraFull, ImgSrc, earthDate, propertyName, resultat : string;
begin
  resultat := '';
  lstImage.Clear;
  CreateReader(jsonText);
  while Reader.read do
   case Reader.TokenType of
      TJsonToken.PropertyName: propertyName := lowercase(Reader.Value.ToString);
      TJsonToken.String:
        begin
          if propertyName = 'name' then camera := Reader.Value.ToString;
          if propertyName = 'full_name' then cameraFull := Reader.Value.ToString;
          if propertyName = 'img_src' then ImgSrc := Reader.Value.ToString;
          if propertyName = 'earth_date' then
          begin
            earthDate := Reader.Value.ToString;
            lstImage.add(TCuriosityImg.create(StrToInt(id), StrToInt(sol), camera, cameraFull, ImgSrc, earthDate));
            // Just th first image returned by request for the moment...
            break;
          end;
          if propertyName = 'errors' then resultat := Reader.Value.ToString;
        end;
      TJsonToken.Integer:
        begin
          if propertyName = 'id' then id := Reader.Value.ToString;
          if propertyName = 'sol' then sol := Reader.Value.ToString;
        end;
   end;

   result := resultat;
end;

{ end methods to parser JSON }

procedure TfPrincipale.bStartClick(Sender: TObject);
begin
  PathAnimation1.Stop;
  FloatAnimation1.StartValue := 0;
  FloatAnimation1.StopValue := fPrincipale.Height + 1;
  FloatAnimation1.Start;
  Calendar1.Date := now;
  layoutMars3D.Visible := true;
  LayoutInfo.Visible := true;
  LayoutZoom.Visible := true;
end;

procedure TfPrincipale.Calendar1Change(Sender: TObject);
begin
  GetImageAction.Execute;
end;

procedure TfPrincipale.CheckBox1Change(Sender: TObject);
begin
  PaperSketchEffect1.Enabled := checkBox1.IsChecked;
end;

procedure TfPrincipale.CheckBox2Change(Sender: TObject);
begin
  SepiaEffect1.Enabled := checkBox2.IsChecked;
end;

procedure TfPrincipale.CheckBox3Change(Sender: TObject);
begin
  InvertEffect1.Enabled := checkBox3.IsChecked;
end;

procedure TfPrincipale.CheckBox4Change(Sender: TObject);
begin
  PencilStrokeEffect1.Enabled := checkBox4.IsChecked;
end;

procedure TfPrincipale.ComboBox1Change(Sender: TObject);
begin
  GetImageAction.Execute;
end;

procedure TfPrincipale.FloatAnimation1Finish(Sender: TObject);
begin
  LayoutHome.Visible := false;
end;

procedure TfPrincipale.FloatAnimation2Finish(Sender: TObject);
begin
  PixelateEffect.Enabled := false;
end;

procedure TfPrincipale.FloatAnimation2Process(Sender: TObject);
begin
  PixelateEffect.BlockCount := PixelateEffect.blockCount +10;
end;

procedure TfPrincipale.FormCreate(Sender: TObject);
begin
  LayoutHome.Visible := true;
  PixelateEffect.Enabled := false;
  BaseURL := 'https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?api_key=' + APIKey;
  lstImage := TObjectList<TCuriosityImg>.Create(True);
end;

procedure TfPrincipale.FormDestroy(Sender: TObject);
begin
  lstImage.free;
end;

procedure TfPrincipale.FormShow(Sender: TObject);
var
  centreX, centreY, limiteHaut, limiteBas, limiteGauche, limiteDroite : Extended;
begin
  centreX := 150;
  centreY := 120;
  limiteHaut := 150;
  limiteBas := 250;
  limiteDroite := 320;
  limiteGauche := -150;
  PathAnimation1.Parent := lDelphiFun;

  PathAnimation1.Path.MoveTo(PointF(limiteGauche, limiteHaut));

  PathAnimation1.Path.LineTo(PointF(centreX, centreY));
  PathAnimation1.Path.LineTo(PointF(limiteDroite,limiteHaut));
  PathAnimation1.Path.LineTo(PointF(centreX,limiteHaut));
  PathAnimation1.Path.LineTo(PointF(limiteGauche,limiteBas));
  PathAnimation1.Path.LineTo(PointF(centreX, centreY));
  PathAnimation1.Path.LineTo(PointF(limiteDroite, limiteBas));
  PathAnimation1.Path.LineTo(PointF(limiteGauche, limiteHaut));
  PathAnimation1.Path.ClosePath;

  PathAnimation1.Loop := True;
  PathAnimation1.Duration := 10;
  PathAnimation1.Start;
end;

procedure TfPrincipale.GetImageActionExecute(Sender: TObject);
var
  AResponseStream: TMemoryStream;
  resultat : string;
begin
  lNoPhoto.Visible := false;
  VisualiseurPrincipal.Visible := false;
  layoutzoom.Visible := false;
  lUrl.Text := '';

  BaseDate := YearOf(Calendar1.Date).ToString + '-' + MonthOfTheYear(Calendar1.Date).ToString + '-' + DayOfTheMonth(Calendar1.Date).ToString;

  RESTClient1.BaseURL := baseurl+ '&earth_date='+BaseDate+'&camera='+lowercase(combobox1.Items[combobox1.ItemIndex]);
  ITask(TTask.Create(procedure
    begin
      TThread.Queue(nil,procedure
        begin
          RESTRequest1.Execute;
          resultat := ParseObject(RESTResponse1.content);
          if trim(resultat) = '' then
          begin
            AResponseStream := TMemoryStream.Create;

            if lstImage.count > 0 then
            begin
              NetHTTPClient1.Get(lstImage[0].ImgSrc,AResponseStream);
              try
               lUrl.Text := lstImage[0].ImgSrc;
               VisualiseurPrincipal.Bitmap.LoadFromStream(AResponseStream);
               VisualiseurPrincipal.Visible := true;
               layoutzoom.Visible := true;
               PixelateEffect.BlockCount := 25;
               PixelateEffect.Enabled := true;
               FloatAnimation2.Start;
               lInfo.text := 'Sol '+inttostr(lstImage[0].Sol)+'  Date : ' +lstImage[0].EarthDate+'  Camera : ' +lstImage[0].Camera;
              except
              end;
            end;
            AResponseStream.Free;
          end
          else
          begin
            lNoPhoto.text := resultat+sLineBreak+'(selected date : '+FormatDateTime('dd/mm/yyyy',Calendar1.Date)+sLineBreak+'camera : '+combobox1.Items[Combobox1.ItemIndex]+')';
            lNoPhoto.Visible := true;
          end;
        end);
    end)).Start;

end;

procedure TfPrincipale.VisualiseurPrincipalMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
begin
  TrackBar1.Value := VisualiseurPrincipal.BitmapScale *100;
end;

procedure TfPrincipale.Pie1Click(Sender: TObject);
begin
  Calendar1.Date := Calendar1.Date-1;
end;

procedure TfPrincipale.Pie2Click(Sender: TObject);
begin
  if (Calendar1.Date+1)>Now then Exit;
  Calendar1.Date := Calendar1.Date+1;
end;

procedure TfPrincipale.TrackBar1Change(Sender: TObject);
begin
  VisualiseurPrincipal.BitmapScale :=  TrackBar1.Value / 100;
end;

procedure TfPrincipale.Viewport3D1Click(Sender: TObject);
begin
  if layoutMars3D.Height = 171 then
  begin
    layoutMars3D.Height := 450;
    Viewport3D1.width := 450;
    Viewport3D1.Align := TAlignLayout.Center;
  end
  else
  begin
    layoutMars3D.Height := 171;
    Viewport3D1.width := 171;
    Viewport3D1.Align := TAlignLayout.Right;
  end;

end;

end.
