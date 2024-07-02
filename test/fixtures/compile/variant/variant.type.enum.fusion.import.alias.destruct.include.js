const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
		return true;
	}}));
	function Director() {
		return Director.__ks_rt(this, arguments);
	};
	Director.__ks_0 = function({start, end}) {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Director;
			o.start = start;
			o.end = end;
			return o;
		})();
	};
	Director.__ks_rt = function(that, args) {
		const t0 = Range.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return Director.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Position,
		Range,
		PersonKind,
		SchoolPerson,
		Director
	};
};