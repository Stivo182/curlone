﻿#Использовать "../../internal"
#Использовать "../../../lib/cli/src/core"

Перем ОписаниеЗапроса;
Перем КаталогСохраненияФайлов;

Перем ПрочитанныеОпции;
Перем ИсходящиеОшибки;

#Область ПрограммныйИнтерфейс

// Конвертирует команду curl в программный код
//
// Параметры:
//   КоманднаяСтрока - Строка - Текст команды
//   ГенераторПрограммногоКода - Объект, Неопределено - Ссылка на класс генератора программного кода
//   Ошибки - Неопределено - Выходной параметр. Передает выходному параметру ошибки найденные в команде:
//      Массив из Структура:
//        * Текст - Строка - Текст ошибки
//        * КритичнаяОшибка - Булево - Признак критичиной ошибки 
//
// Возвращаемое значение:
//   Строка - Программный код
Функция Конвертировать(КоманднаяСтрока, ГенераторПрограммногоКода = Неопределено, Ошибки = Неопределено) Экспорт
	
	Если ГенераторПрограммногоКода = Неопределено Тогда
		Генератор = Новый ГенераторПрограммногоКода1С();
	Иначе
		Генератор = ГенераторПрограммногоКода;
	КонецЕсли;

	Если Ошибки = Неопределено Тогда
		Ошибки = Новый Массив();
	КонецЕсли;

	ИсходящиеОшибки = Ошибки;

	ПрочитанныеОпции = Новый Соответствие();

	Парсер = Новый ПарсерКонсольнойКоманды();
	АргументыКоманд = Парсер.Распарсить(КоманднаяСтрока);

	Если АргументыКоманд.Количество() = 0 Тогда
		ВызватьИсключение "Передана пустая команда";
	КонецЕсли;

	Приложение = СоздатьКонсольноеПриложение();

	Результат = "";
	Для Каждого АргументыКоманды Из АргументыКоманд Цикл
		Если Не (НРег(АргументыКоманды[0]) = "curl") Тогда
			ВызватьИсключение "Команда должна начинаться с ""curl""";
		КонецЕсли;

		ОписаниеЗапроса = Новый ОписаниеЗапроса();

		АргументыКоманды.Удалить(0);

		Попытка
			Приложение.Запустить(АргументыКоманды);
		Исключение
			ОбработатьИсключениеОбработкиКоманды(ИнформацияОбОшибке());
			Возврат "";
		КонецПопытки;

		Если ОписаниеЗапроса.АдресаРесурсов.Количество() = 0 Тогда
			ИсходящиеОшибки.Добавить(ОбщегоНазначения.НоваяОшибка("Не указан URL", Истина));
			Возврат "";
		КонецЕсли;

		Результат = Результат 
			+ ?(Результат = "", "", Символы.ПС + Символы.ПС)
			+ Генератор.Получить(ОписаниеЗапроса, ИсходящиеОшибки);
	КонецЦикла;

	Возврат Результат;

КонецФункции

// Получает поддерживаемые опции
//
// Возвращаемое значение:
//   ТаблицаЗначений - таблица с колонками:
//     * Наименование - Строка - наименование
//     * НаименованияПараметров - Массив - массив строк, с полными наименованиями опции (например, [-f, --force])
//     * Описание     - Строка - краткое описание
//     * ПодробноеОписание - Строка - подробное описание
//     * ПеременнаяОкружения - Строка - переменная окружения, возможно несколько через пробел
//     * СкрытьЗначение - Булево - признак скрытия значения по умолчанию
//     * Значение - Произвольный - строковое представление значения по умолчанию
Функция ПоддерживаемыеОпции() Экспорт
	Возврат ОпцииКоманды(Истина, Ложь);
КонецФункции

// Получает неподдерживаемые опции
//
// Возвращаемое значение:
//   ТаблицаЗначений - таблица с колонками:
//     * Наименование - Строка - наименование
//     * НаименованияПараметров - Массив - массив строк, с полными наименованиями опции (например, [-f, --force])
//     * Описание     - Строка - краткое описание
//     * ПодробноеОписание - Строка - подробное описание
//     * ПеременнаяОкружения - Строка - переменная окружения, возможно несколько через пробел
//     * СкрытьЗначение - Булево - признак скрытия значения по умолчанию
//     * Значение - Произвольный - строковое представление значения по умолчанию
Функция НеподдерживаемыеОпции() Экспорт
	Возврат ОпцииКоманды(Ложь, Истина);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбработатьКоманду(Команда) Экспорт

	ПрочитатьКаталогСохраненияФайлов(Команда);	
	ПрочитатьАдресаРесурсов(Команда);
	ПрочитатьИменаВыходныхФайлов(Команда);
	ПрочитатьЗаголовки(Команда);
	ПрочитатьПользователя(Команда);
	ПрочитатьДанныеДляОтправки(Команда);
	ПрочитатьМетодЗапроса(Команда);
	ПрочитатьПризнакПередачиОтправляемыхДанныхВСтрокуЗапроса(Команда);
	ПрочитатьСертификатКлиента(Команда);
	ПрочитатьИспользованиеСертификатыУЦИзХранилищаОС(Команда);
	ПрочитатьИмяФайлаСертификатовУЦ(Команда);
	ПрочитатьПараметрыЗапросаURL(Команда);
	ПрочитатьАдресПрокси(Команда);
	ПрочитатьПользователяПрокси(Команда);
	ПрочитатьТипАутентификацииПрокси(Команда);
	ПрочитатьТаймаут(Команда);
	ПрочитатьТаймаутСоединения(Команда);
	ПрочитатьРежимаСоединенияFTP(Команда);
	
	ДополнитьОшибкиНеподдерживаемыеОпции(Команда);

КонецПроцедуры

