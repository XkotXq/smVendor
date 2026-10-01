///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$nav$en nav = _Translations$nav$en._(_root);
	@override late final _Translations$login$en login = _Translations$login$en._(_root);
	@override late final _Translations$orders$en orders = _Translations$orders$en._(_root);
	@override late final _Translations$account$en account = _Translations$account$en._(_root);
}

// Path: nav
class _Translations$nav$en implements Translations$nav$pl {
	_Translations$nav$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get orders => 'Orders';
	@override String get account => 'Account';
	@override String get collapse => 'Collapse navigation';
	@override String get expand => 'Expand navigation';
	@override String get history => 'History';
}

// Path: login
class _Translations$login$en implements Translations$login$pl {
	_Translations$login$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Log in';
	@override String get subtitle => 'smVendor - login panel';
	@override String get usernameLabel => 'Username';
	@override String get passwordLabel => 'Password';
	@override String get submit => 'Log in';
	@override String get submitting => 'Logging in...';
	@override String get missingFields => 'Enter your username and password.';
	@override late final _Translations$login$errors$en errors = _Translations$login$errors$en._(_root);
}

// Path: orders
class _Translations$orders$en implements Translations$orders$pl {
	_Translations$orders$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Orders';
	@override String get empty => 'No active orders.';
	@override String get loading => 'Loading...';
	@override String get loadError => 'Failed to load the order list.';
	@override String get retry => 'Try again';
	@override late final _Translations$orders$types$en types = _Translations$orders$types$en._(_root);
	@override late final _Translations$orders$status$en status = _Translations$orders$status$en._(_root);
	@override late final _Translations$orders$card$en card = _Translations$orders$card$en._(_root);
	@override late final _Translations$orders$detail$en detail = _Translations$orders$detail$en._(_root);
	@override String get sectionInProgress => 'In progress';
	@override String get sectionNew => 'New orders';
	@override String get sectionDelivered => 'Awaiting confirmation';
	@override late final _Translations$orders$history$en history = _Translations$orders$history$en._(_root);
	@override String get sectionProblem => 'Problem';
}

// Path: account
class _Translations$account$en implements Translations$account$pl {
	_Translations$account$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Log out';
	@override String get language => 'Language';
	@override String get languagePolish => 'Polski';
	@override String get languageEnglish => 'English';
	@override String get theme => 'Theme';
	@override String get themeSystem => 'System';
	@override String get themeLight => 'Light';
	@override String get themeDark => 'Dark';
	@override String get deviceLabel => 'Forklift label';
	@override String get deviceLabelHint => 'Shown in wps\'s Login history for every login from this device.';
	@override String get save => 'Save';
}

// Path: login.errors
class _Translations$login$errors$en implements Translations$login$errors$pl {
	_Translations$login$errors$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get invalidCredentials => 'Invalid username or password.';
	@override String get cipUnreachable => 'Failed to connect to CIP.';
	@override String get tooManyAttempts => 'Too many login attempts - try again in a moment.';
	@override String get serverUnreachable => 'Failed to connect to the server.';
}

// Path: orders.types
class _Translations$orders$types$en implements Translations$orders$types$pl {
	_Translations$orders$types$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get water_refill => 'Water refill';
	@override String get material_order => 'Material order';
	@override String get spool_order => 'Spool order';
	@override String get goods_transport => 'Semi-finished goods transport';
	@override String get waste_removal => 'Waste removal';
	@override String get warehouse_return => 'Return to warehouse';
	@override String get machine_transport => 'Machine transport';
}

// Path: orders.status
class _Translations$orders$status$en implements Translations$orders$status$pl {
	_Translations$orders$status$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kNew => 'New';
	@override String get inProgress => 'In progress';
	@override String get delivered => 'Delivered';
	@override String get done => 'Completed';
	@override String get cancelled => 'Cancelled';
	@override String get problem => 'Problem';
}

// Path: orders.card
class _Translations$orders$card$en implements Translations$orders$card$pl {
	_Translations$orders$card$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get employeeNo => 'Requested by';
	@override String get take => 'Start fulfilling';
	@override String get taken => 'Already yours';
	@override String takenBy({required Object who}) => 'Taken by ${who}';
	@override String get problemFromRequester => 'The requester reported a problem';
	@override String get problemWithRequester => 'Waiting for the requester';
}

// Path: orders.detail
class _Translations$orders$detail$en implements Translations$orders$detail$pl {
	_Translations$orders$detail$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get line => 'Line';
	@override String get productionOrderNo => 'Order number';
	@override String get employeeNo => 'Requested by';
	@override String get fulfilledBy => 'Fulfilled by';
	@override String get deliveredBy => 'Delivered by';
	@override String get createdAt => 'Created at';
	@override String get itemsTitle => 'Items';
	@override String issued({required Object value}) => 'Issued: ${value}';
	@override String get take => 'Start fulfilling';
	@override String get deliver => 'Delivered';
	@override String get deliverError => 'Failed to mark the order as delivered.';
	@override String get awaitingAcceptance => 'Awaiting delivery confirmation.';
	@override String get reportProblem => 'Report a problem';
	@override String get reportProblemTitle => 'Report a problem';
	@override String get reportProblemDescription => 'Describe what is blocking the transport - the requester sees this and is asked to fix it.';
	@override String get reportProblemPlaceholder => 'What is the problem?';
	@override String get reportProblemSubmit => 'Report';
	@override String get reportProblemCancel => 'Cancel';
	@override String get reportProblemError => 'Failed to report the problem.';
	@override String get problemWaiting => 'Problem reported - waiting on the requester';
	@override String problemResolvedBy({required Object who}) => '${who} marked the problem resolved';
	@override String get problemFromRequester => 'The requester reported a problem';
	@override String get problemResolve => 'Problem solved';
	@override String get problemResolveHint => 'Put it right, mark it done, then deliver again.';
	@override String get resolveError => 'Could not mark the problem as solved.';
	@override String get chat => 'Chat';
	@override String get chatSoon => 'soon';
}

