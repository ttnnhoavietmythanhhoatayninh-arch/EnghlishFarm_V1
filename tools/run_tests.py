#!/usr/bin/env python3
"""Run Godot suites, rejecting runtime errors even when Godot exits zero."""
import argparse
import os
from pathlib import Path
import re
import selectors
import time
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ERROR = re.compile(r'SCRIPT ERROR:|(?:^|\n)\s*ERROR:|(?:^|\n)\s*FAIL:')
PASSED = re.compile(r'^[A-Z][A-Z0-9_]*PASSED\s*$', re.MULTILINE)


def run_engine(command, env, timeout):
    """Stream bounded chunks and stop at the first error, including partial lines."""
    output = bytearray()
    tail = ""
    passed = False
    reason = ""
    cap = 65536
    truncated = False
    try:
        process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, bufsize=0)
    except OSError as error:
        return str(error), "could not start Godot"
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    deadline = time.monotonic() + timeout
    try:
        while selector.get_map():
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                reason = f"timeout after {timeout:g}s"
                break
            for key, _ in selector.select(min(remaining, 0.1)):
                chunk = os.read(key.fd, 4096)
                if not chunk:
                    selector.unregister(key.fileobj)
                    continue
                room = cap - len(output)
                output.extend(chunk[:room])
                truncated = truncated or len(chunk) > room
                tail += chunk.decode(errors="replace")
                match = ERROR.search(tail)
                if match:
                    detail = tail[match.start():].strip().splitlines()[0][:250]
                    reason = "runtime error: " + detail
                    break
                # Accept only complete lines; partial markers may gain suffixes.
                complete, separator, unfinished = tail.rpartition("\n")
                if separator:
                    passed = passed or bool(PASSED.search(complete))
                    tail = unfinished
                tail = tail[-4096:]
            if reason:
                break
        if not reason:
            passed = passed or bool(PASSED.fullmatch(tail))
            try:
                code = process.wait(timeout=max(0.01, deadline - time.monotonic()))
                reason = f"exit {code}" if code else "" if passed else "missing PASSED marker"
            except subprocess.TimeoutExpired:
                reason = f"timeout after {timeout:g}s"
    finally:
        selector.close()
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        process.stdout.close()
    text = output.decode(errors="replace")
    if truncated:
        text += "\n[Log capped at 64 KiB]\n"
    return text, reason


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT', 'godot'))
    parser.add_argument('--timeout', type=float, default=60)
    parser.add_argument('--log-dir', type=Path, default=ROOT / 'build/test-logs')
    parser.add_argument('tests', nargs='*', help='Suite paths relative to project root')
    args = parser.parse_args()
    suites = [ROOT / name for name in args.tests] if args.tests else sorted((ROOT / 'tests').glob('test_*.gd'))
    suites = [p for p in suites if p.name != 'test_support.gd']
    if not suites:
        print('FAIL: No test suites found.', file=sys.stderr)
        return 1
    args.log_dir.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, GODOT_SILENCE_ROOT_WARNING='1')
    for suite in suites:
        print(f'RUN {suite.name}', flush=True)
        command = [args.godot, '--headless', '--path', str(ROOT), '--script', str(suite)]
        output, reason = run_engine(command, env, args.timeout)
        log_path = args.log_dir / (suite.stem + '.log')
        log_path.write_text(output, encoding='utf-8')
        if reason:
            lines = output.splitlines()
            print("\n".join(lines[:60]))
            if len(lines) > 60:
                print("[Console output limited to the first 60 lines]")
            print(f'FAIL: {suite.name}: {reason}\nLog: {log_path}', file=sys.stderr)
            return 1
        print(f'PASS {suite.name}', flush=True)
    print(f'ALL {len(suites)} SUITES PASSED')
    return 0


if __name__ == '__main__':
    sys.exit(main())
