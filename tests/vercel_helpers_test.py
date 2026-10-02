"""Deployment URL capture checks using real subprocess output."""

import contextlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import unittest


SPEC = importlib.util.spec_from_file_location(
    "vercel_helpers", Path(__file__).parents[1] / "just" / "_vercel_helpers.py"
)
helpers = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(helpers)
URL = "https://example-deployment.vercel.app"


class DeploymentUrlTests(unittest.TestCase):
    def capture(self, output, returncode=0):
        return helpers.run_capture_url(
            sys.executable,
            "-c",
            f"import sys; sys.stdout.write({output!r}); sys.exit({returncode})",
        )

    def test_plain_url_and_json_result_preserve_streamed_output(self):
        for output in (
            URL + "\n",
            json.dumps({"status": "ok", "deployment": {"url": URL}}, indent=2) + "\n",
        ):
            with self.subTest(output=output), contextlib.redirect_stdout(io.StringIO()) as stdout:
                self.assertEqual(self.capture(output), URL)
                self.assertEqual(stdout.getvalue(), output)

    def test_invalid_success_output_does_not_become_a_published_url(self):
        for output in (
            "",
            "}",
            "{}",
            '{"deployment":null}',
            '{"deployment":{"url":17}}',
            '{"deployment":{"url":"https://"}}',
            '{"deployment":{"url":"https://example.vercel.app\\ninjected=value"}}',
            "http://example.vercel.app",
        ):
            with (
                self.subTest(output=output),
                contextlib.redirect_stdout(io.StringIO()),
                contextlib.redirect_stderr(io.StringIO()) as stderr,
            ):
                with self.assertRaises(SystemExit) as failure:
                    self.capture(output)
                self.assertEqual(failure.exception.code, 1)
                self.assertIn("no valid deployment URL", stderr.getvalue())

    def test_command_failure_keeps_its_exit_code(self):
        with contextlib.redirect_stdout(io.StringIO()), self.assertRaises(SystemExit) as failure:
            self.capture(URL, returncode=7)
        self.assertEqual(failure.exception.code, 7)


if __name__ == "__main__":
    unittest.main()
