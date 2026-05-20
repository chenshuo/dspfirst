# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python port of the [DSP First](https://dspfirst.gatech.edu) MATLAB toolbox (spfirst v175) from Georgia Tech. The original MATLAB source lives in `spfirst/`. Each interactive demo is a standalone PyQt6 GUI application with embedded matplotlib plots.

## Running the Demos

```bash
python3 cconvdemo.py   # Continuous Convolution Demo
python3 sindrill.py    # Reading Sinusoids Drill
python3 pezdemo.py     # Pole-Zero Demo (z-domain)
python3 phrace.py      # Phasor Race timed quiz
python3 cspindemo.py   # Spinning Phasors Visualisation
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

### cspindemo

Four-panel layout using `gridspec.GridSpec(3, 3, width_ratios=[3,1,2], height_ratios=[3,0.7,1.2])`: the unit circle (`ax_uc`, yellowish background) spans the tall left area; `ax_real` (green, thin vertical strip to its right) shows Re{z(t)} vs time with time running top-to-bottom (`ylim=(T, 0)`); `ax_imag` (pink, wide bottom strip) shows Im{z(t)} vs time; `ax_spec` (upper right) shows spectral lines; `ax_eq` (middle right) shows the equation and parameter table.

`_preset_xf(name)` returns `(X, F)` for each of the 5 built-in cases. The Conjugate checkbox appends `conj(X)` and `-F` to create conjugate-symmetric phasor pairs. All phasor positions for all time steps are precomputed in `_phasors_t` (shape `(N, NT)`) at setup time; each timer tick reads `_phasors_t[:, nt]` to avoid recomputing `exp()`. Each phasor is drawn as a tip-to-tail vector (one `Line2D` per phasor in `self._ph_artists`). Projection lines `_ph1`/`_pv1` (in `ax_uc`) and `_ph2`/`_pv2` (in `ax_imag`/`ax_real`) connect the current phasor tip to both projection axes. Phasor color maps frequency to a red–green gradient via `_phasor_color(fn, maxf)`. Animation uses `QTimer` at 20 ms; Play/Pause/Replay cycles through `_IDLE → _PLAYING → _PAUSED / _DONE` states.

### phrace

Two-panel layout using `gridspec.GridSpec(1, 2, width_ratios=[3, 2])`: the left panel (`ax_q`) renders all text via `ax.text(..., transform=ax.transAxes)` on a blank axes; the right panel (`ax_z`) shows the pole-zero plot for ZTransform questions. All math strings are generated as matplotlib mathtext (using `\pi`, `e^{j...}`, `\cos`, `\mathrm{Re}`, `\frac{}{}`, etc.) and wrapped in `$...$` at render time by `_mt()`.

Six question types: **Complex** (add two phasors in polar form), **Sinusoid** (add two sinusoids at the same frequency), **RealPart** (simplify `Re{(a+jb)e^{jωt}}`), **Spectrum** (convert between cosine and two-sided exponential), **Sampling** (compute `x[n] = x(nTs)`), **ZTransform** (identify pole/zero locations from H(z) given as a ratio of polynomials in z⁻¹). `generate_question()` returns a `QuestionData` dataclass; `polar_form`, `exp_form`, `cos_form`, `rect_form`, `zpoly_str` are pure string formatters with no Qt dependency.

A `QTimer` at 100 ms drives the elapsed-time display. The "Show Rectangular Form" checkbox appears only for Complex questions; the "Alternate Answers" button (cycles through phase + 2πk equivalents) appears only for Sinusoid and RealPart. Level (Novice/Pro) is synced between the radio buttons and the Level menu.

### sindrill

Single-axis quiz app. `LEVELS` dict controls the pools of amplitude/frequency/phase values. User inputs are evaluated via `safe_eval()` — a sandboxed `eval()` that exposes only `pi`, `e`, and basic math functions. The guess overlay (`line_guess`) is toggled with a checkbox; the "Answers" menu items are populated but disabled, revealing true values without requiring extra clicks.

## Porting Convention

When porting a MATLAB demo to Python, mirror the original `.m` file's behavior closely. Place the new `.py` file at root directory (e.g., `./sindrill.py`). Keep all logic in a single file; do not create packages or helper modules.
