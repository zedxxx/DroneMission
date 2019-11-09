program DroneMission;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  u_XmlReader in 'u_XmlReader.pas',
  t_DroneMission in 't_DroneMission.pas',
  u_DroneMission in 'u_DroneMission.pas',
  u_CsvWriter in 'u_CsvWriter.pas',
  u_FileWriter in 'u_FileWriter.pas',
  u_KmlWriter in 'u_KmlWriter.pas';

begin
  try
    TDroneMission.Run;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
  Writeln('Press Enter to exit...');
  Readln;
end.
