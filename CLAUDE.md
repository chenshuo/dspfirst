# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python port of the [DSP First](https://dspfirst.gatech.edu) MATLAB toolbox (spfirst v175) from Georgia Tech. The original MATLAB source lives in `spfirst/`. Each interactive demo is a standalone PyQt6 GUI application with embedded matplotlib plots.

## Running the Demos

```bash
python3 cconvdemo.py   # Continuous Convolution Demo
python3 sindrill.py    # Reading Sinusoids Drill
python3 pezdemo.py     # Pole-Zero Demo (z-domain)
```

No build step, package install, or virtual environment is prescribed — the scripts run directly. Dependencies: `PyQt6`, `numpy`, `matplotlib`, `scipy`.

## Architecture

Each Python demo follows the same pattern:

- **Signal/model classes** at the top of the file — pure Python with `numpy`, no Qt dependencies
- **A single `QMainWindow` subclass** that owns the figure, canvas, and all UI state
- **`matplotlib.use('QtAgg')`** called before any other matplotlib import (required for PyQt6 embedding)
- **`FigureCanvas`** embedded inside a `QVBoxLayout` as the main widget; controls go below
- **No separate modules** — each demo is a single self-contained `.py` file

### cconvdemo

Six-panel layout using `gridspec.GridSpec(2, 3)`. The top row shows x(t), h(t), and a formula key; the bottom row shows τ-domain signals, the τ-domain product (filled), and the output y(t). A horizontal slider controls the current `t` value. Convolution is computed numerically via FFT (`numerical_convolve`), with special-case handling when either signal is an impulse.

Signal types (`CPulse`, `CExponential`, `CCosine`, `CSine`, `CGaussian`, `CImpulse`) all inherit from an abstract `Signal` base class that defines `eval(t)`, `support()`, `suggest_rate()`, and `formula_str()`. `SignalDialog` is a reusable `QDialog` for selecting and parameterizing a signal with a live preview.

### pezdemo

Four-panel layout using `gridspec.GridSpec(3, 2)`: the z-plane pole-zero plot spans the left two rows; magnitude response, phase response, and impulse response fill the right column and a full-width bottom row. `PezModel` holds `poles`/`zeros`/`k` and recomputes `hz` (via FFT of the polynomial coefficients) and `hn` (via `scipy.signal.lfilter` on a unit impulse) on every change. The frequency-response denominator uses `np.real()` before `lfilter` to avoid complex-coefficient warnings.

Interactive features: drag poles/zeros on the z-plane (conjugate pairs co-move); click-to-add modes via the Edit menu or mode buttons; a draggable red frequency cursor (ray) on the mag/phase plots; multiplicity labels for coincident roots; pink background when the system is unstable; zoom +/− buttons scale the z-plane axis. `_parse_coord` accepts `real , imag`, `x+yj`, or sandboxed expressions with `pi`/`j`.

### sindrill

Single-axis quiz app. `LEVELS` dict controls the pools of amplitude/frequency/phase values. User inputs are evaluated via `safe_eval()` — a sandboxed `eval()` that exposes only `pi`, `e`, and basic math functions. The guess overlay (`line_guess`) is toggled with a checkbox; the "Answers" menu items are populated but disabled, revealing true values without requiring extra clicks.

## Porting Convention

When porting a MATLAB demo to Python, mirror the original `.m` file's behavior closely. Place the new `.py` file at root directory (e.g., `./sindrill.py`). Keep all logic in a single file; do not create packages or helper modules.
