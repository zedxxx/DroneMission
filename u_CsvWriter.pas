unit u_CsvWriter;

interface

uses
  t_DroneMission,
  u_FileWriter;

type
  TCsvWriter = class(TFileWriter)
  private
    procedure WriteRoute(const ARoute: TMissionRoute; const ARouteId: Integer);
  public
    procedure DoWrite(const AMission: TMission); override;
  end;

implementation

uses
  SysUtils;

{ TCsvWriter }

procedure TCsvWriter.DoWrite(const AMission: TMission);
var
  I: Integer;
begin
  WriteText('Route,Point,Lat,Lon');
  for I := 0 to Length(AMission) - 1 do begin
    WriteRoute(AMission[I], I+1);
  end;
end;

procedure TCsvWriter.WriteRoute(
  const ARoute: TMissionRoute;
  const ARouteId: Integer
);
var
  I: Integer;
begin
  for I := 0 to Length(ARoute) - 1 do begin
    WriteText(
      Format('%d,%d,%s,%s', [ARouteId, I+1, ARoute[I].Lat, ARoute[I].Lon])
    );
  end;
end;

end.