Процедура ПрочитатьМетодЗапроса(Команда)

	Метод = ЗначениеОпции(Команда, "X");

	Если ЗначениеЗаполнено(Метод) Тогда
		ОписаниеЗапроса.Метод = Метод;
		Возврат;
	КонецЕсли;

	Если ЗначениеОпции(Команда, "get") = Ложь И ЕстьОпцииГруппыData(Команда) 
		ИЛИ ЕстьОпции(команда, "json") Тогда
		ОписаниеЗапроса.Метод = "POST";
	ИначеЕсли ЕстьОпции(Команда, "T,upload-file") Тогда
		ОписаниеЗапроса.Метод = "PUT";
	ИначеЕсли ЗначениеОпции(Команда, "head") = Истина Тогда
		ОписаниеЗапроса.Метод = "HEAD";
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьАдресаРесурсов(Команда)
    
	МассивURL = Новый Массив;
	ОбщегоНазначения.ДополнитьМассив(МассивURL, Команда.ЗначениеАргумента("URL"));
	ОбщегоНазначения.ДополнитьМассив(МассивURL, ЗначениеОпции(Команда, "url"));

	Для Каждого URL Из МассивURL Цикл
		ОписаниеЗапроса.ДобавитьАдресРесурса(URL);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьИменаВыходныхФайлов(Команда)

	ИменаВыходныхФайлов = ЗначениеОпции(Команда, "output");
	ПризнакиИзвлеченияИмениФайлаИзURL = ЗначениеОпции(Команда, "remote-name");
	ИзвлекатьИмяФайлаИзURLДляВсех = ПоследнееЗначениеОпции(Команда, "remote-name-all") = Истина;

	Если ИменаВыходныхФайлов.Количество() И ПризнакиИзвлеченияИмениФайлаИзURL.Количество() Тогда
		ВызватьИсключение "Одновременная передача опций -o (--output) и -O (--remote-name) не поддерживается";
	КонецЕсли;

	// Имя файла из опции
	Индекс = 0;
	Для Каждого ИмяВыходногоФайла Из ИменаВыходныхФайлов Цикл
		Если Индекс > ОписаниеЗапроса.АдресаРесурсов.ВГраница() Тогда
			Прервать;
		КонецЕсли;

		Если ЗначениеЗаполнено(КаталогСохраненияФайлов) Тогда
			ИмяВыходногоФайла = 
				ОбщегоНазначения.ДобавитьКонечныйРазделительПути(КаталогСохраненияФайлов) 
				+ ИмяВыходногоФайла;
		КонецЕсли;

		ОписаниеАдреса = ОписаниеЗапроса.АдресаРесурсов[Индекс];
		ОписаниеАдреса.ИмяВыходногоФайла = ИмяВыходногоФайла;

		Индекс = Индекс + 1;
	КонецЦикла;

	// Имя файла из URL
	Для Индекс = 0 По ОписаниеЗапроса.АдресаРесурсов.ВГраница() Цикл

		ИзвлекатьИмяИзURL = Индекс <= ПризнакиИзвлеченияИмениФайлаИзURL.ВГраница()
			И ПризнакиИзвлеченияИмениФайлаИзURL[Индекс]
			Или ИзвлекатьИмяФайлаИзURLДляВсех;

		Если Не ИзвлекатьИмяИзURL Тогда
			Продолжить;
		КонецЕсли;

		ОписаниеАдреса = ОписаниеЗапроса.АдресаРесурсов[Индекс];
		Если ЗначениеЗаполнено(ОписаниеАдреса.ИмяВыходногоФайла) Тогда
			Продолжить;
		КонецЕсли;

		ПарсерURL = Новый ПарсерURL(ОписаниеАдреса.URL);
		
		ИндексСлеша = СтрНайти(ПарсерURL.Путь, "/", НаправлениеПоиска.СКонца);
		Если ИндексСлеша Тогда
			ИмяВыходногоФайла = СокрЛП(Сред(ПарсерURL.Путь, ИндексСлеша + 1));
		Иначе
			ИмяВыходногоФайла = ПарсерURL.Путь;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(ИмяВыходногоФайла) Тогда
			ВызватьИсключение СтрШаблон("Не удалось получить имя файла из URL %1", ОписаниеАдреса.URL);
		КонецЕсли;

		Если ЗначениеЗаполнено(КаталогСохраненияФайлов) Тогда
			ИмяВыходногоФайла = 
				ОбщегоНазначения.ДобавитьКонечныйРазделительПути(КаталогСохраненияФайлов) 
				+ ИмяВыходногоФайла;
		КонецЕсли;

		ОписаниеАдреса.ИмяВыходногоФайла = ИмяВыходногоФайла;

	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьЗаголовки(Команда)

	ОписаниеЗапроса.Заголовки = РазобратьЗаголовки(Команда);
	ДополнитьЗаголовкиJson(Команда);
	ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда);
	ДополнитьЗаголовокUserAgent(Команда);
	ДополнитьЗаголовокAuthorizationBearerToken(Команда);

КонецПроцедуры

Процедура ДополнитьЗаголовкиJson(Команда)

	Если Не ЕстьОпции(Команда, "json") Тогда
		Возврат;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "Content-Type")) Тогда
		ОписаниеЗапроса.Заголовки.Вставить("Content-Type", "application/json");
	КонецЕсли;

	Если Не ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "Accept")) Тогда
		ОписаниеЗапроса.Заголовки.Вставить("Accept", "application/json");
	КонецЕсли;

КонецПроцедуры

Процедура ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда)
	Если ЕстьОпцииГруппыData(Команда)
		И ЗначениеОпции(Команда, "get") = Ложь
		И Не ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "Content-Type")) Тогда
		ОписаниеЗапроса.Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	КонецЕсли;
КонецПроцедуры

Процедура ДополнитьЗаголовокUserAgent(Команда)

	UserAgent = ПоследнееЗначениеОпции(Команда, "user-agent");

	Если UserAgent = Неопределено Или СтрДлина(UserAgent) = 0 Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "User-Agent")) Тогда
		Возврат;
	КонецЕсли;

	Если ПустаяСтрока(UserAgent) Тогда
		UserAgent = "";
	КонецЕсли;

	ОписаниеЗапроса.Заголовки.Вставить("User-Agent", UserAgent);

КонецПроцедуры

