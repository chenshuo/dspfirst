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
python3 cspin.py          # Spinning Phasors Visualisation
python3 strobedemo.py     # Strobe / Aliasing Demo
python3 specgramdemo.py   # Spectrogram Demo
python3 zdrill.py         # Complex Number Operations Drill
python3 fseriesdemo.py    # Fourier Series Demo
python3 filterdesign.py   # Filter Design Demo (FIR/IIR)
python3 dltidemo.py       # Discrete LTI System Demo
python3 cltidemo.py       # Continuous LTI System Demo
python3 con2dis.py        # Continuous-to-Discrete Sampling Demo
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

### dltidemo

Four-panel layout using `gridspec.GridSpec(2, 3, width_ratios=[3,4,3], height_ratios=[1,1])`: the input signal (`ax_in`, red stems) spans both rows in the left column; the filter magnitude (`ax_mag`) and phase (`ax_phase`) stack in the centre column; the output signal (`ax_out`, magenta stems) spans both rows in the right column. A fixed-height (≤190 px) control strip sits below.

**Input panel** (dark-purple `QGroupBox`): four slider+edit rows for Amplitude (0–4), Frequency (0–1.5, where 1.0 = 2π), Phase (−1–2, units of π), and DC Level (−2–2). Labels update dynamically (e.g. "Frequency = 2π(0.1)"). Sliders use `blockSignals` when synced from the edit box to avoid re-entrancy.

**Filter panel** (dark-blue `QGroupBox`): a `QComboBox` selects from nine filter types (Averager, Differencer, Ideal LP/HP/BP, FIR LP/HP/BP, User-defined). A shared freq/length label+slider+edit row reconfigures for each type; a phase-slope row (±5) appears only for ideal filters; a b_k edit field appears only for user-defined. `_apply_filter_visibility()` shows/hides widgets; `_configure_ff_slider()` resets the slider range and integer/float mode.

**Filter design** (all pure-math, no Qt dependency):
- `_myfir1(M, wc, fir_type)`: Hamming-windowed sinc FIR (port of `myfir1.m`); `wc` ∈ [0,1] (fraction of π); M forced even; bandpass shifts centre frequency via cosine modulation.
- `_ideal_filter(pop_up, freq1, phase_shift)`: returns (ff, HH) on a 1001-pt grid over [−0.5, 0.5]; masks LP/HP/BP and multiplies by `exp(j·2π·ff·phase_shift)`.
- `_freqz(b)`: 512-pt whole-spectrum `scipy.signal.freqz`, mapped to [−0.5, 0.5] with fftshift.
- `_freqz_at(b, freqs)`: evaluates freqz at specific normalised frequencies for output computation.

**Output computation**: for ideal filters (3–5), finds nearest bins in the 1001-pt grid for DC and the input frequency; for all other filters, calls `_freqz_at` at [0, Freq, −Freq]. `out_phase` is in units of π; `out_dc = Re{H(0)} × DC`.

**Frequency markers**: five red `'o'` `Line2D` artists on mag+phase axes — one at DC, one at ±Freqmod — updated on every parameter change. Freqmod folds `self.Freq` into (−∞, 0.5) by subtracting 1 while ≥ 0.5. DC marker hidden when DC=0; freq markers hidden when Freqmod=0 and DC≠0 (they coincide with DC marker); negative-freq marker hidden when |Freq| < 1e-5.

**Theoretical Answer button**: calls `cosine_string(out_mag, 2*Freq, out_phase, out_dc)` and sets `ax_out.set_title(...)` to show the output formula.

`cosine_string(Amp, Freq, Phase, DC)` generates a human-readable formula for `DC + Amp·cos(Freq·π·n + Phase·π)` using Unicode π, snapping near-integer multiples to exact strings (same logic as `cosinestring.m`).

### cltidemo

Four-panel layout using `gridspec.GridSpec(2, 3, width_ratios=[3,4,3], height_ratios=[1,1])`: the input signal (`ax_in`, red line) spans both rows in the left column; the filter magnitude (`ax_mag`) and phase (`ax_phase`) stack in the centre column; the output signal (`ax_out`, magenta line) spans both rows in the right column. A fixed-height (≤210 px) control strip sits below. Unlike dltidemo, signals are drawn as continuous lines (`ax.plot()`), not stems.

**Input panel** (dark-purple `QGroupBox`): four slider+edit rows for Amplitude (0–4), Frequency (10–100 Hz), Phase (−1–2, units of π), and DC Level (−2–2). Labels update dynamically (e.g. "Frequency = 20 Hz"). Sliders use `blockSignals` when synced from the edit box.

**Filter panel** (dark-blue `QGroupBox`): a `QComboBox` selects from eight filter types (Ideal LP/HP/BP/BR, First-order LP/HP/BP/BR). A cutoff/center-freq label+slider+edit row applies to all types. A phase-slope row (−1 to 1 seconds) appears only for ideal filters (types 1–4). A bandwidth row (10–50 Hz) appears only for first-order BP/BR (types 7–8). `_apply_filter_visibility()` shows/hides widgets. When switching to types 3,4,6,7,8 (band/high-pass), the freq slider lower bound becomes 20 Hz; if the current `filt_freq1 < 20`, it resets to 50 Hz.

