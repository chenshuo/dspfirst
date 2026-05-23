#!/usr/bin/env python3
"""
CltiDemo — Continuous LTI System Demo

Shows how a continuous-time LTI filter transforms a cosine input
x(t) = DC + A·cos(2π·f·t + φ·π) into an output y(t) by multiplying
amplitude by |H(f)| and adding phase ∠H(f) to the phase of the input.

Four panels update simultaneously as the input or filter parameters change:
  · x(t)    — input signal as a red line (left)
  · |H(f)|  — filter magnitude response, 0–200 Hz (centre-top)
  · ∠H(f)  — filter phase response, 0–200 Hz (centre-bottom)
  · y(t)    — output signal as a magenta line (right)

Red markers on the magnitude and phase plots show the filter's gain and
phase shift at DC (f=0) and at the input frequency.

Eight filter types are available:
  · Ideal Low Pass / High Pass / Band Pass / Band Reject
    (with optional phase-slope delay ∈ [−1, 1] s)
  · First-order Low Pass / High Pass  H(f) = 1/(1+jf/fc) or (jf/fc)/(1+jf/fc)
  · First-order Band Pass / Band Reject  with adjustable bandwidth ∈ [10, 50] Hz

The "Theoretical Answer" button annotates the output axes with the
closed-form expression for y(t) derived from the filter's frequency response.

Original MATLAB GUI by Dr. James H. McClellan et al. (Georgia Tech, 1994–2021).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
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


# ── Formatting ─────────────────────────────────────────────────────────────────

def _fmt(x, ndigs=3):
    if x == 0.0:
        return '0'
    return f'{x:.{ndigs}g}'


def cosine_string_ct(Amp, Freq, Phase, DC=0.0):
    """
    Build display string for  DC + Amp·cos(2π·Freq·t + Phase·π).
    Freq is in Hz; for Freq=20 the string shows 'cos(40πt)'.
    Mirrors cosinestring.m from spfirst/cltidemo/private/.
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

    w0 = Freq
    if abs(w0) <= TOL:
        w0_str = ''; t_str = ''
    elif abs(w0 - 1) < TOL:
        w0_str = 'π'; t_str = 't'
    elif abs(w0 + 1) < TOL:
        w0_str = '-π'; t_str = 't'
    elif w0 > 0:
        w0_str = f'{_fmt(2*w0)}π'; t_str = 't'   # "40π" for Freq=20
    else:
        w0_str = f'{_fmt(-2*w0)}-2π'; t_str = 't'

    if abs(Phase) <= TOL:       ph = ''
    elif abs(Phase - 1) < TOL: ph = ' + π' if w0 != 0 else 'π'
    elif abs(Phase + 1) < TOL: ph = ' - π'
    elif Phase > 0:
        ph = (' + ' + _fmt(Phase) + 'π') if w0 != 0 else (_fmt(Phase) + 'π')
    else:
        ph = ' - ' + _fmt(-Phase) + 'π'

    if Amp != 0:
        if not w0_str and not ph:
            return _fmt(DC + Amp)
        return f'{txt_dc}{A}cos({w0_str}{t_str}{ph})'
    elif txt_dc:
        return txt_dc.strip()
    return '0'


# ── CT first-order filter (port of ctfirstorderfilter.m) ──────────────────────

def ct_filter(filter_type, cutoff, bandwidth, freqs=None):
    """
    Evaluate a continuous-time first-order filter.
    filter_type: 'Lowpass' | 'Highpass' | 'Bandpass' | 'Bandreject'
    freqs: evaluation frequencies in Hz; if None uses linspace(0, 200, 1001).
    Returns (f, H) arrays.
    """
    if freqs is None:
        f = np.linspace(0, 200, 1001)
    else:
        f = np.asarray(freqs, dtype=float)
    fc = float(cutoff)
    bw = float(bandwidth)
    if filter_type == 'Lowpass':
        H = 1.0 / (1 + 1j * f / fc)
    elif filter_type == 'Highpass':
        H = (1j * f / fc) / (1 + 1j * f / fc)
    elif filter_type == 'Bandpass':
        H = (1j * f * bw) / (fc**2 - f**2 + 1j * f * bw)
    elif filter_type == 'Bandreject':
        H = (fc**2 - f**2) / (fc**2 - f**2 + 1j * f * bw)
    else:
        raise ValueError(f'Unknown filter type: {filter_type}')
    return f, H