Процедура ДополнитьЗаголовокAuthorizationBearerToken(Команда)

	Токен = ПоследнееЗначениеОпции(Команда, "oauth2-bearer");
	
	Если ПустаяСтрока(Токен) Тогда
		Возврат;
	КонецЕсли;

	ОписаниеЗапроса.Заголовки.Вставить("Authorization", "Bearer " + Токен);

КонецПроцедуры

Функция РазобратьЗаголовки(Команда)

	Заголовки = Новый Соответствие;
	МассивЗаголовков = ЗначениеОпции(Команда, "H");
	Для Каждого Строка Из МассивЗаголовков Цикл
		Имя = "";
		Значение = "";

		ПозицияДвоеточия = СтрНайти(Строка, ":");
		Если ПозицияДвоеточия Тогда
			Имя = СокрЛП(Сред(Строка, 1, ПозицияДвоеточия - 1));
			Значение = СокрЛП(Сред(Строка, ПозицияДвоеточия + 1));
		Иначе
			Имя = Строка;
		КонецЕсли;

		Заголовки.Вставить(Имя, Значение);
	КонецЦикла;

	Возврат Заголовки;

КонецФункции

Функция ЗначениеЗаголовка(Заголовки, Имя)

	Для Каждого КлючЗначение Из Заголовки Цикл
		Если НРег(КлючЗначение.Ключ) = НРег(Имя) Тогда
			Возврат КлючЗначение.Значение;
		КонецЕсли;
	КонецЦикла;

КонецФункции

Процедура ПрочитатьПользователя(Команда)
	ПользовательИПароль = ЗначениеОпции(Команда, "u");
	МассивПодстрок = СтрРазделить(ПользовательИПароль, ":");

	ОписаниеЗапроса.ИмяПользователя = МассивПодстрок[0];
	Если МассивПодстрок.Количество() = 2 Тогда
		ОписаниеЗапроса.ПарольПользователя = МассивПодстрок[1];
	КонецЕсли
КонецПроцедуры

Процедура ПрочитатьДанныеДляОтправки(Команда)

	ПрочитатьData(Команда);
	ПрочитатьDataRaw(Команда);
	ПрочитатьDataBinary(Команда);
	ПрочитатьDataUrlencode(Команда);
	ПрочитатьUploadFile(Команда);
	ПрочитатьОпициюJson(Команда);

КонецПроцедуры

Процедура ПрочитатьData(Команда)

	МассивДанных = ЗначениеОпции(Команда, "d"); // -d, --data

	Для Каждого Данные Из МассивДанных Цикл

		Если Лев(Данные, 1) = "@" Тогда
			ИмяФайла = Сред(Данные, 2);

			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.УдалятьПереносыСтрок = Истина;
			
			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ПередаваемыйТекст = Новый ПередаваемыйТекст(Данные, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		КонецЕсли;
	
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataRaw(Команда)

	МассивДанных = ЗначениеОпции(Команда, "data-raw");

	Для Каждого Данные Из МассивДанных Цикл
		ПередаваемыйТекст = Новый ПередаваемыйТекст(Данные, НазначенияПередаваемыхДанных.ТелоЗапроса);
		ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataBinary(Команда)

	МассивДанных = ЗначениеОпции(Команда, "data-binary");
	Для Каждого ИмяФайла Из МассивДанных Цикл		
		Если Лев(ИмяФайла, 1) = "@" Тогда
			ИмяФайла = Сред(ИмяФайла, 2);
		КонецЕсли;
		
		ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.ТелоЗапроса);
		ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataUrlencode(Команда)

	МассивДанных = ЗначениеОпции(Команда, "data-urlencode");
	Для Каждого Данные Из МассивДанных Цикл
		ПозицияРавенства = СтрНайти(Данные, "=");
		ПозицияСобачки = СтрНайти(Данные, "@");
		Если ПозицияРавенства > 0 Тогда
			Ключ = Сред(Данные, 1, ПозицияРавенства - 1);
			Значение = Сред(Данные, ПозицияРавенства + 1);
			
			Значение = КодироватьСтроку(Значение, СпособКодированияСтроки.URLВКодировкеURL);
			Если ЗначениеЗаполнено(Ключ) Тогда
				Значение = СтрШаблон("%1=%2", Ключ, Значение);
			КонецЕсли;

			ПередаваемыйТекст = Новый ПередаваемыйТекст(Значение, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		ИначеЕсли ПозицияСобачки > 0 Тогда
			Ключ = Сред(Данные, 1, ПозицияСобачки - 1);
			ИмяФайла = СокрЛП(Сред(Данные, ПозицияСобачки + 1));	
			
			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ПередаваемыйФайл.Ключ = Ключ;
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.КодироватьСодержимое = Истина;

			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			Значение = КодироватьСтроку(Данные, СпособКодированияСтроки.URLВКодировкеURL);
			ПередаваемыйТекст = Новый ПередаваемыйТекст(Значение, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьUploadFile(Команда)

	МассивДанных = ЗначениеОпции(Команда, "T"); // T, --upload-file

	Для Каждого ИмяФайла Из МассивДанных Цикл

		ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.ТелоЗапроса);
		ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);

	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьОпициюJson(Команда)

	МассивДанных = ЗначениеОпции(Команда, "json");

	Для Каждого Данные Из МассивДанных Цикл

		Если Лев(Данные, 1) = "@" Тогда
			ИмяФайла = Сред(Данные, 2);

			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.РазделительТелаЗапроса = "";
			
			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ПередаваемыйТекст = Новый ПередаваемыйТекст(Данные, НазначенияПередаваемыхДанных.ТелоЗапроса);
			ПередаваемыйТекст.РазделительТелаЗапроса = "";	
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		КонецЕсли;
	
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьПризнакПередачиОтправляемыхДанныхВСтрокуЗапроса(Команда)
	
	ОписаниеЗапроса.ПередаватьОтправляемыеДанныеВСтрокуЗапроса = ЗначениеОпции(Команда, "get");

КонецПроцедуры

