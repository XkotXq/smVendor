///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsPl = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pl>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$nav$pl nav = Translations$nav$pl._(_root);
	late final Translations$login$pl login = Translations$login$pl._(_root);
	late final Translations$orders$pl orders = Translations$orders$pl._(_root);
	late final Translations$account$pl account = Translations$account$pl._(_root);
	late final Translations$frpStock$pl frpStock = Translations$frpStock$pl._(_root);
	late final Translations$shortLengths$pl shortLengths = Translations$shortLengths$pl._(_root);
}

// Path: nav
class Translations$nav$pl {
	Translations$nav$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Konto'
	String get account => 'Konto';

	/// pl: 'Zwiń nawigację'
	String get collapse => 'Zwiń nawigację';

	/// pl: 'Rozwiń nawigację'
	String get expand => 'Rozwiń nawigację';

	/// pl: 'Historia'
	String get history => 'Historia';

	/// pl: 'Zadania'
	String get available => 'Zadania';

	/// pl: 'Realizowane'
	String get inProgress => 'Realizowane';
}

// Path: login
class Translations$login$pl {
	Translations$login$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Zaloguj się'
	String get title => 'Zaloguj się';

	/// pl: 'smVendor - panel logowania'
	String get subtitle => 'smVendor - panel logowania';

	/// pl: 'Login'
	String get usernameLabel => 'Login';

	/// pl: 'Hasło'
	String get passwordLabel => 'Hasło';

	/// pl: 'Zaloguj się'
	String get submit => 'Zaloguj się';

	/// pl: 'Logowanie...'
	String get submitting => 'Logowanie...';

	/// pl: 'Wpisz login i hasło.'
	String get missingFields => 'Wpisz login i hasło.';

	late final Translations$login$errors$pl errors = Translations$login$errors$pl._(_root);
}

// Path: orders
class Translations$orders$pl {
	Translations$orders$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Zamówienia'
	String get title => 'Zamówienia';

	/// pl: 'Wczytywanie...'
	String get loading => 'Wczytywanie...';

	/// pl: 'Nie udało się pobrać listy zamówień.'
	String get loadError => 'Nie udało się pobrać listy zamówień.';

	/// pl: 'Spróbuj ponownie'
	String get retry => 'Spróbuj ponownie';

	late final Translations$orders$types$pl types = Translations$orders$types$pl._(_root);
	late final Translations$orders$status$pl status = Translations$orders$status$pl._(_root);
	late final Translations$orders$card$pl card = Translations$orders$card$pl._(_root);
	late final Translations$orders$detail$pl detail = Translations$orders$detail$pl._(_root);

	/// pl: 'W realizacji'
	String get sectionInProgress => 'W realizacji';

	/// pl: 'Nowe zamówienia'
	String get sectionNew => 'Nowe zamówienia';

	/// pl: 'Oczekują na potwierdzenie'
	String get sectionDelivered => 'Oczekują na potwierdzenie';

	late final Translations$orders$history$pl history = Translations$orders$history$pl._(_root);

	/// pl: 'Problem'
	String get sectionProblem => 'Problem';

	late final Translations$orders$chat$pl chat = Translations$orders$chat$pl._(_root);

	/// pl: 'Brak zadań do wzięcia.'
	String get emptyAvailable => 'Brak zadań do wzięcia.';

	/// pl: 'Nie realizujesz żadnego zadania.'
	String get emptyMine => 'Nie realizujesz żadnego zadania.';
}

// Path: account
class Translations$account$pl {
	Translations$account$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Wyloguj'
	String get logout => 'Wyloguj';

	/// pl: 'Język'
	String get language => 'Język';

	/// pl: 'Polski'
	String get languagePolish => 'Polski';

	/// pl: 'English'
	String get languageEnglish => 'English';

	/// pl: 'Motyw'
	String get theme => 'Motyw';

	/// pl: 'Systemowy'
	String get themeSystem => 'Systemowy';

	/// pl: 'Jasny'
	String get themeLight => 'Jasny';

	/// pl: 'Ciemny'
	String get themeDark => 'Ciemny';
}

// Path: frpStock
class Translations$frpStock$pl {
	Translations$frpStock$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Stan FRP'
	String get title => 'Stan FRP';

	/// pl: 'Wczytywanie...'
	String get loading => 'Wczytywanie...';

	/// pl: 'Nie udało się pobrać stanu FRP.'
	String get loadError => 'Nie udało się pobrać stanu FRP.';

	/// pl: 'Spróbuj ponownie'
	String get retry => 'Spróbuj ponownie';

	/// pl: 'Brak pozycji.'
	String get empty => 'Brak pozycji.';

	/// pl: 'Nazwa, item, bęben lub lokalizacja'
	String get searchPlaceholder => 'Nazwa, item, bęben lub lokalizacja';

	/// pl: 'Z tego zamówienia'
	String get fromThisOrder => 'Z tego zamówienia';

	/// pl: 'Pozostałe'
	String get otherDrums => 'Pozostałe';

	/// pl: 'Zarezerwowana'
	String get reserved => 'Zarezerwowana';
}

// Path: shortLengths
class Translations$shortLengths$pl {
	Translations$shortLengths$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Krótkie odcinki'
	String get title => 'Krótkie odcinki';

	/// pl: 'Zgłoś krótkie odcinki'
	String get button => 'Zgłoś krótkie odcinki';

	/// pl: 'Materiał'
	String get material => 'Materiał';

	/// pl: 'Ilość'
	String get quantity => 'Ilość';

	/// pl: 'Zgłoś'
	String get submit => 'Zgłoś';

	/// pl: 'Zgłoszono'
	String get reported => 'Zgłoszono';

	/// pl: 'Nie udało się wysłać zgłoszenia.'
	String get submitError => 'Nie udało się wysłać zgłoszenia.';

	/// pl: 'Zdjęcie'
	String get photo => 'Zdjęcie';

	/// pl: 'Zrób zdjęcie'
	String get photoTake => 'Zrób zdjęcie';

	/// pl: 'Z galerii'
	String get photoPick => 'Z galerii';

	/// pl: 'Nie udało się wczytać zdjęcia.'
	String get photoError => 'Nie udało się wczytać zdjęcia.';

	/// pl: 'Zgłoszenie zapisane, ale zdjęcie się nie wysłało.'
	String get photoUploadError => 'Zgłoszenie zapisane, ale zdjęcie się nie wysłało.';
}

// Path: login.errors
class Translations$login$errors$pl {
	Translations$login$errors$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Nieprawidłowy login lub hasło.'
	String get invalidCredentials => 'Nieprawidłowy login lub hasło.';

	/// pl: 'Nie udało się połączyć z CIP.'
	String get cipUnreachable => 'Nie udało się połączyć z CIP.';

	/// pl: 'Zbyt wiele prób logowania - spróbuj ponownie za chwilę.'
	String get tooManyAttempts => 'Zbyt wiele prób logowania - spróbuj ponownie za chwilę.';

	/// pl: 'Nie udało się połączyć z serwerem.'
	String get serverUnreachable => 'Nie udało się połączyć z serwerem.';
}

// Path: orders.types
class Translations$orders$types$pl {
	Translations$orders$types$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Dolewanie wody'
	String get water_refill => 'Dolewanie wody';

	/// pl: 'Zamówienie materiału'
	String get material_order => 'Zamówienie materiału';

	/// pl: 'Zamówienie szpul'
	String get spool_order => 'Zamówienie szpul';

	/// pl: 'Transport półproduktów'
	String get goods_transport => 'Transport półproduktów';

	/// pl: 'Wywożenie odpadu'
	String get waste_removal => 'Wywożenie odpadu';

	/// pl: 'Zwrot na magazyn'
	String get warehouse_return => 'Zwrot na magazyn';

	/// pl: 'Przewóz maszyny'
	String get machine_transport => 'Przewóz maszyny';
}

// Path: orders.status
class Translations$orders$status$pl {
	Translations$orders$status$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Nowe'
	String get kNew => 'Nowe';

	/// pl: 'W realizacji'
	String get inProgress => 'W realizacji';

	/// pl: 'Dostarczone'
	String get delivered => 'Dostarczone';

	/// pl: 'Zrealizowane'
	String get done => 'Zrealizowane';

	/// pl: 'Anulowane'
	String get cancelled => 'Anulowane';

	/// pl: 'Problem'
	String get problem => 'Problem';
}

// Path: orders.card
class Translations$orders$card$pl {
	Translations$orders$card$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Zlecający'
	String get employeeNo => 'Zlecający';

	/// pl: 'Rozpocznij zadanie'
	String get take => 'Rozpocznij zadanie';

	/// pl: 'Realizuje {who}'
	String takenBy({required Object who}) => 'Realizuje ${who}';

	/// pl: 'Zamawiający zgłosił problem'
	String get problemFromRequester => 'Zamawiający zgłosił problem';

	/// pl: 'Czeka na zamawiającego'
	String get problemWithRequester => 'Czeka na zamawiającego';

	/// pl: 'Dostarczone'
	String get deliver => 'Dostarczone';

	/// pl: 'Oczekuje na potwierdzenie'
	String get awaitingConfirm => 'Oczekuje na potwierdzenie';

	/// pl: '{n} poz.'
	String itemsShort({required Object n}) => '${n} poz.';
}

// Path: orders.detail
class Translations$orders$detail$pl {
	Translations$orders$detail$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Linia'
	String get line => 'Linia';

	/// pl: 'Numer zamówienia'
	String get productionOrderNo => 'Numer zamówienia';

	/// pl: 'Zlecający'
	String get employeeNo => 'Zlecający';

	/// pl: 'Zrealizował'
	String get fulfilledBy => 'Zrealizował';

	/// pl: 'Dostarczył'
	String get deliveredBy => 'Dostarczył';

	/// pl: 'Utworzono'
	String get createdAt => 'Utworzono';

	/// pl: 'Pozycje'
	String get itemsTitle => 'Pozycje';

	/// pl: 'Wydano: {value}'
	String issued({required Object value}) => 'Wydano: ${value}';

	/// pl: 'Rozpocznij zadanie'
	String get take => 'Rozpocznij zadanie';

	/// pl: 'Dostarczone'
	String get deliver => 'Dostarczone';

	/// pl: 'Nie udało się oznaczyć zamówienia jako dostarczone.'
	String get deliverError => 'Nie udało się oznaczyć zamówienia jako dostarczone.';

	/// pl: 'Oczekuje na potwierdzenie odbioru.'
	String get awaitingAcceptance => 'Oczekuje na potwierdzenie odbioru.';

	/// pl: 'Zgłoś problem'
	String get reportProblem => 'Zgłoś problem';

	/// pl: 'Zgłoszenie problemu'
	String get reportProblemTitle => 'Zgłoszenie problemu';

	/// pl: 'Napisz, co blokuje transport.'
	String get reportProblemDescription => 'Napisz, co blokuje transport.';

	/// pl: 'Na czym polega problem?'
	String get reportProblemPlaceholder => 'Na czym polega problem?';

	/// pl: 'Zgłoś'
	String get reportProblemSubmit => 'Zgłoś';

	/// pl: 'Anuluj'
	String get reportProblemCancel => 'Anuluj';

	/// pl: 'Nie udało się zgłosić problemu.'
	String get reportProblemError => 'Nie udało się zgłosić problemu.';

	/// pl: 'Zgłoszono problem - czeka na zamawiającego'
	String get problemWaiting => 'Zgłoszono problem - czeka na zamawiającego';

	/// pl: '{who} oznaczył problem jako rozwiązany'
	String problemResolvedBy({required Object who}) => '${who} oznaczył problem jako rozwiązany';

	/// pl: 'Zamawiający zgłosił problem'
	String get problemFromRequester => 'Zamawiający zgłosił problem';

	/// pl: 'Problem rozwiązany'
	String get problemResolve => 'Problem rozwiązany';

	/// pl: 'Nie udało się oznaczyć problemu jako rozwiązanego.'
	String get resolveError => 'Nie udało się oznaczyć problemu jako rozwiązanego.';

	/// pl: 'Czat'
	String get chat => 'Czat';

	/// pl: 'Stan FRP w magazynie'
	String get frpStockButton => 'Stan FRP w magazynie';
}

// Path: orders.history
class Translations$orders$history$pl {
	Translations$orders$history$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Brak zrealizowanych zamówień.'
	String get empty => 'Brak zrealizowanych zamówień.';

	/// pl: 'Nie udało się pobrać historii.'
	String get loadError => 'Nie udało się pobrać historii.';

