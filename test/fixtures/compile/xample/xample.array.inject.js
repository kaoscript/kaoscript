require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = require("../_/_array.ks")().__ks_Array;
	__ks_Array.__ks_func_injectAt_0 = function(index, ...args) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(index === void 0 || index === null) {
			throw new TypeError("'index' is not nullable");
		}
		else if(!Type.isNumber(index)) {
			throw new TypeError("'index' is not of type 'Number'");
		}
		if(index < 0) {
			do {
				index = this.length + index + 1;
			}
			while(index < 0)
		}
		if(args.length > 1) {
			if(index !== 0) {
				if(index >= this.length) {
					for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
						this.push.apply(this, [].concat(args[i]));
					}
				}
				else {
					for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
						this.splice.apply(this, [].concat([index, 0], args[i]));
						index += [].concat(args[i]).length;
					}
				}
			}
			else {
				for(let i = args.length - 1; i >= 0; --i) {
					this.unshift.apply(this, [].concat(args[i]));
				}
			}
		}
		else {
			if(index !== 0) {
				if(index >= this.length) {
					this.push.apply(this, [].concat(args[0]));
				}
				else {
					this.splice.apply(this, [].concat([index, 0], args[0]));
				}
			}
			else {
				this.unshift.apply(this, [].concat(args[0]));
			}
		}
		return this;
	};
	__ks_Array._im_injectAt = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_injectAt_0.apply(that, args);
	};
};