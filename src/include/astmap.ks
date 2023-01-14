var $assignmentOperators = {
	`\(AssignmentOperatorKind::Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperatorKind::And)`				: AssignmentOperatorAnd
	`\(AssignmentOperatorKind::Division)`			: AssignmentOperatorDivision
	`\(AssignmentOperatorKind::Empty)`				: AssignmentOperatorEmpty
	`\(AssignmentOperatorKind::EmptyCoalescing)`	: AssignmentOperatorEmptyCoalescing
	`\(AssignmentOperatorKind::Equals)`				: AssignmentOperatorEquals
	`\(AssignmentOperatorKind::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperatorKind::LeftShift)`			: AssignmentOperatorLeftShift
	`\(AssignmentOperatorKind::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind::NonEmpty)`			: AssignmentOperatorNonEmpty
	`\(AssignmentOperatorKind::NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind::Or)`					: AssignmentOperatorOr
	`\(AssignmentOperatorKind::Quotient)`			: AssignmentOperatorQuotient
	`\(AssignmentOperatorKind::Return)`				: AssignmentOperatorReturn
	`\(AssignmentOperatorKind::RightShift)`			: AssignmentOperatorRightShift
	`\(AssignmentOperatorKind::Subtraction)`		: AssignmentOperatorSubtraction
	`\(AssignmentOperatorKind::Xor)`				: AssignmentOperatorXor
}

var $binaryOperators = {
	`\(BinaryOperatorKind::Addition)`			: BinaryOperatorAddition
	`\(BinaryOperatorKind::And)`				: BinaryOperatorAnd
	`\(BinaryOperatorKind::Division)`			: BinaryOperatorDivision
	`\(BinaryOperatorKind::EmptyCoalescing)`	: BinaryOperatorEmptyCoalescing
	`\(BinaryOperatorKind::Imply)`				: BinaryOperatorImply
	`\(BinaryOperatorKind::LeftShift)`			: BinaryOperatorLeftShift
	`\(BinaryOperatorKind::Match)`				: BinaryOperatorMatch
	`\(BinaryOperatorKind::Mismatch)`			: BinaryOperatorMismatch
	`\(BinaryOperatorKind::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: BinaryOperatorQuotient
	`\(BinaryOperatorKind::RightShift)`			: BinaryOperatorRightShift
	`\(BinaryOperatorKind::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperatorKind::TypeCasting)`		: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind::TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind::TypeInequality)`		: BinaryOperatorTypeInequality
	`\(BinaryOperatorKind::Xor)`				: BinaryOperatorXor
}

