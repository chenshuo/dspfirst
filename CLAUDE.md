# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python port of the [DSP First](https://dspfirst.gatech.edu) MATLAB toolbox (spfirst v175) from Georgia Tech. The original MATLAB source lives in `spfirst/`. Each interactive demo is a standalone PyQt6 GUI application with embedded matplotlib plots.

## Running the Demos

```bash
python3 dconvdemo.py      # Discrete Convolution Demo
python3 cconvdemo.py      # Continuous Convolution Demo
python3 sindrill.py       # Reading Sinusoids Drill
python3 pezdemo.py        # Pole-Zero Demo (z-domain)
python3 phrace.py         # Phasor Race timed quiz
python3 cspindemo.py      # Spinning Phasors Visualisation
python3 strobedemo.py     # Strobe / Aliasing Demo
python3 specgramdemo.py   # Spectrogram Demo
python3 zdrill.py         # Complex Number Operations Drill
python3 fseriesdemo.py    # Fourier Series Demo
python3 filterdesign.py   # Filter Design Demo (FIR/IIR)
```

No build step, package install, or virtual environment is prescribed — the scripts run directly. Dependencies: `PyQt6`, `numpy`, `matplotlib`, `scipy`.

## Architecture

Each Python demo follows the same pattern:

- **Signal/model classes** at the top of the file — pure Python with `numpy`, no Qt dependencies
- **A single `QMainWindow` subclass** that owns the figure, canvas, and all UI state
- **`matplotlib.use('QtAgg')`** called before any other matplotlib import (required for PyQt6 embedding)
- **`FigureCanvas`** embedded inside a `QVBoxLayout` as the main widget; controls go below
- **No separate modules** — each demo is a single self-contained `.py` file

### dconvdemo

Two-section layout: a `QHBoxLayout` splits the window into a left matplotlib canvas and a fixed-width (295 px) right control panel.

**Left — main canvas** uses `gridspec.GridSpec(3, 1)` (or 4 rows when circular mode is on), all axes sharing the same x-axis via `sharex`:
- `ax_sig` — fixed signal (blue stems) + flipped/shifted signal (red stems) + ↑ n annotation.
- `ax_mul` — pointwise product at overlapping sample positions (green stems).
- `ax_out` — full linear convolution y[n], with the current-n sample highlighted green; in circular mode the stems are colour-coded red/blue to show aliasing (red circles = extra-period samples that wrap into [0, N−1]; red squares = in-range samples that receive aliased energy).
- `ax_circ` — circular convolution result (inserted between `ax_mul` and `ax_out` when enabled).

**Right panel** (top → bottom): two mini `FigureCanvas` widgets showing x[n] and h[n] previews; **Get x[n]** / **Get h[n]** buttons; **Flip x[n]** / **Flip h[n]** radio buttons; **Show Circular Convolution** checkbox; an HTML `QLabel` formula key; **Close** button.

Five signal classes (`UnitSample`, `Pulse`, `Exponential`, `Cosine`, `Sine`) each expose `xdata`, `ydata` arrays and a `formula_str()`. `SignalDialog` is a modal `QDialog` with a `QStackedWidget` (one `QFormLayout` per signal type) and a live matplotlib preview.

Stems are drawn by `_stem_artists`: a zigzag `Line2D` (`x, x, nan` / `0, y, nan` triplets) plus dot markers — no `ax.stem()` call, matching the MATLAB `mystem.m` approach.

`alias(x, L, nStart)` pads `x` to a multiple of `L` using `mod(nStart, L)` / `L − mod(nend, L) − 1` fill amounts, then reshapes and sums rows — a direct port of `alias.m`.

n can be moved by: dragging the mouse in `ax_sig` or `ax_out` (press → record `_drag_x0` and `_drag_n0`, motion → delta = `round(xdata − x0)`, integer steps); or ← → / 4 6 key presses. The x-axis auto-pans when n leaves the current view. Changing the flip selection or circular mode calls `_initialize()` which recomputes the full linear convolution via `np.convolve` and resets n to −5.

### cconvdemo

