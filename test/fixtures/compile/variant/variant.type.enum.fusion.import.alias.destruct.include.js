const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isRange: value => Type.isDexObject(value, 1, 0, {start: __ksType.isPosition, end: __ksType.isPosition}),
		isSchoolPerson: (value, filter) => __ksType.isRange(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
			if(!Type.isEnumInstance(variant, PersonKind)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Student) {
				return Type.isDexObject(value, 0, 0, {name: Type.isString});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
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
		const t0 = __ksType.isRange;
		if(args.length === 1) {
			if(t0(args[0])) {
				return Director.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		PersonKind,
		Director,
		__ksType: [__ksType.isPosition, __ksType.isRange, __ksType.isSchoolPerson]
	};
};