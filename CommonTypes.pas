Unit CommonTypes;

interface

USES RESTContentTypeStr;

type
  TRepositoryListRec = Record
    ReposUrl       : string; // Repository URL
    ReposDir       : string; // Repository Directory
    ApiReposUrl    : string; // Api repository URL
    ApiReleasesUrl : string; // Api Repository Releases URL
    ReposName      : string; // Repository name
    FullReposName  : string; //
    AvatarFile     : string; //
    AvatarUrl      : string; //
    FilterInclude  : string; //
    FilterExclude  : string; //
    DatePublish    : string; // Дата публикации релиза на GitHub
    Language       : string; // Язык программирования репозитория (бонус)
    LastVersion    : string; // Последняя версия релиза
    LastChecked    : TDateTime; // Дата и время последней проверки
    RuleDownload   : UInt8;     // Параметры правила для скасивания
    RuleNotis      : UInt8;     // Параметры правила для уведомления об новой версии
    NeedSubDir     : Boolean;   // необходимость субдиректории для каждого редиза
    NewReleaseDT   : TDateTime; // Дата и время скачивания нового релиза
    AddVerToFileName: Boolean;  // Прибавлять версию релиза к сохраняемому файлу
    TimelAvtoCheck : Byte;      // Время интервала для автоматической проверки релиза
  End;



  
implementation

end.