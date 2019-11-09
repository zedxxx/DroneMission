unit u_KmlWriter;

interface

uses
  t_DroneMission,
  u_FileWriter;

type
  TKmlWriter = class(TFileWriter)
  private
    procedure WriteHeader;
    procedure WriteFooter;
    procedure WriteRoute(const ARoute: TMissionRoute; const ARouteId: Integer);
  public
    procedure DoWrite(const AMission: TMission); override;
  end;

implementation

uses
  SysUtils;

const
  CRLF = #13#10;
  CTAB = '  ';

{ TKmlWriter }

procedure TKmlWriter.DoWrite(const AMission: TMission);
var
  I: Integer;
begin
  WriteHeader;
  for I := 0 to Length(AMission) - 1 do begin
    WriteRoute(AMission[I], I+1);
  end;
  WriteFooter;
end;

procedure TKmlWriter.WriteHeader;
begin
  WriteText(
    '<?xml version="1.0" encoding="UTF-8"?>' + CRLF +
    '<kml xmlns="http://www.opengis.net/kml/2.2">' + CRLF +
    CTAB + '<Document>'
  );
end;

procedure TKmlWriter.WriteFooter;
begin
  WriteText(
    CTAB + '</Document>' + CRLF +
    '</kml>'
  );
end;

procedure TKmlWriter.WriteRoute(
  const ARoute: TMissionRoute;
  const ARouteId: Integer
);
var
  I: Integer;
  VCoord: string;
begin
  VCoord := '';

  for I := 0 to Length(ARoute) - 1 do begin
    VCoord := VCoord + CTAB + CTAB + CTAB + CTAB +
      Format('%s,%s,0 ', [ARoute[I].Lon, ARoute[I].Lat]) + CRLF;
  end;

  WriteText(
    CTAB + CTAB + '<Placemark>' + CRLF +
    CTAB + CTAB + '<name>Route ' + IntToStr(ARouteId)  + '</name>' + CRLF +
    CTAB + CTAB + '<LineString>' + CRLF +
    CTAB + CTAB + CTAB + '<coordinates>' + ' ' + CRLF + VCoord +
    CTAB + CTAB + CTAB + '</coordinates>' + CRLF +
    CTAB + CTAB + '</LineString>' + CRLF +
    CTAB + CTAB + '</Placemark>'
  );

  for I := 0 to Length(ARoute) - 1 do begin
    VCoord := Format('%s,%s,0', [ARoute[I].Lon, ARoute[I].Lat]);
    WriteText(
      CTAB + CTAB + '<Placemark>' + CRLF +
      CTAB + CTAB + '<name>' + Format('Point %d.%d', [ARouteId, I+1]) + '</name>' + CRLF +
      CTAB + CTAB + '<Point>' + CRLF +
      CTAB + CTAB + CTAB + '<coordinates>' + VCoord + '</coordinates>' + CRLF +
      CTAB + CTAB + '</Point>' + CRLF +
      CTAB + CTAB + '</Placemark>'
    );
  end;
end;

end.
