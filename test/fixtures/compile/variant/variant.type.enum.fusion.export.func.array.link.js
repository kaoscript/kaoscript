const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const Range = Helper.alias(value => Type.isDexObject(value, 1, 0, {start: Position.is, end: Position.is}));
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const SchoolPerson = Helper.alias((value, cast, filter) => Range.is(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
		if(cast) {
			if((variant = PersonKind(variant)) === null) {
				return false;
			}
			value["kind"] = variant;
		}
		else if(!Type.isEnumInstance(variant, PersonKind)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant === PersonKind.Student) {
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
		}
		if(variant === PersonKind.Teacher) {
			return Type.isDexObject(value, 0, 0, {favorite: value => SchoolPerson.is(value, cast, value => value === PersonKind.Student), cards: value => Type.isArray(value, value => Card.is(value, cast, CardSuit.__ks_eq_Reds))});
		}
		return true;
	}}));
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	const Card = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
		if(cast) {
			if((variant = CardSuit(variant)) === null) {
				return false;
			}
			value["suit"] = variant;
		}
		else if(!Type.isEnumInstance(variant, CardSuit)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		return true;
	}, rank: Type.isNumber}));
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(person) {
		if(person.kind === PersonKind.Student) {
			console.log(person.name);
		}
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = SchoolPerson.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		greeting
	};
};