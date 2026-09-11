import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

temporary_directory = tempfile.TemporaryDirectory()
directory = Path(temporary_directory.name)
source = Path(__file__).parents[1] / "config.toml"
target = directory / "config.toml"
target.write_text(
    'model = "old"\ncustom_setting = true\n\n[tui]\nnotifications = false\nalternate_screen = false\n\n[projects."/tmp/project"]\ntrust_level = "trusted"\n',
    encoding="utf-8",
)
command = [
    sys.executable,
    str(Path(__file__).parents[1] / "merge_config.py"),
    str(source),
    str(target),
]
subprocess.run(command, check=True)
first = target.read_text(encoding="utf-8")
config = tomllib.loads(first)
assert config["model"] == "gpt-5.6-sol"
assert config["custom_setting"] is True
assert config["tui"]["notifications"] is True
assert config["tui"]["alternate_screen"] is False
assert config["projects"]["/tmp/project"]["trust_level"] == "trusted"
subprocess.run(command, check=True)
assert target.read_text(encoding="utf-8") == first
target.write_text('model = """old\nmodel"""\n', encoding="utf-8")
result = subprocess.run(command, capture_output=True)
assert result.returncode != 0
assert target.read_text(encoding="utf-8") == 'model = """old\nmodel"""\n'
temporary_directory.cleanup()