Процедура ПрочитатьСертификатКлиента(Команда)

	СертификатКлиента = ПоследнееЗначениеОпции(Команда, "E");

	Если Не ЗначениеЗаполнено(СертификатКлиента) Тогда
		Возврат;
	КонецЕсли;

	ПозицияДвоеточия = СтрНайти(СертификатКлиента, ":");
	Если ПозицияДвоеточия > 0 Тогда
		ОписаниеЗапроса.ИмяФайлаСертификатаКлиента = Сред(СертификатКлиента, 1, ПозицияДвоеточия - 1);
		ОписаниеЗапроса.ПарольСертификатаКлиента = Сред(СертификатКлиента, ПозицияДвоеточия + 1);
	Иначе
		ОписаниеЗапроса.ИмяФайлаСертификатаКлиента = СертификатКлиента;
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьИмяФайлаСертификатовУЦ(Команда)

	МассивЗначений = ЗначениеОпции(Команда, "cacert");
	Если МассивЗначений.Количество() Тогда
		ОписаниеЗапроса.ИмяФайлаСертификатовУЦ = МассивЗначений[МассивЗначений.ВГраница()];
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьИспользованиеСертификатыУЦИзХранилищаОС(Команда)

	ОписаниеЗапроса.ИспользоватьСертификатыУЦИзХранилищаОС = ЗначениеОпции(Команда, "ca-native");

КонецПроцедуры

Процедура ПрочитатьПараметрыЗапросаURL(Команда)
    
	МассивДанных = ЗначениеОпции(Команда, "url-query");

	Для Каждого Данные Из МассивДанных Цикл
		
		НачинаетсяСПлюса = Лев(Данные, 1) = "+";
		Если НачинаетсяСПлюса Тогда
			Данные = Сред(Данные, 2);
		КонецЕсли;

		ПозицияРавенства = СтрНайти(Данные, "=");
		ПозицияСобачки = СтрНайти(Данные, "@");
		КодироватьЗначение = Не НачинаетсяСПлюса;

		Если ПозицияРавенства > 0 Тогда
			Ключ = Сред(Данные, 1, ПозицияРавенства - 1);
			ПараметрЗапроса = Сред(Данные, ПозицияРавенства + 1);

			Если КодироватьЗначение Тогда
				ПараметрЗапроса = КодироватьСтроку(ПараметрЗапроса, СпособКодированияСтроки.URLВКодировкеURL);
			КонецЕсли;

			Если ЗначениеЗаполнено(Ключ) Тогда
				ПараметрЗапроса = СтрШаблон("%1=%2", Ключ, ПараметрЗапроса);
			КонецЕсли;

			ПередаваемыйТекст = Новый ПередаваемыйТекст(ПараметрЗапроса, НазначенияПередаваемыхДанных.СтрокаЗапроса);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		ИначеЕсли ПозицияСобачки > 0 И Не НачинаетсяСПлюса Тогда
			Ключ = Сред(Данные, 1, ПозицияСобачки - 1);
			ИмяФайла = СокрЛП(Сред(Данные, ПозицияСобачки + 1));	
			
			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияПередаваемыхДанных.СтрокаЗапроса);
			ПередаваемыйФайл.Ключ = Ключ;
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.КодироватьСодержимое = Истина;

			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ПараметрЗапроса = Данные;
			Если КодироватьЗначение Тогда
				ПараметрЗапроса = КодироватьСтроку(Данные, СпособКодированияСтроки.URLВКодировкеURL);
			КонецЕсли;

			ПередаваемыйТекст = Новый ПередаваемыйТекст(ПараметрЗапроса, НазначенияПередаваемыхДанных.СтрокаЗапроса);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыйТекст);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьКаталогСохраненияФайлов(Команда)
	КаталогСохраненияФайлов = "";
	Каталог = ПоследнееЗначениеОпции(Команда, "output-dir");
	Если Не Каталог = Неопределено Тогда
		КаталогСохраненияФайлов = Каталог;
	КонецЕсли;
КонецПроцедуры

Процедура ПрочитатьАдресПрокси(Команда)

	АдресПрокси = ПоследнееЗначениеОпции(Команда, "proxy");
	Если Не ЗначениеЗаполнено(АдресПрокси) Тогда
		Возврат;
	КонецЕсли;

	ПарсерURL = Новый ПарсерURL(АдресПрокси);

	ОписаниеЗапроса.ПроксиСервер = ПарсерURL.Сервер;
	
	ОписаниеЗапроса.ПроксиПротокол = НРег(ПарсерURL.Схема);
	Если Не ЗначениеЗаполнено(ОписаниеЗапроса.ПроксиПротокол) Тогда
		ОписаниеЗапроса.ПроксиПротокол = "http";
	КонецЕсли;

	ОписаниеЗапроса.ПроксиПорт = ПарсерURL.Порт;
	Если Не ЗначениеЗаполнено(ОписаниеЗапроса.ПроксиПорт) Тогда
		ОписаниеЗапроса.ПроксиПорт = 1080;	
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьПользователяПрокси(Команда)

	СтрокаПользователя = ПоследнееЗначениеОпции(Команда, "proxy-user");
	Если Не ЗначениеЗаполнено(СтрокаПользователя) Тогда
		Возврат;
	КонецЕсли;

	ИндексДвоеточия = СтрНайти(СтрокаПользователя, ":");
	Если ИндексДвоеточия > 0 Тогда
		ОписаниеЗапроса.ПроксиПользователь = Сред(СтрокаПользователя, 1, ИндексДвоеточия - 1);
		ОписаниеЗапроса.ПроксиПароль = Сред(СтрокаПользователя, ИндексДвоеточия + 1);
	Иначе
		ОписаниеЗапроса.ПроксиПользователь = СтрокаПользователя;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьТипАутентификацииПрокси(Команда)

	Если ПоследнееЗначениеОпции(Команда, "proxy-ntlm") = Истина Тогда
		ОписаниеЗапроса.ТипАутентификацииПрокси = ТипыАутентификацииПрокси.NTLM;
	Иначе
		ОписаниеЗапроса.ТипАутентификацииПрокси = ТипыАутентификацииПрокси.Basic;
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьТаймаут(Команда)

	Таймаут = ПоследнееЗначениеОпции(Команда, "max-time");
	Если Не Таймаут = Неопределено Тогда
		ОписаниеЗапроса.Таймаут = Таймаут;
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьТаймаутСоединения(Команда)

	ТаймаутСоединения = ПоследнееЗначениеОпции(Команда, "connect-timeout");
	Если Не ТаймаутСоединения = Неопределено Тогда
		ОписаниеЗапроса.ТаймаутСоединения = ТаймаутСоединения;
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьРежимаСоединенияFTP(Команда)

	ПассивныйРежим = ПоследнееЗначениеОпции(Команда, "ftp-pasv");
	АдресДляОбратногоСоединения = ПоследнееЗначениеОпции(Команда, "ftp-port");

	Если ЗначениеЗаполнено(АдресДляОбратногоСоединения) Тогда
		ОписаниеЗапроса.FTPАдресОбратногоСоединения = АдресДляОбратногоСоединения;
		ОписаниеЗапроса.FTPПассивныйРежимСоединения = Ложь;
	ИначеЕсли Не ПассивныйРежим = Неопределено Тогда
		ОписаниеЗапроса.FTPПассивныйРежимСоединения = ПассивныйРежим;
	Иначе
		ОписаниеЗапроса.FTPПассивныйРежимСоединения = Истина;
	КонецЕсли;

