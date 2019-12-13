func toArray(x) => x as? Array
func toBoolean(x) => x as? Boolean
func toClass(x) => x as? Class
func toDictionary(x) => x as? Dictionary
func toEnum(x) => x as? Enum
func toFunction(x) => x as? Function
func toNamespace(x) => x as? Namespace
func toNumber(x) => x as? Number
func toObject(x) => x as? Object
func toPrimitive(x) => x as? Primitive
func toRegExp(x) => x as? RegExp
func toString(x) => x as? String
func toStruct(x) => x as? Struct

class Foobar {
}

func toClassInstance(x) => x as? Foobar

enum Quxbaz {
}

func toEnumInstance(x) => x as? Quxbaz

struct Corge {
}

func toStructInstance(x) => x as? Corge