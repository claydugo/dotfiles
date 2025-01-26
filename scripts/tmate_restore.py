#!/usr/bin/env python3
"""
Add to ~/.ssh/config

```
Host *.tmate.io
    PermitLocalCommand yes
    LocalCommand echo "[`date '+%%Y-%%m-%%d %%H:%%M'`]: %r@%h" >> ~/.cache/tmate_logs.log
```
"""
import argparse
import curses
import hashlib
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional, Tuple

DEFAULT_LOG_FILE_PATH = os.path.expanduser("~/.cache/tmate_logs.log")
LOG_PATTERN = re.compile(r"\[\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\s*\]:\s*(\S+@\S+)")
DATETIME_FORMAT = "%Y-%m-%d %H:%M"
CONNECTION_TIMEOUT = 10
MAX_RETRIES = 3
RETRY_DELAY = 2


@dataclass
class TmateEntry:
    __slots__ = ["timestamp", "connection"]
    timestamp: datetime
    connection: str

    def __str__(self) -> str:
        return f"[{self.timestamp.strftime(DATETIME_FORMAT)}]: {self.connection}"


class TmateManager:
    def __init__(self, log_file: str, max_age: int, sort_by: str = "time"):
        self.log_file = log_file
        self.max_age = max_age
        self.sort_by = sort_by
        self.entries: List[TmateEntry] = []
        self._cache = {}
        self._load_entries()

    def _compute_hash(self) -> str:
        hasher = hashlib.md5()
        try:
            with open(self.log_file, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hasher.update(chunk)
            return hasher.hexdigest()
        except (IOError, OSError):
            return ""

    def _load_entries(self) -> None:
        if not os.path.exists(self.log_file):
            return

        file_hash = self._compute_hash()
        if file_hash in self._cache:
            self.entries = self._cache[file_hash]
            return

        connection_dict = {}
        cutoff_time = datetime.now() - timedelta(days=self.max_age)

        try:
            with open(self.log_file, "r") as f:
                for line in f:
                    match = LOG_PATTERN.search(line)
                    if match:
                        try:
                            timestamp = datetime.strptime(
                                match.group(1).strip(), DATETIME_FORMAT
                            )
                            if timestamp >= cutoff_time:
                                connection = match.group(2).strip()
                                existing_ts = connection_dict.get(connection)
                                if not existing_ts or timestamp > existing_ts:
                                    connection_dict[connection] = timestamp
                        except ValueError:
                            pass
        except (IOError, OSError) as e:
            raise RuntimeError(f"Failed to read log file '{self.log_file}': {e}")

        self.entries = [TmateEntry(ts, conn) for conn, ts in connection_dict.items()]
        self._sort_entries()
        self._cache[file_hash] = self.entries

    def _sort_entries(self) -> None:
        if self.sort_by == "host":
            self.entries.sort(key=lambda x: x.connection.lower())
        else:
            self.entries.sort(key=lambda x: x.timestamp, reverse=True)

    def sort_entries(self) -> None:
        self._sort_entries()
        file_hash = self._compute_hash()
        self._cache[file_hash] = self.entries


class TmateUI:
    def __init__(self, stdscr: "curses.window", manager: TmateManager):
        self.stdscr = stdscr
        self.manager = manager
        self.selected_idx = 0
        self.search_query = ""
        self._setup_curses()
        self._init_mouse()

    def _setup_curses(self) -> None:
        curses.curs_set(0)
        curses.use_default_colors()
        curses.start_color()
        self._init_colors()
        curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)

    def _init_mouse(self) -> None:
        print("\033[?1003h")

    def _cleanup_mouse(self) -> None:
        print("\033[?1003l")

    def _init_colors(self) -> None:
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)
        curses.init_pair(2, curses.COLOR_YELLOW, -1)
        curses.init_pair(3, curses.COLOR_GREEN, -1)
        curses.init_pair(4, curses.COLOR_RED, -1)

    def _get_visible_range(self) -> Tuple[int, int]:
        height, _ = self.stdscr.getmaxyx()
        display_height = height - 6

        if len(self.manager.entries) <= display_height:
            return 0, len(self.manager.entries)

        if self.selected_idx < display_height // 2:
            start_idx = 0
        elif self.selected_idx >= len(self.manager.entries) - display_height // 2:
            start_idx = len(self.manager.entries) - display_height
        else:
            start_idx = self.selected_idx - display_height // 2

        return start_idx, start_idx + display_height

    def _get_footer_text(self, width: int) -> str:
        if width >= 100:
            return "UP/DOWN/j/k to navigate | HOME/END | PG UP/DOWN to scroll | '/' search | 's' sort | ENTER select | 'q' quit"
        elif width >= 70:
            return "↑↓/j/k nav | HOME/END | PG UP/DN | / search | s sort | ENTER/q"
        else:
            return "↑↓ nav | / search | s sort"

    def _handle_mouse(self, event: int) -> None:
        _, mx, my, _, bstate = curses.getmouse()
        start_idx, _ = self._get_visible_range()

        if bstate & curses.BUTTON1_CLICKED:
            entry_idx = my - 3 + start_idx
            if 0 <= entry_idx < len(self.manager.entries):
                self.selected_idx = entry_idx
                if bstate & curses.BUTTON1_DOUBLE_CLICKED:
                    return self._handle_connection(
                        self.manager.entries[self.selected_idx]
                    )

    def _handle_connection(self, entry: TmateEntry) -> Optional[str]:
        return entry.connection

    def draw(self, error_message: Optional[str] = None) -> None:
        self.stdscr.clear()
        height, width = self.stdscr.getmaxyx()

        title = " Select a tmate Session to Connect "
        self.stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
        self.stdscr.addstr(1, max((width - len(title)) // 2, 0), title)
        self.stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)

        start_idx, end_idx = self._get_visible_range()
        for idx, entry in enumerate(
            self.manager.entries[start_idx:end_idx], start=start_idx
        ):
            y = 3 + idx - start_idx
            x = 2
            entry_str = f"{idx + 1}. {str(entry)}"[: width - 6]
            if idx == self.selected_idx:
                self.stdscr.attron(curses.color_pair(1))
                self.stdscr.addstr(y, x, entry_str.ljust(width - 4))
                self.stdscr.attroff(curses.color_pair(1))
            else:
                self.stdscr.addstr(y, x, entry_str.ljust(width - 4))

        instructions = self._get_footer_text(width)
        total_sessions = f"Total: {len(self.manager.entries)}"

        footer_space = width - 4
        if len(instructions) + len(total_sessions) + 2 <= footer_space:
            try:
                self.stdscr.attron(curses.color_pair(3))
                self.stdscr.addstr(height - 2, 2, instructions)
                self.stdscr.addstr(
                    height - 2, width - len(total_sessions) - 2, total_sessions
                )
                self.stdscr.attroff(curses.color_pair(3))
            except curses.error:
                pass
        else:
            try:
                self.stdscr.attron(curses.color_pair(3))
                self.stdscr.addstr(height - 2, 2, instructions[:footer_space])
                self.stdscr.attroff(curses.color_pair(3))
            except curses.error:
                pass

        if error_message:
            try:
                self.stdscr.attron(curses.color_pair(4) | curses.A_BOLD)
                self.stdscr.addstr(
                    height // 2,
                    max((width - len(error_message)) // 2, 0),
                    error_message,
                )
                self.stdscr.attroff(curses.color_pair(4) | curses.A_BOLD)
            except curses.error:
                pass

        self.stdscr.refresh()

    def run(self) -> Optional[str]:
        if not self.manager.entries:
            self._show_error("No tmate sessions found matching the criteria.")
            self.stdscr.getch()
            return None

        while True:
            self.draw()
            try:
                key = self.stdscr.getch()
                if key in (ord("k"), ord("K")):
                    self.selected_idx = (self.selected_idx - 1) % len(
                        self.manager.entries
                    )
                elif key in (ord("j"), ord("J")):
                    self.selected_idx = (self.selected_idx + 1) % len(
                        self.manager.entries
                    )
                elif key == curses.KEY_MOUSE:
                    self._handle_mouse(key)
                elif key == curses.KEY_RESIZE:
                    curses.resize_term(*self.stdscr.getmaxyx())
                elif key == curses.KEY_UP:
                    self.selected_idx = (self.selected_idx - 1) % len(
                        self.manager.entries
                    )
                elif key == curses.KEY_DOWN:
                    self.selected_idx = (self.selected_idx + 1) % len(
                        self.manager.entries
                    )
                elif key == curses.KEY_HOME:
                    self.selected_idx = 0
                elif key == curses.KEY_END:
                    self.selected_idx = len(self.manager.entries) - 1
                elif key == curses.KEY_PPAGE:
                    self.selected_idx = max(self.selected_idx - 10, 0)
                elif key == curses.KEY_NPAGE:
                    self.selected_idx = min(
                        self.selected_idx + 10, len(self.manager.entries) - 1
                    )
                elif key == ord("/"):
                    query = self._prompt_search()
                    if query:
                        self.search_query = query.lower()
                        self._filter_entries()
                elif key == ord("s"):
                    self.manager.sort_by = (
                        "host" if self.manager.sort_by == "time" else "time"
                    )
                    self.manager.sort_entries()
                    self.selected_idx = 0
                elif key in (ord("\n"), curses.KEY_ENTER):
                    selected_entry = self.manager.entries[self.selected_idx]
                    if connection := self._handle_connection(selected_entry):
                        return connection
                elif key in (ord("q"), ord("Q")):
                    return None
            except curses.error:
                continue
            except KeyboardInterrupt:
                return None

    def __del__(self):
        self._cleanup_mouse()


def main(stdscr: "curses.window", args: argparse.Namespace) -> int:
    try:
        manager = TmateManager(args.log_file, args.max_age, args.sort)
        ui = TmateUI(stdscr, manager)

        connection = ui.run()
        if connection:
            curses.endwin()
            try:
                os.execvp("ssh", ["ssh", connection])
            except OSError as e:
                print(f"Failed to establish SSH connection: {e}", file=sys.stderr)
                return 1
        return 0

    except Exception as e:
        curses.endwin()
        print(f"Error: {str(e)}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="TUI for managing tmate SSH connections"
    )
    parser.add_argument(
        "--log-file",
        type=str,
        default=DEFAULT_LOG_FILE_PATH,
        help="Path to the tmate log file",
    )
    parser.add_argument(
        "--max-age",
        type=int,
        default=7,
        help="Maximum age of connections to display in days (default: 7)",
    )
    parser.add_argument(
        "--sort",
        choices=["time", "host"],
        default="time",
        help="Sort entries by timestamp or hostname",
    )

    try:
        sys.exit(curses.wrapper(main, parser.parse_args()))
    except KeyboardInterrupt:
        sys.exit(0)
