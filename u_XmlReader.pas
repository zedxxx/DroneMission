unit u_XmlReader;

interface

uses
  ActiveX,
  Variants,
  SysUtils,
  XMLDom,
  XMLDoc,
  XMLIntf,
  OmniXMLDom,
  t_DroneMission;

type
  TXmlDomVendor = (dvMSXML, dvOmniXML);

  TXmlReader = class
  private
    FOnLogEvent: TOnLogEvent;
    FDomVendor: TXmlDomVendor;
    function AddRoutePoint(var ARoute: TMissionRoute; const APoint: IXMLNode): Boolean;
  public
    function DoReadFile(const AFileName: string): TMission;
  public
    constructor Create(
      const ADomVendor: TXmlDomVendor;
      const AOnLogEvent: TOnLogEvent = nil
    );
    destructor Destroy; override;
  end;

implementation

{ TXmlReader }

constructor TXmlReader.Create(
  const ADomVendor: TXmlDomVendor;
  const AOnLogEvent: TOnLogEvent
);
begin
  inherited Create;

  FDomVendor := ADomVendor;
  FOnLogEvent := AOnLogEvent;

  if FDomVendor = dvMSXML then begin
    CoInitialize(nil);
  end;
end;

destructor TXmlReader.Destroy;
begin
  if FDomVendor = dvMSXML then begin
    CoUninitialize;
  end;
  inherited Destroy;
end;

function TXmlReader.DoReadFile(const AFileName: string): TMission;
var
  I, J, K: Integer;
  VDocument: IXMLDocument;
  VMission: IXMLNode;
  VRoute: IXMLNode;
  VPoint: IXMLNode;
begin
  Result := nil;

  VDocument := TXMLDocument.Create(nil);

  if FDomVendor = dvOmniXML then begin
    TXMLDocument(VDocument).DomVendor := GetDOMVendor(sOmniXmlVendor);
  end;

  VDocument.LoadFromFile(AFileName);
  VDocument.Active := True;

  VMission := VDocument.ChildNodes['mission'];

  if VMission = nil then begin
    if Assigned(FOnLogEvent) then begin
      FOnLogEvent('Root node <mission> is not found!');
    end;
    Exit;
  end;

  K := 0;
  SetLength(Result, 1);

  for I := 0 to VMission.ChildNodes.Count - 1 do begin
    VRoute := VMission.ChildNodes.Get(I);
    for J := 0 to VRoute.ChildNodes.Count - 1 do begin
      VPoint := VRoute.ChildNodes.Get(J);
      if not AddRoutePoint(Result[K], VPoint) then begin
        if Assigned(FOnLogEvent) then begin
          FOnLogEvent(
            Format('Route %.3d, Point %.3d: skipped - reading failed!', [I, J])
          );
        end;
      end;
    end;
  end;

  if Length(Result[K]) > 0 then begin
    Inc(K);
  end;
  SetLength(Result, K);
end;

function TXmlReader.AddRoutePoint(var ARoute: TMissionRoute; const APoint: IXMLNode): Boolean;

  function _TryReadVal(const AName: string): string;
  var
    VVariant: OleVariant;
  begin
    VVariant := APoint.ChildValues[AName];
    if not VarIsNull(VVariant) then begin
      Result := VVariant;
    end else begin
      Result := '';
    end;
  end;

var
  I: Integer;
  VLon, VLat: string;
begin
  Result := False;
  if APoint <> nil then begin
    VLat := _TryReadVal('lat');
    VLon := _TryReadVal('lon');

    if (VLat <> '') and (VLon <> '') then begin
      I := Length(ARoute);
      SetLength(ARoute, I+1);

      ARoute[I].Lat := VLat;
      ARoute[I].Lon := VLon;

      Result := True;
    end;
  end;
end;

end.
