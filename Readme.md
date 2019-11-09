Утилита для конвертирования xml файлов с логом полёта дрона в kml и csv форматы.

Инструкция по использованию:

1. В папку *Input* положить один или несколько xml файлов;
2. Запустить *DroneMission.exe*, дождаться сообщения об окончании работы, нажать Ввод для
того, чтобы закрылось окно консоли;
3. В папке *Output* будут файлы с расширением \*.kml и \*.csv и имененм, соответствущем входному xml.

По каждому обработанному xml файлу выводится статистика общего числа путей и точек.

При повторном запуске утилиты, если в папке *Output* будет найден существующий kml/csv файл с таким
же именем, то этот файл будет пропущен и конвертироваться повторно не будет.

Во входной директории поддерживаются под-директории.

Ожидаемая структура xml файла:

```
<mission>
  <route>
    <element>
      <lat>12.123456</lat>
      <lon>12.123456</lon>
    </element>
    <element>
      ...
    </element>
  </route>
  <route>
    ...
  </route>
</mission>
```
