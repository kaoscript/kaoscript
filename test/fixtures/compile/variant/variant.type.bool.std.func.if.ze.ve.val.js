const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
		if(!Type.isBoolean(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant) {
			return Type.isDexObject(value, 0, 0, {value: Type.isString});
		}
		else {
			return Type.isDexObject(value, 0, 0, {expecting: Type.isString});
		}
	}}));
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(event) {
		if(event.ok) {
			console.log(event.value);
		}
		else {
			console.log(event.expecting);
		}
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = Event.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};