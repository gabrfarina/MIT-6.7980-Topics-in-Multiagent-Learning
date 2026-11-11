#!/usr/bin/env python3
"""Build stale standalone figures with PDF and HTML typography."""
import argparse
import json
import os
from pathlib import Path
import subprocess
from build_cache import fingerprint

ROOT = Path(__file__).resolve().parents[1]
HTML_FIGURES = Path('.build/html-figures')
EXPORTER = ROOT / 'html-exporter/target/release/notes-html-exporter'

# These are included by other figures rather than rendered on their own.
SUPPORT_SOURCES = {
    'kernelized/vertices.typ',
    'learning2/ftr_ent.typ',
    'learning2/ftr_euc.typ',
    'learning2/ftr_log.typ',
    'learning2/omd_euc.typ',
    'team_belief_dag/pair.typ',
