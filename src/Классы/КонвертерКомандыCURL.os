﻿#Использовать cli
#Использовать "../internal"

Перем ОписаниеЗапроса;
Перем КаталогСохраненияФайлов;

#Область ПрограммныйИнтерфейс

Функция Конвертировать(КоманднаяСтрока, пГенераторПрограммногоКода = Неопределено) Экспорт
	
	Если пГенераторПрограммногоКода = Неопределено Тогда
		ГенераторПрограммногоКода = Новый ГенераторПрограммногоКода1С();
	Иначе
		ГенераторПрограммногоКода = пГенераторПрограммногоКода;
	КонецЕсли;

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
		Приложение.Запустить(АргументыКоманды);

		Результат = Результат 
			+ ?(Результат = "", "", Символы.ПС + Символы.ПС)
			+ ГенераторПрограммногоКода.Получить(ОписаниеЗапроса);
	КонецЦикла;

	Возврат Результат;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ВыполнитьКоманду(Команда) Экспорт

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
	
КонецПроцедуры

Процедура ПрочитатьМетодЗапроса(Команда)

	Метод = Команда.ЗначениеОпции("X");

	Если ЗначениеЗаполнено(Метод) Тогда
		ОписаниеЗапроса.Метод = Метод;
		Возврат;
	КонецЕсли;

	Если Команда.ЗначениеОпции("get") = Ложь И ЕстьОпцииГруппыData(Команда) Тогда
		ОписаниеЗапроса.Метод = "POST";
	ИначеЕсли ЕстьОпции(Команда, "T,upload-file") Тогда
		ОписаниеЗапроса.Метод = "PUT";
	ИначеЕсли Команда.ЗначениеОпции("head") = Истина Тогда
		ОписаниеЗапроса.Метод = "HEAD";
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьАдресаРесурсов(Команда)
    
	МассивURL = Новый Массив;
	ОбщегоНазначения.ДополнитьМассив(МассивURL, Команда.ЗначениеАргумента("URL"));
	ОбщегоНазначения.ДополнитьМассив(МассивURL, Команда.ЗначениеОпции("url"));

	Для Каждого URL Из МассивURL Цикл
		ОписаниеЗапроса.ДобавитьАдресРесурса(URL);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьИменаВыходныхФайлов(Команда)

	ИменаВыходныхФайлов = Команда.ЗначениеОпции("output");
	ПризнакиИзвлеченияИмениФайлаИзURL = Команда.ЗначениеОпции("remote-name");
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
	ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда);

КонецПроцедуры

Процедура ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда)
	Если ЕстьОпцииГруппыData(Команда)
		И Команда.ЗначениеОпции("get") = Ложь
		И Не ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "Content-Type")) Тогда
		ОписаниеЗапроса.Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	КонецЕсли;
КонецПроцедуры

Функция РазобратьЗаголовки(Команда)

	Заголовки = Новый Соответствие;
	МассивЗаголовков = Команда.ЗначениеОпции("H");
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
	ПользовательИПароль = Команда.ЗначениеОпции("u");
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

КонецПроцедуры

Процедура ПрочитатьData(Команда)

	МассивДанных = Команда.ЗначениеОпции("d"); // -d, --data

	Для Каждого Данные Из МассивДанных Цикл

		Если Лев(Данные, 1) = "@" Тогда
			ИмяФайла = Сред(Данные, 2);

			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияФайлов.ТелоЗапроса);
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.УдалятьПереносыСтрок = Истина;
			
			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(Данные);
		КонецЕсли;
	
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataRaw(Команда)

	МассивДанных = Команда.ЗначениеОпции("data-raw");

	Для Каждого Данные Из МассивДанных Цикл
		ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(Данные);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataBinary(Команда)

	МассивДанных = Команда.ЗначениеОпции("data-binary");
	Для Каждого ИмяФайла Из МассивДанных Цикл		
		Если Лев(ИмяФайла, 1) = "@" Тогда
			ИмяФайла = Сред(ИмяФайла, 2);
		КонецЕсли;
		
		ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияФайлов.ТелоЗапроса);			
		ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьDataUrlencode(Команда)

	МассивДанных = Команда.ЗначениеОпции("data-urlencode");
	Для Каждого Данные Из МассивДанных Цикл
		ПозицияРавенства = СтрНайти(Данные, "=");
		ПозицияСобачки = СтрНайти(Данные, "@");
		Если ПозицияРавенства > 0 Тогда
			Ключ = Сред(Данные, 1, ПозицияРавенства - 1);
			Значение = Сред(Данные, ПозицияРавенства + 1);
			
			ПередаваемыеДанные = КодироватьСтроку(Значение, СпособКодированияСтроки.URLВКодировкеURL);
			Если ЗначениеЗаполнено(Ключ) Тогда
				ПередаваемыеДанные = СтрШаблон("%1=%2", Ключ, ПередаваемыеДанные);
			КонецЕсли;

			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыеДанные);
		ИначеЕсли ПозицияСобачки > 0 Тогда
			Ключ = Сред(Данные, 1, ПозицияСобачки - 1);
			ИмяФайла = СокрЛП(Сред(Данные, ПозицияСобачки + 1));	
			
			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияФайлов.ТелоЗапроса);
			ПередаваемыйФайл.Ключ = Ключ;
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.КодироватьСодержимое = Истина;

			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ПередаваемыеДанные = КодироватьСтроку(Данные, СпособКодированияСтроки.URLВКодировкеURL);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(ПередаваемыеДанные);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьUploadFile(Команда)

	МассивДанных = Команда.ЗначениеОпции("T"); // T, --upload-file

	Для Каждого ИмяФайла Из МассивДанных Цикл

		ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияФайлов.ТелоЗапроса);
		ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);

	КонецЦикла;