UI layout split into two main sections:
- **Left Side (Dynamic Plots):** 3 vertically stacked, aligned plots (`ax_sig` for τ-domain signals, `ax_mul` for τ-domain product, and `ax_out` for output y(t)) using a `3x1` `GridSpec` on `self.fig_main`. A horizontal slider below controls `t`.
- **Right Side (Controls & Static Plots):**
  - Two static plots side-by-side (`ax_x` for input x(t) and `ax_h` for impulse response h(t)), each with its own figure and canvas.
  - "Get" buttons and "Flip" radio buttons positioned directly below their respective static plots.
  - A styled `QLabel` (`self.lbl_key`) with HTML content serving as the formula key.
  - "Close" and "Help" buttons at the very bottom right.

Convolution is computed numerically via FFT (`numerical_convolve`), with special-case handling when either signal is an impulse. Signal types (`CPulse`, `CExponential`, `CCosine`, `CSine`, `CGaussian`, `CImpulse`) all inherit from an abstract `Signal` base class. `SignalDialog` is a reusable `QDialog` for selecting and parameterizing a signal with a live preview.

### pezdemo

Four-panel layout using `gridspec.GridSpec(3, 2)`: the z-plane pole-zero plot spans the left two rows; magnitude response, phase response, and impulse response fill the right column and a full-width bottom row. `PezModel` holds `poles`/`zeros`/`k` and recomputes `hz` (via FFT of the polynomial coefficients) and `hn` (via `scipy.signal.lfilter` on a unit impulse) on every change. The frequency-response denominator uses `np.real()` before `lfilter` to avoid complex-coefficient warnings.

Interactive features: drag poles/zeros on the z-plane (conjugate pairs co-move); click-to-add modes via the Edit menu or mode buttons; a draggable red frequency cursor (ray) on the mag/phase plots; multiplicity labels for coincident roots; pink background when the system is unstable; zoom +/− buttons scale the z-plane axis. `_parse_coord` accepts `real , imag`, `x+yj`, or sandboxed expressions with `pi`/`j`.

### cspin

Four-panel layout using `gridspec.GridSpec(3, 3, width_ratios=[3,1,2], height_ratios=[3,0.7,1.2])`: the unit circle (`ax_uc`, yellowish background) spans the tall left area; `ax_real` (green, thin vertical strip to its right) shows Re{z(t)} vs time with time running top-to-bottom (`ylim=(T, 0)`); `ax_imag` (pink, wide bottom strip) shows Im{z(t)} vs time; `ax_spec` (upper right) shows spectral lines; `ax_eq` (middle right) shows the equation and parameter table.

`_preset_xf(name)` returns `(X, F)` for each of the 5 built-in cases. The Conjugate checkbox appends `conj(X)` and `-F` to create conjugate-symmetric phasor pairs. All phasor positions for all time steps are precomputed in `_phasors_t` (shape `(N, NT)`) at setup time; each timer tick reads `_phasors_t[:, nt]` to avoid recomputing `exp()`. Each phasor is drawn as a tip-to-tail vector (one `Line2D` per phasor in `self._ph_artists`). Projection lines `_ph1`/`_pv1` (in `ax_uc`) and `_ph2`/`_pv2` (in `ax_imag`/`ax_real`) connect the current phasor tip to both projection axes. Phasor color maps frequency to a red–green gradient via `_phasor_color(fn, maxf)`. Animation uses `QTimer` at 20 ms; Play/Pause/Replay cycles through `_IDLE → _PLAYING → _PAUSED / _DONE` states.

### phrace

Two-panel layout using `gridspec.GridSpec(1, 2, width_ratios=[3, 2])`: the left panel (`ax_q`) renders all text via `ax.text(..., transform=ax.transAxes)` on a blank axes; the right panel (`ax_z`) shows the pole-zero plot for ZTransform questions. All math strings are generated as matplotlib mathtext (using `\pi`, `e^{j...}`, `\cos`, `\mathrm{Re}`, `\frac{}{}`, etc.) and wrapped in `$...$` at render time by `_mt()`.

Six question types: **Complex** (add two phasors in polar form), **Sinusoid** (add two sinusoids at the same frequency), **RealPart** (simplify `Re{(a+jb)e^{jωt}}`), **Spectrum** (convert between cosine and two-sided exponential), **Sampling** (compute `x[n] = x(nTs)`), **ZTransform** (identify pole/zero locations from H(z) given as a ratio of polynomials in z⁻¹). `generate_question()` returns a `QuestionData` dataclass; `polar_form`, `exp_form`, `cos_form`, `rect_form`, `zpoly_str` are pure string formatters with no Qt dependency.

