const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const ANSIColor = Helper.enum(Number, 0, "black", 0, "red", 1, "green", 2, "yellow", 3, "blue", 4, "magenta", 5, "cyan", 6, "white", 7, "default", 8);
	function color() {
		return color.__ks_rt(this, arguments);
	};
	color.__ks_0 = function(fg, bg) {
		let fgCode;
		if(fg === ANSIColor.black) {
			fgCode = 30;
		}
		else if(fg === ANSIColor.red) {
			fgCode = 31;
		}
		else if(fg === ANSIColor.green) {
			fgCode = 32;
		}
		else if(fg === ANSIColor.yellow) {
			fgCode = 33;
		}
		else if(fg === ANSIColor.blue) {
			fgCode = 34;
		}
		else if(fg === ANSIColor.magenta) {
			fgCode = 35;
		}
		else if(fg === ANSIColor.cyan) {
			fgCode = 36;
		}
		else if(fg === ANSIColor.white) {
			fgCode = 37;
		}
		else {
			fgCode = 39;
		}
		let bgCode;
		if(bg === ANSIColor.black) {
			bgCode = 40;
		}
		else if(bg === ANSIColor.red) {
			bgCode = 41;
		}
		else if(bg === ANSIColor.green) {
			bgCode = 42;
		}
		else if(bg === ANSIColor.yellow) {
			bgCode = 44;
		}
		else if(bg === ANSIColor.blue) {
			bgCode = 44;
		}
		else if(bg === ANSIColor.magenta) {
			bgCode = 45;
		}
		else if(bg === ANSIColor.cyan) {
			bgCode = 46;
		}
		else if(bg === ANSIColor.white) {
			bgCode = 47;
		}
		else {
			bgCode = 49;
		}
		return Helper.concatString(fgCode, ";", bgCode, "m");
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