КонецПроцедуры

Функция СоздатьКонсольноеПриложение(ВключатьПоддерживаемые = Истина, ВключатьНеподдерживаемые = Истина)

	Приложение = Новый КонсольноеПриложение("curl", "", ЭтотОбъект);
	Приложение.УстановитьСпек("[ANY]");

	Приложение.Аргумент("URL", "", "Адрес ресурса").ТМассивСтрок();

	Если ВключатьПоддерживаемые Тогда
		Приложение.Опция("url", "", "URL").ТМассивСтрок();
		Приложение.Опция("H header", "", "HTTP заголовок").ТМассивСтрок();
		Приложение.Опция("X request", "", "Метод запроса").ТСтрока();
		Приложение.Опция("u user", "", "Пользователь и пароль").ТСтрока();
		Приложение.Опция("d data data-ascii", "", "Передаваемые данные по HTTP POST").ТМассивСтрок();
		Приложение.Опция("data-raw", "", "Передаваемые данные по HTTP POST без интерпретации символа @").ТМассивСтрок();
		Приложение.Опция("data-binary", "", "Передаваемые двоичные данные по HTTP POST").ТМассивСтрок();
		Приложение.Опция("data-urlencode", "", "Передаваемые данные по HTTP POST с URL кодированием").ТМассивСтрок();
		Приложение.Опция("T upload-file", "", "Загружаемый файл").ТМассивСтрок();
		Приложение.Опция("G get", Ложь, "Данные из опций -d и--data-... добавляются в URL как строка запроса").Флаговый();
		Приложение.Опция("I head", Ложь, "Получение заголовков").Флаговый();
		Приложение.Опция("E cert", "", "Сертификат клиента").ТМассивСтрок();
		Приложение.Опция("ca-native", Ложь, "Использование сертификатов УЦ из системного хранилища сертификатов операционной системы").Флаговый();
		Приложение.Опция("cacert", "", "Файл сертификатов удостоверяющих центров").ТМассивСтрок();
		Приложение.Опция("url-query", "", "Параметры строки запроса URL").ТМассивСтрок();
		Приложение.Опция("o output", "", "Имя выходного файла").ТМассивСтрок();
		Приложение.Опция("output-dir", "", "Каталог сохранения файлов").ТМассивСтрок();
		Приложение.Опция("O remote-name", "", "Извлечение имени выходного файла из URL").ТМассивБулево();
		Приложение.Опция("remote-name-all", "", "Извлечение имени выходного файла для всех URL").ТМассивБулево();
		Приложение.Опция("x proxy", "", "Прокси").ТМассивСтрок();
		Приложение.Опция("U proxy-user", "", "Пользователь прокси").ТМассивСтрок();
		Приложение.Опция("proxy-basic", "", "Использовать HTTP Basic-аутентификация прокси").ТМассивБулево();
		Приложение.Опция("proxy-ntlm", "", "Использовать NTLM-аутентификацию").ТМассивБулево();
		Приложение.Опция("m max-time", 0, "Максимальное время ожидания на выполнение запроса").ТМассивЧисел();
		Приложение.Опция("connect-timeout", 0, "Максимальное время ожидания на попытку соединения к хосту").ТМассивЧисел();
		Приложение.Опция("json", "", "Данные JSON").ТМассивСтрок();
		Приложение.Опция("A user-agent", "", "HTTP заголовок запроса User-Agent").ТМассивСтрок();		
		Приложение.Опция("oauth2-bearer", "", "Bearer-token").ТМассивСтрок();
		Приложение.Опция("ftp-pasv", , "Использование пассивного режима ftp-соединения").ТМассивБулево();		
		Приложение.Опция("P ftp-port", "", "Использование активного режима ftp-соединения").ТМассивСтрок();
	КонецЕсли;

	Если ВключатьНеподдерживаемые Тогда
		Приложение.Опция("abstract-unix-socket").ТМассивСтрок();
		Приложение.Опция("alt-svc").ТМассивСтрок();
		Приложение.Опция("anyauth").ТМассивБулево();
		Приложение.Опция("a append").ТМассивБулево();
		Приложение.Опция("aws-sigv4").ТМассивСтрок();
		Приложение.Опция("basic").ТМассивБулево();
		Приложение.Опция("capath").ТМассивСтрок();
		Приложение.Опция("cert-status").ТМассивБулево();
		Приложение.Опция("cert-type").ТМассивСтрок();
		Приложение.Опция("ciphers").ТМассивСтрок();
		Приложение.Опция("compressed").ТМассивБулево();
		Приложение.Опция("compressed-ssh").ТМассивБулево();
		Приложение.Опция("K config").ТМассивСтрок();
		Приложение.Опция("connect-to").ТМассивСтрок();
		Приложение.Опция("C continue-at").ТМассивСтрок();
		Приложение.Опция("b cookie").ТМассивСтрок();
		Приложение.Опция("c cookie-jar").ТМассивСтрок();
		Приложение.Опция("create-dirs").ТМассивБулево();
		Приложение.Опция("create-file-mode").ТМассивСтрок();
		Приложение.Опция("crlf").ТМассивБулево();
		Приложение.Опция("crlfile").ТМассивСтрок();
		Приложение.Опция("curves").ТМассивСтрок();
		Приложение.Опция("delegation").ТМассивСтрок();
		Приложение.Опция("digest").ТМассивБулево();
		Приложение.Опция("q disable").ТМассивБулево();
		Приложение.Опция("disable-eprt").ТМассивБулево();
		Приложение.Опция("disable-epsv").ТМассивБулево();
		Приложение.Опция("disallow-username-in-url").ТМассивБулево();
		Приложение.Опция("dns-interface").ТМассивСтрок();
		Приложение.Опция("dns-ipv4-addr").ТМассивСтрок();
		Приложение.Опция("dns-ipv6-addr").ТМассивСтрок();
		Приложение.Опция("dns-servers").ТМассивСтрок();
		Приложение.Опция("doh-cert-status").ТМассивБулево();
		Приложение.Опция("doh-insecure").ТМассивБулево();
		Приложение.Опция("doh-url").ТМассивСтрок();
		Приложение.Опция("dump-ca-embed").ТМассивБулево();
		Приложение.Опция("D dump-header").ТМассивСтрок();
		Приложение.Опция("ech").ТМассивСтрок();
		Приложение.Опция("egd-file").ТМассивСтрок();
		Приложение.Опция("engine").ТМассивСтрок();
		Приложение.Опция("etag-compare").ТМассивСтрок();
		Приложение.Опция("etag-save").ТМассивСтрок();
		Приложение.Опция("expect100-timeout").ТМассивСтрок();
		Приложение.Опция("f fail").ТМассивБулево();
		Приложение.Опция("fail-early").ТМассивБулево();
		Приложение.Опция("fail-with-body").ТМассивБулево();
		Приложение.Опция("false-start").ТМассивБулево();
		Приложение.Опция("F form").ТМассивСтрок();
		Приложение.Опция("form-escape").ТМассивБулево();
		Приложение.Опция("form-string").ТМассивСтрок();
		Приложение.Опция("ftp-account").ТМассивСтрок();
		Приложение.Опция("ftp-alternative-to-user").ТМассивСтрок();
		Приложение.Опция("ftp-create-dirs").ТМассивБулево();
		Приложение.Опция("ftp-method").ТМассивСтрок();
		Приложение.Опция("ftp-pret").ТМассивБулево();
		Приложение.Опция("ftp-skip-pasv-ip").ТМассивБулево();
		Приложение.Опция("ftp-ssl-ccc").ТМассивБулево();
		Приложение.Опция("ftp-ssl-ccc-mode").ТМассивСтрок();
		Приложение.Опция("ftp-ssl-control").ТМассивБулево();
		Приложение.Опция("g globoff").ТМассивБулево();
		Приложение.Опция("happy-eyeballs-timeout-ms").ТМассивСтрок();
		Приложение.Опция("haproxy-clientip").ТМассивСтрок();
		Приложение.Опция("haproxy-protocol").ТМассивБулево();
		Приложение.Опция("h help").ТМассивСтрок();
		Приложение.Опция("hostpubmd5").ТМассивСтрок();
		Приложение.Опция("hostpubsha256").ТМассивСтрок();
		Приложение.Опция("hsts").ТМассивСтрок();
		Приложение.Опция("http0.9").ТМассивБулево();
		Приложение.Опция("0 http1.0").ТМассивБулево();
		Приложение.Опция("http1.1").ТМассивБулево();
		Приложение.Опция("http2").ТМассивБулево();
		Приложение.Опция("http2-prior-knowledge").ТМассивБулево();
		Приложение.Опция("http3").ТМассивБулево();
		Приложение.Опция("http3-only").ТМассивБулево();
		Приложение.Опция("ignore-content-length").ТМассивБулево();
		Приложение.Опция("k insecure").ТМассивБулево();
		Приложение.Опция("interface").ТМассивСтрок();
		Приложение.Опция("ip-tos").ТМассивСтрок();
		Приложение.Опция("ipfs-gateway").ТМассивСтрок();
		Приложение.Опция("4 ipv4").ТМассивБулево();
		Приложение.Опция("6 ipv6").ТМассивБулево();
		Приложение.Опция("j junk-session-cookies").ТМассивБулево();
		Приложение.Опция("keepalive-cnt").ТМассивСтрок();
		Приложение.Опция("keepalive-time").ТМассивСтрок();
		Приложение.Опция("key").ТМассивСтрок();
		Приложение.Опция("key-type").ТМассивСтрок();
		Приложение.Опция("krb").ТМассивСтрок();
		Приложение.Опция("libcurl").ТМассивСтрок();
		Приложение.Опция("limit-rate").ТМассивСтрок();
		Приложение.Опция("l list-only").ТМассивБулево();
		Приложение.Опция("local-port").ТМассивСтрок();
		Приложение.Опция("L location").ТМассивБулево();
		Приложение.Опция("location-trusted").ТМассивБулево();
		Приложение.Опция("login-options").ТМассивСтрок();
		Приложение.Опция("mail-auth").ТМассивСтрок();
		Приложение.Опция("mail-from").ТМассивСтрок();
		Приложение.Опция("mail-rcpt").ТМассивСтрок();
		Приложение.Опция("mail-rcpt-allowfails").ТМассивБулево();
		Приложение.Опция("M manual").ТМассивБулево();
		Приложение.Опция("max-filesize").ТМассивСтрок();
		Приложение.Опция("max-redirs").ТМассивСтрок();
		Приложение.Опция("metalink").ТМассивБулево();
		Приложение.Опция("mptcp").ТМассивБулево();
		Приложение.Опция("negotiate").ТМассивБулево();
		Приложение.Опция("n netrc").ТМассивБулево();
		Приложение.Опция("netrc-file").ТМассивСтрок();
		Приложение.Опция("netrc-optional").ТМассивБулево();
		Приложение.Опция("no-alpn").ТМассивБулево();
		Приложение.Опция("N no-buffer").ТМассивБулево();
		Приложение.Опция("no-clobber").ТМассивБулево();
		Приложение.Опция("no-keepalive").ТМассивБулево();
		Приложение.Опция("no-npn").ТМассивБулево();
		Приложение.Опция("no-progress-meter").ТМассивБулево();
		Приложение.Опция("no-sessionid").ТМассивБулево();
		Приложение.Опция("noproxy").ТМассивСтрок();
		Приложение.Опция("ntlm").ТМассивБулево();
		Приложение.Опция("ntlm-wb").ТМассивБулево();
		Приложение.Опция("Z parallel").ТМассивБулево();
		Приложение.Опция("parallel-immediate").ТМассивБулево();
		Приложение.Опция("parallel-max").ТМассивСтрок();
		Приложение.Опция("pass").ТМассивСтрок();
		Приложение.Опция("path-as-is").ТМассивБулево();
		Приложение.Опция("pinnedpubkey").ТМассивСтрок();
		Приложение.Опция("post301").ТМассивБулево();
		Приложение.Опция("post302").ТМассивБулево();
		Приложение.Опция("post303").ТМассивБулево();
		Приложение.Опция("preproxy").ТМассивБулево();
		Приложение.Опция("proto").ТМассивСтрок();
		Приложение.Опция("proto-default").ТМассивСтрок();
		Приложение.Опция("proto-redir").ТМассивСтрок();
		Приложение.Опция("proxy-anyauth").ТМассивБулево();
		Приложение.Опция("proxy-ca-native").ТМассивБулево();
		Приложение.Опция("proxy-cacert").ТМассивСтрок();
		Приложение.Опция("proxy-capath").ТМассивСтрок();
		Приложение.Опция("proxy-cert").ТМассивСтрок();
		Приложение.Опция("proxy-cert-type").ТМассивСтрок();
		Приложение.Опция("proxy-ciphers").ТМассивСтрок();
		Приложение.Опция("proxy-crlfile").ТМассивСтрок();
		Приложение.Опция("proxy-digest").ТМассивБулево();
		Приложение.Опция("proxy-header").ТМассивСтрок();
		Приложение.Опция("proxy-http2").ТМассивБулево();
		Приложение.Опция("proxy-insecure").ТМассивБулево();
		Приложение.Опция("proxy-key").ТМассивСтрок();
		Приложение.Опция("proxy-key-type").ТМассивСтрок();
		Приложение.Опция("proxy-negotiate").ТМассивБулево();
		Приложение.Опция("proxy-pass").ТМассивСтрок();
		Приложение.Опция("proxy-pinnedpubkey").ТМассивСтрок();
		Приложение.Опция("proxy-service-name").ТМассивСтрок();
		Приложение.Опция("proxy-ssl-allow-beast").ТМассивБулево();
		Приложение.Опция("proxy-ssl-auto-client-cert").ТМассивБулево();
		Приложение.Опция("proxy-tls13-ciphers").ТМассивСтрок();
		Приложение.Опция("proxy-tlsauthtype").ТМассивСтрок();
		Приложение.Опция("proxy-tlspassword").ТМассивСтрок();
		Приложение.Опция("proxy-tlsuser").ТМассивСтрок();
		Приложение.Опция("proxy-tlsv1").ТМассивБулево();
		Приложение.Опция("proxy1.0").ТМассивСтрок();
		Приложение.Опция("p proxytunnel").ТМассивБулево();
		Приложение.Опция("pubkey").ТМассивСтрок();
		Приложение.Опция("Q quote").ТМассивСтрок();
		Приложение.Опция("random-file").ТМассивСтрок();
		Приложение.Опция("r range").ТМассивСтрок();
		Приложение.Опция("rate").ТМассивСтрок();
		Приложение.Опция("raw").ТМассивБулево();
		Приложение.Опция("e referer").ТМассивСтрок();
		Приложение.Опция("J remote-header-name").ТМассивБулево();
		Приложение.Опция("R remote-time").ТМассивБулево();
		Приложение.Опция("remove-on-error").ТМассивБулево();
		Приложение.Опция("request-target").ТМассивСтрок();
		Приложение.Опция("resolve").ТМассивСтрок();
		Приложение.Опция("retry").ТМассивСтрок();
		Приложение.Опция("retry-all-errors").ТМассивБулево();
		Приложение.Опция("retry-connrefused").ТМассивБулево();
		Приложение.Опция("retry-delay").ТМассивСтрок();
		Приложение.Опция("retry-max-time").ТМассивСтрок();
		Приложение.Опция("sasl-authzid").ТМассивСтрок();
		Приложение.Опция("sasl-ir").ТМассивБулево();
		Приложение.Опция("service-name").ТМассивСтрок();
		Приложение.Опция("S show-error").ТМассивБулево();
		Приложение.Опция("i show-headers").ТМассивБулево();
		Приложение.Опция("s silent").ТМассивБулево();
		Приложение.Опция("skip-existing").ТМассивБулево();
		Приложение.Опция("socks4").ТМассивСтрок();
		Приложение.Опция("socks4a").ТМассивСтрок();
		Приложение.Опция("socks5").ТМассивСтрок();
		Приложение.Опция("socks5-basic").ТМассивБулево();
		Приложение.Опция("socks5-gssapi").ТМассивБулево();
		Приложение.Опция("socks5-gssapi-nec").ТМассивБулево();
		Приложение.Опция("socks5-gssapi-service").ТМассивСтрок();
		Приложение.Опция("socks5-hostname").ТМассивСтрок();
		Приложение.Опция("Y speed-limit").ТМассивСтрок();
		Приложение.Опция("y speed-time").ТМассивСтрок();
		Приложение.Опция("ssl").ТМассивБулево();
		Приложение.Опция("ssl-allow-beast").ТМассивБулево();
		Приложение.Опция("ssl-auto-client-cert").ТМассивБулево();
		Приложение.Опция("ssl-no-revoke").ТМассивБулево();
		Приложение.Опция("ssl-reqd").ТМассивБулево();
		Приложение.Опция("ssl-revoke-best-effort").ТМассивБулево();
		Приложение.Опция("2 sslv2").ТМассивБулево();
		Приложение.Опция("3 sslv3").ТМассивБулево();
		Приложение.Опция("stderr").ТМассивСтрок();
		Приложение.Опция("styled-output").ТМассивБулево();
		Приложение.Опция("suppress-connect-headers").ТМассивБулево();
		Приложение.Опция("tcp-fastopen").ТМассивБулево();
		Приложение.Опция("tcp-nodelay").ТМассивБулево();
		Приложение.Опция("t telnet-option").ТМассивСтрок();
		Приложение.Опция("tftp-blksize").ТМассивСтрок();
		Приложение.Опция("tftp-no-options").ТМассивБулево();
		Приложение.Опция("z time-cond").ТМассивСтрок();
		Приложение.Опция("tls-earlydata").ТМассивБулево();
		Приложение.Опция("tls-max").ТМассивСтрок();
		Приложение.Опция("tls13-ciphers").ТМассивСтрок();
		Приложение.Опция("tlsauthtype").ТМассивСтрок();
		Приложение.Опция("tlspassword").ТМассивСтрок();
		Приложение.Опция("tlsuser").ТМассивСтрок();
		Приложение.Опция("1 tlsv1").ТМассивБулево();
		Приложение.Опция("tlsv1.0").ТМассивБулево();
		Приложение.Опция("tlsv1.1").ТМассивБулево();
		Приложение.Опция("tlsv1.2").ТМассивБулево();
		Приложение.Опция("tlsv1.3").ТМассивБулево();
		Приложение.Опция("tr-encoding").ТМассивБулево();
		Приложение.Опция("trace").ТМассивСтрок();
		Приложение.Опция("trace-ascii").ТМассивСтрок();
		Приложение.Опция("trace-config").ТМассивСтрок();
		Приложение.Опция("trace-ids").ТМассивБулево();
		Приложение.Опция("trace-time").ТМассивБулево();
		Приложение.Опция("unix-socket").ТМассивСтрок();
		Приложение.Опция("B use-ascii").ТМассивБулево();
		Приложение.Опция("variable").ТМассивСтрок();
		Приложение.Опция("v verbose").ТМассивБулево();
		Приложение.Опция("V version").ТМассивБулево();
		Приложение.Опция("vlan-priority").ТМассивСтрок();
		Приложение.Опция("w write-out").ТМассивСтрок();
		Приложение.Опция("xattr").ТМассивБулево();				
	КонецЕсли;

	Приложение.УстановитьОсновноеДействие(ЭтотОбъект, "ОбработатьКоманду");

	Возврат Приложение;

