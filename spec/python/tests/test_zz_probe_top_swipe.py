import os
import tempfile
from pathlib import Path

import pytest

from zen_driver import ZenDriver, launch, stop, wait_for_socket
from test_emulator_reader_tools import _write_reader_epub


@pytest.mark.parametrize("last_tab,full", [("aa", False), ("aa", True), ("browser", True), ("browser", False)])
def test_probe(last_tab, full):
    runtime = Path(os.environ["KOREADER_DIR"])
    with tempfile.TemporaryDirectory(prefix="zrc-", dir="/tmp") as temporary:
        root = Path(temporary)
        home, library = root / "home", root / "library"
        home.mkdir()
        library.mkdir()
        book = library / "probe.epub"
        _write_reader_epub(book)
        socket_path = root / "driver.sock"
        process = launch(runtime, home, socket_path, library, zen_config_source=(
            "return {page_browser={last_tab='%s',font_full_page=%s}}" % (last_tab, str(full).lower())))
        try:
            wait_for_socket(socket_path)
            driver = ZenDriver(socket_path)
            assert driver.open_book(book)["ok"]
            assert driver.command("activate_reader_control", name="page_browser")["activated"]
            before = driver.command("page_browser_state")["page_browser"]["active_tab"]
            assert driver.command("activate_reader_control", name="page_browser_controls")["activated"]
            swiped = driver.command("activate_reader_control", name="page_browser_top_swipe")["activated"]
            state = driver.command("reader_controls")
            Path(f"/tmp/zen-probe-swipe-{last_tab}-{full}.txt").write_text(
                f"opened_on={before} swiped={swiped} menu_top={state.get('menu_top')} page={state.get('page')}")
        finally:
            stop(process)
