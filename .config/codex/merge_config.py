import os
import re
import sys
import tempfile

source_path = sys.argv[1]
target_path = sys.argv[2]
with open(source_path, encoding="utf-8") as source_handle:
    source_lines = source_handle.read().splitlines()
try:
    with open(target_path, encoding="utf-8") as target_handle:
        target_lines = target_handle.read().splitlines()
except FileNotFoundError:
    target_lines = []

source_root = []
source_tui = []
source_section = ""
for line in source_lines:
    match = re.match(r"^\s*\[([^]]+)]\s*$", line)
    if match:
        source_section = match.group(1)
        continue
    if source_section == "":
        source_root.append(line)
    elif source_section == "tui":
        source_tui.append(line)

root_keys = {
    match.group(1)
    for line in source_root
    if (match := re.match(r"^\s*([A-Za-z0-9_-]+)\s*=", line))
}
tui_keys = {
    match.group(1)
    for line in source_tui
    if (match := re.match(r"^\s*([A-Za-z0-9_-]+)\s*=", line))
}

filtered = []
target_section = ""
tui_found = False
for line in target_lines:
    section_match = re.match(r"^\s*\[([^]]+)]\s*$", line)
    if section_match:
        target_section = section_match.group(1)
        filtered.append(line)
        if target_section == "tui":
            tui_found = True
            filtered.extend(value for value in source_tui if value)
        continue
    assignment_match = re.match(r"^\s*([A-Za-z0-9_-]+)\s*=", line)
    if (
        assignment_match
        and target_section == ""
        and assignment_match.group(1) in root_keys
    ):
        continue
    if (
        assignment_match
        and target_section == "tui"
        and assignment_match.group(1) in tui_keys
    ):
        continue
    filtered.append(line)

while filtered and not filtered[0]:
    filtered.pop(0)
root_values = [line for line in source_root if line]
merged = root_values + ([""] if root_values else []) + filtered
if not tui_found:
    while merged and not merged[-1]:
        merged.pop()
    if merged:
        merged.append("")
    merged.append("[tui]")
    merged.extend(value for value in source_tui if value)
merged_text = "\n".join(merged).rstrip() + "\n"

try:
    with open(target_path, encoding="utf-8") as target_handle:
        current_text = target_handle.read()
except FileNotFoundError:
    current_text = ""
if merged_text != current_text:
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    descriptor, temporary_path = tempfile.mkstemp(dir=os.path.dirname(target_path))
    with os.fdopen(descriptor, "w", encoding="utf-8") as temporary_handle:
        temporary_handle.write(merged_text)
    os.replace(temporary_path, target_path)
