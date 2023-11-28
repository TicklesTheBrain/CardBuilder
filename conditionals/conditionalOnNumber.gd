extends Conditional
class_name ConditionalOnNumber

@export var amountToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

enum type {TOTAL_VALUE, AMOUNT_OF_CARDS, AMOUNT_OF_TYPES, AMOUNT_OF_SINGLE_TYPE}