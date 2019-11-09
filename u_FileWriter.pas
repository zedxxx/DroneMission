unit u_FileWriter;

interface

uses
  Classes,
  SysUtils,
  t_DroneMission;

type
  TFileWriter = class
  private
    FFileStream: TFileStream;
  protected
    procedure WriteText(const AText: string);
  public
    procedure DoWrite(const AMission: TMission); virtual; abstract;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
  end;

  TFileWriterClass = class of TFileWriter;

implementation

{ TFileWriter }

constructor TFileWriter.Create(const AFileName: string);
begin
  inherited Create;
  FFileStream := TFileStream.Create(AFileName, fmCreate);
end;

destructor TFileWriter.Destroy;
begin
  FreeAndNil(FFileStream);
  inherited Destroy;
end;

procedure TFileWriter.WriteText(const AText: string);
var
  VText: UTF8String;
begin
  VText := UTF8Encode(AText) + #13#10;
  FFileStream.WriteBuffer(PAnsiChar(VText)^, Length(VText));
end;

end.
