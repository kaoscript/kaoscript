const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(person) {
		quxbaz(AnimalFlags.CanFly, person.firstname);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(animal, name) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, AnimalFlags);
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};