A `QTimer` at 100 ms drives the elapsed-time display. The "Show Rectangular Form" checkbox appears only for Complex questions; the "Alternate Answers" button (cycles through phase + 2πk equivalents) appears only for Sinusoid and RealPart. Level (Novice/Pro) is synced between the radio buttons and the Level menu.

### sindrill

Single-axis quiz app. `LEVELS` dict controls the pools of amplitude/frequency/phase values. User inputs are evaluated via `safe_eval()` — a sandboxed `eval()` that exposes only `pi`, `e`, and basic math functions. The guess overlay (`line_guess`) is toggled with a checkbox; the "Answers" menu items are populated but disabled, revealing true values without requiring extra clicks.

### strobedemo

Five-panel layout using `gridspec.GridSpec(2, 3)`: top row holds `ax1` (MOTOR disk, static) and `ax3` (SAMPLES disk, updates with strobe); bottom row holds `ax2` (continuous-time spectrum), `ax4` (discrete-time spectrum, ω domain), and `ax5` (sampled/aliased spectrum).

`draw_arrow_line` / `draw_arrow_patch` / `update_arrow_line` are pure-function helpers ported from `arrow.m`; they return tuples of `Line2D` / `Polygon` artists that are updated in place on every `_update()` call. `_wrap_delt` mirrors the MATLAB degree-wrapping logic from `fig4update.m`.

State: `fm` (motor Hz) and `fs` (flash Hz), both driven by QSliders (in RPM / flashes-per-min) with paired QLineEdit boxes showing both the per-minute and Hz values. `_update()` computes `what = 2π(−fm/fs)` and classifies into no-aliasing / c==1 alias / c>1 deep-alias, then updates all five axes in one pass. Aliasing detection follows `fig4update.m` exactly: alias arrow visibility, "ALIASING!" text, stem colours, and the three sample-position arrows (black/green/magenta) in `ax3` with visibility gated on `abs(delt) ≤ 120°`.

### specgramdemo

Single large spectrogram plot on the left; a right-side control panel with stacked signal-parameter pages (QStackedWidget, one per signal type). A button row under the plot provides Play, 3D View (toggle), and FT at Click (toggle).

Three signal types — **Linear Chirp** (`cos(π·α·t² + 2π·f₀·t)`, matching `chirp_spec.m`), **Sum of Sinusoids** (space-separated amplitude/frequency/phase vectors), **User Audio** (load `.wav` via `scipy.io.wavfile`). `compute_stft` is a direct port of `spectgr_RWS_GUI.m`: manual overlap-add loop with `np.fft.rfft`, producing `(B, F, T)`. `to_db` clips to `[BAmax − drange, BAmax]`.

2D view uses `ax.imshow` with `origin='lower'`; 3D view uses `Axes3D.plot_surface` with a `np.meshgrid(T, F)` grid. FT-at-click mode is toggled via the button; `canvas.mpl_connect('button_press_event', ...)` calls `_plot_ft(x)` which replaces the spectrogram with a single dB-spectrum slice. STFT parameters (NFFT, window type, window size, overlap) are kept in sync: changing window size via slider or text recalculates noverlap using the current overlap-% menu selection.

### zdrill

Two-axis layout (side-by-side, `add_subplot(1, 2, ...)`) inside a single Figure: `ax_in` shows the input vector(s), `ax_ans` shows the guess (and optionally the answer / vector sum). Controls sit above the axes in a horizontal row.

Six operations: **Add**, **Subtract**, **Multiply**, **Divide**, **Inverse**, **Conjugate**. The active operation is chosen from a QComboBox; unary operations (Inverse, Conjugate) hide the z₂ input panel and the vector-sum checkbox. `new_question()` picks `z1` (and `z2` for binary ops) from `LEVELS[level]` — magnitude from `r` list, angle from `theta` list — then pre-computes all six answers into `self.z3` dict so switching operations never requires recomputation.

`draw_arrow` uses `mpatches.FancyArrow` with sizes proportional to the current axis extent (`M = max(x-range, y-range)`), mirroring `plotvect.m`'s `basewidth = 0.035 * M * arrow_scale`. Tip-to-tail vector-sum display for Add/Subtract draws z₁ first, then z₂ (or −z₂) starting from z₁'s tip. `set_axis_lims` expands the plot to fit whichever complex numbers are currently visible (inputs, guess, answer, vector-sum components).

