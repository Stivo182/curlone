// Возвращает возможные типы токенов
//
//  Возвращаемое значение:
//   Структура - структура данных вида:
//    * Ключ - Имя токена
//    * Значение - представление токена
//
Функция ТипыТокенов() Экспорт
	Типы = Новый Структура;
	Типы.Вставить("TTArg", "Arg");
	Типы.Вставить("TTOpenPar", "OpenPar");
	Типы.Вставить("TTClosePar", "ClosePar");
	Типы.Вставить("TTOpenSq", "TTOpenSq");
	Типы.Вставить("TTCloseSq", "CloseSq");
	Типы.Вставить("TTChoice", "Choice");
	Типы.Вставить("TTOptions", "Options");
	Типы.Вставить("TTAny", "Any");
	Типы.Вставить("TTRep", "Rep");
	Типы.Вставить("TTShortOpt", "ShortOpt");
	Типы.Вставить("TTLongOpt", "LongOpt");
	Типы.Вставить("TTOptSeq", "OptSeq");
	Типы.Вставить("TTOptValue", "OptValue");
	Типы.Вставить("TTDoubleDash", "DblDash");
	
	Возврат Типы;
КонецФункции

// Создает структура описания токена
//
// Параметры:
//   ТипТокена - Строка - тип токена
//   Значение - Строка - значение токена
//   Позиция - Число - текущая позиция в строке
//
//  Возвращаемое значение:
//   Структура - структура описания токена
//    * ТипТокена - Строка - тип токена
//    * Значение - Строка - значение токена
//    * Позиция - Число - текущая позиция в строке
//
Функция НовыйТокен(ТипТокена, Значение, Позиция) Экспорт

	Возврат Новый Структура("Тип, Значение, Позиция", ТипТокена, Значение, Позиция);

КонецФункции

// Выводит данные по структуре описанию токена
//
// Параметры:
//   Токен - Структура - структура описания токена
//    * ТипТокена - Строка - тип токена
//    * Значение - Строка - значение токена
//    * Позиция - Число - текущая позиция в строке
//
Процедура СообщитьТокен(Токен) Экспорт
	
	Сообщить(СтрШаблон("Тип: %1
	|Значение: %2
	|Пизиция: %3", Токен.Тип, Токен.Значение, Токен.Позиция));

КонецПроцедуры