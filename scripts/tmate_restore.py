import curses
import sys
import os
import re
import argparse
from datetime import datetime, timedelta



"""
Add to ~/.ssh/config

```
Host *.tmate.io
    PermitLocalCommand yes
    LocalCommand echo "[`date '+%%Y-%%m-%%d %%H:%%M'`]: %r@%h" >> ~/.cache/tmate_logs.log
```
"""
DEFAULT_LOG_FILE_PATH = os.path.expanduser("~/.cache/tmate_logs.log")


def parse_log_file(file_path, max_age_days):
    """
    Parses the tmate log file and extracts unique connection entries within the max_age_days.
    Only the most recent entry for each unique connection is retained.

    Args:
        file_path (str): Path to the log file.
        max_age_days (int): Maximum age of the connections to include.

    Returns:
        List of tuples: [(timestamp, connection_string), ...]
    """
    if not os.path.exists(file_path):
        return []

    connection_dict = {}
    pattern = re.compile(r"\[\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\s*\]:\s*(\S+@\S+)")
    cutoff_time = datetime.now() - timedelta(days=max_age_days)

    with open(file_path, "r") as f:
        for line in f:
            match = pattern.search(line)
            if match:
                timestamp_str = match.group(1).strip()
                connection = match.group(2).strip()
                normalized_conn = connection
                try:
                    timestamp = datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M")
                    if timestamp >= cutoff_time:
                        if (normalized_conn not in connection_dict) or (
                            timestamp > connection_dict[normalized_conn]
                        ):
                            connection_dict[normalized_conn] = timestamp
                except ValueError:
                    continue

    entries = [(ts, conn) for conn, ts in connection_dict.items()]
    entries.sort(key=lambda x: x[0], reverse=True)

    return entries


def draw_menu(stdscr, selected_idx, entries):
    """
    Draws the menu with the list of tmate connections.

    Args:
        stdscr: curses window object
        selected_idx: currently selected index
        entries: list of connection entries
    """
    stdscr.clear()
    height, width = stdscr.getmaxyx()

    title = "Select a tmate Session to Connect"
    stdscr.addstr(
        1, max((width - len(title)) // 2, 0), title, curses.A_BOLD | curses.A_UNDERLINE
    )

    display_height = height - 6
    total_entries = len(entries)

    if total_entries > display_height:
        if selected_idx < display_height // 2:
            start_idx = 0
        elif selected_idx > total_entries - display_height // 2:
            start_idx = total_entries - display_height
        else:
            start_idx = selected_idx - display_height // 2
        end_idx = start_idx + display_height
    else:
        start_idx = 0
        end_idx = total_entries

    for idx in range(start_idx, end_idx):
        entry = entries[idx]
        timestamp, connection = entry
        display_str = (
            f"{idx + 1}. [{timestamp.strftime('%Y-%m-%d %H:%M')}]: {connection}"
        )
        if idx == selected_idx:
            mode = curses.A_REVERSE
        else:
            mode = curses.A_NORMAL
        try:
            stdscr.addstr(3 + idx - start_idx, 2, display_str[: width - 4], mode)
        except curses.error:
            pass

    instructions = "Use UP/DOWN arrows to navigate, ENTER to select, 'q' to quit."
    stdscr.addstr(height - 2, 2, instructions, curses.A_DIM)

    footer = f"Total Sessions: {total_entries}"
    stdscr.addstr(height - 2, width - len(footer) - 2, footer, curses.A_DIM)

    stdscr.refresh()


def main(stdscr, args):
    curses.curs_set(0)

    entries = parse_log_file(args.log_file, args.max_age)

    if not entries:
        stdscr.clear()
        msg = "No tmate sessions found matching the criteria."
        stdscr.addstr(0, 0, msg, curses.A_BOLD)
        stdscr.refresh()
        stdscr.getch()
        return

    selected_idx = 0
    draw_menu(stdscr, selected_idx, entries)

    while True:
        key = stdscr.getch()

        if key == curses.KEY_UP:
            selected_idx = (selected_idx - 1) % len(entries)
            draw_menu(stdscr, selected_idx, entries)
        elif key == curses.KEY_DOWN:
            selected_idx = (selected_idx + 1) % len(entries)
            draw_menu(stdscr, selected_idx, entries)
        elif key in [ord("\n"), curses.KEY_ENTER]:
            _, connection = entries[selected_idx]
            curses.endwin()
            try:
                os.execvp("ssh", ["ssh", connection])
            except Exception as e:
                print(f"Failed to establish SSH connection: {e}")
                sys.exit(1)
        elif key in [ord("q"), ord("Q")]:
            break


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="TUI for managing tmate SSH connections."
    )
    parser.add_argument(
        "--log-file",
        type=str,
        default=DEFAULT_LOG_FILE_PATH,
        help="Path to the tmate log file.",
    )
    parser.add_argument(
        "--max-age",
        type=int,
        default=7,
        help="Maximum age of connections to display in days (default: 7).",
    )
    args = parser.parse_args()

    try:
        curses.wrapper(main, args)
    except KeyboardInterrupt:
        curses.endwin()
        sys.exit(0)
