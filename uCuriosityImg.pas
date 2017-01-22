unit uCuriosityImg;

interface

type
  TCuriosityImg = class
  private
    FId, FSol : integer;
    FCamera, FCameraFull: string;
    FImgsrc: string;
    FEarthDate: string;
  public
    constructor Create(const id, sol : integer; const Camera, cameraFull, ImgSrc, EarthDate : String);
    property Id: integer read FId write FId;
    property Sol: integer read FSol write FSol;
    property Camera: string read FCamera write FCamera;
    property CameraFull: string read FCameraFull write FCameraFull;
    property ImgSrc: string read FImgSrc write FImgSrc;
    property EarthDate: string read FEarthDate write FEarthDate;
  end;

implementation

{ TCuriosityImg }

constructor TCuriosityImg.Create(const id, sol : integer; const Camera, cameraFull, ImgSrc, EarthDate : String);
begin
  FId := id;
  FSol := sol;
  FCamera := camera;
  FCameraFull := cameraFull;
  FImgsrc := ImgSrc;
  FEarthDate := EarthDate;
end;

end.
