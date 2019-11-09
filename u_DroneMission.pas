unit u_DroneMission;

interface

uses
  t_DroneMission,
  u_XmlReader;

type
  TDroneConfig = record
    InPath: string;
    OutPath: string;
    AppPath: string;
    SkipExisting: Boolean;
  end;

  TDroneMission = record
  private
    class procedure ProcessFile(
      const AFileName: string;
      const AReader: TXmlReader;
      const AConfig: TDroneConfig
    ); static;
  public
    class procedure Run; static;
  end;

implementation

uses
  Types,
  SysUtils,
  IOUtils,
  u_FileWriter,
  u_CsvWriter,
  u_KmlWriter;

procedure OnLogEvent(const AMsg: string);
begin
  Writeln(AMsg);
end;

{ TDroneMission }

class procedure TDroneMission.Run;
var
  I: Integer;
  VConfig: TDroneConfig;
  VXmlFiles: TStringDynArray;
  VXmlReader: TXmlReader;
begin
  VConfig.SkipExisting := True;

  VConfig.AppPath := ExtractFilePath(ParamStr(0));

  VConfig.InPath := VConfig.AppPath + 'Input\';
  if not DirectoryExists(VConfig.InPath) then begin
    OnLogEvent('Input directory is not exists: ' + VConfig.InPath);
    Exit;
  end;

  VConfig.OutPath := VConfig.AppPath + 'Output\';
  if not DirectoryExists(VConfig.OutPath) then begin
    if not ForceDirectories(VConfig.OutPath) then begin
      RaiseLastOSError;
    end;
  end;

  OnLogEvent('Scaning input directory...');
  VXmlFiles := TDirectory.GetFiles(VConfig.InPath, '*.xml', IOUtils.TSearchOption.soAllDirectories);

  I := Length(VXmlFiles);
  if I > 0 then begin
    OnLogEvent(Format('Found %d xml file(s)', [I]));
  end else begin
    OnLogEvent('Nothing to do: The input directory doesn''t contain any xml file!');
  end;

  VXmlReader := TXmlReader.Create(dvOmniXML, @OnLogEvent);
  try
    for I := Low(VXmlFiles) to High(VXmlFiles) do begin
      ProcessFile(VXmlFiles[I], VXmlReader, VConfig);
    end;
  finally
    VXmlReader.Free;
  end;

  OnLogEvent('Finished!');
end;

class procedure TDroneMission.ProcessFile(
  const AFileName: string;
  const AReader: TXmlReader;
  const AConfig: TDroneConfig
);

  function Relative(const AName, ABase: string): string;
  begin
    Result := StringReplace(AName, ABase, '', [rfIgnoreCase])
  end;

  procedure WriteFile(
    const AWriterId: string;
    const AWriterClass: TFileWriterClass;
    const AFileNameForWriter: string;
    const AMission: TMission
  );
  var
    VRelative: string;
    VWriter: TFileWriter;
  begin
    VRelative := Relative(AFileNameForWriter, AConfig.AppPath);

    if AConfig.SkipExisting and FileExists(AFileNameForWriter) then begin
      OnLogEvent(AWriterId + ' file already exists, skipping: ' + VRelative);
      Exit;
    end;

    if not ForceDirectories(ExtractFileDir(AFileNameForWriter)) then begin
      RaiseLastOSError;
    end;

    VWriter := AWriterClass.Create(AFileNameForWriter);
    try
      VWriter.DoWrite(AMission);
      OnLogEvent(AWriterId + ' file saved to: ' + VRelative);
    finally
      VWriter.Free;
    end;
  end;

  procedure WriteStat(const AMission: TMission);
  var
    I, J: Integer;
  begin
    J := 0;
    for I := 0 to Length(AMission) - 1 do begin
      Inc(J, Length(AMission[I]));
    end;
    OnLogEvent('Routs:  ' + IntToStr(Length(AMission)));
    OnLogEvent('Points: ' + IntToStr(J));
  end;

const
  CWriterId: array [0..1] of string = ('CSV', 'KML');
  CWriterClass: array [0..1] of TFileWriterClass = (TCsvWriter, TKmlWriter);
var
  I: Integer;
  VXmlName: string;
  VFileName: string;
  VMission: TMission;
begin
  OnLogEvent('');
  OnLogEvent('Processing xml file: ' + Relative(AFileName, AConfig.AppPath));

  VMission := AReader.DoReadFile(AFileName);
  VXmlName := Relative(AFileName, AConfig.InPath);

  for I := 0 to Length(CWriterId) - 1 do begin
    VFileName := ChangeFileExt(AConfig.OutPath + VXmlName, '.' + LowerCase(CWriterId[I]));
    WriteFile(CWriterId[I], CWriterClass[I], VFileName, VMission);
  end;

  WriteStat(VMission);
  OnLogEvent('');
end;

end.
