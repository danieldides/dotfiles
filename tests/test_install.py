import contextlib
import io
import subprocess
import unittest
from unittest.mock import patch

import install


class HerdrLayoutTests(unittest.TestCase):
    def test_applies_persistent_layout(self):
        with (
            patch("install.shutil.which", return_value="/usr/local/bin/herdr-app"),
            patch("install.subprocess.run") as run,
            contextlib.redirect_stdout(io.StringIO()),
        ):
            run.return_value = subprocess.CompletedProcess([], 0, "", "")
            install.apply_herdr_layout()
        run.assert_called_once_with(
            ["herdr-app", "do", "layout.switch", "--name", "main"],
            capture_output=True,
            text=True,
        )

    def test_missing_app_gives_manual_command(self):
        with (
            patch("install.shutil.which", return_value=None),
            patch("install.subprocess.run") as run,
            contextlib.redirect_stdout(io.StringIO()) as output,
        ):
            install.apply_herdr_layout()
        run.assert_not_called()
        self.assertIn("herdr-app do layout.switch --name main", output.getvalue())

    def test_closed_app_does_not_abort_installation(self):
        with (
            patch("install.shutil.which", return_value="/usr/local/bin/herdr-app"),
            patch("install.subprocess.run") as run,
            contextlib.redirect_stdout(io.StringIO()) as output,
        ):
            run.return_value = subprocess.CompletedProcess([], 1, "", "Not running")
            install.apply_herdr_layout()
        self.assertIn("Not running", output.getvalue())
        self.assertIn("herdr-app do layout.switch --name main", output.getvalue())


if __name__ == "__main__":
    unittest.main()
