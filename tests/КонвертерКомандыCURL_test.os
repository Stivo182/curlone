// BSLLS:LatinAndCyrillicSymbolInWord-off

#Использовать asserts
#Использовать "../src/core"

Перем КонвертерКомандыCURL; // см. КонвертерКомандыCURL

&Инициализация
Процедура ПередЗапускомТестов() Экспорт

	КонвертерКомандыCURL = Новый КонвертерКомандыCURL();
	
КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуКомандаДолжнаНачинатьсяСCurl() Экспорт

	КонсольнаяКоманда = "myapp -H 'accept: text/html'";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Команда должна начинаться с ""curl"", но вместо этого начинается с myapp");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуПереданаПустаяКоманда() Экспорт

	КонсольнаяКоманда = "";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Передана пустая команда");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуОпцияНеизвестна() Экспорт

	КонсольнаяКоманда = "curl http://example.com/ --unknown-option";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Опция --unknown-option неизвестна");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуОпцияНеПоддерживается() Экспорт

	КонсольнаяКоманда = "curl http://example.com/ --hsts cache.txt";
	
	ПрограммныйКод = "Соединение = Новый HTTPСоединение(""example.com"", 80);
	|HTTPЗапрос = Новый HTTPЗапрос(""/"");
	|
	|HTTPОтвет = Соединение.ВызватьHTTPМетод(""GET"", HTTPЗапрос);";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Равно(ПрограммныйКод);
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Опция --hsts не поддерживается");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоЛожь();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуНеУказанURL() Экспорт

	КонсольнаяКоманда = "curl";
	
	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Не указан URL");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуНеУказанОдинИзURL() Экспорт

	КонсольнаяКоманда = "curl example1.com '' example2.com";
	
	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Не указан URL #2");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуНеУдалосьПолучитьНомерПортаИзURL() Экспорт

	КонсольнаяКоманда = "curl http://example.com:port";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Не удалось получить номер порта из URL 'http://example.com:port'");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуНеправильноеИспользованиеФигурныхСкобокПриПередачеФайла() Экспорт

	ТестовыеЗначения = Новый Массив();
	ТестовыеЗначения.Добавить("{path");
	ТестовыеЗначения.Добавить("path}");
	ТестовыеЗначения.Добавить("}path}");
	ТестовыеЗначения.Добавить("{path{");
	ТестовыеЗначения.Добавить("}path{");

	Для Каждого ТестовоеЗначение Из ТестовыеЗначения Цикл
		КонсольнаяКоманда = "curl --upload-file '" + ТестовоеЗначение + "' http://example.com";

		Ошибки = Неопределено;

		Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

		Ожидаем.Что(Результат).Не_().Заполнено();
		Ожидаем.Что(Ошибки).Заполнено();
		Ожидаем.Что(Ошибки[0].Текст).Равно("Неправильное использование фигурных скобок в значении '" + ТестовоеЗначение + "' опции -T, --upload-file");
		Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();
	КонецЦикла;
	
КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуЗапрещеноОдновременноеИспользованиеНесколькихHTTPМетодов() Экспорт
	
	// Ошибочные команды
	ОшибочныеКоманды = Новый Массив();
	ОшибочныеКоманды.Добавить("-T file --get -d 'key=val'");
	ОшибочныеКоманды.Добавить("-T file -d 'key=val'");
	ОшибочныеКоманды.Добавить("-T file --json '{""key"": ""val""}'");
	ОшибочныеКоманды.Добавить("-T file --head");
	ОшибочныеКоманды.Добавить("-d 'key=val' --head");

	Для Каждого Команда Из ОшибочныеКоманды Цикл
		КонсольнаяКоманда = "curl http://example.com " + Команда;

		Ошибки = Неопределено;

		Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

		Ожидаем.Что(Результат).Не_().Заполнено();
		Ожидаем.Что(Ошибки, "Команда не валидна: " + КонсольнаяКоманда).Заполнено();
		Ожидаем.Что(Ошибки[0].Текст).Содержит("Запрещено одновременное использование нескольких HTTP методов");
		Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();
	КонецЦикла;
	
	// Валидные команды
	ВалидныеКоманды = Новый Массив();
	ВалидныеКоманды.Добавить("-T file --get");
	ВалидныеКоманды.Добавить("--get --head");
	ВалидныеКоманды.Добавить("-d 'key=val' --get");
	ВалидныеКоманды.Добавить("-d 'key=val' --get --head");

	Для Каждого Команда Из ВалидныеКоманды Цикл
		КонсольнаяКоманда = "curl http://example.com " + Команда;

		Ошибки = Неопределено;

		Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

		Ожидаем.Что(Ошибки, "Команда валидна: " + КонсольнаяКоманда).Не_().Заполнено();
	КонецЦикла;

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуПротоколНеПоддерживается() Экспорт

	КонсольнаяКоманда = "curl smtp://example.com";

	Ошибки = Неопределено;

	Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

	Ожидаем.Что(Результат).Не_().Заполнено();
	Ожидаем.Что(Ошибки).Заполнено();
	Ожидаем.Что(Ошибки[0].Текст).Равно("Протокол ""smtp"" не поддерживается");
	Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуОдновременнаяПередачаОпцийЗапрещенаДляОтправляемыхДанных() Экспорт
	
	// Ошибочные команды
	ОшибочныеКоманды = Новый Массив();
	ОшибочныеКоманды.Добавить("-d data -F data");
	ОшибочныеКоманды.Добавить("--data data -F data");
	ОшибочныеКоманды.Добавить("--data-raw data -F data");
	ОшибочныеКоманды.Добавить("--data-binary @file -F data");
	ОшибочныеКоманды.Добавить("--data-urlencode data -F data");
	ОшибочныеКоманды.Добавить("--data-ascii data -F data");
	ОшибочныеКоманды.Добавить("--head -F data");
	ОшибочныеКоманды.Добавить("-T file -F data");
	ОшибочныеКоманды.Добавить("--upload-file file -F data");

	Для Каждого Команда Из ОшибочныеКоманды Цикл
		КонсольнаяКоманда = "curl http://example.com " + Команда;

		Ошибки = Неопределено;

		Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

		Ожидаем.Что(Результат).Не_().Заполнено();
		Ожидаем.Что(Ошибки, "Команда не валидна: " + КонсольнаяКоманда).Заполнено();
		Ожидаем.Что(Ошибки[0].Текст).Содержит("Одновременная передача опций");
		Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();
	КонецЦикла;

КонецПроцедуры

&Тест
Процедура ТестДолжен_ПроверитьОшибкуЗапрещеноИспользоватьНесколькоТиповАутентификации() Экспорт

	ОшибочныеКоманды = Новый Массив();
	ОшибочныеКоманды.Добавить("--basic --digest");
	ОшибочныеКоманды.Добавить("--ntlm --negotiate");
	ОшибочныеКоманды.Добавить("--aws-sigv4 'aws:amz:us-east-2:es' --oauth2-bearer token");

	Для Каждого Команда Из ОшибочныеКоманды Цикл
		КонсольнаяКоманда = "curl http://example.com " + Команда;

		Ошибки = Неопределено;

		Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, , Ошибки);

		Ожидаем.Что(Результат).Не_().Заполнено();
		Ожидаем.Что(Ошибки, "Команда не валидна: " + КонсольнаяКоманда).Заполнено();
		Ожидаем.Что(Ошибки[0].Текст).Содержит("Запрещено использовать несколько типов аутентификации");
		Ожидаем.Что(Ошибки[0].Критичная).ЭтоИстина();
	КонецЦикла;

КонецПроцедуры