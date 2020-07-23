﻿
Процедура ПриСозданииНаСервере(Обработчики, Форма, Объект, Отказ, ОтложенноеОткрытие = Истина) Экспорт
	
	ТипСтрока = Новый ОписаниеТипов("Строка");
	ДобавляемыРеквизиты = Новый Массив;
	ДобавляемыРеквизиты.Добавить(Новый РеквизитФормы("КД3_Обработчики", Новый ОписаниеТипов("СписокЗначений")));
	ДобавляемыРеквизиты.Добавить(Новый РеквизитФормы("КД3_Конфигурация", Новый ОписаниеТипов("СправочникСсылка.Конфигурации")));
	Для Каждого ИмяОбработчика Из Обработчики Цикл
		ДобавляемыРеквизиты.Добавить(Новый РеквизитФормы("КД3_" + ИмяОбработчика, ТипСтрока));
	КонецЦикла;
	Форма.ИзменитьРеквизиты(ДобавляемыРеквизиты, Новый Массив);
	
	Для Каждого ИмяОбработчика Из Обработчики Цикл
		
		ЭлементЭталон = Форма.Элементы[ИмяОбработчика];
		ЭлементЭталон.Видимость = Ложь;
		
		Элемент = Форма.Элементы.Добавить("КД3_Конфигурация_" + ИмяОбработчика, Тип("ПолеФормы"), ЭлементЭталон.Родитель);
		Элемент.Вид = ВидПоляФормы.ПолеВвода;
		Элемент.ПутьКДанным = "КД3_Конфигурация";
		Элемент.Заголовок = "Конфигурация контекстной подсказки";
		Элемент.УстановитьДействие("ПриИзменении", "КД3_ПриИзмененииКонфигурации");
		
		Элемент = Форма.Элементы.Добавить("КД3_" + ИмяОбработчика, Тип("ПолеФормы"), ЭлементЭталон.Родитель);
		Элемент.Вид = ВидПоляФормы.ПолеHTMLДокумента;
		Элемент.ПутьКДанным = "КД3_" + ИмяОбработчика;
		Элемент.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
		Элемент.УстановитьДействие("ДокументСформирован", "КД3_ДокументСформирован");
		
	КонецЦикла;
	
	Форма["КД3_Обработчики"].ЗагрузитьЗначения(Обработчики);
	
КонецПроцедуры

Функция ПолучитьКонфигурацию(СсылкаНаОбъект) Экспорт
	
	Конфигурация = Неопределено;
	
	Если ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Конвертации.Конфигурация КАК Конфигурация
		|ИЗ
		|	Справочник.СоставыКонвертаций КАК СоставыКонвертаций
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Конвертации КАК Конвертации
		|		ПО СоставыКонвертаций.Владелец = Конвертации.Ссылка
		|ГДЕ
		|	СоставыКонвертаций.ЭлементКонвертации = &СсылкаНаОбъект
		|	И НЕ СоставыКонвертаций.Отключить";
		Запрос.УстановитьПараметр("СсылкаНаОбъект", СсылкаНаОбъект);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Конфигурация = Выборка.Конфигурация;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Конфигурация;
	
КонецФункции

Функция ПолучитьФайлМакетаИсходников() Экспорт
	Возврат ПоместитьВоВременноеХранилище(ПолучитьОбщийМакет("КД3_src"));
КонецФункции

Функция КоллекцияМетаданных(Конфигурация) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	БезопасноеХранилищеДанных.Данные КАК Данные
	|ИЗ
	|	РегистрСведений.БезопасноеХранилищеДанных КАК БезопасноеХранилищеДанных
	|ГДЕ
	|	БезопасноеХранилищеДанных.Владелец = &Владелец";
	Запрос.УстановитьПараметр("Владелец", КлючКэшаНастроек(Конфигурация));
	РезультатЗапроса = Запрос.Выполнить();
	
	МетаданныеJSON = Неопределено;
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Если Выборка.Следующий() Тогда
			МетаданныеJSON = Выборка.Данные.Получить();
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеJSON = Неопределено Тогда
		ЗагрузитьОписаниеМетаданных(Конфигурация, МетаданныеJSON);
	КонецЕсли;
	
	Возврат ПоместитьВоВременноеХранилище(МетаданныеJSON);
	
КонецФункции

Функция КлючКэшаНастроек(Конфигурация)
	
	Возврат "КД3_" + XMLСтрока(Конфигурация);
	
КонецФункции

Процедура ЗагрузитьОписаниеМетаданных(Конфигурация, МетаданныеJSON) Экспорт
	
	КорневыеТипы = Новый Соответствие;
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.Справочник, "Справочник");
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.Документ, "Документ");
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.РегистрСведений, "РегистрСведений");
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.РегистрНакопления, "РегистрНакопления");
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.РегистрБухгалтерии, "РегистрБухгалтерии");
	КорневыеТипы.Вставить(Перечисления.ТипыОбъектов.Перечисление, "Перечисление");
	
	КоллекцияМетаданных = Новый Структура;
	КоллекцияМетаданных.Вставить("catalogs", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "Справочники", КорневыеТипы));
	КоллекцияМетаданных.Вставить("documents", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "Документы", КорневыеТипы));
	КоллекцияМетаданных.Вставить("infoRegs", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "РегистрыСведений", КорневыеТипы));
	КоллекцияМетаданных.Вставить("accumRegs", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "РегистрыНакопления", КорневыеТипы));
	КоллекцияМетаданных.Вставить("accountRegs", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "РегистрыБухгалтерии", КорневыеТипы));
	//КоллекцияМетаданных.Вставить("dataProc", ОписатьКоллекциюОбъектовМетаданых(Метаданные.Обработки));
	//КоллекцияМетаданных.Вставить("reports", ОписатьКоллекциюОбъектовМетаданых(Метаданные.Отчеты));
	КоллекцияМетаданных.Вставить("enums", ОписатьКоллекциюОбъектовМетаданых(Конфигурация, "Перечисления", КорневыеТипы));
	
	Файл = Новый ЗаписьJSON();
	Файл.УстановитьСтроку();
	Попытка
		ЗаписатьJSON(Файл, КоллекцияМетаданных);
		МетаданныеJSON = Файл.Закрыть();
	Исключение
		МетаданныеJSON = "";
		ТекстСообщения = "Не удалось сохранить коллекцию метаданных:" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	КонецПопытки;
	
	МенеджерЗаписи = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Владелец = КлючКэшаНастроек(Конфигурация);
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(МетаданныеJSON);
	Попытка
		МенеджерЗаписи.Записать();
	Исключение
		ТекстСообщения = "Не удалось сохранить метаданные конфигурации в ИБ" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	КонецПопытки;
	
