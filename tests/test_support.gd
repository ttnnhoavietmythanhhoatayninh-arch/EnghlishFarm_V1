extends SceneTree

# Unlike assert(), this records failure across helper/coroutine boundaries.
var test_failed := false

func expect_test(condition: bool, reason: String = "Expectation failed") -> bool:
	if not condition:
		test_failed = true
		printerr("FAIL: " + reason)
		for frame in get_stack():
			printerr("  %s:%s in %s" % [frame.source, frame.line, frame.function])
		quit(1)
	return condition

func finish_test(marker: String = "TEST_SUITE_PASSED") -> void:
	if test_failed:
		quit(1)
		return
	print(marker)
	quit(0)
