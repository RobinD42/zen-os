---
title: Reader
category: Reader
summary: Configure reader appearance, controls, lookup tools, and page navigation.
settingsPath: Zen Settings > Reader
order: 50
---

<!-- Documentation current through ZenOS v3.3.0. -->

![Page browser grid](/images/zen_os/page_browser_grid.webp)

![Page browser menu](/images/zen_os/page_browser_menu.webp)

![Page browser table of contents](/images/zen_os/page_browser_toc.webp)

![Page browser bookmarks](/images/zen_os/page_browser_bookmarks.webp)

![Page browser search](/images/zen_os/page_browser_search.webp)

![Reader](/images/zen_os/reader.webp)

![Dictionary lookup menu](/images/zen_os/reader_dict.webp)

![Highlight menu](/images/zen_os/reader_highlight.webp)

![Reader menu](/images/zen_os/reader_menu.webp)

![Book details](/images/zen_os/reader_book_details.webp)

## Overview

Reader settings control the reading screen. They cover appearance, reader controls, lookup and highlighting, page navigation, and what happens when you leave a book.

![Page browser](/images/zen_os/page_browser.webp)

## Options

- Configure one reader top status bar with shared left, center, and right item slots across document formats.
- Reserve the top bar's space in paged reflowable documents, or paint it over CBZ/PDF files.
- Use the top bar's border as reading progress with optional chapter marks.
- Apply built-in or custom themes for light and dark reader modes.
- Apply prebuilt bottom status bars or save your current setup as a preset.
- Configure the Reader controls bottom menu and its tabs.
- Configure Zen quick lookup, Zen highlight menu, Wikipedia, and detected X-Ray, KOAssistant, or AI Assistant integrations.
- Choose the bottom swipe gesture: KOReader reader menu, Reader controls, Zen page browser, none, or a custom action.
- Use stable page labels in the page browser and table of contents when a book provides a page map.
- Restore the previous library location when leaving the reader.
- Enable or disable the bottom status bar and configure its Zen Presets, font, and CBZ/PDF hiding.

## Setting reference

| Setting | Description |
| --- | --- |
| Reader controls | Enables a bottom menu with tabs for reader settings and actions; open its submenu to edit tabs and page chevrons. |
| Appearance > Top status bar | Shows ZenOS's top reader status bar. |
| Appearance > Top status bar > Left items | Selects and arranges time, combined or separate battery information, Incognito, Wi-Fi, brightness, RAM usage, disk space, custom text, book title, author, chapter, progress percentage, separate current/total pages, or combined current/total pages for the left slot. |
| Appearance > Top status bar > Center items | Selects and arranges top-bar items for the center slot. |
| Appearance > Top status bar > Right items | Selects and arranges top-bar items for the right slot. |
| Appearance > Top status bar > Left/center/right items > Show separator | Shows separators inside the selected slot. |
| Appearance > Top status bar > Left/center/right items > Custom text | Enables custom text in that slot and opens its value editor. Empty text falls back to the device model. |
| Appearance > Top status bar > Font size | Sets the top-bar font size from 8 to 36. |
| Appearance > Top status bar > Font | Sets the top-bar font face or restores the default font. |
| Appearance > Top status bar > Separator | Selects a preset separator for top-bar items. |
| Appearance > Top status bar > Show bottom border | Draws a separator below the reader top status bar. |
| Appearance > Top status bar > Use border as progress bar | Fills the bottom border to show reading progress. Enabling it also enables the border. |
| Appearance > Top status bar > Chapter marks | Draws table-of-contents marks on the progress border. Enabling it also enables the progress border. |
| Appearance > Top status bar > Colored status icons | Uses the library status-bar colors for Wi-Fi, storage, memory, brightness, and battery icons on supported color screens. |
| Appearance > Top status bar > Hide in CBZ/PDF files | Hides the top bar for CBZ and PDF documents. |
| Appearance > Reader themes | Enables ZenOS reader themes. |
| Appearance > Reader themes > Dark mode | Selects the theme used while KOReader night mode is active. |
| Appearance > Reader themes > Light mode | Selects the theme used while KOReader night mode is inactive. |
| Appearance > Reader themes > Custom themes | Creates, edits, and deletes custom themes. A custom theme can set its name, background color, text color, and font. |
| Highlight / Lookup > Zen quick lookup | Enables ZenOS quick lookup behavior. |
| Highlight / Lookup > Zen highlight menu | Enables ZenOS's highlight menu. |
| Highlight / Lookup > Show Wikipedia | Shows Wikipedia in lookup options. |
| Highlight / Lookup > Show X-Ray | Shows X-Ray in lookup and highlight menus when the plugin is installed. |
| Highlight / Lookup > Show KOAssistant | Shows KOAssistant in lookup and highlight menus when the plugin is installed. |
| Highlight / Lookup > Show AI assistant | Shows an Assistant plugin button in lookup and highlight menus when the plugin is installed. |
| Highlight / Lookup > Show other items | Shows non-Zen KOReader quick lookup options alongside Zen buttons. |
| Appearance > Bottom status bar > Status bar items > Time left to finish chapter > Time until chapter end | Selects `5 min left in chapter`, `5 min left`, abbreviated `5m`/`1h 5m`, or KOReader's default `hh:mm` format for compatible footer layouts. |
| Reader > Bottom swipe gesture | Selects KOReader reader menu, Reader controls, Zen page browser, None, or Custom. Tapping anywhere on Custom opens choices for one dispatcher action, control, plugin menu, or KOReader menu, without button label or icon settings. Custom becomes selected only after a valid target is saved. Backing out without saving keeps the previous gesture choice. |
| Reader > Restore library location on exit | Returns to the previous library location after leaving the reader. |
| Appearance > Bottom status bar | Shows or hides KOReader's bottom reader status bar. |
| Appearance > Bottom status bar > Zen Presets > Built-in presets | Applies a prebuilt bottom status bar layout. |
| Appearance > Bottom status bar > Zen Presets > Save current settings as preset | Saves the current bottom status bar setup as a user preset. |
| Appearance > Bottom status bar > Zen Presets > User presets | Applies or deletes saved bottom status bar presets. |
| Appearance > Bottom status bar > Left items | Selects and arranges bottom-bar items for the left slot, independent of the top bar. |
| Appearance > Bottom status bar > Center items | Selects and arranges bottom-bar items for the center slot. |
| Appearance > Bottom status bar > Right items | Selects and arranges bottom-bar items for the right slot. |
| Appearance > Bottom status bar > Font | Sets footer font face, size, and bold style. |
| Appearance > Bottom status bar > Hide in CBZ/PDF files | Hides the footer for CBZ and PDF documents. |
| Appearance > Bottom status bar > KOReader status bar options | Exposes KOReader's built-in footer/status bar settings. |
| Appearance > Align status bars with book margins | Aligns both status bars with the book's horizontal margins. On by default; disabling uses KOReader's standard horizontal padding. |
| Appearance > Flash on every CBZ page turn | Uses a full screen refresh when the page changes in a CBZ file. On by default; takes effect on the next page turn. |

