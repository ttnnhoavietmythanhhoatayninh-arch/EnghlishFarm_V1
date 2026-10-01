extends "res://tests/test_support.gd"

# Intentional failure: not part of the normal test_*.gd suite discovery.
func helper() -> void:
 if not expect_test(false, "Intentional helper failure proves nonzero exit"): return

func _initialize() -> void:
 helper()
 # Even if the caller forgets to return, failure must remain sticky.
 finish_test("INCORRECT_FALSE_PASSED")
