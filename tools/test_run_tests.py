#!/usr/bin/env python3
"""Self-tests for the test runner; does not launch or modify the game."""
import os
import sys
import time
import unittest

from run_tests import run_engine


class RunnerTests(unittest.TestCase):
    def engine(self, source, timeout=3):
        return run_engine([sys.executable, '-u', '-c', source], os.environ.copy(), timeout)

    def test_runtime_error_stops_repeating_process_immediately(self):
        start = time.monotonic()
        output, reason = self.engine(
            'import time\nprint("FAKE_PASSED")\n'
            'while True:\n print("SCRIPT ERROR: deliberate fixture error", flush=True)\n time.sleep(0.01)',
            timeout=30)
        self.assertIn('runtime error', reason)
        self.assertIn('deliberate fixture error', output)
        self.assertLess(time.monotonic() - start, 3)
        self.assertLess(len(output), 65536)

    def test_partial_line_error_is_detected(self):
        output, reason = self.engine('import sys,time; sys.stdout.write("ERROR: partial"); sys.stdout.flush(); time.sleep(30)')
        self.assertIn('runtime error', reason)

    def test_timeout(self):
        _, reason = self.engine('import time; time.sleep(30)', timeout=0.2)
        self.assertIn('timeout', reason)

    def test_nonzero(self):
        _, reason = self.engine('print("FAKE_PASSED"); raise SystemExit(4)')
        self.assertEqual(reason, 'exit 4')

    def test_missing_marker(self):
        _, reason = self.engine('print("done")')
        self.assertEqual(reason, 'missing PASSED marker')

    def test_success(self):
        _, reason = self.engine('print("FAKE_PASSED")')
        self.assertEqual(reason, '')

    def test_large_output_is_bounded(self):
        output, reason = self.engine('print("x"*100000); print("FAKE_PASSED")')
        self.assertEqual(reason, '')
        self.assertLess(len(output), 65600)
        self.assertIn('Log capped', output)


if __name__ == '__main__':
    unittest.main(verbosity=2)
