unit t_DroneMission;

interface

type
  TMissionPoint = record
    Lat: string;
    Lon: string;
  end;
  PMissionPoint = ^TMissionPoint;

  TMissionRoute = array of TMissionPoint;

  TMission = array of TMissionRoute;

  TOnLogEvent = procedure(const AMsg: string);

implementation

end.
