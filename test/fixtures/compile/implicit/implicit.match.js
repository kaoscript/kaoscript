const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const ANSIColor = Helper.enum(Number, {
		BLACK: 0,
		RED: 1,
		GREEN: 2,
		YELLOW: 3,
		BLUE: 4,
		MAGENTA: 5,
		CYAN: 6,
		WHITE: 7,
		DEFAULT: 8
	});
	function color() {
		return color.__ks_rt(this, arguments);
	};
	color.__ks_0 = function(fg, bg) {
		let fgCode;
		if(fg === ANSIColor.BLACK) {
			fgCode = 30;
		}
		else if(fg === ANSIColor.RED) {
			fgCode = 31;
		}
		else if(fg === ANSIColor.GREEN) {
			fgCode = 32;
		}
		else if(fg === ANSIColor.YELLOW) {
			fgCode = 33;
		}
		else if(fg === ANSIColor.BLUE) {
			fgCode = 34;
		}
		else if(fg === ANSIColor.MAGENTA) {
			fgCode = 35;
		}
		else if(fg === ANSIColor.CYAN) {
			fgCode = 36;
		}
		else if(fg === ANSIColor.WHITE) {
			fgCode = 37;
		}
		else {
			fgCode = 39;
		}
		return Helper.concatString(fgCode, ";m");
	};
	color.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, ANSIColor);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return color.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};