КонецПроцедуры

Процедура ПрочитатьПризнакПередачиОтправляемыхДанныхВСтрокуЗапроса(Команда)
	
	ОписаниеЗапроса.ПередаватьОтправляемыеДанныеВСтрокуЗапроса = Команда.ЗначениеОпции("get");

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

	МассивЗначений = Команда.ЗначениеОпции("cacert");
	Если МассивЗначений.Количество() Тогда
		ОписаниеЗапроса.ИмяФайлаСертификатовУЦ = МассивЗначений[МассивЗначений.ВГраница()];
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьИспользованиеСертификатыУЦИзХранилищаОС(Команда)

	ОписаниеЗапроса.ИспользоватьСертификатыУЦИзХранилищаОС = Команда.ЗначениеОпции("ca-native");

КонецПроцедуры

Процедура ПрочитатьПараметрыЗапросаURL(Команда)
    
	МассивДанных = Команда.ЗначениеОпции("url-query");

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

			ОписаниеЗапроса.ПараметрыЗапроса.Добавить(ПараметрЗапроса);
		ИначеЕсли ПозицияСобачки > 0 И Не НачинаетсяСПлюса Тогда
			Ключ = Сред(Данные, 1, ПозицияСобачки - 1);
			ИмяФайла = СокрЛП(Сред(Данные, ПозицияСобачки + 1));	
			
			ПередаваемыйФайл = Новый ПередаваемыйФайл(ИмяФайла, НазначенияФайлов.СтрокаЗапроса);
			ПередаваемыйФайл.Ключ = Ключ;
			ПередаваемыйФайл.ПрочитатьСодержимое = Истина;
			ПередаваемыйФайл.КодироватьСодержимое = Истина;

			ОписаниеЗапроса.Файлы.Добавить(ПередаваемыйФайл);
		Иначе
			ПараметрЗапроса = Данные;
			Если КодироватьЗначение Тогда
				ПараметрЗапроса = КодироватьСтроку(Данные, СпособКодированияСтроки.URLВКодировкеURL);
			КонецЕсли;

			ОписаниеЗапроса.ПараметрыЗапроса.Добавить(ПараметрЗапроса);
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

Функция СоздатьКонсольноеПриложение()

	Приложение = Новый КонсольноеПриложение("curl", "", ЭтотОбъект);

	Приложение.Аргумент("URL", "", "Адрес ресурса").ТМассивСтрок();
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

	УстановитьСтрокуИспользованияКоманды(Приложение);
	Приложение.УстановитьОсновноеДействие(ЭтотОбъект);

	Возврат Приложение;

КонецФункции

Функция ЕстьОпции(Команда, Опции)
	Для Каждого Опция Из СтрРазделить(Опции, ",") Цикл
		Если ЗначениеЗаполнено(Команда.ЗначениеОпции(Опция)) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
КонецФункции

Функция ЕстьОпцииГруппыData(Команда)
	Возврат ЕстьОпции(Команда, "d,data,data-raw,data-binary,data-urlencode,data-ascii");
КонецФункции

Процедура УстановитьСтрокуИспользованияКоманды(Приложение)

	Команда = Приложение.ПолучитьКоманду();
	
	МассивОпцийИАргументов = Новый Массив;

	МассивОписанийОпцийИАргументов = Новый Массив;
	ОбщегоНазначения.ДополнитьМассив(МассивОписанийОпцийИАргументов, Команда.ПолучитьТаблицуОпций());
	ОбщегоНазначения.ДополнитьМассив(МассивОписанийОпцийИАргументов, Команда.ПолучитьТаблицуАргументов());

	Для Каждого Описание Из МассивОписанийОпцийИАргументов Цикл
		ОбщегоНазначения.ДополнитьМассив(МассивОпцийИАргументов, Описание.НаименованияПараметров);
	КонецЦикла;

	СтрокаСпек = СтрШаблон("[%1]...", СтрСоединить(МассивОпцийИАргументов, " |"));

	Приложение.УстановитьСпек(СтрокаСпек);

КонецПроцедуры

Функция ПоследнееЗначениеОпции(Команда, ИмяОпции)
	МассивЗначений = Команда.ЗначениеОпции(ИмяОпции);
	Если ТипЗнч(МассивЗначений) = Тип("Массив") И МассивЗначений.Количество() Тогда
		Возврат МассивЗначений[МассивЗначений.ВГраница()];
	КонецЕсли;
КонецФункции

#КонецОбласти