КонецПроцедуры

Функция ОписатьКоллекциюОбъектовМетаданых(Конфигурация, Коллекция, КорневыеТипы)
	
	ОписаниеКоллекции = Новый Структура();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Объекты.Ссылка КАК Ссылка,
	|	Объекты.Имя КАК Имя,
	|	Объекты.Тип КАК Тип
	|ПОМЕСТИТЬ Объекты
	|ИЗ
	|	Справочник.Объекты КАК Объекты
	|ГДЕ
	|	Объекты.Родитель В
	|			(ВЫБРАТЬ
	|				Объекты.Ссылка КАК Ссылка
	|			ИЗ
	|				Справочник.Объекты КАК Объекты
	|			ГДЕ
	|				Объекты.Владелец = &Конфигурация
	|				И Объекты.Наименование = &Коллекция)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Объекты.Ссылка КАК Ссылка,
	|	Объекты.Имя КАК Имя,
	|	Объекты.Тип КАК Тип
	|ИЗ
	|	Объекты КАК Объекты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Значения.Владелец КАК Объект,
	|	Значения.Ссылка КАК Ссылка,
	|	Значения.Наименование КАК Наименование,
	|	Значения.Синоним КАК Синоним
	|ИЗ
	|	Справочник.Значения КАК Значения
	|ГДЕ
	|	Значения.Владелец В
	|			(ВЫБРАТЬ
	|				Объекты.Ссылка
	|			ИЗ
	|				Объекты)
	|ИТОГИ ПО
	|	Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Свойства.Владелец КАК Объект,
	|	Свойства.Вид КАК Вид,
	|	Свойства.Ссылка КАК Ссылка,
	|	Свойства.Наименование КАК Наименование,
	|	Свойства.Синоним КАК Синоним
	|ИЗ
	|	Справочник.Свойства КАК Свойства
	|ГДЕ
	|	Свойства.Владелец В
	|			(ВЫБРАТЬ
	|				ОБъекты.Ссылка
	|			ИЗ
	|				ОБъекты)
	|ИТОГИ ПО
	|	Объект,
	|	Вид";
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	Запрос.УстановитьПараметр("Коллекция", Коллекция);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	ВыборкаОбъектМетаданных = РезультатЗапроса[1].Выбрать();
	ВыборкаЗначенияОбъектов = РезультатЗапроса[2].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаСвойстваОбъектов = РезультатЗапроса[3].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаОбъектМетаданных.Следующий() Цикл
		
		ОписаниеРеквизитов = Новый Структура();
		
		КорневойТип = КорневыеТипы[ВыборкаОбъектМетаданных.Тип];
		ПолноеИмя = КорневойТип + "." + ВыборкаОбъектМетаданных.Имя;
		
		Если КорневойТип = "Перечисление" ИЛИ КорневойТип = "Справочник" Тогда
			Если ВыборкаЗначенияОбъектов.НайтиСледующий(ВыборкаОбъектМетаданных.Ссылка, "Объект") Тогда
				Выборка = ВыборкаЗначенияОбъектов.Выбрать();
				Пока Выборка.Следующий() Цикл
					Если НЕ ПустаяСтрока(Выборка.Наименование) Тогда
						ОписаниеРеквизитов.Вставить(Выборка.Наименование, Выборка.Синоним);
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		
		Если ВыборкаСвойстваОбъектов.НайтиСледующий(ВыборкаОбъектМетаданных.Ссылка, "Объект") Тогда
			ВыборкаВидыСвойств = ВыборкаСвойстваОбъектов.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			
			ВидыСвойств = Новый Массив;
			ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Реквизит);
			Если КорневойТип = "РегистрСведений" ИЛИ КорневойТип = "РегистрНакопления" ИЛИ КорневойТип = "РегистрБухгалтерии" Тогда
				ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Измерение);
				ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Ресурс);
			КонецЕсли;
			
			Для Каждого ВидСвойства Из ВидыСвойств Цикл
				Если ВыборкаВидыСвойств.НайтиСледующий(ВидСвойства, "Вид") Тогда
					Выборка = ВыборкаВидыСвойств.Выбрать();
					Пока Выборка.Следующий() Цикл
						ОписаниеРеквизитов.Вставить(Выборка.Наименование, Выборка.Синоним);
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		ОписаниеКоллекции.Вставить(ВыборкаОбъектМетаданных.Имя, Новый Структура("properties", ОписаниеРеквизитов));
		
	КонецЦикла;
	
	Возврат ОписаниеКоллекции;
	
КонецФункции

Функция ВерсияИсходников() Экспорт
	Возврат СтрЗаменить(Метаданные.ОбщиеМакеты.КД3_src.Комментарий, ".", "_");
КонецФункции
