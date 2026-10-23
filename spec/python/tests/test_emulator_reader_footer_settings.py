import os
import tempfile
from pathlib import Path

import pytest

from test_emulator_reader_tools import _write_reader_epub
from zen_driver import ZenDriver, launch, stop, wait_for_socket


pytestmark = pytest.mark.skipif(
    os.environ.get("ZEN_UI_RUN_EMULATOR") != "1", reason="requires the KOReader emulator",
)


def test_bottom_bar_settings_apply_on_next_reader_open() -> None:
    runtime = Path(os.environ["KOREADER_DIR"])
    with tempfile.TemporaryDirectory(prefix="zen-footer-settings-") as temporary:
        root = Path(temporary)
        home, library = root / "home", root / "library"
        home.mkdir()
        library.mkdir()
        book = library / "footer.epub"
        _write_reader_epub(book)
        socket = root / "driver.sock"
        process = launch(runtime, home, socket, library)
        try:
            wait_for_socket(socket)
            driver = ZenDriver(socket)
            assert not driver.command("reader_state")["reader"]["open"]
            assert driver.command("open_settings_page")["ok"]
            assert driver.command("settings_page_select", label="Reader")["ok"]
            items = driver.command("settings_page_state")["settings"]["items"]
            annotation = next(item for item in items if item["label"] == "Annotation viewer")
            assert annotation["icon_file"].endswith("/icons/bookmark.svg")
            for label in ("Appearance", "Bottom status bar", "Status bar items"):
                result = driver.command("settings_page_select", label=label)
                assert result["ok"], result
            items = driver.command("settings_page_state")["settings"]["items"]
            assert items[0]["label"] == "Pinned pages" and items[0]["checked"]
            assert driver.command("settings_page_select", label="Pinned pages")["ok"]
            clock = next(item for item in items if item["label"].startswith("Current time"))
            title = next(item for item in items if item["label"] == "Book title")
            assert driver.command("settings_page_select", label=clock["label"])["ok"]
            assert driver.command("settings_page_select", label=title["label"])["ok"]
            assert driver.command("close_settings_page")["ok"]
            assert driver.open_book(book)["ok"]
            state = driver.command("reader_state")["reader"]
            assert state["open"]
            assert state["footer_time"] == (not clock["checked"])
            assert state["footer_book_title"] == (not title["checked"])
            references = driver.command("reference_action", action="paint")["references"]
            assert references["footer_pinned_pages"] is False
        finally:
            stop(process)