КонецФункции

Функция ЕстьОпции(Команда, Опции)
	Для Каждого Опция Из СтрРазделить(Опции, ",") Цикл
		Если ЗначениеЗаполнено(ЗначениеОпции(Команда, Опция)) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
КонецФункции

Функция ЕстьОпцииГруппыData(Команда)
	Возврат ЕстьОпции(Команда, "d,data,data-raw,data-binary,data-urlencode,data-ascii");
КонецФункции

Функция ПоследнееЗначениеОпции(Команда, ИмяОпции)
	МассивЗначений = ЗначениеОпции(Команда, ИмяОпции);
	Если ТипЗнч(МассивЗначений) = Тип("Массив") И МассивЗначений.Количество() Тогда
		Возврат МассивЗначений[МассивЗначений.ВГраница()];
	КонецЕсли;
КонецФункции

Функция ЗначениеОпции(Команда, ИмяОпции)
	ПрочитанныеОпции.Вставить(ИмяОпции, Истина);
	Возврат Команда.ЗначениеОпции(ИмяОпции);
КонецФункции

Функция ОпцииКоманды(ВключатьПоддерживаемые = Истина, ВключатьНеподдерживаемые = Истина) Экспорт

	Приложение = СоздатьКонсольноеПриложение(ВключатьПоддерживаемые, ВключатьНеподдерживаемые);
	ТаблицаОпций = Приложение.ПолучитьКоманду().ПолучитьТаблицуОпций();

	Возврат ТаблицаОпций;