`polar_form_str` / `rect_form_str` mirror `polarformstring.m` / `rectformstring.m`: snap near-zero values and well-known multiples of π to clean strings. The Answer menu shows read-only `r`, `θ`, and rectangular entries that are always populated but never editable. Level (Novice/Pro) and arrow width are set via the Options menu.

### fseriesdemo

Three-panel layout using `gridspec.GridSpec(3, 1)`: waveform (top), magnitude spectrum (middle), phase spectrum (bottom). A right-side controls panel holds a signal-type QComboBox, a period slider (T = 5…25 s, default 10), a coefficient-count slider (N = 0…15) with a paired QLineEdit, a "Show Error" checkbox, and a "coeff / freq" x-axis toggle.

Seven signal types with **analytical** Fourier coefficients (matching `changeplots` in `fouriergui_callbacks.m`): Square ($c_k = -2j/(k\pi)$ for odd k), Triangle ($c_k = 4/(k\pi)^2$ for odd k), Ramp/Sawtooth ($c_k = (-1)^k j/(k\pi)$), Full-wave rectified Sine, Full-wave rectified Cosine, Half-wave rectified Sine, Half-wave rectified Cosine. The reconstruction is the partial sum $\sum_{n=-N}^{N} c_n e^{j2\pi f_0 n t}$; the waveform generators (`sqar`, `make_triangle`, `make_ramp`, `fullwave`, `halfwave`) reproduce the original `.m` helper logic exactly.

Stem plots are drawn as two `Line2D` objects: dot-markers at the tips and a zigzag line (`xs[0::3]=x, xs[1::3]=x, xs[2::3]=NaN`) for the vertical stems. The "Show Error" toggle swaps the original/reconstructed pair for the error signal in the waveform panel. The "coeff / freq" checkbox relabels the spectrum x-axes from integer k to $k \cdot f_0$ Hz without recomputing anything. Mouse hover over either spectrum panel highlights the nearest stem in red and annotates its value (with `π`-fraction labels for phase).

### filterdesign

Single-plot layout: a `FigureCanvas` on the left (expandable) with a fixed-width (248 px) right-side control panel. The single `ax` is reused for all four views — Magnitude, Phase, Impulse Response, and Pole-Zero — cleared and redrawn on every switch via `_do_plot()`.

Two pure-math helper functions sit outside the class: `fir_ideal_impulse` computes the ideal sinc-based impulse response for LP/HP/BP/BR shapes; `compute_window` returns one of 10 window functions (Rectangular, Bartlett, Hann, Hamming, Blackman, Gaussian, Dolph-Chebyshev, BarcTemes, Lanczos, Kaiser).

Three design paths:
- **FIR Window** (`_fir_window`): multiplies `fir_ideal_impulse` by `compute_window`; Kaiser window auto-computes β from δ and optionally auto-sizes M via the Kaiser–Samueli formula.
- **FIR Parks-McClellan** (`_fir_pm`): calls `scipy.signal.remez`; enforces odd filter length; clamps band edges to avoid degenerate inputs.
- **IIR Butterworth** (`_iir_butter`): calls `scipy.signal.butter` (with optional `buttord` for auto-order); normalizes to unit peak; evaluates impulse response via `lfilter` on a 50-sample unit impulse.

`_update_visibility()` shows/hides parameter fields dynamically (F_stop, F_pass2/F_stop2 for band types, δ_pass/δ_stop for Kaiser/PM/IIR, Alpha for Gaussian/Dolph-Chebyshev, Auto Order checkbox). The `x_mode` toggle switches between Hz and normalized-frequency (0–1) display without recomputing; `y_mode` toggles linear vs. dB magnitude and converts the ripple fields accordingly. Red spec-lines (`_draw_spec_lines`) overlay the magnitude plot for designs with an explicit stopband spec (Kaiser, PM, IIR); plain dashed cutoff lines for basic window designs.

File menu exports `b`/`a` coefficients as `.npz` via `np.savez`.

## Porting Convention

When porting a MATLAB demo to Python, mirror the original `.m` file's behavior closely. Place the new `.py` file at root directory (e.g., `./sindrill.py`). Keep all logic in a single file; do not create packages or helper modules.