## Dictionary lookup menu

![Dictionary lookup menu](/images/zen_os/reader_dict.webp)

Tap and hold a word while reading to open the Zen quick lookup menu. It shows the dictionary definition for the selected word along with ZenOS action buttons. Enable it with **Zen Settings > Reader > Highlight / Lookup > Zen quick lookup**. Wikipedia and installed X-Ray, KOAssistant, and AI Assistant integrations can appear as dedicated buttons; use **Show other items** to retain KOReader's remaining lookup options.

## Highlight menu

![Highlight menu](/images/zen_os/reader_highlight.webp)

Tap + hold and drag to highlight a selection of text and open the Zen highlight menu. It collects highlight, lookup, and annotation actions for the selected text in a single Zen-styled menu. When you reopen the menu for an existing highlight, its first action extends or adjusts the selected text. Enable the menu with **Zen Settings > Reader > Highlight / Lookup > Zen highlight menu**.

## Stable Page Labels

ZenOS uses KOReader page-map labels when a book provides them. The reader page browser shows stable labels on page tiles and during page scrubbing, and the Zen table of contents shows the same labels beside chapter entries. It also handles non-linear book content without breaking page navigation. Home featured widgets use the same page data for current/total progress.

The page browser has Book info at the top left, centered tabs for Pages, Aa, Bookmarks, and TOC, and Close at the top right. Bookmarks and TOC fill the browser below its tabs. On Pages, Grid and Search flank the chapter title, with the slider and navigation chevrons below. A light divider separates the preview from the controls on Pages and Aa. The view chooser, font list, and three-dot menu open as compact anchored menus inset from the screen edge.

**Reader > Page Browser > Top status bar** shows the Interface status bar above the tabs, with top padding and a fixed position across all four tabs. It is enabled by default and stays hidden when **Interface > Status bar** is disabled.

Aa keeps the single-page or carousel preview, switching Grid to single-page. Its fixed-height settings panel has **Font, Layout, Themes** tabs for EPUB and **Contrast, Page, Document, Themes** for PDF/CBZ. Smaller dots above these tabs show the page within each section; switching sections remembers your page. Each page fits three settings rows, separated by full-width dividers, with titles on the left and numeric values on the right. The first Font page contains family, size, and weight. The font-family button shows the current family and opens a scrollable list with font samples. Its three-dot menu offers **Set as default** and **Reset**; Reset restores the saved default family, or the built-in family when none is saved.

In **Aa → Font** (EPUB) or **Aa → Contrast** (PDF/CBZ), open the three-dot menu beside Close and enable **Show full page** to see the page at its actual reading size behind the top and bottom controls. The visible center updates as you adjust settings. This choice is remembered for the font tab. The same menu also offers **Reader controls**. Elsewhere, the menu offers **Reader controls** above **Settings**. Both close the browser: Reader controls opens Zen Reader Controls, and Settings opens the Reader settings page.

After first-run setup, a one-time Reader tour demonstrates the swipe-up page browser and its layouts. Run **Zen Settings > About > Setup Guide** to queue the tour again.

## Status bars

The reader has two independent status bars: a top bar and a bottom bar. Each bar has three slots — left, center, and right — that you customize separately. Drop items like time, battery, Incognito, Wi-Fi, brightness, RAM usage, disk space, custom text, book title, author, chapter, progress percentage, or current/total pages into any slot and arrange their order. The top and bottom bars are configured independently, so you can show different items in each.

## Time until chapter end

Open **Zen Settings > Reader > Appearance > Bottom status bar > Status bar items > Time left to finish chapter > Time until chapter end** to choose how the current chapter estimate appears: `5 min left in chapter`, `5 min left`, abbreviated `5m`/`1h 5m`, or KOReader's default `hh:mm` format. The abbreviated hour and minute units are localized.

## End of book

The Zen end-of-book screen reuses Home's featured book, statistics, quotes, and book strip widgets. Open **Zen Settings > Reader > End of book > Widgets** to reorder or hide widgets and customize their content independently of Home. **Preview** opens the screen for the current book without marking it finished.

Swipe a highlight left or right to browse this book's highlights and notes; each shows its page label. Tap it to return to that passage. The book strip offers books by the same author, the next unfinished volume in this series, and a next book from each other series already started. Recommendations use the library's indexed metadata.

Statistics cover only the current book: active reading days, recorded reading time, minutes per page, and minutes per reading day. Choose any three in the statistics widget's settings. The toggle on the **Label** row shows or hides the heading; its submenu caret opens the text, font, size, bold weight, and default-style controls. The text defaults to **Statistics**; an empty label restores it. Missing statistics appear as a dash.

**Zen Settings > Reader > End of book > End of document action** uses KOReader's action setting. **Zen end of book** and **Always mark as finished** are the defaults for unset preferences; saved choices survive restarts. Turning off automatic marking keeps the current status in both Book Status and Zen's end-of-book screen. Book Status remains available from the action menu.

## Reader controls

Reader controls opens at the bottom of the reading screen, with KOReader-style icon tabs below its
settings. The selected tab opens into the panel through a gap in the top border.
There is no status row or up chevron. Optional page chevrons stay at the edges to page through additional tabs.
The tabs and three-dot menus follow the active custom icons when enabled.
Choose **Reader controls** under **Bottom swipe gesture** to open it with a swipe up,
or use the embedded **Aa** tab in the page browser. Its TOC and Bookmarks tabs also stay inside the browser.
Back, a tap outside the panel, or a swipe down dismisses Reader controls.
Reader controls has no top-menu tab and does not hatch the reading screen.
Swiping down while reading opens the usual top-menu default.
Font, Contrast, Page, Document, Book info, Profiles, and Themes select content above the
tabs. Book info uses Launcher’s book details view. TOC, Bookmarks, Search,
Vocabulary builder and custom buttons open their destinations directly. Bookmarks includes bookmarks, highlights, and notes; Search opens the book’s search input. Use the pagination row to page
through settings three rows at a time, using the same arrow-and-dot pager as the page browser.
Swipe the settings area or use the pager arrows to change pages. Reader initially opens its first section, including Contrast for PDF/CBZ.

**Vocabulary builder**, **Page Browser**, and **KOReader reader menu** appear in
**Zen Settings > Reader > Reader controls > Buttons** alongside Font, Contrast, and Page.
Existing saved button lists receive missing entries automatically.
**Page Browser** is an optional button, disabled by default. Enable it in the Buttons list.
It opens the Zen page browser independently of the bottom swipe gesture. KOReader’s
existing **Reader > Page browser** dispatch action opens the same view.

**KOReader reader menu** is another optional button, disabled by default in the same
Buttons editor. It opens KOReader’s native bottom reader menu, including in Zen mode
and when the bottom swipe gesture is disabled or assigned to the page browser.