**Filter design** (pure-math, no Qt dependency):
- `ct_filter(filter_type, cutoff, bandwidth, freqs)`: port of `ctfirstorderfilter.m`; LP: `1/(1+jf/fc)`, HP: `(jf/fc)/(1+jf/fc)`, BP: `(jf·bw)/(fc²−f²+jf·bw)`, BR: `(fc²−f²)/(fc²−f²+jf·bw)`. `freqs` defaults to `linspace(0,200,1001)`.
- `ideal_filter_ct(pop_up, freq1, phase_shift)`: port of `IdealFilter` subfunction; 1001-pt grid 0–200 Hz; masks LP/HP/BP/BR (BP/BR use fixed bw=20 Hz) multiplied by `exp(j·2π·f·phase_shift)`.

**Output computation**: for ideal filters (1–4), finds nearest bins in the 1001-pt grid for DC (f=0) and input frequency; for first-order filters (5–8), calls `ct_filter(..., freqs=[0, Freq])` to evaluate exactly at DC and the signal frequency. `out_mag = |H(Freq)| × Amp`, `out_phase = ∠H(Freq)/π + Phase`, `out_dc = Re{H(0)} × DC`.

**Frequency markers**: five red `'o'` `Line2D` artists on mag+phase axes. The frequency axis is 0–200 Hz (one-sided), so the negative-frequency marker is permanently hidden (off-screen). DC marker (at f=0) visible when DC≠0; positive-freq marker (at f=Freq) hidden when Freq=0 and DC≠0.

**Theoretical Answer button**: calls `cosine_string_ct(out_mag, Freq, out_phase, out_dc)` and sets `ax_out.set_title(...)` to display the output formula.

`cosine_string_ct(Amp, Freq, Phase, DC)` generates a human-readable formula for `DC + Amp·cos(2π·Freq·t + Phase·π)` using Unicode π. For Freq=20 Hz it produces "cos(40πt)" (matching MATLAB `cosinestring.m` which formats `2*Freq` as the π coefficient).

### con2dis

Six-panel layout using `gridspec.GridSpec(2, 3)` with explicit margins (no `tight_layout`):
- `ax1` (top-left) — continuous signal x(t) as a blue line.
- `ax2` (top-centre) — sampled signal x[n] as black stems, with a faint blue continuous-time underlay (`line11`). A second underlay (`line52`) toggled by **Show Lower Frequency Signal** shows the aliased sinusoid.
- `ax5` (top-right) — reconstructed output y(t); turns dark red when aliasing occurs.
- `ax4` (bottom-left) — continuous-time spectrum: yellow `Rectangle` passband patch, dotted lines at ±fs, blue stems at ±fo (`ln4_dot`/`ln4_stem` and `ln4c_dot`/`ln4c_stem`).
- `ax3` (bottom-centre) — discrete-time spectrum: yellow passband patch, blue in-band stems at ±R, red alias-copy stems at ±1±R and ±2±R.
- `ax6` (bottom-right) — output CT spectrum; background turns pink when aliasing; stems change colour (blue → magenta → red) for normal / Nyquist / aliasing states; "A L I A S I N G !" text appears in `ax5` when `Fo > Fs/2`.

**Controls** (below canvas): a single `QHBoxLayout` row with a **Rad/s** radio button, fo slider+editbox, phase editbox, **Radian** radio button, and fs slider+editbox. A `QLabel` row above shows the current fo, phase, and fs values in bold.

**State flags**: `wflag` (False = Hz, True = rad/s for CT axes) and `what_flag` (True = show ω̂ = 2π·fo/fs labels in DT spectrum, False = show f = fo/fs). Both are toggled by the radio buttons and mirrored to menu checkboxes under **Plot Options**.

**Key helpers** (module-level, no Qt dependency):
- `_phase_info(Fo, Fs, phase)` — computes the aliased output frequency `FoNm = Fo − Fs` when `Fo > Fs/2`, and the output amplitude/phase for the special cases at ω̂ = 0 (DC) and ω̂ = π (Nyquist).
- `_Xsp(Fo, Fs, phase)` — returns stem height: `|cos(phase)|` at DC/Nyquist, `0.5` otherwise.
- `_make_stem_artists` / `_update_stem` — zigzag `Line2D` + marker dot approach (same as other demos; no `ax.stem()` call).
- `_input_label` / `_output_label` — build mathtext strings for the signal formulas shown above each panel.

**Spectrum patch update**: the yellow passband uses `matplotlib.patches.Rectangle` (not `axvspan`) so `patch.set_x()` / `patch.set_width()` can update it in place when `Fs` changes.

**Drag interaction**: pressing in `ax4` near either stem (tolerance = 10% of x-axis range) starts a drag; `_on_motion` reads `abs(xdata)`, rounds to nearest 0.1 Hz, clamps to `[0, 1.49·Fs]`, and calls `_update_all()`.

**Menu**: **Plot Options** → Show All Plots (hides/shows ax5 and ax6), Show Lower Frequency Signal, Show Radian Frequency, Show Discrete Radian Frequency.

## Porting Convention

When porting a MATLAB demo to Python, mirror the original `.m` file's behavior closely. Place the new `.py` file at root directory (e.g., `./sindrill.py`). Keep all logic in a single file; do not create packages or helper modules.