# ── Ideal CT filter (port of IdealFilter subfunction in cltidemo.m) ───────────

def ideal_filter_ct(pop_up, freq1, phase_shift):
    """
    Compute ideal CT filter response.
    pop_up: 1=LP, 2=HP, 3=BP (fixed bw=20 Hz), 4=BR (fixed bw=20 Hz).
    freq1 in Hz; phase_shift in seconds (multiplies 2πf).
    Returns (ff [0..200 Hz, 1001 pts], HH complex).
    """
    ff = np.linspace(0, 200, 1001)
    TOL = 1e-6
    bw = 20.0
    HH = np.exp(1j * 2 * np.pi * ff * phase_shift)
    if pop_up == 1:
        HH = HH * (np.abs(ff) <= freq1 + TOL)
    elif pop_up == 2:
        HH = HH * (np.abs(ff) >= freq1 - TOL)
    elif pop_up == 3:
        HH = HH * (np.abs(np.abs(ff) - freq1) <= bw / 2 + TOL)
    elif pop_up == 4:
        HH = HH * (np.abs(np.abs(ff) - freq1) >= bw / 2 + TOL)
    return ff, HH


# ── Main window ───────────────────────────────────────────────────────────────

FILTERS = [
    'Ideal Low Pass',
    'Ideal High Pass',
    'Ideal Band Pass',
    'Ideal Band Reject',
    'First-order Low Pass',
    'First-order High Pass',
    'First-order Band Pass',
    'First-order Band Reject',
]

_FTYPE = ['Lowpass', 'Highpass', 'Bandpass', 'Bandreject']   # index by pop_up-5

_IN_STYLE = 'background:#3a003a; color:white; border:1px solid #888; border-radius:4px; padding-top:14px;'
_FL_STYLE = 'background:#00003a; color:white; border:1px solid #888; border-radius:4px; padding-top:14px;'
_GB_TITLE = 'QGroupBox::title{color:white; subcontrol-origin:margin; left:6px;}'
_LBL_STYLE = 'color:white; font-weight:bold; font-size:10px;'
_EDT_STYLE = 'background:white; font-size:10px;'


