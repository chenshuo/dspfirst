#!/usr/bin/env python3
"""
DltiDemo — Discrete LTI System Demo

Shows how a discrete-time LTI filter transforms a cosine input
x[n] = DC + A·cos(2π·f̂·n + φ·π) into an output y[n] by multiplying
amplitude by |H(f̂)| and adding phase ∠H(f̂) to the phase of the input.

Four panels update simultaneously as the input or filter parameters change:
  · x[n]      — input signal as red stems (left)
  · |H(ω̂)|   — filter magnitude response (centre-top)
  · ∠H(ω̂)   — filter phase response (centre-bottom)
  · y[n]      — output signal as magenta stems (right)

Red markers on the magnitude and phase plots show the filter's gain and
phase shift at DC (f̂=0) and at the input frequency (f̂=Freq).

Nine filter types are available:
  · Averager (length 1–15)
  · Differencer  b_k = [0.5, −0.5]
  · Ideal Low Pass / High Pass / Band Pass (with optional phase slope)
  · FIR Hamming-windowed Low Pass / High Pass / Band Pass
  · User-defined b_k coefficients

The "Theoretical Answer" button annotates the output axes with the
closed-form expression for y[n] derived from the filter's frequency response.

Original MATLAB GUI by Dr. James H. McClellan et al. (Georgia Tech, 1994–2021).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
from scipy import signal as scipy_signal
import matplotlib
matplotlib.use('QtAgg')
import matplotlib.gridspec as gridspec
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QSlider, QLineEdit, QPushButton, QComboBox, QGroupBox,
    QSizePolicy,
)
from PyQt6.QtCore import Qt


# ── Formatting ────────────────────────────────────────────────────────────────

def _fmt(x, ndigs=3):
    if x == 0.0:
        return '0'
    return f'{x:.{ndigs}g}'


def cosine_string(Amp, Freq, Phase, DC=0.0):
    """
    Build display string for  DC + Amp·cos(Freq·π·n + Phase·π).
    Call as: cosine_string(Amp, 2*self.Freq, self.Phase, self.DC)
    """
    TOL = 1e-7
    txt_dc = ''
    if abs(DC) > TOL:
        txt_dc = _fmt(DC) + ' '
        if Amp > TOL:
            txt_dc += '+ '
    if abs(Amp) <= TOL:
        Amp = 0.0

    if abs(Amp - 1) <= TOL:    A = ''
    elif abs(Amp + 1) <= TOL:  A = '-'
    else:                       A = _fmt(Amp) + ' '

    if abs(Freq) <= TOL:        w0 = ''
    elif abs(Freq - 1) < TOL:  w0 = 'π'
    elif abs(Freq + 1) < TOL:  w0 = '-π'
    else:                       w0 = _fmt(Freq) + 'π'

    if abs(Phase) <= TOL:       ph = ''
    elif abs(Phase - 1) < TOL: ph = ' + π' if Freq != 0 else 'π'
    elif abs(Phase + 1) < TOL: ph = ' - π'
    elif Phase > 0:
        ph = (' + ' + _fmt(Phase) + 'π') if Freq != 0 else (_fmt(Phase) + 'π')
    else:
        ph = ' - ' + _fmt(-Phase) + 'π'

    ns = 'n' if Freq != 0 else ''

    if Amp != 0:
        if not w0 and not ph:
            return _fmt(DC + Amp)
        return f'{txt_dc}{A}cos({w0}{ns}{ph})'
    elif txt_dc:
        return txt_dc.strip()
    return '0'


# ── FIR filter design — port of myfir1.m ─────────────────────────────────────

def _myfir1(M, wc, fir_type='lowpass'):
    """Hamming-windowed sinc FIR.  wc ∈ [0,1] (fraction of π).  M must be even."""
    wc = np.atleast_1d(np.asarray(wc, dtype=float)).ravel()
    wcenter = None
    if wc.size == 2:
        wcenter = (wc[0] + wc[1]) / 4.0
        wc_s = (wc[1] - wc[0]) / 2.0
        fir_type = 'bandpass'
    else:
        wc_s = float(wc[0])
    if fir_type == 'high':
        wc_s = 1.0 - wc_s
    if M % 2 == 1:
        M = 2 * int(np.ceil(M / 2))
    nn = np.arange(-M // 2, M // 2 + 1, dtype=float)
    nn[nn == 0] = 1e-8
    hn = np.sin(np.pi * wc_s * nn) / (np.pi * nn)
    hn *= 0.54 + 0.46 * np.cos(2 * np.pi * nn / M)
    hn /= hn.sum()
    if fir_type[:4].lower() == 'high':
        hn *= (-1) ** np.arange(M + 1)
    elif fir_type == 'bandpass':
        k = np.arange(M + 1)
        hn = 2 * hn * np.cos(2 * np.pi * wcenter * k)
        hn /= abs(hn @ np.exp(-1j * 2 * np.pi * wcenter * k))
    return hn


def _fir_design(pop_up, freq1, bw=0.2):
    if pop_up == 6:
        return _myfir1(14, 2 * freq1)
    elif pop_up == 7:
        return _myfir1(14, 2 * freq1, 'high')
    else:  # 8 — band pass
        F1 = max(1e-3, freq1 - bw / 2)
        F2 = min(0.499, freq1 + bw / 2)
        return _myfir1(20, 2 * np.array([F1, F2]))


def _ideal_filter(pop_up, freq1, phase_shift):
    """Return (ff, HH) for ideal filter  (pop_up ∈ {3,4,5})."""
    ff = np.linspace(-0.5, 0.5, 1001)
    TOL = 1e-6
    HH = np.exp(1j * 2 * np.pi * ff * phase_shift)
    if pop_up == 3:
        HH *= np.abs(ff) <= freq1 + TOL
    elif pop_up == 4:
        HH *= np.abs(ff) >= freq1 - TOL
    else:  # 5 — band pass
        HH *= np.abs(np.abs(ff) - freq1) <= 0.1 + TOL
    return ff, HH


def _freqz(b):
    """512-pt whole-spectrum freqz → (freq ∈ [−0.5, 0.5], H fftshifted)."""
    w, H = scipy_signal.freqz(b, [1.0], worN=512, whole=True)
    return w / (2 * np.pi) - 0.5, np.fft.fftshift(H)


def _freqz_at(b, freqs_norm):
    """Evaluate H at normalised frequencies ∈ [0,1] (fraction of 2π)."""
    _, H = scipy_signal.freqz(b, [1.0], worN=2 * np.pi * np.array(freqs_norm))
    return H


# ── Stem helpers (zigzag + dots, no ax.stem()) ────────────────────────────────

def _stems_create(ax, x, y, color='b', ms=5, lw=1.5):
    N = len(x)
    zx, zy = np.empty(3 * N), np.empty(3 * N)
    zx[0::3] = x; zx[1::3] = x; zx[2::3] = np.nan
    zy[0::3] = 0; zy[1::3] = y; zy[2::3] = np.nan
    dots, = ax.plot(x, y, 'o', color=color, markerfacecolor=color,
                    markersize=ms, linestyle='none', zorder=3)
    zigz, = ax.plot(zx, zy, color=color, linewidth=lw, zorder=2)
    return dots, zigz


def _stems_update(dots, zigz, x, y):
    N = len(x)
    zx, zy = np.empty(3 * N), np.empty(3 * N)
    zx[0::3] = x; zx[1::3] = x; zx[2::3] = np.nan
    zy[0::3] = 0; zy[1::3] = y; zy[2::3] = np.nan
    dots.set_data(x, y)
    zigz.set_data(zx, zy)


# ── Main window ───────────────────────────────────────────────────────────────

FILTERS = [
    'Averager',
    'Differencer',
    'Ideal Low Pass',
    'Ideal High Pass',
    'Ideal Band Pass',
    'FIR Low Pass',
    'FIR High Pass',
    'FIR Band Pass',
    'User-defined b_k',
]

_IN_STYLE = 'background:#3a003a; color:white; border:1px solid #888; border-radius:4px; padding-top:14px;'
_FL_STYLE = 'background:#00003a; color:white; border:1px solid #888; border-radius:4px; padding-top:14px;'
_GB_TITLE = 'QGroupBox::title{color:white; subcontrol-origin:margin; left:6px;}'
_LBL_STYLE = 'color:white; font-weight:bold; font-size:10px;'
_EDT_STYLE = 'background:white; font-size:10px;'


class DltiDemo(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Discrete LTI System Demo')

        # ── Signal state ──────────────────────────────────────────────────
        self.Amp   = 1.0       # ∈ [0, 4]
        self.DC    = 0.0       # ∈ [−2, 2]
        self.Freq  = 0.1       # ω̂ ∈ [0, 1.5] (normalised, × 2π gives angular freq)
        self.Phase = 0.0       # ∈ [−1, 2], units of π
        self.n     = np.arange(-5, 31)

        # ── Filter state ──────────────────────────────────────────────────
        self.pop_up     = 1        # 1-indexed (1=Averager … 9=User)
        self.filt_freq1 = 0.2
        self.filt_phase = 0.0
        self.filt_bw    = 0.2
        self.avg_len    = 3
        self.bk_str     = '[1,1,1,1]/4'
        self.imp_resp   = np.ones(3) / 3

        # Cached frequency response (None → stale)
        self._ffreq = None   # [-0.5, 0.5] array
        self._fH    = None   # complex array (fftshifted)

        # ── Filter slider limits (init before build to avoid race) ────────
        self._ff_lo    = 1.0
        self._ff_hi    = 15.0
        self._ff_steps = 14
        self._ff_int   = True   # integer mode (averager)
        self._ff_last  = float(self.avg_len)

        # ── Output ────────────────────────────────────────────────────────
        self.out_mag   = 0.0
        self.out_phase = 0.0
        self.out_dc    = 0.0

        self._build_ui()
        self._compute_filter()
        self._update_plots()

    # ════════════════════════════════════════════════════════════════════════
    # UI construction
    # ════════════════════════════════════════════════════════════════════════

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        root = QVBoxLayout(central)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(4)

        # ── Figure ────────────────────────────────────────────────────────
        self.fig = Figure(figsize=(12, 4.8))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        root.addWidget(self.canvas, stretch=1)

        gs = gridspec.GridSpec(2, 3, figure=self.fig,
                               width_ratios=[3, 4, 3], height_ratios=[1, 1],
                               hspace=0.70, wspace=0.40,
                               left=0.07, right=0.97, top=0.91, bottom=0.11)
        self.ax_in    = self.fig.add_subplot(gs[:, 0])
        self.ax_mag   = self.fig.add_subplot(gs[0, 1])
        self.ax_phase = self.fig.add_subplot(gs[1, 1])
        self.ax_out   = self.fig.add_subplot(gs[:, 2])
        self._init_axes()

        # ── Control strip ─────────────────────────────────────────────────
        ctrl = QWidget()
        ctrl.setMaximumHeight(190)
        row = QHBoxLayout(ctrl)
        row.setContentsMargins(4, 2, 4, 2)
        row.setSpacing(8)

        row.addWidget(self._build_input_panel())
        row.addStretch()

        ans = QPushButton('Theoretical\nAnswer')
        ans.setFixedSize(110, 48)
        ans.setStyleSheet('font-weight:bold; font-size:11px;')
        ans.clicked.connect(self._on_answer)
        row.addWidget(ans, alignment=Qt.AlignmentFlag.AlignVCenter)

        row.addStretch()
        row.addWidget(self._build_filter_panel())
        root.addWidget(ctrl)

        # ── Menu bar ──────────────────────────────────────────────────────
        po = self.menuBar().addMenu('&Plot Options')
        po.addAction('Set &Line Width…')
        self.menuBar().addMenu('&Help')

        self.resize(1150, 730)

    # ── Axes ──────────────────────────────────────────────────────────────

    def _init_axes(self):
        XTKS = np.arange(-0.5, 0.501, 0.05)
        def _xlbl(v):
            if abs(v + 0.5) < 1e-9:  return '-π'
            if abs(v + 0.25) < 1e-9: return '-π/2'
            if abs(v) < 1e-9:         return '0'
            if abs(v - 0.25) < 1e-9: return 'π/2'
            if abs(v - 0.5) < 1e-9:  return 'π'
            return ''
        XLBL = [_xlbl(v) for v in XTKS]

        for ax, col in ((self.ax_in, 'r'), (self.ax_out, 'm')):
            ax.set_xlim(-5, 30); ax.set_ylim(-5, 5)
            ax.set_yticks([-5, -2.5, 0, 2.5, 5])
            ax.set_xlabel('n', fontsize=8)
            ax.set_ylabel('Amplitude', fontsize=8)
            ax.grid(True, alpha=0.4)
            ax.axhline(0, color='k', lw=0.5)
            ax.axvline(0, color=col, lw=0.9, linestyle='--', alpha=0.6)

        for ax, title, ylabel, ylim, ytks in [
            (self.ax_mag,   'Magnitude of Filter',  '|H(ω̂)|',   (0, 1.1),    None),
            (self.ax_phase, 'Phase of Filter',       '∠H  (rad)', (-3.5, 3.5), range(-3, 4)),
        ]:
            ax.set_xlim(-0.5, 0.5); ax.set_ylim(*ylim)
            ax.set_xticks(XTKS); ax.set_xticklabels(XLBL, fontsize=7)
            ax.set_title(title, fontsize=9, fontweight='bold', pad=2)
            ax.set_xlabel('ω̂  (normalised, ×2π)', fontsize=8)
            ax.set_ylabel(ylabel, fontsize=8)
            ax.grid(True, alpha=0.4)
            if ytks is not None:
                ax.set_yticks(list(ytks))

        # Artist handles (created lazily on first _update_plots)
        self._in_dots = self._in_zig = None
        self._out_dots = self._out_zig = None
        self._mag_line = self._phs_line = None
        self._mk0_mag = self._mk0_phs = None
        self._mk1_mag = self._mk2_mag = self._mk1_phs = None

    # ── Input signal panel ────────────────────────────────────────────────

    def _build_input_panel(self):
        gb = QGroupBox('Input Signal')
        gb.setStyleSheet(f'QGroupBox{{{_IN_STYLE}}} {_GB_TITLE}')
        vb = QVBoxLayout(gb)
        vb.setSpacing(1); vb.setContentsMargins(6, 2, 6, 4)

        def mk(text, lo, hi, val, steps=400):
            lbl = QLabel(text); lbl.setStyleSheet(_LBL_STYLE)
            sl = QSlider(Qt.Orientation.Horizontal)
            sl.setRange(0, steps)
            sl.setValue(round((val - lo) / (hi - lo) * steps))
            ed = QLineEdit(_fmt(val))
            ed.setFixedWidth(54); ed.setStyleSheet(_EDT_STYLE)
            h = QHBoxLayout()
            h.setContentsMargins(0, 0, 0, 0); h.setSpacing(3)
            h.addWidget(sl, 1); h.addWidget(ed)
            vb.addWidget(lbl); vb.addLayout(h)
            return lbl, sl, ed

        self.lbl_amp,   self.sl_amp,   self.ed_amp   = mk(self._amp_lbl(),   0,  4,   1.0)
        self.lbl_freq,  self.sl_freq,  self.ed_freq  = mk(self._freq_lbl(),  0,  1.5, 0.1)
        self.lbl_phase, self.sl_phase, self.ed_phase = mk(self._phase_lbl(), -1, 2,   0.0)
        self.lbl_dc,    self.sl_dc,    self.ed_dc    = mk(self._dc_lbl(),    -2, 2,   0.0)

        # Slider → value (slider range is 0..steps over [lo, hi])
        for sl, lo, hi, fn in [
            (self.sl_amp,   0,  4,   self._apply_amp),
            (self.sl_freq,  0,  1.5, self._apply_freq),
            (self.sl_phase, -1, 2,   self._apply_phase),
            (self.sl_dc,    -2, 2,   self._apply_dc),
        ]:
            steps = sl.maximum()
            sl.valueChanged.connect(
                lambda v, L=lo, H=hi, S=steps, f=fn: f(L + (H - L) * v / S, from_slider=True))

        # Edit → value
        for ed, lo, hi, fn, cur in [
            (self.ed_amp,   0,  4,   self._apply_amp,   self.Amp),
            (self.ed_freq,  0,  1.5, self._apply_freq,  self.Freq),
            (self.ed_phase, -1, 2,   self._apply_phase, self.Phase),
            (self.ed_dc,    -2, 2,   self._apply_dc,    self.DC),
        ]:
            ed.returnPressed.connect(
                lambda e=ed, L=lo, H=hi, f=fn: f(self._parse(e.text(), L, H), from_slider=False))

        return gb

    # ── Filter panel ──────────────────────────────────────────────────────

    def _build_filter_panel(self):
        gb = QGroupBox('Filter Specifications')
        gb.setStyleSheet(f'QGroupBox{{{_FL_STYLE}}} {_GB_TITLE}')
        vb = QVBoxLayout(gb)
        vb.setSpacing(1); vb.setContentsMargins(6, 2, 6, 4)

        # Filter choice row
        h_fc = QHBoxLayout()
        lfc = QLabel('Filter Choice:'); lfc.setStyleSheet(_LBL_STYLE)
        self.cb = QComboBox()
        self.cb.addItems(FILTERS); self.cb.setCurrentIndex(0)
        self.cb.setStyleSheet('background:white; font-size:10px;')
        h_fc.addWidget(lfc); h_fc.addWidget(self.cb, 1)
        vb.addLayout(h_fc)

        # Shared freq / length label + slider + edit
        self.lbl_ff = QLabel('Length = 3 pts'); self.lbl_ff.setStyleSheet(_LBL_STYLE)
        self.sl_ff  = QSlider(Qt.Orientation.Horizontal)
        self.sl_ff.setRange(0, 14); self.sl_ff.setValue(2)   # 0..14 → 1..15
        self.ed_ff  = QLineEdit('3'); self.ed_ff.setFixedWidth(54)
        self.ed_ff.setStyleSheet(_EDT_STYLE)
        hff = QHBoxLayout()
        hff.setContentsMargins(0, 0, 0, 0); hff.setSpacing(3)
        hff.addWidget(self.sl_ff, 1); hff.addWidget(self.ed_ff)
        self._hff = hff                    # kept for visibility toggling
        vb.addWidget(self.lbl_ff); vb.addLayout(hff)

        # Phase slope label + slider + edit  (ideal filters only)
        self.lbl_fp = QLabel('Phase Slope = 0'); self.lbl_fp.setStyleSheet(_LBL_STYLE)
        self.sl_fp  = QSlider(Qt.Orientation.Horizontal)
        self.sl_fp.setRange(0, 500); self.sl_fp.setValue(250)   # 0..500 → −5..5
        self.ed_fp  = QLineEdit('0'); self.ed_fp.setFixedWidth(54)
        self.ed_fp.setStyleSheet(_EDT_STYLE)
        hfp = QHBoxLayout()
        hfp.setContentsMargins(0, 0, 0, 0); hfp.setSpacing(3)
        hfp.addWidget(self.sl_fp, 1); hfp.addWidget(self.ed_fp)
        vb.addWidget(self.lbl_fp); vb.addLayout(hfp)

        # User-defined b_k edit
        self.lbl_bk = QLabel('Filter Coeffs: b_k'); self.lbl_bk.setStyleSheet(_LBL_STYLE)
        self.ed_bk  = QLineEdit(self.bk_str); self.ed_bk.setStyleSheet(_EDT_STYLE)
        vb.addWidget(self.lbl_bk); vb.addWidget(self.ed_bk)

        # Connect signals
        self.cb.currentIndexChanged.connect(self._on_filter_choice)
        self.sl_ff.valueChanged.connect(self._on_ff_slider)
        self.ed_ff.returnPressed.connect(self._on_ff_edit)
        self.sl_fp.valueChanged.connect(self._on_fp_slider)
        self.ed_fp.returnPressed.connect(self._on_fp_edit)
        self.ed_bk.returnPressed.connect(self._on_bk_edit)

        self._apply_filter_visibility()
        return gb

    def _apply_filter_visibility(self):
        p = self.pop_up
        show_ff_lbl = p in (1, 2, 3, 4, 5, 6, 7, 8)
        show_ff_sl  = p in (1, 3, 4, 5, 6, 7, 8)
        show_fp     = p in (3, 4, 5)
        show_bk     = (p == 9)

        self.lbl_ff.setVisible(show_ff_lbl)
        self.sl_ff.setVisible(show_ff_sl)
        self.ed_ff.setVisible(show_ff_sl)
        self.lbl_fp.setVisible(show_fp)
        self.sl_fp.setVisible(show_fp)
        self.ed_fp.setVisible(show_fp)
        self.lbl_bk.setVisible(show_bk)
        self.ed_bk.setVisible(show_bk)

    # ════════════════════════════════════════════════════════════════════════
    # Signal parameter handlers
    # ════════════════════════════════════════════════════════════════════════

    @staticmethod
    def _parse(text, lo, hi):
        try:
            v = float(text)
            return v if lo <= v <= hi else None
        except ValueError:
            return None

    def _apply_amp(self, v, from_slider=False):
        if v is None: return
        v = max(0.0, min(4.0, v))
        self.Amp = v
        self.lbl_amp.setText(self._amp_lbl())
        self.ed_amp.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_amp, v, 0, 4)
        self._update_plots()

    def _apply_freq(self, v, from_slider=False):
        if v is None: return
        if abs(v) <= 1e-7:      v = 0.0
        elif abs(1 - v) < 1e-7: v = 1.0
        self.Freq = v
        self.lbl_freq.setText(self._freq_lbl())
        self.ed_freq.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_freq, v, 0, 1.5)
        self._update_plots()

    def _apply_phase(self, v, from_slider=False):
        if v is None: return
        if abs(v) <= 1e-7:       v = 0.0
        elif abs(1 - v) < 1e-7:  v = 1.0
        elif abs(1 + v) < 1e-7:  v = -1.0
        self.Phase = v
        self.lbl_phase.setText(self._phase_lbl())
        self.ed_phase.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_phase, v, -1, 2)
        self._update_plots()

    def _apply_dc(self, v, from_slider=False):
        if v is None: return
        if abs(v) <= 1e-7: v = 0.0
        self.DC = v
        self.lbl_dc.setText(self._dc_lbl())
        self.ed_dc.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_dc, v, -2, 2)
        self._update_plots()

    @staticmethod
    def _sync_sl(sl, v, lo, hi):
        sl.blockSignals(True)
        steps = sl.maximum()
        sl.setValue(int(round(max(0, min(steps, (v - lo) / (hi - lo) * steps)))))
        sl.blockSignals(False)

    # ════════════════════════════════════════════════════════════════════════
    # Filter parameter handlers
    # ════════════════════════════════════════════════════════════════════════

    def _on_filter_choice(self, idx):
        self.pop_up = idx + 1
        self._fH = None           # invalidate FFT cache
        p = self.pop_up

        if p == 1:                # Averager
            self._configure_ff_slider(1, 15, self.avg_len, integer=True)
            self.lbl_ff.setText(f'Length = {self.avg_len} pts')
            self.ed_ff.setText(str(self.avg_len))
            self.imp_resp = np.ones(self.avg_len) / self.avg_len
        elif p == 2:              # Differencer
            self.lbl_ff.setText('b_k = [0.5, −0.5]')
            self.imp_resp = np.array([0.5, -0.5])
        elif p in (3, 4, 5):      # Ideal LP / HP / BP
            lo, hi = (0.18, 0.38) if p == 5 else (0.01, 0.4)
            if not (lo <= self.filt_freq1 <= hi):
                self.filt_freq1 = 0.25
            self._configure_ff_slider(lo, hi, self.filt_freq1)
            lbl = 'Center Freq' if p == 5 else 'Cutoff Freq'
            self.lbl_ff.setText(f'{lbl} = 2π({_fmt(self.filt_freq1)})')
            self.ed_ff.setText(_fmt(self.filt_freq1))
            if p in (3, 4, 5):
                self._update_phase_label()
        elif p in (6, 7, 8):      # FIR LP / HP / BP
            lo, hi = (0.18, 0.38) if p == 8 else (0.01, 0.4)
            if not (lo <= self.filt_freq1 <= hi):
                self.filt_freq1 = 0.25
            self._configure_ff_slider(lo, hi, self.filt_freq1)
            lbl = 'Center Freq' if p == 8 else 'Cutoff Freq'
            self.lbl_ff.setText(f'{lbl} = 2π({_fmt(self.filt_freq1)})')
            self.ed_ff.setText(_fmt(self.filt_freq1))
            self.imp_resp = _fir_design(p, self.filt_freq1, self.filt_bw)
        elif p == 9:              # User-defined
            self._apply_bk_str(self.bk_str, update_plots=False)

        self._apply_filter_visibility()
        self._compute_filter()
        self._update_plots()

    def _configure_ff_slider(self, lo, hi, val, integer=False):
        steps = int(hi - lo) if integer else 400
        self._ff_lo = lo; self._ff_hi = hi
        self._ff_steps = steps; self._ff_int = integer
        self._ff_last = val
        self.sl_ff.blockSignals(True)
        self.sl_ff.setRange(0, steps)
        self.sl_ff.setValue(int(round((val - lo) / (hi - lo) * steps)))
        self.sl_ff.blockSignals(False)

    def _on_ff_slider(self, v):
        val = self._ff_lo + (self._ff_hi - self._ff_lo) * v / self._ff_steps
        if self._ff_int:
            val = float(int(round(val)))
        self._apply_ff(val)

    def _on_ff_edit(self):
        try:
            v = float(self.ed_ff.text())
        except ValueError:
            return
        if not (self._ff_lo <= v <= self._ff_hi):
            self.ed_ff.setText(_fmt(self._ff_last))
            return
        self._apply_ff(v)
        self._sync_sl_raw(self.sl_ff, v, self._ff_lo, self._ff_hi, self._ff_steps)

    def _apply_ff(self, v):
        p = self.pop_up
        self._ff_last = v
        self._fH = None
        if p == 1:
            self.avg_len = max(1, int(round(v)))
            self.lbl_ff.setText(f'Length = {self.avg_len} pts')
            self.ed_ff.setText(str(self.avg_len))
            self.imp_resp = np.ones(self.avg_len) / self.avg_len
        elif p in (3, 4, 5):
            if abs(v) <= 1e-10: v = 0.0
            self.filt_freq1 = v
            lbl = 'Center Freq' if p == 5 else 'Cutoff Freq'
            self.lbl_ff.setText(f'{lbl} = 2π({_fmt(v)})')
            self.ed_ff.setText(_fmt(v))
        elif p in (6, 7, 8):
            if abs(v) <= 1e-10: v = 0.0
            self.filt_freq1 = v
            lbl = 'Center Freq' if p == 8 else 'Cutoff Freq'
            self.lbl_ff.setText(f'{lbl} = 2π({_fmt(v)})')
            self.ed_ff.setText(_fmt(v))
            self.imp_resp = _fir_design(p, v, self.filt_bw)
        self._compute_filter()
        self._update_plots()

    def _on_fp_slider(self, v):
        val = -5 + 10.0 * v / 500
        self._apply_fp(val, from_slider=True)

    def _on_fp_edit(self):
        try:
            v = float(self.ed_fp.text())
        except ValueError:
            return
        if not (-5 <= v <= 5):
            self.ed_fp.setText(_fmt(self.filt_phase))
            return
        self._apply_fp(v, from_slider=False)

    def _apply_fp(self, v, from_slider=False):
        if abs(v) <= 1e-10: v = 0.0
        self.filt_phase = v
        self._update_phase_label()
        self.ed_fp.setText(_fmt(v))
        if not from_slider:
            self._sync_sl_raw(self.sl_fp, v, -5, 5, 500)
        self._fH = None
        self._compute_filter()
        self._update_plots()

    def _update_phase_label(self):
        v = self.filt_phase
        if abs(v) < 1e-7:          self.lbl_fp.setText('Phase Slope = 0')
        elif abs(v - 1) < 1e-7:    self.lbl_fp.setText('Phase Slope = 1')
        elif abs(v + 1) < 1e-7:    self.lbl_fp.setText('Phase Slope = -1')
        else:                       self.lbl_fp.setText(f'Phase Slope = {_fmt(v)}')

    def _on_bk_edit(self):
        self._apply_bk_str(self.ed_bk.text())

    def _apply_bk_str(self, s, update_plots=True):
        try:
            b = np.atleast_1d(eval(s, {'__builtins__': {}}, {})).ravel()
            if b.ndim != 1 or b.size == 0:
                raise ValueError
        except Exception:
            self.ed_bk.setText(self.bk_str)
            return
        self.bk_str = s
        self.imp_resp = b.astype(float)
        self._fH = None
        if update_plots:
            self._compute_filter()
            self._update_plots()

    @staticmethod
    def _sync_sl_raw(sl, v, lo, hi, steps):
        sl.blockSignals(True)
        sl.setValue(int(round(max(0, min(steps, (v - lo) / (hi - lo) * steps)))))
        sl.blockSignals(False)

    # ════════════════════════════════════════════════════════════════════════
    # Filter response computation
    # ════════════════════════════════════════════════════════════════════════

    def _compute_filter(self):
        p = self.pop_up
        if self._fH is None:
            if p in (3, 4, 5):
                self._ffreq, self._fH = _ideal_filter(p, self.filt_freq1, self.filt_phase)
            else:
                self._ffreq, self._fH = _freqz(self.imp_resp)

    # ════════════════════════════════════════════════════════════════════════
    # Plot update
    # ════════════════════════════════════════════════════════════════════════

    def _update_plots(self):
        n = self.n

        # Fold Freq into (−∞, 0.5) to find aliased bin
        Freqmod = self.Freq
        while Freqmod >= 0.5:
            Freqmod -= 1.0

        # ── Input signal ─────────────────────────────────────────────────
        x_in = self.DC + self.Amp * np.cos(2 * np.pi * self.Freq * n + self.Phase * np.pi)
        if self._in_dots is None:
            self._in_dots, self._in_zig = _stems_create(self.ax_in, n, x_in, 'r')
        else:
            _stems_update(self._in_dots, self._in_zig, n, x_in)
        self.ax_in.set_title(f'x[n] = {cosine_string(self.Amp, 2*self.Freq, self.Phase, self.DC)}',
                             fontsize=8, pad=2)

        # ── Filter magnitude & phase ──────────────────────────────────────
        ff   = self._ffreq
        fmag = np.abs(self._fH)
        fphs = np.angle(self._fH)

        if self._mag_line is None:
            self._mag_line, = self.ax_mag.plot(ff, fmag, 'b', lw=1.5)
            self._phs_line, = self.ax_phase.plot(ff, fphs, 'b', lw=1.5)
        else:
            self._mag_line.set_data(ff, fmag)
            self._phs_line.set_data(ff, fphs)

        Hmax = fmag.max()
        self.ax_mag.set_ylim(0, max(1.0, np.ceil(Hmax - 0.05)) + 0.1)

        # ── Output ───────────────────────────────────────────────────────
        p = self.pop_up
        if p in (3, 4, 5):           # Ideal: nearest-bin lookup
            k0   = int(np.argmin(np.abs(ff)))
            kMag = int(np.argmin(np.abs(ff - Freqmod)))
            self.out_mag   = fmag[kMag] * self.Amp
            self.out_phase = fphs[kMag] / np.pi + self.Phase
            self.out_dc    = np.real(self._fH[k0]) * self.DC
            FM0 = fmag[k0]; FP0 = fphs[k0]
            FM1 = fmag[kMag]; FP1 = fphs[kMag] * (FM1 > 1e-6)
        else:                         # FIR / Averager / Differencer: evaluate at freq
            HHH = _freqz_at(self.imp_resp, [0.0, self.Freq, -self.Freq])
            self.out_mag   = abs(HHH[1]) * self.Amp
            self.out_phase = np.angle(HHH[1]) / np.pi + self.Phase
            self.out_dc    = np.real(HHH[0]) * self.DC
            FM0 = abs(HHH[0]); FP0 = np.angle(HHH[0])
            FM1 = abs(HHH[1]); FP1 = np.angle(HHH[1]) * (FM1 > 1e-6)

        x_out = (self.out_dc
                 + self.out_mag * np.cos(2 * np.pi * self.Freq * n + self.out_phase * np.pi))
        if self._out_dots is None:
            self._out_dots, self._out_zig = _stems_create(self.ax_out, n, x_out, 'm')
        else:
            _stems_update(self._out_dots, self._out_zig, n, x_out)
        self.ax_out.set_title('y[n]', fontsize=8, pad=2)

        # ── Frequency markers (red dots on mag + phase plots) ─────────────
        if self._mk0_mag is None:
            kw = dict(color='r', marker='o', markerfacecolor='r',
                      markersize=7, linestyle='none', zorder=5)
            self._mk0_mag, = self.ax_mag.plot(  [0],        [FM0], **kw)
            self._mk0_phs, = self.ax_phase.plot([0],        [FP0], **kw)
            self._mk1_mag, = self.ax_mag.plot(  [Freqmod],  [FM1], **kw)
            self._mk2_mag, = self.ax_mag.plot(  [-Freqmod], [FM1], **kw)
            self._mk1_phs, = self.ax_phase.plot([Freqmod],  [FP1], **kw)
        else:
            self._mk0_mag.set_data([0],        [FM0])
            self._mk0_phs.set_data([0],        [FP0])
            self._mk1_mag.set_data([Freqmod],  [FM1])
            self._mk2_mag.set_data([-Freqmod], [FM1])
            self._mk1_phs.set_data([Freqmod],  [FP1])

        dc_vis    = self.DC != 0
        freq_zero = (Freqmod == 0 and self.DC != 0)
        self._mk0_mag.set_visible(dc_vis)
        self._mk0_phs.set_visible(dc_vis)
        self._mk1_mag.set_visible(not freq_zero)
        self._mk2_mag.set_visible(not freq_zero and abs(self.Freq) > 1e-5)
        self._mk1_phs.set_visible(not freq_zero)

        self.canvas.draw_idle()

    # ════════════════════════════════════════════════════════════════════════
    # Label text helpers
    # ════════════════════════════════════════════════════════════════════════

    def _amp_lbl(self):   return f'Amplitude = {_fmt(self.Amp)}'
    def _dc_lbl(self):    return f'DC Level = {_fmt(self.DC)}'

    def _freq_lbl(self):
        f = self.Freq
        if f == 0:  return 'Frequency = 0'
        if f == 1:  return 'Frequency = 2π'
        return f'Frequency = 2π({_fmt(f)})'

    def _phase_lbl(self):
        v = self.Phase
        if v == 0:    return 'Phase = 0'
        if v == 1:    return 'Phase = π'
        if v == -1:   return 'Phase = -π'
        return f'Phase = {_fmt(v)}π'

    # ════════════════════════════════════════════════════════════════════════
    # Theoretical Answer button
    # ════════════════════════════════════════════════════════════════════════

    def _on_answer(self):
        s = cosine_string(self.out_mag, 2 * self.Freq, self.out_phase,
                          float(np.real(self.out_dc)))
        self.ax_out.set_title(f'y[n] = {s}', fontsize=8, pad=2)
        self.canvas.draw_idle()


# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    app = QApplication(sys.argv)
    w = DltiDemo()
    w.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
