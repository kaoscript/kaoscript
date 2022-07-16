const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Message {
		static __ks_new_0(...args) {
			const o = Object.create(Message.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(messages) {
			this._messages = messages;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Message.prototype.__ks_cons_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	return {
		Message
	};
};