// Path: orders.history
class _Translations$orders$history$en implements Translations$orders$history$pl {
	_Translations$orders$history$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No finished orders yet.';
	@override String get loadError => 'Failed to load the history.';
	@override String get today => 'Today';
	@override String get yesterday => 'Yesterday';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.orders' => 'Orders',
			'nav.account' => 'Account',
			'nav.collapse' => 'Collapse navigation',
			'nav.expand' => 'Expand navigation',
			'nav.history' => 'History',
			'login.title' => 'Log in',
			'login.subtitle' => 'smVendor - login panel',
			'login.usernameLabel' => 'Username',
			'login.passwordLabel' => 'Password',
			'login.submit' => 'Log in',
			'login.submitting' => 'Logging in...',
			'login.missingFields' => 'Enter your username and password.',
			'login.errors.invalidCredentials' => 'Invalid username or password.',
			'login.errors.cipUnreachable' => 'Failed to connect to CIP.',
			'login.errors.tooManyAttempts' => 'Too many login attempts - try again in a moment.',
			'login.errors.serverUnreachable' => 'Failed to connect to the server.',
			'orders.title' => 'Orders',
			'orders.empty' => 'No active orders.',
			'orders.loading' => 'Loading...',
			'orders.loadError' => 'Failed to load the order list.',
			'orders.retry' => 'Try again',
			'orders.types.water_refill' => 'Water refill',
			'orders.types.material_order' => 'Material order',
			'orders.types.spool_order' => 'Spool order',
			'orders.types.goods_transport' => 'Semi-finished goods transport',
			'orders.types.waste_removal' => 'Waste removal',
			'orders.types.warehouse_return' => 'Return to warehouse',
			'orders.types.machine_transport' => 'Machine transport',
			'orders.status.kNew' => 'New',
			'orders.status.inProgress' => 'In progress',
			'orders.status.delivered' => 'Delivered',
			'orders.status.done' => 'Completed',
			'orders.status.cancelled' => 'Cancelled',
			'orders.status.problem' => 'Problem',
			'orders.card.employeeNo' => 'Requested by',
			'orders.card.take' => 'Start fulfilling',
			'orders.card.taken' => 'Already yours',
			'orders.card.takenBy' => ({required Object who}) => 'Taken by ${who}',
			'orders.card.problemFromRequester' => 'The requester reported a problem',
			'orders.card.problemWithRequester' => 'Waiting for the requester',
			'orders.detail.line' => 'Line',
			'orders.detail.productionOrderNo' => 'Order number',
			'orders.detail.employeeNo' => 'Requested by',
			'orders.detail.fulfilledBy' => 'Fulfilled by',
			'orders.detail.deliveredBy' => 'Delivered by',
			'orders.detail.createdAt' => 'Created at',
			'orders.detail.itemsTitle' => 'Items',
			'orders.detail.issued' => ({required Object value}) => 'Issued: ${value}',
			'orders.detail.take' => 'Start fulfilling',
			'orders.detail.deliver' => 'Delivered',
			'orders.detail.deliverError' => 'Failed to mark the order as delivered.',
			'orders.detail.awaitingAcceptance' => 'Awaiting delivery confirmation.',
			'orders.detail.reportProblem' => 'Report a problem',
			'orders.detail.reportProblemTitle' => 'Report a problem',
			'orders.detail.reportProblemDescription' => 'Describe what is blocking the transport - the requester sees this and is asked to fix it.',
			'orders.detail.reportProblemPlaceholder' => 'What is the problem?',
			'orders.detail.reportProblemSubmit' => 'Report',
			'orders.detail.reportProblemCancel' => 'Cancel',
			'orders.detail.reportProblemError' => 'Failed to report the problem.',
			'orders.detail.problemWaiting' => 'Problem reported - waiting on the requester',
			'orders.detail.problemResolvedBy' => ({required Object who}) => '${who} marked the problem resolved',
			'orders.detail.problemFromRequester' => 'The requester reported a problem',
			'orders.detail.problemResolve' => 'Problem solved',
			'orders.detail.problemResolveHint' => 'Put it right, mark it done, then deliver again.',
			'orders.detail.resolveError' => 'Could not mark the problem as solved.',
			'orders.detail.chat' => 'Chat',
			'orders.detail.chatSoon' => 'soon',
			'orders.sectionInProgress' => 'In progress',
			'orders.sectionNew' => 'New orders',
			'orders.sectionDelivered' => 'Awaiting confirmation',
			'orders.history.empty' => 'No finished orders yet.',
			'orders.history.loadError' => 'Failed to load the history.',
			'orders.history.today' => 'Today',
			'orders.history.yesterday' => 'Yesterday',
			'orders.sectionProblem' => 'Problem',
			'account.logout' => 'Log out',
			'account.language' => 'Language',
			'account.languagePolish' => 'Polski',
			'account.languageEnglish' => 'English',
			'account.theme' => 'Theme',
			'account.themeSystem' => 'System',
			'account.themeLight' => 'Light',
			'account.themeDark' => 'Dark',
			'account.deviceLabel' => 'Forklift label',
			'account.deviceLabelHint' => 'Shown in wps\'s Login history for every login from this device.',
			'account.save' => 'Save',
			_ => null,
		};
	}
}
