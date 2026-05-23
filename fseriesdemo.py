#!/usr/bin/env python3
"""
FSeriesDemo — Fourier Series Demo

Illustrates how a periodic signal is built up from its complex exponential
Fourier series coefficients  c_k = (1/T)∫ x(t) e^{−j2πkf₀t} dt.

The partial sum  x̂(t) = Σ_{n=−N}^{N} c_n e^{j2πnf₀t}  is updated live as
the number of coefficients N (0–15) changes via slider or edit box.

Seven signal types with analytical coefficients are available:
  · Square wave
  · Triangle wave
  · Ramp / Sawtooth
  · Full-wave rectified Sine
  · Full-wave rectified Cosine
  · Half-wave rectified Sine
  · Half-wave rectified Cosine

Three vertically stacked panels update simultaneously:
  · Waveform — original signal (black) and partial-sum reconstruction (red),
               or the error signal (blue) when "Show Error" is checked.
  · Magnitude spectrum — |c_k| as stem plot.
  · Phase spectrum     — ∠c_k as stem plot; hovering highlights the nearest stem.

The period slider sets T ∈ [5, 25] s; the "coeff / freq" toggle relabels the
spectrum x-axis from integer k to k·f₀ (Hz) without recomputing.

Original MATLAB GUI by Dr. James H. McClellan et al. (Georgia Tech, 1994–2021).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QSlider, QComboBox, QCheckBox, QLineEdit, QSizePolicy,
    QInputDialog,
)
from PyQt6.QtCore import Qt

# ── Signal generators ──────────────────────────────────────────────────────────

def sqar(t):
    """50% duty-cycle square wave; t is already 2π·freq·timeaxis."""
    return 2.0 * (np.mod(t, 2 * np.pi) < np.pi).astype(float) - 1.0


def make_triangle(timeaxis, freq):
    """Even triangle wave peaking at t=0, as in tri.m + defaultplots.m."""
    t_pos = timeaxis[timeaxis >= 0]
    Ns = len(t_pos)
    n = np.arange(Ns, dtype=float)
    T_arg = 10.0 / freq          # period parameter passed to tri()
    yp = -1.0 + 4.0 * np.abs(np.round(n / T_arg) - n / T_arg)
    return -np.concatenate([np.flip(yp[1:]), yp])


def make_ramp(timeaxis, freq):
    """Odd sawtooth wave, zero at t=0."""
    T = 1.0 / freq
    tp = timeaxis[timeaxis >= 0]
    yp = (np.mod(tp + T / 2.0, T) - T / 2.0) / T * 2.0
    return np.concatenate([-np.flip(yp[1:]), yp])


def fullwave(t, T, kind):
    return np.abs(np.sin(np.pi / T * t) if kind == 'sine' else np.cos(np.pi / T * t))


def halfwave(t, T, kind):
    y = np.sin(2 * np.pi / T * t) if kind == 'sine' else np.cos(2 * np.pi / T * t)
    return np.maximum(y, 0.0)


# ── Fourier coefficients ───────────────────────────────────────────────────────

def fourier_coeff(sig_idx, n):
    """Return complex Fourier coefficient c_n for signal type sig_idx (0-based)."""
    if sig_idx == 0:                           # Square
        return 0j if (n == 0 or n % 2 == 0) else -2j / (n * np.pi)

    elif sig_idx == 1:                         # Triangle
        return 0j if (n == 0 or n % 2 == 0) else 4.0 / (n * np.pi) ** 2

    elif sig_idx == 2:                         # Ramp / Sawtooth
        return 0j if n == 0 else ((-1) ** n) * 1j / (n * np.pi)

    elif sig_idx == 3:                         # Full-wave rectified Sine
        ck = -2.0 / (np.pi * (4 * n ** 2 - 1))
        return (1 + 1j * 1e-8) * ck if n < 0 else complex(ck)

    elif sig_idx == 4:                         # Full-wave rectified Cosine
        ck = 2.0 * np.cos(n * np.pi) / (np.pi * (1 - 4 * n ** 2))
        return (1 + 1j * 1e-8) * ck if n < 0 else complex(ck)

    elif sig_idx == 5:                         # Half-wave rectified Sine
        base = _halfwave_cosine_coeff(n)
        return np.exp(-1j * n * np.pi / 2) * base

    else:                                      # Half-wave rectified Cosine (sig_idx == 6)
        ck = _halfwave_cosine_coeff(n)
        return (1 + 1j * 1e-8) * ck if n < 0 else complex(ck)


def _halfwave_cosine_coeff(n):
    if n == 0:
        return 1.0 / np.pi
    if abs(n) == 1:
        return 0.25
    return np.cos(n * np.pi / 2) / np.pi / (1 - n ** 2)


# magnitude y-limit per signal type
_YLIM_MAG = [0.78, 0.50, 0.40, 0.77, 0.77, 0.41, 0.41]

_SIGNAL_NAMES = [
    'Square',
    'Triangle',
    'Ramp or Sawtooth',
    'Full-Wave Rectified Sine',
    'Full-Wave Rectified Cosine',
    'Half-Wave Rectified Sine',
    'Half-Wave Rectified Cosine',
]

# DC text position in waveform data coords when k=0
_DC_POS = {
    0: (0.4,  0.30),
    1: (9.0,  0.30),
    2: (-2.0, 0.30),
    3: (-1.0, 0.95),
    4: (4.0,  0.95),
    5: (10.0, 0.60),
    6: (10.0, 0.60),
}


# ── Main window ────────────────────────────────────────────────────────────────

class FSeriesDemo(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Fourier Series Demo v1.45')

        self._freq      = 0.10          # fundamental frequency (Hz)
        self._timeaxis  = np.arange(-30, 30.01, 0.1)
        self._num_coeff = 0             # current N (coeffs −N … N shown)
        self._sig_idx   = 0             # index into _SIGNAL_NAMES
        self._show_error = False
        self._show_freq  = False        # coeff/freq toggle
        self._line_width = 1.0

        self._build_ui()
        self._update_signal()
        self._update_plots()

    # ── UI construction ────────────────────────────────────────────────────────

    def _build_ui(self):
        self._build_menu()

        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setContentsMargins(4, 4, 4, 4)
        root.setSpacing(6)

        # --- matplotlib canvas ---
        self._fig = Figure(figsize=(7, 9), facecolor='#cccccc')
        self._canvas = FigureCanvas(self._fig)
        self._canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                   QSizePolicy.Policy.Expanding)
        gs = gridspec.GridSpec(3, 1, figure=self._fig,
                               left=0.11, right=0.97,
                               top=0.97, bottom=0.06,
                               hspace=0.50)
        self._ax_wave = self._fig.add_subplot(gs[0])
        self._ax_mag  = self._fig.add_subplot(gs[1])
        self._ax_pha  = self._fig.add_subplot(gs[2])
        self._style_axes()
        self._init_artists()
        root.addWidget(self._canvas, stretch=6)

        # --- controls panel ---
        ctrl = QWidget()
        ctrl.setMaximumWidth(270)
        cv = QVBoxLayout(ctrl)
        cv.setContentsMargins(4, 4, 4, 4)
        cv.setSpacing(8)

        cv.addWidget(self._green_label('Choose the signal type:'))
        self._sig_combo = QComboBox()
        self._sig_combo.addItems(_SIGNAL_NAMES)
        self._sig_combo.currentIndexChanged.connect(self._on_signal_change)
        cv.addWidget(self._sig_combo)

        self._lbl_period = self._green_label('Choose the Signal Period: T = 10')
        cv.addWidget(self._lbl_period)
        self._period_slider = QSlider(Qt.Orientation.Horizontal)
        self._period_slider.setRange(5, 25)
        self._period_slider.setValue(10)
        self._period_slider.setTickInterval(1)
        self._period_slider.valueChanged.connect(self._on_period_change)
        cv.addWidget(self._period_slider)

        cv.addWidget(self._green_label(
            'Choose number of Fourier coefficients\n(0–15) via slider or edit box.'))

        self._lbl_coeff = self._green_label('DC Coefficient:  k = 0')
        cv.addWidget(self._lbl_coeff)

        coeff_row = QWidget()
        ch = QHBoxLayout(coeff_row)
        ch.setContentsMargins(0, 0, 0, 0)
        self._coeff_slider = QSlider(Qt.Orientation.Horizontal)
        self._coeff_slider.setRange(0, 15)
        self._coeff_slider.setValue(0)
        self._coeff_edit = QLineEdit('0')
        self._coeff_edit.setFixedWidth(36)
        ch.addWidget(self._coeff_slider, stretch=4)
        ch.addWidget(self._coeff_edit)
        self._coeff_slider.valueChanged.connect(self._on_coeff_slider)
        self._coeff_edit.editingFinished.connect(self._on_coeff_edit)
        cv.addWidget(coeff_row)

        self._cb_error = QCheckBox('Show Error')
        self._cb_error.toggled.connect(self._on_show_error)
        cv.addWidget(self._cb_error)

        self._cb_freq = QCheckBox('coeff / freq')
        self._cb_freq.toggled.connect(self._on_freq_toggle)
        cv.addWidget(self._cb_freq)

        cv.addStretch()
        root.addWidget(ctrl, stretch=2)

        self._canvas.mpl_connect('motion_notify_event', self._on_mouse_move)
        self.resize(980, 680)

    def _build_menu(self):
        mb = self.menuBar()
        fm = mb.addMenu('&File')
        fm.addAction('&Exit', self.close)

        pm = mb.addMenu('&Plot Options')
        pm.addAction('&Set Line Width…', self._ask_line_width)

    @staticmethod
    def _green_label(text):
        lbl = QLabel(text)
        lbl.setWordWrap(True)
        lbl.setStyleSheet(
            'background:#558855; color:white; font-weight:bold; padding:3px;')
        return lbl

    # ── Axes styling ───────────────────────────────────────────────────────────

    def _style_axes(self):
        self._ax_wave.set_facecolor('white')
        self._ax_wave.set_xlim(-30, 30)
        self._ax_wave.set_ylim(-1.5, 1.5)
        self._ax_wave.set_xlabel('Time (seconds)', fontsize=8)
        self._ax_wave.set_ylabel('Amplitude', fontsize=8, fontweight='bold')
        self._ax_wave.set_title('Waveform of the signal',
                                fontsize=9, fontweight='bold', color='#336633', pad=3)
        self._ax_wave.tick_params(labelsize=8)

        self._ax_mag.set_facecolor('white')
        self._ax_mag.set_xlim(-15, 15)
        self._ax_mag.set_ylim(0, 0.78)
        self._ax_mag.set_xlabel('Number of Fourier Coefficients', fontsize=8)
        self._ax_mag.set_ylabel('Amplitude', fontsize=8, fontweight='bold')
        self._ax_mag.set_title('Magnitude spectrum',
                               fontsize=9, fontweight='bold', color='#336633', pad=3)
        self._ax_mag.tick_params(labelsize=8)

        self._ax_pha.set_facecolor('white')
        self._ax_pha.set_xlim(-15, 15)
        self._ax_pha.set_ylim(-4.7, 4.7)
        self._ax_pha.set_yticks([-np.pi, -np.pi / 2, 0, np.pi / 2, np.pi])
        self._ax_pha.set_yticklabels(
            [r'$-\pi$', r'$-\pi/2$', '0', r'$\pi/2$', r'$\pi$'], fontsize=8)
        self._ax_pha.set_xlabel('Number of Fourier Coefficients', fontsize=8)
        self._ax_pha.set_ylabel('Phase', fontsize=8, fontweight='bold')
        self._ax_pha.set_title('Phase spectrum',
                               fontsize=9, fontweight='bold', color='#336633', pad=3)
        self._ax_pha.tick_params(labelsize=8)

        k_ticks = np.arange(-15, 16, 5)
        for ax in (self._ax_mag, self._ax_pha):
            ax.set_xticks(k_ticks)
            ax.set_xticklabels([str(v) for v in k_ticks], fontsize=8)

    # ── Artist initialisation ──────────────────────────────────────────────────

    def _init_artists(self):
        t = self._timeaxis

        # Waveform panel
        self._line_orig, = self._ax_wave.plot(t, sqar(2 * np.pi * self._freq * t),
                                               'k', lw=1.0)
        self._line_rec,  = self._ax_wave.plot(t, np.zeros_like(t), 'r', lw=1.0)
        self._line_err,  = self._ax_wave.plot(t, np.zeros_like(t), 'b', lw=1.0,
                                               visible=False)
        self._dc_text = self._ax_wave.text(0, 0, 'DC\n↓', color='r',
                                            fontsize=9, visible=False)
        self._lbl_orig_txt = self._ax_wave.text(
            0.01, 0.97, 'Original Signal', color='k', fontsize=8,
            style='italic', transform=self._ax_wave.transAxes, va='top')
        self._lbl_syn_txt = self._ax_wave.text(
            0.62, 0.97, 'Synthesized Signal', color='r', fontsize=8,
            style='italic', transform=self._ax_wave.transAxes, va='top')
        self._lbl_err_txt = self._ax_wave.text(
            0.01, 0.97, 'Error Signal', color='b', fontsize=8,
            style='italic', transform=self._ax_wave.transAxes, va='top',
            visible=False)

        # Magnitude spectrum
        self._ax_mag.axhline(0, color='k', lw=0.8)
        self._mag_dots,  = self._ax_mag.plot([], [], 'bo', ms=5, mfc='b', lw=0)
        self._mag_lines, = self._ax_mag.plot([], [], 'b-', lw=1.0)
        self._mag_hi_dot,  = self._ax_mag.plot([], [], 'ro', ms=6, visible=False)
        self._mag_hi_line, = self._ax_mag.plot([], [], 'r-', lw=1.5, visible=False)
        self._mag_hi_txt   = self._ax_mag.text(0, 0, '', fontsize=8,
                                                fontweight='bold', visible=False,
                                                ha='center', va='bottom')

        # Phase spectrum
        self._ax_pha.axhline(0, color=[0.7, 0.7, 0.7], lw=1.0, ls='--')
        self._pha_dots,  = self._ax_pha.plot([], [], 'bo', ms=5, mfc='b', lw=0)
        self._pha_lines, = self._ax_pha.plot([], [], 'b-', lw=1.0)
        self._pha_hi_dot,  = self._ax_pha.plot([], [], 'ro', ms=6, visible=False)
        self._pha_hi_line, = self._ax_pha.plot([], [], 'r-', lw=1.5, visible=False)
        self._pha_hi_txt   = self._ax_pha.text(0, 0, '', fontsize=8,
                                                fontweight='bold', visible=False,
                                                ha='center', va='bottom')

    # ── Signal computation ─────────────────────────────────────────────────────

    def _compute_signal(self):
        t  = self._timeaxis
        T  = 1.0 / self._freq
        s  = self._sig_idx
        if   s == 0: return sqar(2 * np.pi * self._freq * t)
        elif s == 1: return make_triangle(t, self._freq)
        elif s == 2: return make_ramp(t, self._freq)
        elif s == 3: return fullwave(t, T, 'sine')
        elif s == 4: return fullwave(t, T, 'cosine')
        elif s == 5: return halfwave(t, T, 'sine')
        else:        return halfwave(t, T, 'cosine')

    def _compute_reconstruction(self):
        N  = self._num_coeff
        t  = self._timeaxis
        rec = np.zeros(len(t), dtype=complex)
        cks = []
        for n in range(-N, N + 1):
            ck = fourier_coeff(self._sig_idx, n)
            rec += ck * np.exp(1j * 2 * np.pi * self._freq * n * t)
            cks.append(ck)
        return np.real(rec), np.array(cks)

    def _update_signal(self):
        self._yval = self._compute_signal()

    def _update_plots(self):
        t = self._timeaxis
        rec, cks = self._compute_reconstruction()
        err = self._yval - rec

        N     = self._num_coeff
        k_idx = np.arange(-N, N + 1)
        mags  = np.abs(cks)
        phis  = np.angle(cks)
        mags[mags < np.sqrt(np.finfo(float).eps)] = 0.0

        # Waveform
        show_err = self._show_error
        self._line_orig.set_visible(not show_err)
        self._line_rec.set_visible(not show_err)
        self._line_err.set_visible(show_err)
        self._lbl_orig_txt.set_visible(not show_err)
        self._lbl_syn_txt.set_visible(not show_err)
        self._lbl_err_txt.set_visible(show_err)
        if not show_err:
            self._line_orig.set_data(t, self._yval)
            self._line_rec.set_data(t, rec)
            if N == 0:
                x0, y0 = _DC_POS[self._sig_idx]
                self._dc_text.set_position((x0, y0))
                self._dc_text.set_visible(True)
            else:
                self._dc_text.set_visible(False)
        else:
            self._line_err.set_data(t, err)
            self._dc_text.set_visible(False)

        # Magnitude spectrum
        self._ax_mag.set_ylim(0, _YLIM_MAG[self._sig_idx])
        self._set_stem(self._mag_dots, self._mag_lines, k_idx, mags)

        # Phase spectrum
        self._set_stem(self._pha_dots, self._pha_lines, k_idx, phis)

        self._update_xaxis_labels()
        self._canvas.draw_idle()

    @staticmethod
    def _set_stem(dots, lines, x, y):
        dots.set_data(x, y)
        N = len(x)
        xs = np.empty(3 * N)
        ys = np.empty(3 * N)
        xs[0::3] = x;  xs[1::3] = x;  xs[2::3] = np.nan
        ys[0::3] = 0;  ys[1::3] = y;  ys[2::3] = np.nan
        lines.set_data(xs, ys)

    def _update_xaxis_labels(self):
        k_ticks = np.arange(-15, 16, 5)
        if self._show_freq:
            labels = [f'{v * self._freq:.4g}' for v in k_ticks]
            xlabel = 'Frequency (Hz)'
        else:
            labels = [str(int(v)) for v in k_ticks]
            xlabel = 'Number of Fourier Coefficients'
        for ax in (self._ax_mag, self._ax_pha):
            ax.set_xticks(k_ticks)
            ax.set_xticklabels(labels, fontsize=7)
            ax.set_xlabel(xlabel, fontsize=8)

    # ── Qt callbacks ───────────────────────────────────────────────────────────

    def _on_signal_change(self, idx):
        self._sig_idx = idx
        self._update_signal()
        self._update_plots()

    def _on_period_change(self, val):
        self._freq = 1.0 / val
        self._lbl_period.setText(f'Choose the Signal Period: T = {val}')
        self._update_signal()
        self._update_plots()

    def _on_coeff_slider(self, val):
        self._num_coeff = val
        self._coeff_edit.blockSignals(True)
        self._coeff_edit.setText(str(val))
        self._coeff_edit.blockSignals(False)
        self._refresh_coeff_label()
        self._update_plots()

    def _on_coeff_edit(self):
        try:
            val = round(float(self._coeff_edit.text()))
        except ValueError:
            self._coeff_edit.setText(str(self._num_coeff))
            return
        val = max(0, min(15, val))
        self._num_coeff = val
        self._coeff_slider.blockSignals(True)
        self._coeff_slider.setValue(val)
        self._coeff_slider.blockSignals(False)
        self._coeff_edit.setText(str(val))
        self._refresh_coeff_label()
        self._update_plots()

    def _refresh_coeff_label(self):
        N = self._num_coeff
        if N == 0:
            self._lbl_coeff.setText('DC Coefficient:  k = 0')
        else:
            self._lbl_coeff.setText(
                f'Coefficients from k = -{N}  to  k = {N}')

    def _on_show_error(self, checked):
        self._show_error = checked
        self._update_plots()

    def _on_freq_toggle(self, checked):
        self._show_freq = checked
        self._update_xaxis_labels()
        self._canvas.draw_idle()

    def _ask_line_width(self):
        val, ok = QInputDialog.getDouble(
            self, 'Set Line Width', 'Line width (pts):',
            value=self._line_width, min=0.1, max=5.0, decimals=1)
        if ok:
            self._line_width = val
            for artist in (self._line_orig, self._line_rec, self._line_err,
                           self._mag_dots, self._mag_lines,
                           self._pha_dots, self._pha_lines):
                artist.set_linewidth(val)
            self._canvas.draw_idle()

    # ── Mouse hover ────────────────────────────────────────────────────────────

    def _on_mouse_move(self, event):
        changed = False
        if event.inaxes is self._ax_mag:
            changed = self._hover(event,
                                  self._mag_dots,
                                  self._mag_hi_dot, self._mag_hi_line,
                                  self._mag_hi_txt, is_phase=False)
            self._clear_hover(self._pha_hi_dot, self._pha_hi_line, self._pha_hi_txt)
        elif event.inaxes is self._ax_pha:
            changed = self._hover(event,
                                  self._pha_dots,
                                  self._pha_hi_dot, self._pha_hi_line,
                                  self._pha_hi_txt, is_phase=True)
            self._clear_hover(self._mag_hi_dot, self._mag_hi_line, self._mag_hi_txt)
        else:
            self._clear_hover(self._mag_hi_dot, self._mag_hi_line, self._mag_hi_txt)
            self._clear_hover(self._pha_hi_dot, self._pha_hi_line, self._pha_hi_txt)
            changed = True
        if changed:
            self._canvas.draw_idle()

    def _hover(self, event, dots, hi_dot, hi_line, hi_txt, is_phase):
        xdata = np.asarray(dots.get_xdata())
        ydata = np.asarray(dots.get_ydata())
        if len(xdata) == 0:
            return False
        dist = np.abs(xdata - event.xdata)
        idx  = int(np.argmin(dist))
        if dist[idx] > 0.45:
            self._clear_hover(hi_dot, hi_line, hi_txt)
            return True
        xv, yv = xdata[idx], ydata[idx]
        hi_dot.set_data([xv], [yv])
        hi_dot.set_visible(True)
        hi_line.set_data([xv, xv], [0, yv])
        hi_line.set_visible(True)
        label = self._format_val(yv, is_phase)
        offset = 1.1 if is_phase else 0.03
        hi_txt.set_position((xv, yv + offset))
        hi_txt.set_text(label)
        hi_txt.set_visible(True)
        return True

    @staticmethod
    def _clear_hover(dot, line, txt):
        dot.set_visible(False)
        line.set_visible(False)
        txt.set_visible(False)

    @staticmethod
    def _format_val(v, is_phase):
        if is_phase:
            eps = 1e-7
            if abs(abs(v) - np.pi) < eps:
                return r'$\pi$' if v > 0 else r'$-\pi$'
            if abs(abs(v) - np.pi / 2) < eps:
                return r'$\pi/2$' if v > 0 else r'$-\pi/2$'
        return f'{round(v * 1000) / 1000:.4g}'


# ── Entry point ────────────────────────────────────────────────────────────────

def main():
    app = QApplication(sys.argv)
    win = FSeriesDemo()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
