#!/usr/bin/env python3
"""Prepare customer docs for manual upload into Kotaemon.

This helper copies simple text files, optionally converts common Office/PDF/HTML
formats with MarkItDown, and writes a manifest. It does not index, upload, or
delete source files.
"""

from __future__ import annotations

import argparse
import csv
import re
import shutil
import sys
from pathlib import Path
from typing import Iterable


COPY_DIRECT = {".md", ".txt", ".csv"}
CONVERT_TO_MD = {".docx", ".pptx", ".xlsx", ".pdf", ".html", ".htm"}
JUNK_NAMES = {".DS_Store", "Thumbs.db", "desktop.ini"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prepare docs for manual upload into Kotaemon."
    )
    parser.add_argument("--input", required=True, help="Input folder of raw docs")
    parser.add_argument("--output", required=True, help="Output folder for prepared docs")
    return parser.parse_args()


def iter_files(root: Path) -> Iterable[Path]:
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        rel_path = path.relative_to(root)
        if path.name in JUNK_NAMES:
            continue
        if any(part.startswith(".") for part in rel_path.parts):
            continue
        yield path


def sanitize_piece(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9._-]+", "_", value.strip())
    value = re.sub(r"_+", "_", value).strip("._")
    return value or "file"


def output_path_for(source: Path, input_root: Path, output_root: Path, suffix: str) -> Path:
    rel_path = source.relative_to(input_root).with_suffix("")
    stem = "__".join(sanitize_piece(part) for part in rel_path.parts)
    candidate = output_root / f"{stem}{suffix}"
    counter = 2
    while candidate.exists():
        candidate = output_root / f"{stem}_{counter}{suffix}"
        counter += 1
    return candidate


def load_markitdown():
    try:
        from markitdown import MarkItDown  # type: ignore
    except ImportError:
        return None
    return MarkItDown()


def convert_with_markitdown(markitdown, source: Path, destination: Path) -> None:
    result = markitdown.convert(str(source))
    text = getattr(result, "text_content", None)
    if text is None:
        text = str(result)
    destination.write_text(text, encoding="utf-8")


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def main() -> int:
    args = parse_args()
    input_root = Path(args.input).expanduser().resolve()
    output_root = Path(args.output).expanduser().resolve()

    if not input_root.exists() or not input_root.is_dir():
        print(f"ERROR: input folder does not exist or is not a directory: {input_root}", file=sys.stderr)
        return 2

    output_root.mkdir(parents=True, exist_ok=True)
    markitdown = load_markitdown()
    rows = []
    copied = 0
    converted = 0
    warnings = 0

    for source in iter_files(input_root):
        suffix = source.suffix.lower()
        warning = ""

        if suffix in COPY_DIRECT:
            destination = output_path_for(source, input_root, output_root, suffix)
            copy_file(source, destination)
            action = "copied"
            copied += 1
        elif suffix in CONVERT_TO_MD and markitdown is not None:
            destination = output_path_for(source, input_root, output_root, ".md")
            try:
                convert_with_markitdown(markitdown, source, destination)
                action = "converted_to_markdown"
                converted += 1
            except Exception as exc:  # noqa: BLE001 - conversion failure belongs in manifest.
                destination = output_path_for(source, input_root, output_root, suffix)
                copy_file(source, destination)
                action = "copied_as_is"
                warning = f"conversion failed: {exc}"
                copied += 1
                warnings += 1
        elif suffix in CONVERT_TO_MD:
            destination = output_path_for(source, input_root, output_root, suffix)
            copy_file(source, destination)
            action = "copied_as_is"
            warning = "markitdown not installed; copied original file"
            copied += 1
            warnings += 1
        else:
            destination = output_path_for(source, input_root, output_root, suffix or ".bin")
            copy_file(source, destination)
            action = "copied_as_is"
            warning = "unsupported file type; copied original file"
            copied += 1
            warnings += 1

        rows.append(
            {
                "original_path": str(source),
                "output_path": str(destination),
                "file_type": suffix.lstrip(".") or "unknown",
                "action": action,
                "warning": warning,
            }
        )

    manifest_path = output_root / "MANIFEST.csv"
    with manifest_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["original_path", "output_path", "file_type", "action", "warning"],
        )
        writer.writeheader()
        writer.writerows(rows)

    print("Document preparation complete")
    print(f"Input:     {input_root}")
    print(f"Output:    {output_root}")
    print(f"Manifest:  {manifest_path}")
    print(f"Files:     {len(rows)}")
    print(f"Copied:    {copied}")
    print(f"Converted: {converted}")
    print(f"Warnings:  {warnings}")
    if markitdown is None:
        print("Note: install MarkItDown for Office/PDF/HTML conversion: pip install 'markitdown[all]'")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