Font lists installed fonts as radio buttons in two columns and four rows, aligned
left with a divider under each font. Swipe the chooser or use its arrows to change
font pages; dots mark the current page. Hold a font to open KOReader’s default-font prompt. Themes uses the same two-column chooser,
with up to four rows per page and local paging. Swipe the tab row to change tab pages.
**Zen Settings → Reader → Reader controls → Show page chevrons** controls the tab-row arrows.
It defaults off on touch devices and on without touch. Enabled chevrons have padded tap targets at both edges, and fewer buttons fit per page. Swiping changes pages with or without chevrons.
Reader theme settings sits at the far right in Themes, as an outlined button without a repeated heading.
Themes is available for reflowable books. Reflowable Font pages include font family, size,
weight, contrast, kerning, hinting, word spacing, and expansion. Kerning, hinting, word spacing, and expansion use
the shared tab selector, with the current preset filled in the accent color. Word spacing and
expansion keep KOReader’s native presets and granular adjustments, without percentage values in their titles. Slider three-dot menus
sit after the slider controls; tab selectors place their detail menu directly after the final tab. Page lists margins, followed by line spacing
and page/continuous mode. Rakuyomi’s View Mode appears below the native mode when available; later settings include two-column
layout. Page/continuous mode also uses tabs. Top/bottom sync lives in the margin picker:
The Sync action switches between separate top/bottom sliders and a shared slider. A check marks the active sync state. Values and sync changes apply immediately.
For PDF/CBZ, the separate **Contrast** button uses KOReader’s native icon. It reads the native Contrast panel: numeric progress controls such as contrast, white threshold, and saturation remain sliders; the other supported choices appear as tabs on later pages. These include Dewatermark, PDF Background Cleanup, and the device’s native dithering option. Contrast also includes Invert Document in night mode. Choices, values, and availability follow the installed KOReader version and hardware. Crop, Fit, and Zoom to use tabs. Straighten
under Page uses KOReader’s degree presets. Unsupported options disappear. PDF reflow is controlled through
KOReader's own menu.

Tab selector borders align with the visible −/+ symbols, independent of the number of tabs; slider buttons keep their full touch targets. Settings, profile actions, and toggle titles share the same right-aligned column and font. Zoom to and Direction use larger KOReader icons, with Direction immediately below Zoom to. Rows/columns use the native 1–8 tabs and a granular picker; numeric zoom and overlap controls use sliders. A bold Overlap heading groups the Horizontal and Vertical controls. Longer
labels use a second line. Numeric values align right in compact cells sized for the visible slider range, updating independently of their titles. Font weight uses numeric classes such as 350 or 400; paired margins get extra space when unequal. The Reader footer has less padding above and below its
collapse chevron to keep more of the book visible.

Changes use KOReader's native book settings. Sliders snap to native steps and preview changes at most about every 150 ms while dragging, then apply the final value on release; **−/+** uses the Controls brightness-button style and moves one step at a time across the full range. Sliders zoom to five native presets around the default, expanding to include the current value and saved default. They follow KOReader’s ordered stops, including decreasing White Threshold values from 255 at the left. Font size keeps KOReader’s native fine steps. A black notch marks the saved global default, or the native built-in default when none is saved. Font size, weight, contrast, and margins have
three-dot menus offering Set as default and Reset. Adjust values with the sliders and their −/+ controls.
Reset restores the saved default, or the built-in default when none is saved. Tap outside or press Back to dismiss.
Font size defaults are set through its menu. Other settings also support holding
the label or value to save a default. Changes to Font, Page, Document, or reader theme settings
remain visible in the underlying book.
Synced top/bottom margins use one slider. Left/right margins show one value when equal; existing asymmetric values remain visible as a pair. Profiles > Defaults lets you save all
eligible settings or select just one or several. Saving only font size leaves
all other defaults unchanged.
Defaults follow KOReader's two groups: reflowable documents and fixed-layout
documents. Saved book settings continue to take precedence.

Profiles use KOReader's Profiles plugin. Save current reader settings captures
transferable reading settings, including styles and typography outside this
panel. Hold a saved profile to update or manage it; tap to apply it. Progress,
annotations, metadata, and page-specific crop coordinates are excluded. Profiles
captured here apply only to compatible document engines. Include reader theme
saves independent copies of both light and dark themes; applying them updates the global reader themes.

Themes shows a radio list for the current light/dark mode and a link to the global reader
theme editor. Selections apply immediately to the open book and all other books. Profile theme snapshots retain
their colors and font even if a custom theme is later changed or deleted. Theme
rendering retains its existing support for reflowable documents.

Configure the bottom menu at **Zen Settings > Reader > Reader controls**. The switch on that row enables or disables it. **Buttons** opens the
shared arrange list: reorder or toggle any button, and edit its label and icon or
delete it from its submenu. Use **+** to add actions, Controls buttons, plugin
menus, reader KOReader menus, or restore a deleted built-in button. Reader buttons
are stored independently of Launcher. **Contrast (PDF/CBZ)** is a separate button for fixed-layout documents; Font is available only for reflowable books. Their order, labels, icons, and toggles can be edited independently.