КонецФункции

Процедура ОбработатьИсключениеОбработкиКоманды(ИнформацияОбОшибке)

	Текст = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);

	// Неожидаемая опция
	ПодстрокаПоиска = "Неожидаемая опция";
	Инд = СтрНайти(Текст, ПодстрокаПоиска);
	Если Инд Тогда
		Опция = СокрЛП(Сред(Текст, Инд + СтрДлина(ПодстрокаПоиска)));
		ТекстОшибки = СтрШаблон("Опция %1 неизвестна", Опция);
		ИсходящиеОшибки.Добавить(ОбщегоНазначения.НоваяОшибка(ТекстОшибки, Истина));
		Возврат;
	КонецЕсли;

	// Опция должна содержать значение
	ПодстрокаПоиска = "должна содержать значение";
	Инд = СтрНайти(Текст, ":");
	Если СтрНайти(Текст, ПодстрокаПоиска) И Инд Тогда
		ТекстОшибки = СокрЛП(Сред(Текст, Инд + 1));
		ИсходящиеОшибки.Добавить(ОбщегоНазначения.НоваяОшибка(ТекстОшибки, Истина));
		Возврат;
	КонецЕсли;

	ВызватьИсключение Текст;

КонецПроцедуры

Процедура ДополнитьОшибкиНеподдерживаемыеОпции(Команда)

	НеподдерживаемыеОпции = НеподдерживаемыеОпции();

	Для Каждого Строка Из НеподдерживаемыеОпции Цикл
		Значение = Команда.ЗначениеОпции(Строка.Наименование);
		Если ЗначениеЗаполнено(Значение) Тогда
			ТекстОшибки = СтрШаблон("Опция %1 не поддерживается", СтрСоединить(Строка.НаименованияПараметров, ", "));
			ИсходящиеОшибки.Добавить(ОбщегоНазначения.НоваяОшибка(ТекстОшибки));
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти