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
}

// Path: nav
class Translations$nav$pl {
	Translations$nav$pl._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pl: 'Zamówienia'
	String get orders => 'Zamówienia';

	/// pl: 'Konto'
	String get account => 'Konto';

	/// pl: 'Zwiń nawigację'
	String get collapse => 'Zwiń nawigację';

	/// pl: 'Rozwiń nawigację'
	String get expand => 'Rozwiń nawigację';

	/// pl: 'Historia'
	String get history => 'Historia';
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

	/// pl: 'Brak aktywnych zamówień.'
	String get empty => 'Brak aktywnych zamówień.';

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

	/// pl: 'Oznaczenie wózka'
	String get deviceLabel => 'Oznaczenie wózka';

	/// pl: 'Widoczne w Historii logowania (wps) przy każdym logowaniu z tego urządzenia.'
	String get deviceLabelHint => 'Widoczne w Historii logowania (wps) przy każdym logowaniu z tego urządzenia.';

	/// pl: 'Zapisz'
	String get save => 'Zapisz';
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

	/// pl: 'Transport maszyny'
	String get machine_transport => 'Transport maszyny';
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

	/// pl: 'Rozpocznij realizację'
	String get take => 'Rozpocznij realizację';

	/// pl: 'Już realizujesz'
	String get taken => 'Już realizujesz';

	/// pl: 'Realizuje {who}'
	String takenBy({required Object who}) => 'Realizuje ${who}';

	/// pl: 'Zamawiający zgłosił problem'
	String get problemFromRequester => 'Zamawiający zgłosił problem';

	/// pl: 'Czeka na zamawiającego'
	String get problemWithRequester => 'Czeka na zamawiającego';
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

	/// pl: 'Rozpocznij realizację'
	String get take => 'Rozpocznij realizację';

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

	/// pl: 'Napisz, co blokuje transport - zamawiający to zobaczy i ma to rozwiązać.'
	String get reportProblemDescription => 'Napisz, co blokuje transport - zamawiający to zobaczy i ma to rozwiązać.';

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

	/// pl: 'Popraw to i oznacz, że gotowe - potem dostarcz ponownie.'
	String get problemResolveHint => 'Popraw to i oznacz, że gotowe - potem dostarcz ponownie.';

	/// pl: 'Nie udało się oznaczyć problemu jako rozwiązanego.'
	String get resolveError => 'Nie udało się oznaczyć problemu jako rozwiązanego.';

	/// pl: 'Czat'
	String get chat => 'Czat';

	/// pl: 'wkrótce'
	String get chatSoon => 'wkrótce';
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
}

/// The flat map containing all translations for locale <pl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.orders' => 'Zamówienia',
			'nav.account' => 'Konto',
			'nav.collapse' => 'Zwiń nawigację',
			'nav.expand' => 'Rozwiń nawigację',
			'nav.history' => 'Historia',
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
			'orders.empty' => 'Brak aktywnych zamówień.',
			'orders.loading' => 'Wczytywanie...',
			'orders.loadError' => 'Nie udało się pobrać listy zamówień.',
			'orders.retry' => 'Spróbuj ponownie',
			'orders.types.water_refill' => 'Dolewanie wody',
			'orders.types.material_order' => 'Zamówienie materiału',
			'orders.types.spool_order' => 'Zamówienie szpul',
			'orders.types.goods_transport' => 'Transport półproduktów',
			'orders.types.waste_removal' => 'Wywożenie odpadu',
			'orders.types.warehouse_return' => 'Zwrot na magazyn',
			'orders.types.machine_transport' => 'Transport maszyny',
			'orders.status.kNew' => 'Nowe',
			'orders.status.inProgress' => 'W realizacji',
			'orders.status.delivered' => 'Dostarczone',
			'orders.status.done' => 'Zrealizowane',
			'orders.status.cancelled' => 'Anulowane',
			'orders.status.problem' => 'Problem',
			'orders.card.employeeNo' => 'Zlecający',
			'orders.card.take' => 'Rozpocznij realizację',
			'orders.card.taken' => 'Już realizujesz',
			'orders.card.takenBy' => ({required Object who}) => 'Realizuje ${who}',
			'orders.card.problemFromRequester' => 'Zamawiający zgłosił problem',
			'orders.card.problemWithRequester' => 'Czeka na zamawiającego',
			'orders.detail.line' => 'Linia',
			'orders.detail.productionOrderNo' => 'Numer zamówienia',
			'orders.detail.employeeNo' => 'Zlecający',
			'orders.detail.fulfilledBy' => 'Zrealizował',
			'orders.detail.deliveredBy' => 'Dostarczył',
			'orders.detail.createdAt' => 'Utworzono',
			'orders.detail.itemsTitle' => 'Pozycje',
			'orders.detail.issued' => ({required Object value}) => 'Wydano: ${value}',
			'orders.detail.take' => 'Rozpocznij realizację',
			'orders.detail.deliver' => 'Dostarczone',
			'orders.detail.deliverError' => 'Nie udało się oznaczyć zamówienia jako dostarczone.',
			'orders.detail.awaitingAcceptance' => 'Oczekuje na potwierdzenie odbioru.',
			'orders.detail.reportProblem' => 'Zgłoś problem',
			'orders.detail.reportProblemTitle' => 'Zgłoszenie problemu',
			'orders.detail.reportProblemDescription' => 'Napisz, co blokuje transport - zamawiający to zobaczy i ma to rozwiązać.',
			'orders.detail.reportProblemPlaceholder' => 'Na czym polega problem?',
			'orders.detail.reportProblemSubmit' => 'Zgłoś',
			'orders.detail.reportProblemCancel' => 'Anuluj',
			'orders.detail.reportProblemError' => 'Nie udało się zgłosić problemu.',
			'orders.detail.problemWaiting' => 'Zgłoszono problem - czeka na zamawiającego',
			'orders.detail.problemResolvedBy' => ({required Object who}) => '${who} oznaczył problem jako rozwiązany',
			'orders.detail.problemFromRequester' => 'Zamawiający zgłosił problem',
			'orders.detail.problemResolve' => 'Problem rozwiązany',
			'orders.detail.problemResolveHint' => 'Popraw to i oznacz, że gotowe - potem dostarcz ponownie.',
			'orders.detail.resolveError' => 'Nie udało się oznaczyć problemu jako rozwiązanego.',
			'orders.detail.chat' => 'Czat',
			'orders.detail.chatSoon' => 'wkrótce',
			'orders.sectionInProgress' => 'W realizacji',
			'orders.sectionNew' => 'Nowe zamówienia',
			'orders.sectionDelivered' => 'Oczekują na potwierdzenie',
			'orders.history.empty' => 'Brak zrealizowanych zamówień.',
			'orders.history.loadError' => 'Nie udało się pobrać historii.',
			'orders.history.today' => 'Dziś',
			'orders.history.yesterday' => 'Wczoraj',
			'orders.sectionProblem' => 'Problem',
			'account.logout' => 'Wyloguj',
			'account.language' => 'Język',
			'account.languagePolish' => 'Polski',
			'account.languageEnglish' => 'English',
			'account.theme' => 'Motyw',
			'account.themeSystem' => 'Systemowy',
			'account.themeLight' => 'Jasny',
			'account.themeDark' => 'Ciemny',
			'account.deviceLabel' => 'Oznaczenie wózka',
			'account.deviceLabelHint' => 'Widoczne w Historii logowania (wps) przy każdym logowaniu z tego urządzenia.',
			'account.save' => 'Zapisz',
			_ => null,
		};
	}
}