class CltiDemo(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Continuous LTI System Demo')

        # Fixed display time axis: −0.1 to 0.1 s, 2001 points (10 kHz effective)
        self.t = np.linspace(-0.1, 0.1, 2001)

        # ── Signal state ──────────────────────────────────────────────────
        self.Amp   = 1.0    # ∈ [0, 4]
        self.DC    = 0.0    # ∈ [−2, 2]
        self.Freq  = 20.0   # Hz ∈ [10, 100]
        self.Phase = 0.0    # ∈ [−1, 2], units of π

        # ── Filter state ──────────────────────────────────────────────────
        self.pop_up     = 5      # 1-indexed default: First-order Low Pass
        self.filt_freq1 = 10.0   # Hz, cutoff / center frequency
        self.filt_phase = 0.0    # phase slope (seconds) ∈ [−1, 1]
        self.filt_bw    = 20.0   # Hz bandwidth for 1st-order BP/BR ∈ [10, 50]

        # Cached filter response (None = stale, must recompute)
        self._ffreq = None
        self._fH    = None

        # Filter freq slider state (must init before _build_ui to avoid race)
        self._ff_lo    = 10.0
        self._ff_hi    = 100.0
        self._ff_steps = 400
        self._ff_last  = 10.0

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
        ctrl.setMaximumHeight(210)
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
        for ax, col in ((self.ax_in, 'r'), (self.ax_out, 'm')):
            ax.set_xlim(-0.1, 0.1)
            ax.set_ylim(-5, 5)
            ax.set_yticks([-5, -2.5, 0, 2.5, 5])
            ax.set_xlabel('t  (s)', fontsize=8)
            ax.set_ylabel('Amplitude', fontsize=8)
            ax.grid(True, alpha=0.4)
            ax.axhline(0, color='k', lw=0.5)
            ax.axvline(0, color=col, lw=0.9, linestyle='--', alpha=0.6)

        XTKS = [0, 20, 40, 60, 80, 100, 150, 200]
        for ax, title, ylabel, ylim, ytks in [
            (self.ax_mag,   'Magnitude of the Filter', '|H(f)|',       (0, 1.1),   None),
            (self.ax_phase, 'Phase of the Filter',     'Phase (rad)',  (-3.5, 3.5), range(-3, 4)),
        ]:
            ax.set_xlim(0, 200)
            ax.set_ylim(*ylim)
            ax.set_xticks(XTKS)
            ax.set_title(title, fontsize=9, fontweight='bold', pad=2)
            ax.set_xlabel('Frequency (Hz)', fontsize=8)
            ax.set_ylabel(ylabel, fontsize=8)
            ax.grid(True, alpha=0.4)
            if ytks is not None:
                ax.set_yticks(list(ytks))

        # Artist handles created lazily on first _update_plots call
        self._in_line = None
        self._out_line = None
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
        self.lbl_freq,  self.sl_freq,  self.ed_freq  = mk(self._freq_lbl(),  10, 100, 20.0)
        self.lbl_phase, self.sl_phase, self.ed_phase = mk(self._phase_lbl(), -1, 2,   0.0, steps=300)
        self.lbl_dc,    self.sl_dc,    self.ed_dc    = mk(self._dc_lbl(),    -2, 2,   0.0)

        for sl, lo, hi, steps, fn in [
            (self.sl_amp,   0,  4,   400, self._apply_amp),
            (self.sl_freq,  10, 100, 400, self._apply_freq),
            (self.sl_phase, -1, 2,   300, self._apply_phase),
            (self.sl_dc,    -2, 2,   400, self._apply_dc),
        ]:
            sl.valueChanged.connect(
                lambda v, L=lo, H=hi, S=steps, f=fn: f(L + (H - L) * v / S, from_slider=True))

        for ed, lo, hi, fn in [
            (self.ed_amp,   0,  4,   self._apply_amp),
            (self.ed_freq,  10, 100, self._apply_freq),
            (self.ed_phase, -1, 2,   self._apply_phase),
            (self.ed_dc,    -2, 2,   self._apply_dc),
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
        self.cb.addItems(FILTERS)
        self.cb.setCurrentIndex(self.pop_up - 1)
        self.cb.setStyleSheet('background:white; font-size:10px;')
        h_fc.addWidget(lfc); h_fc.addWidget(self.cb, 1)
        vb.addLayout(h_fc)

        # Cutoff / center frequency
        self.lbl_ff = QLabel(self._ff_lbl()); self.lbl_ff.setStyleSheet(_LBL_STYLE)
        self.sl_ff  = QSlider(Qt.Orientation.Horizontal)
        self.sl_ff.setRange(0, 400)
        self.sl_ff.setValue(int(round(
            (self.filt_freq1 - self._ff_lo) / (self._ff_hi - self._ff_lo) * 400)))
        self.ed_ff  = QLineEdit(_fmt(self.filt_freq1))
        self.ed_ff.setFixedWidth(54); self.ed_ff.setStyleSheet(_EDT_STYLE)
        hff = QHBoxLayout()
        hff.setContentsMargins(0, 0, 0, 0); hff.setSpacing(3)
        hff.addWidget(self.sl_ff, 1); hff.addWidget(self.ed_ff)
        vb.addWidget(self.lbl_ff); vb.addLayout(hff)

        # Phase slope  (ideal filters 1–4 only)
        self.lbl_fp = QLabel('Phase Slope = 0'); self.lbl_fp.setStyleSheet(_LBL_STYLE)
        self.sl_fp  = QSlider(Qt.Orientation.Horizontal)
        self.sl_fp.setRange(0, 200); self.sl_fp.setValue(100)   # 0..200 → −1..1
        self.ed_fp  = QLineEdit('0')
        self.ed_fp.setFixedWidth(54); self.ed_fp.setStyleSheet(_EDT_STYLE)
        hfp = QHBoxLayout()
        hfp.setContentsMargins(0, 0, 0, 0); hfp.setSpacing(3)
        hfp.addWidget(self.sl_fp, 1); hfp.addWidget(self.ed_fp)
        vb.addWidget(self.lbl_fp); vb.addLayout(hfp)

        # Bandwidth  (1st-order BP/BR only)
        self.lbl_bw = QLabel(f'Bandwidth = {_fmt(self.filt_bw)} Hz')
        self.lbl_bw.setStyleSheet(_LBL_STYLE)
        self.sl_bw  = QSlider(Qt.Orientation.Horizontal)
        self.sl_bw.setRange(0, 400)
        self.sl_bw.setValue(int(round((self.filt_bw - 10) / (50 - 10) * 400)))
        self.ed_bw  = QLineEdit(_fmt(self.filt_bw))
        self.ed_bw.setFixedWidth(54); self.ed_bw.setStyleSheet(_EDT_STYLE)
        hbw = QHBoxLayout()
        hbw.setContentsMargins(0, 0, 0, 0); hbw.setSpacing(3)
        hbw.addWidget(self.sl_bw, 1); hbw.addWidget(self.ed_bw)
        vb.addWidget(self.lbl_bw); vb.addLayout(hbw)

        # Connect signals
        self.cb.currentIndexChanged.connect(self._on_filter_choice)
        self.sl_ff.valueChanged.connect(self._on_ff_slider)
        self.ed_ff.returnPressed.connect(self._on_ff_edit)
        self.sl_fp.valueChanged.connect(self._on_fp_slider)
        self.ed_fp.returnPressed.connect(self._on_fp_edit)
        self.sl_bw.valueChanged.connect(self._on_bw_slider)
        self.ed_bw.returnPressed.connect(self._on_bw_edit)

        self._apply_filter_visibility()
        return gb

    def _apply_filter_visibility(self):
        p = self.pop_up
        show_phase = p in (1, 2, 3, 4)    # ideal filters
        show_bw    = p in (7, 8)           # 1st-order BP / BR
        self.lbl_fp.setVisible(show_phase)
        self.sl_fp.setVisible(show_phase)
        self.ed_fp.setVisible(show_phase)
        self.lbl_bw.setVisible(show_bw)
        self.sl_bw.setVisible(show_bw)
        self.ed_bw.setVisible(show_bw)

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
            self._sync_sl(self.sl_amp, v, 0, 4, 400)
        self._update_plots()

    def _apply_freq(self, v, from_slider=False):
        if v is None: return
        if abs(v) <= 1e-7: v = 0.0
        self.Freq = v
        self.lbl_freq.setText(self._freq_lbl())
        self.ed_freq.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_freq, v, 10, 100, 400)
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
            self._sync_sl(self.sl_phase, v, -1, 2, 300)
        self._update_plots()

    def _apply_dc(self, v, from_slider=False):
        if v is None: return
        if abs(v) <= 1e-7: v = 0.0
        self.DC = v
        self.lbl_dc.setText(self._dc_lbl())
        self.ed_dc.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_dc, v, -2, 2, 400)
        self._update_plots()

    @staticmethod
    def _sync_sl(sl, v, lo, hi, steps):
        sl.blockSignals(True)
        sl.setValue(int(round(max(0, min(steps, (v - lo) / (hi - lo) * steps)))))
        sl.blockSignals(False)

    # ════════════════════════════════════════════════════════════════════════
    # Filter parameter handlers
    # ════════════════════════════════════════════════════════════════════════

    def _on_filter_choice(self, idx):
        self.pop_up = idx + 1
        self._fH = None
        p = self.pop_up

        # Adjust freq slider range; reset freq if now out of bounds
        if p in (3, 4, 6, 7, 8):
            lo, hi = 20.0, 100.0
            if not (20.0 <= self.filt_freq1 <= 100.0):
                self.filt_freq1 = 50.0
        else:
            lo, hi = 10.0, 100.0

        self._ff_lo = lo; self._ff_hi = hi
        self._ff_last = self.filt_freq1
        self._sync_sl(self.sl_ff, self.filt_freq1, lo, hi, 400)
        self.lbl_ff.setText(self._ff_lbl())
        self.ed_ff.setText(_fmt(self.filt_freq1))

        self._update_phase_label()
        self._apply_filter_visibility()
        self._compute_filter()
        self._update_plots()

    def _on_ff_slider(self, v):
        val = self._ff_lo + (self._ff_hi - self._ff_lo) * v / self._ff_steps
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
        self._sync_sl(self.sl_ff, v, self._ff_lo, self._ff_hi, self._ff_steps)

    def _apply_ff(self, v):
        if abs(v) <= 1e-10: v = 0.0
        self.filt_freq1 = v
        self._ff_last = v
        self._fH = None
        self.lbl_ff.setText(self._ff_lbl())
        self.ed_ff.setText(_fmt(v))
        self._compute_filter()
        self._update_plots()

    def _on_fp_slider(self, v):
        val = -1.0 + 2.0 * v / 200
        self._apply_fp(val, from_slider=True)

    def _on_fp_edit(self):
        try:
            v = float(self.ed_fp.text())
        except ValueError:
            return
        if not (-1.0 <= v <= 1.0):
            self.ed_fp.setText(_fmt(self.filt_phase))
            return
        self._apply_fp(v, from_slider=False)

    def _apply_fp(self, v, from_slider=False):
        if abs(v) <= 1e-10: v = 0.0
        self.filt_phase = v
        self._update_phase_label()
        self.ed_fp.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_fp, v, -1, 1, 200)
        self._fH = None
        self._compute_filter()
        self._update_plots()

    def _on_bw_slider(self, v):
        val = 10.0 + 40.0 * v / 400
        self._apply_bw(val, from_slider=True)

    def _on_bw_edit(self):
        try:
            v = float(self.ed_bw.text())
        except ValueError:
            return
        if not (10.0 <= v <= 50.0):
            self.ed_bw.setText(_fmt(self.filt_bw))
            return
        self._apply_bw(v, from_slider=False)

    def _apply_bw(self, v, from_slider=False):
        if abs(v) <= 1e-10: v = 10.0
        self.filt_bw = v
        self.lbl_bw.setText(f'Bandwidth = {_fmt(v)} Hz')
        self.ed_bw.setText(_fmt(v))
        if not from_slider:
            self._sync_sl(self.sl_bw, v, 10, 50, 400)
        self._fH = None
        self._compute_filter()
        self._update_plots()

    def _update_phase_label(self):
        v = self.filt_phase
        if abs(v) < 1e-7:          self.lbl_fp.setText('Phase Slope = 0')
        elif abs(v - 1) < 1e-7:    self.lbl_fp.setText('Phase Slope = π')
        elif abs(v + 1) < 1e-7:    self.lbl_fp.setText('Phase Slope = -π')
        else:                       self.lbl_fp.setText(f'Phase Slope = {_fmt(v)}π')

    # ════════════════════════════════════════════════════════════════════════
    # Filter response computation
    # ════════════════════════════════════════════════════════════════════════

    def _compute_filter(self):
        if self._fH is None:
            p = self.pop_up
            if p in (1, 2, 3, 4):
                self._ffreq, self._fH = ideal_filter_ct(p, self.filt_freq1, self.filt_phase)
            else:
                self._ffreq, self._fH = ct_filter(
                    _FTYPE[p - 5], self.filt_freq1, self.filt_bw)

    # ════════════════════════════════════════════════════════════════════════
    # Plot update
    # ════════════════════════════════════════════════════════════════════════

    def _update_plots(self):
        t = self.t
        Freqmod = self.Freq   # no aliasing fold for continuous-time

        # ── Input signal ─────────────────────────────────────────────────
        x_in = self.DC + self.Amp * np.cos(2 * np.pi * self.Freq * t + self.Phase * np.pi)
        if self._in_line is None:
            self._in_line, = self.ax_in.plot(t, x_in, 'r', lw=1.5)
        else:
            self._in_line.set_data(t, x_in)
        self.ax_in.set_title(
            f'x(t) = {cosine_string_ct(self.Amp, self.Freq, self.Phase, self.DC)}',
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

        # ── Output computation ────────────────────────────────────────────
        p = self.pop_up
        if p in (1, 2, 3, 4):          # ideal: nearest-bin lookup
            k0   = int(np.argmin(np.abs(ff)))             # DC bin
            kMag = int(np.argmin(np.abs(ff - Freqmod)))   # signal freq bin
            H0   = self._fH[k0]    # complex but always real at DC (0 or 1)
            FilterMag_0   = float(np.real(H0))
            FilterPhase_0 = float(fphs[k0])
            FilterMag_k   = float(fmag[kMag])
            FilterPhase_k = float(fphs[kMag])
        else:                           # 1st-order: exact evaluation
            _, H_exact = ct_filter(_FTYPE[p - 5], self.filt_freq1, self.filt_bw,
                                   freqs=[0.0, self.Freq])
            FilterMag_0   = float(abs(H_exact[0]))
            FilterPhase_0 = float(np.angle(H_exact[0]))
            FilterMag_k   = float(abs(H_exact[1]))
            FilterPhase_k = float(np.angle(H_exact[1]))

        self.out_mag   = FilterMag_k * self.Amp
        self.out_phase = FilterPhase_k / np.pi + self.Phase
        self.out_dc    = FilterMag_0 * self.DC

        x_out = (self.out_dc
                 + self.out_mag * np.cos(2 * np.pi * self.Freq * t + self.out_phase * np.pi))
        if self._out_line is None:
            self._out_line, = self.ax_out.plot(t, x_out, 'm', lw=1.5)
        else:
            self._out_line.set_data(t, x_out)
        self.ax_out.set_title('y(t)', fontsize=8, pad=2)

        # ── Frequency markers (red dots on mag/phase plots) ───────────────
        FM0 = FilterMag_0
        FP0 = FilterPhase_0
        FM1 = FilterMag_k
        FP1 = FilterPhase_k if FM1 > 1e-6 else 0.0

        if self._mk0_mag is None:
            kw = dict(color='r', marker='o', markerfacecolor='r',
                      markersize=7, linestyle='none', zorder=5)
            self._mk0_mag, = self.ax_mag.plot(  [0],         [FM0], **kw)
            self._mk0_phs, = self.ax_phase.plot([0],         [FP0], **kw)
            self._mk1_mag, = self.ax_mag.plot(  [Freqmod],   [FM1], **kw)
            self._mk2_mag, = self.ax_mag.plot(  [-Freqmod],  [FM1], **kw)
            self._mk1_phs, = self.ax_phase.plot([Freqmod],   [FP1], **kw)
        else:
            self._mk0_mag.set_data([0],         [FM0])
            self._mk0_phs.set_data([0],         [FP0])
            self._mk1_mag.set_data([Freqmod],   [FM1])
            self._mk2_mag.set_data([-Freqmod],  [FM1])
            self._mk1_phs.set_data([Freqmod],   [FP1])

        dc_vis    = self.DC != 0
        freq_zero = (abs(Freqmod) < 1e-7 and self.DC != 0)
        self._mk0_mag.set_visible(dc_vis)
        self._mk0_phs.set_visible(dc_vis)
        self._mk1_mag.set_visible(not freq_zero)
        # negative-freq marker is always off-screen (Hz axis is 0..200)
        self._mk2_mag.set_visible(False)
        self._mk1_phs.set_visible(not freq_zero)

        self.canvas.draw_idle()

    # ════════════════════════════════════════════════════════════════════════
    # Label text helpers
    # ════════════════════════════════════════════════════════════════════════

    def _amp_lbl(self):   return f'Amplitude = {_fmt(self.Amp)}'
    def _dc_lbl(self):    return f'DC Level = {_fmt(self.DC)}'
    def _freq_lbl(self):  return f'Frequency = {_fmt(self.Freq)} Hz'

    def _phase_lbl(self):
        v = self.Phase
        if v == 0:    return 'Phase = 0'
        if v == 1:    return 'Phase = π'
        if v == -1:   return 'Phase = -π'
        return f'Phase = {_fmt(v)}π'

    def _ff_lbl(self):
        p = self.pop_up
        lbl = 'Center Freq' if p in (3, 4, 7, 8) else 'Cutoff Freq'
        return f'{lbl} = {_fmt(self.filt_freq1)} Hz'

    # ════════════════════════════════════════════════════════════════════════
    # Theoretical Answer button
    # ════════════════════════════════════════════════════════════════════════

    def _on_answer(self):
        s = cosine_string_ct(self.out_mag, self.Freq, self.out_phase,
                             float(np.real(self.out_dc)))
        self.ax_out.set_title(f'y(t) = {s}', fontsize=8, pad=2)
        self.canvas.draw_idle()


# ── Entry point ────────────────────────────────────────────────────────────────

def main():
    app = QApplication(sys.argv)
    w = CltiDemo()
    w.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