	/// pl: 'Dziś'
	String get today => 'Dziś';

	/// pl: 'Wczoraj'
	String get yesterday => 'Wczoraj';

	/// pl: 'To już wszystko.'
	String get allLoaded => 'To już wszystko.';
}

// Path: orders.chat
class Translations$orders$chat$pl {
	Translations$orders$chat$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Czat'
	String get title => 'Czat';

	/// pl: 'Napisz wiadomość...'
	String get placeholder => 'Napisz wiadomość...';

	/// pl: 'Brak wiadomości.'
	String get empty => 'Brak wiadomości.';

	/// pl: 'Nie udało się pobrać czatu.'
	String get loadError => 'Nie udało się pobrać czatu.';

	/// pl: 'Nie udało się wysłać wiadomości.'
	String get sendError => 'Nie udało się wysłać wiadomości.';
}

/// The flat map containing all translations for locale <pl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.account' => 'Konto',
			'nav.collapse' => 'Zwiń nawigację',
			'nav.expand' => 'Rozwiń nawigację',
			'nav.history' => 'Historia',
			'nav.available' => 'Zadania',
			'nav.inProgress' => 'Realizowane',
			'login.title' => 'Zaloguj się',
			'login.subtitle' => 'smVendor - panel logowania',
			'login.usernameLabel' => 'Login',
			'login.passwordLabel' => 'Hasło',
			'login.submit' => 'Zaloguj się',
			'login.submitting' => 'Logowanie...',
			'login.missingFields' => 'Wpisz login i hasło.',
			'login.errors.invalidCredentials' => 'Nieprawidłowy login lub hasło.',
			'login.errors.cipUnreachable' => 'Nie udało się połączyć z CIP.',
			'login.errors.tooManyAttempts' => 'Zbyt wiele prób logowania - spróbuj ponownie za chwilę.',
			'login.errors.serverUnreachable' => 'Nie udało się połączyć z serwerem.',
			'orders.title' => 'Zamówienia',
			'orders.loading' => 'Wczytywanie...',
			'orders.loadError' => 'Nie udało się pobrać listy zamówień.',
			'orders.retry' => 'Spróbuj ponownie',
			'orders.types.water_refill' => 'Dolewanie wody',
			'orders.types.material_order' => 'Zamówienie materiału',
			'orders.types.spool_order' => 'Zamówienie szpul',
			'orders.types.goods_transport' => 'Transport półproduktów',
			'orders.types.waste_removal' => 'Wywożenie odpadu',
			'orders.types.warehouse_return' => 'Zwrot na magazyn',
			'orders.types.machine_transport' => 'Przewóz maszyny',
			'orders.status.kNew' => 'Nowe',
			'orders.status.inProgress' => 'W realizacji',
			'orders.status.delivered' => 'Dostarczone',
			'orders.status.done' => 'Zrealizowane',
			'orders.status.cancelled' => 'Anulowane',
			'orders.status.problem' => 'Problem',
			'orders.card.employeeNo' => 'Zlecający',
			'orders.card.take' => 'Rozpocznij zadanie',
			'orders.card.takenBy' => ({required Object who}) => 'Realizuje ${who}',
			'orders.card.problemFromRequester' => 'Zamawiający zgłosił problem',
			'orders.card.problemWithRequester' => 'Czeka na zamawiającego',
			'orders.card.deliver' => 'Dostarczone',
			'orders.card.awaitingConfirm' => 'Oczekuje na potwierdzenie',
			'orders.card.itemsShort' => ({required Object n}) => '${n} poz.',
			'orders.detail.line' => 'Linia',
			'orders.detail.productionOrderNo' => 'Numer zamówienia',
			'orders.detail.employeeNo' => 'Zlecający',
			'orders.detail.fulfilledBy' => 'Zrealizował',
			'orders.detail.deliveredBy' => 'Dostarczył',
			'orders.detail.createdAt' => 'Utworzono',
			'orders.detail.itemsTitle' => 'Pozycje',
			'orders.detail.issued' => ({required Object value}) => 'Wydano: ${value}',
			'orders.detail.take' => 'Rozpocznij zadanie',
			'orders.detail.deliver' => 'Dostarczone',
			'orders.detail.deliverError' => 'Nie udało się oznaczyć zamówienia jako dostarczone.',
			'orders.detail.awaitingAcceptance' => 'Oczekuje na potwierdzenie odbioru.',
			'orders.detail.reportProblem' => 'Zgłoś problem',
			'orders.detail.reportProblemTitle' => 'Zgłoszenie problemu',
			'orders.detail.reportProblemDescription' => 'Napisz, co blokuje transport.',
			'orders.detail.reportProblemPlaceholder' => 'Na czym polega problem?',
			'orders.detail.reportProblemSubmit' => 'Zgłoś',
			'orders.detail.reportProblemCancel' => 'Anuluj',
			'orders.detail.reportProblemError' => 'Nie udało się zgłosić problemu.',
			'orders.detail.problemWaiting' => 'Zgłoszono problem - czeka na zamawiającego',
			'orders.detail.problemResolvedBy' => ({required Object who}) => '${who} oznaczył problem jako rozwiązany',
			'orders.detail.problemFromRequester' => 'Zamawiający zgłosił problem',
			'orders.detail.problemResolve' => 'Problem rozwiązany',
			'orders.detail.resolveError' => 'Nie udało się oznaczyć problemu jako rozwiązanego.',
			'orders.detail.chat' => 'Czat',
			'orders.detail.frpStockButton' => 'Stan FRP w magazynie',
			'orders.sectionInProgress' => 'W realizacji',
			'orders.sectionNew' => 'Nowe zamówienia',
			'orders.sectionDelivered' => 'Oczekują na potwierdzenie',
			'orders.history.empty' => 'Brak zrealizowanych zamówień.',
			'orders.history.loadError' => 'Nie udało się pobrać historii.',
			'orders.history.today' => 'Dziś',
			'orders.history.yesterday' => 'Wczoraj',
			'orders.history.allLoaded' => 'To już wszystko.',
			'orders.sectionProblem' => 'Problem',
			'orders.chat.title' => 'Czat',
			'orders.chat.placeholder' => 'Napisz wiadomość...',
			'orders.chat.empty' => 'Brak wiadomości.',
			'orders.chat.loadError' => 'Nie udało się pobrać czatu.',
			'orders.chat.sendError' => 'Nie udało się wysłać wiadomości.',
			'orders.emptyAvailable' => 'Brak zadań do wzięcia.',
			'orders.emptyMine' => 'Nie realizujesz żadnego zadania.',
			'account.logout' => 'Wyloguj',
			'account.language' => 'Język',
			'account.languagePolish' => 'Polski',
			'account.languageEnglish' => 'English',
			'account.theme' => 'Motyw',
			'account.themeSystem' => 'Systemowy',
			'account.themeLight' => 'Jasny',
			'account.themeDark' => 'Ciemny',
			'frpStock.title' => 'Stan FRP',
			'frpStock.loading' => 'Wczytywanie...',
			'frpStock.loadError' => 'Nie udało się pobrać stanu FRP.',
			'frpStock.retry' => 'Spróbuj ponownie',
			'frpStock.empty' => 'Brak pozycji.',
			'frpStock.searchPlaceholder' => 'Nazwa, item, bęben lub lokalizacja',
			'frpStock.fromThisOrder' => 'Z tego zamówienia',
			'frpStock.otherDrums' => 'Pozostałe',
			'frpStock.reserved' => 'Zarezerwowana',
			'shortLengths.title' => 'Krótkie odcinki',
			'shortLengths.button' => 'Zgłoś krótkie odcinki',
			'shortLengths.material' => 'Materiał',
			'shortLengths.quantity' => 'Ilość',
			'shortLengths.submit' => 'Zgłoś',
			'shortLengths.reported' => 'Zgłoszono',
			'shortLengths.submitError' => 'Nie udało się wysłać zgłoszenia.',
			'shortLengths.photo' => 'Zdjęcie',
			'shortLengths.photoTake' => 'Zrób zdjęcie',
			'shortLengths.photoPick' => 'Z galerii',
			'shortLengths.photoError' => 'Nie udało się wczytać zdjęcia.',
			'shortLengths.photoUploadError' => 'Zgłoszenie zapisane, ale zdjęcie się nie wysłało.',
			_ => null,
		};
	}
}