var $expressions = {
	`\(NodeKind::ArrayBinding)`					: ArrayBinding
	`\(NodeKind::ArrayComprehension)`			: func(data, parent, scope) {
		if data.loop.kind == NodeKind::ForFromStatement {
			return new ArrayComprehensionForFrom(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForInStatement {
			return new ArrayComprehensionForIn(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForOfStatement {
			return new ArrayComprehensionForOf(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForRangeStatement {
			return new ArrayComprehensionForRange(data, parent, scope)
		}
		else {
			throw new NotSupportedException(`Unexpected kind \(data.loop.kind)`, parent)
		}
	}
	`\(NodeKind::ArrayExpression)`				: ArrayExpression
	`\(NodeKind::ArrayRange)`					: ArrayRange
	`\(NodeKind::AwaitExpression)`				: AwaitExpression
	`\(NodeKind::CallExpression)`				: CallExpression
	`\(NodeKind::CallMacroExpression)`	 		: $callMacroExpression
	`\(NodeKind::ComparisonExpression)`			: ComparisonExpression
	`\(NodeKind::ConditionalExpression)`		: ConditionalExpression
	`\(NodeKind::CreateExpression)`				: CreateExpression
	`\(NodeKind::CurryExpression)`				: CurryExpression
	`\(NodeKind::EnumExpression)`				: EnumExpression
	`\(NodeKind::FunctionExpression)`			: AnonymousFunctionExpression
	`\(NodeKind::Identifier)`					: IdentifierLiteral
	`\(NodeKind::IfExpression)`					: IfExpression
	`\(NodeKind::LambdaExpression)`				: ArrowFunctionExpression
	`\(NodeKind::Literal)`						: StringLiteral
	`\(NodeKind::MemberExpression)`				: MemberExpression
	`\(NodeKind::NamedArgument)`				: NamedArgument
	`\(NodeKind::NumericExpression)`			: NumberLiteral
	`\(NodeKind::ObjectBinding)`				: ObjectBinding
	`\(NodeKind::ObjectExpression)`				: ObjectExpression
	`\(NodeKind::OmittedExpression)`			: OmittedExpression
	`\(NodeKind::PositionalArgument)`			: PositionalArgument
	`\(NodeKind::RegularExpression)`			: RegularExpression
	`\(NodeKind::SequenceExpression)`			: SequenceExpression
	`\(NodeKind::TemplateExpression)`			: TemplateExpression
	`\(NodeKind::ThisExpression)`				: ThisExpression
	`\(NodeKind::TryExpression)`				: TryExpression
	`\(NodeKind::UnlessExpression)`				: UnlessExpression
}

var $statements = {
	`\(NodeKind::BitmaskDeclaration)`			: BitmaskDeclaration
	`\(NodeKind::BreakStatement)`				: BreakStatement
	`\(NodeKind::CallMacroExpression)`	 		: CallMacroStatement
	`\(NodeKind::ClassDeclaration)`				: ClassDeclaration
	`\(NodeKind::ContinueStatement)`			: ContinueStatement
	`\(NodeKind::DestroyStatement)`				: DestroyStatement
	`\(NodeKind::DiscloseDeclaration)`			: DiscloseDeclaration
	`\(NodeKind::DoUntilStatement)`				: DoUntilStatement
	`\(NodeKind::DoWhileStatement)`				: DoWhileStatement
	`\(NodeKind::EnumDeclaration)`				: EnumDeclaration
	`\(NodeKind::ExportDeclaration)`			: ExportDeclaration
	`\(NodeKind::ExternDeclaration)`			: ExternDeclaration
	`\(NodeKind::ExternOrImportDeclaration)`	: ExternOrImportDeclaration
	`\(NodeKind::ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(NodeKind::FallthroughStatement)`			: FallthroughStatement
	`\(NodeKind::ForFromStatement)`				: ForFromStatement
	`\(NodeKind::ForInStatement)`				: ForInStatement
	`\(NodeKind::ForOfStatement)`				: ForOfStatement
	`\(NodeKind::ForRangeStatement)`			: ForRangeStatement
	`\(NodeKind::FunctionDeclaration)`			: FunctionDeclaration
	`\(NodeKind::IfStatement)`					: IfStatement
	`\(NodeKind::ImplementDeclaration)`			: ImplementDeclaration
	`\(NodeKind::ImportDeclaration)`			: ImportDeclaration
	`\(NodeKind::IncludeDeclaration)`			: IncludeDeclaration
	`\(NodeKind::IncludeAgainDeclaration)`		: IncludeAgainDeclaration
	`\(NodeKind::MacroDeclaration)`				: MacroDeclaration
	`\(NodeKind::NamespaceDeclaration)`			: NamespaceDeclaration
	`\(NodeKind::PassStatement)`				: PassStatement
	`\(NodeKind::RepeatStatement)`				: RepeatStatement
	`\(NodeKind::RequireDeclaration)`			: RequireDeclaration
	`\(NodeKind::RequireOrExternDeclaration)`	: RequireOrExternDeclaration
	`\(NodeKind::RequireOrImportDeclaration)`	: RequireOrImportDeclaration
	`\(NodeKind::ReturnStatement)`				: ReturnStatement
	`\(NodeKind::StructDeclaration)`			: StructDeclaration
	`\(NodeKind::MatchStatement)`				: MatchStatement
	`\(NodeKind::ThrowStatement)`				: ThrowStatement
	`\(NodeKind::TryStatement)`					: TryStatement
	`\(NodeKind::TupleDeclaration)`				: TupleDeclaration
	`\(NodeKind::TypeAliasDeclaration)`			: TypeAliasDeclaration
	`\(NodeKind::UnlessStatement)`				: UnlessStatement
	`\(NodeKind::UntilStatement)`				: UntilStatement
	`\(NodeKind::VariableStatement)`			: VariableStatement
	`\(NodeKind::WhileStatement)`				: WhileStatement
	`\(NodeKind::WithStatement)`				: WithStatement
	`default`									: ExpressionStatement
}

var $polyadicOperators = {
	`\(BinaryOperatorKind::Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperatorKind::And)`				: PolyadicOperatorAnd
	`\(BinaryOperatorKind::Division)`			: PolyadicOperatorDivision
	`\(BinaryOperatorKind::EmptyCoalescing)`	: PolyadicOperatorEmptyCoalescing
	`\(BinaryOperatorKind::Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind::Imply)`				: PolyadicOperatorImply
	`\(BinaryOperatorKind::LeftShift)`			: PolyadicOperatorLeftShift
	`\(BinaryOperatorKind::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: PolyadicOperatorQuotient
	`\(BinaryOperatorKind::RightShift)`			: PolyadicOperatorRightShift
	`\(BinaryOperatorKind::Subtraction)`		: PolyadicOperatorSubtraction
	`\(BinaryOperatorKind::Xor)`				: PolyadicOperatorXor
}

var $unaryOperators = {
	`\(UnaryOperatorKind::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind::ForcedTypeCasting)`	: UnaryOperatorForcedTypeCasting
	`\(UnaryOperatorKind::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperatorKind::Negative)`			: UnaryOperatorNegative
	`\(UnaryOperatorKind::NonEmpty)`			: UnaryOperatorNonEmpty
	`\(UnaryOperatorKind::NullableTypeCasting)`	: UnaryOperatorNullableTypeCasting
	`\(UnaryOperatorKind::Spread)`				: UnaryOperatorSpread
}
