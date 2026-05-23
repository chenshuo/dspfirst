#!/usr/bin/env python3
"""
Con2Dis — Continuous-to-Discrete Sampling Demo

Demonstrates the relationship between a continuous-time sinusoid
x(t) = cos(2π·fo·t + φ) and its sampled discrete-time counterpart
x[n] = cos(2π·(fo/fs)·n + φ), showing how aliasing occurs when
fo exceeds the Nyquist frequency fs/2.

Six panels update simultaneously as fo, fs, or phase change:
  · x(t)  — continuous-time signal (top-left)
  · x[n]  — sampled signal with stem plot (top-centre)
  · y(t)  — reconstructed output (top-right, red when aliasing)
  · CT Spectrum   — two-sided spectrum of x(t) at ±fo (bottom-left)
  · DT Spectrum   — periodic DT spectrum in f = fo/fs or ω̂ (bottom-centre)
  · Output Spectrum — aliased/folded CT spectrum (bottom-right)

The DT spectrum x-axis can display either normalised frequency
f = fo/fs ∈ [−1, 1] or discrete radian frequency ω̂ = 2π·f ∈ [−2π, 2π].
Similarly, the CT spectrum axes can display either Hz or rad/s.
fo can also be set by clicking and dragging the stem in the CT Spectrum panel.

Original MATLAB GUI by Gregory Krudysz (Georgia Tech, 2001).
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
    QSlider, QLineEdit, QLabel, QSizePolicy, QMenuBar, QMenu,
    QButtonGroup, QRadioButton, QFrame
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction, QDoubleValidator

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

YSPMAX = 1.05   # max height for spectrum plots
TIME_END = 0.50  # time axis limit for continuous plots
TIME1 = np.arange(0, TIME_END + 0.0001, 0.0001)


def _make_stem_artists(ax, x, y, color='b', marker='o', lw=2):
    """Return (marker_line, stem_line, baseline) for a stem plot."""
    xs, ys = _stem_xy(np.atleast_1d(x), np.atleast_1d(y))
    dot, = ax.plot(x, y, linestyle='none', marker=marker,
                   color=color, markerfacecolor=color, markersize=8, zorder=3)
    stem, = ax.plot(xs, ys, color=color, linewidth=lw)
    return dot, stem


def _stem_xy(x, y):
    """Build zigzag arrays for stem lines."""
    n = len(x)
    xs = np.empty(3 * n)
    ys = np.zeros(3 * n)
    xs[0::3] = x
    xs[1::3] = x
    xs[2::3] = np.nan
    ys[1::3] = y
    ys[2::3] = np.nan
    return xs, ys


def _update_stem(dot, stem, x, y):
    """Update stem artists in place."""
    x = np.atleast_1d(x)
    y = np.atleast_1d(y)
    dot.set_xdata(x)
    dot.set_ydata(y)
    xs, ys = _stem_xy(x, y)
    stem.set_xdata(xs)
    stem.set_ydata(ys)


def _phase_info(Fo, Fs, phase):
    """
    Compute the aliased output frequency and amplitude/phase for the output.
    Returns (FoNm, Aout, PhOut)
      FoNm  – aliased freq (possibly negative, meaning folded)
      Aout  – output amplitude
      PhOut – output phase offset
    """
    if Fo <= Fs / 2:
        FoNm = Fo
    else:
        FoNm = Fo - Fs

    if abs(FoNm) < 1e-3:          # at ω̂ = 0 or 2π
        Aout = np.cos(phase)
        PhOut = 0.0
        if Aout < 0:
            Aout = abs(Aout)
            PhOut = np.pi
    elif abs(2 * FoNm - Fs) < 0.001 * Fs:   # at ω̂ = π
        Aout = np.cos(phase)
        PhOut = 0.0
        if Aout < 0:
            Aout = abs(Aout)
            PhOut = np.pi
    else:
        PhOut = phase * (1 - 2 * (FoNm < 0))
        Aout = 1.0

    return FoNm, Aout, PhOut


def _Xsp(Fo, Fs, phase):
    """Height of spectrum stems (0.5 normally; |cos(phase)| at special freqs)."""
    R = Fo / Fs if Fs > 0 else 0
    if abs(Fo) < 1e-3:
        return abs(np.cos(phase))
    if abs(mod_half(R)) < 1e-3:
        return abs(np.cos(phase))
    return 0.5


def mod_half(R):
    """Return mod(R, 0.5) mapped to [-0.25, 0.25]."""
    m = R % 0.5
    return m


def _input_label(Fo, Fs, phase, wflag):
    R = Fo / Fs if Fs > 0 else 0
    pi2 = 2 * np.pi
    if wflag:
        Wo = pi2 * Fo
        if abs(phase) < 1e-3:
            in_str = rf"$x(t)=\cos({Wo:.1f}\,t)$"
            mid_str = rf"$x[n]=\cos({pi2*R:.2f}\,n)$"
        elif phase < 0:
            in_str = rf"$x(t)=\cos({Wo:.1f}\,t - {-phase:.2f})$"
            mid_str = rf"$x[n]=\cos({pi2*R:.2f}\,n - {-phase:.2f})$"
        else:
            in_str = rf"$x(t)=\cos({Wo:.1f}\,t + {phase:.2f})$"
            mid_str = rf"$x[n]=\cos({pi2*R:.2f}\,n + {phase:.2f})$"
    else:
        if abs(phase) < 1e-3:
            in_str = rf"$x(t)=\cos(2\pi({Fo:.1f})\,t)$"
            mid_str = rf"$x[n]=\cos(2\pi({R:.2f})\,n)$"
        elif phase < 0:
            in_str = rf"$x(t)=\cos(2\pi({Fo:.1f})\,t - {-phase:.2f})$"
            mid_str = rf"$x[n]=\cos(2\pi({R:.2f})\,n - {-phase:.2f})$"
        else:
            in_str = rf"$x(t)=\cos(2\pi({Fo:.1f})\,t + {phase:.2f})$"
            mid_str = rf"$x[n]=\cos(2\pi({R:.2f})\,n + {phase:.2f})$"
    return in_str, mid_str


def _output_label(FoNout, Aout, PhOut, wflag):
    Astr = f"{Aout:.2f}" if abs(Aout - 1.0) > 1e-3 else ""
    pi2 = 2 * np.pi
    if wflag:
        FoNout_w = pi2 * FoNout
        if abs(PhOut) < 1e-3:
            return rf"$y(t)={Astr}\cos({FoNout_w:.1f}\,t)$"
        elif abs(abs(PhOut) - np.pi) < 1e-3:
            return rf"$y(t)={Astr}\cos({FoNout_w:.1f}\,t + \pi)$"
        elif PhOut < 0:
            return rf"$y(t)={Astr}\cos({FoNout_w:.1f}\,t - {-PhOut:.2f})$"
        else:
            return rf"$y(t)={Astr}\cos({FoNout_w:.1f}\,t + {PhOut:.2f})$"
    else:
        if abs(PhOut) < 1e-3:
            return rf"$y(t)={Astr}\cos(2\pi({FoNout:.1f})\,t)$"
        elif abs(abs(PhOut) - np.pi) < 1e-3:
            return rf"$y(t)={Astr}\cos(2\pi({FoNout:.1f})\,t + \pi)$"
        elif PhOut < 0:
            return rf"$y(t)={Astr}\cos(2\pi({FoNout:.1f})\,t - {-PhOut:.2f})$"
        else:
            return rf"$y(t)={Astr}\cos(2\pi({FoNout:.1f})\,t + {PhOut:.2f})$"


# ──────────────────────────────────────────────────────────────────────────────
# Main window
# ──────────────────────────────────────────────────────────────────────────────

class Con2Dis(QMainWindow):

    # ── defaults ──────────────────────────────────────────────────────────────
    FO_DEFAULT = 8.0
    FS_DEFAULT = 20.0
    FS_MIN = 0.5
    FS_MAX = 30.0
    FO_MIN = 0.0
    LW = 2

    def __init__(self):
        super().__init__()
        self.setWindowTitle("CON2DIS ver. 2.31")

        self.Fo = self.FO_DEFAULT
        self.Fs = self.FS_DEFAULT
        self.phase = 0.0
        self.wflag = False      # False = Hz, True = rad/s
        self.what_flag = True   # True = show ω̂ in DT spectrum, False = show f=fo/fs
        self.show_lf = False    # show lower-frequency alias signal
        self.show_all = True    # show all 6 panels

        self._build_ui()
        self._update_all()

    # ── UI construction ───────────────────────────────────────────────────────

    def _build_ui(self):
        self._build_menu()
        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(4, 4, 4, 4)
        main_layout.setSpacing(4)

        # ── matplotlib figure ──────────────────────────────────────────────
        self.fig = Figure(figsize=(14, 7))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        main_layout.addWidget(self.canvas)

        gs = gridspec.GridSpec(2, 3, figure=self.fig,
                               left=0.06, right=0.97,
                               top=0.92, bottom=0.10,
                               hspace=0.55, wspace=0.35)

        self.ax1 = self.fig.add_subplot(gs[0, 0])   # x(t) continuous
        self.ax2 = self.fig.add_subplot(gs[0, 1])   # x[n] sampled
        self.ax5 = self.fig.add_subplot(gs[0, 2])   # y(t) output
        self.ax4 = self.fig.add_subplot(gs[1, 0])   # CT spectrum
        self.ax3 = self.fig.add_subplot(gs[1, 1])   # DT spectrum
        self.ax6 = self.fig.add_subplot(gs[1, 2])   # output CT spectrum

        self._setup_axes()
        self._create_artists()

        # ── controls ──────────────────────────────────────────────────────
        ctrl = QWidget()
        ctrl_layout = QVBoxLayout(ctrl)
        ctrl_layout.setContentsMargins(4, 0, 4, 0)
        ctrl_layout.setSpacing(2)
        main_layout.addWidget(ctrl)

        # Row 1: labels/info
        row1 = QHBoxLayout()
        self.lbl_fo = QLabel()
        self.lbl_ph = QLabel()
        self.lbl_fs = QLabel()
        for lbl in (self.lbl_fo, self.lbl_ph, self.lbl_fs):
            lbl.setAlignment(Qt.AlignmentFlag.AlignCenter)
            lbl.setStyleSheet("font-weight: bold; font-size: 12px;")
        row1.addWidget(self.lbl_fo, 3)
        row1.addWidget(self.lbl_ph, 2)
        row1.addWidget(self.lbl_fs, 3)
        ctrl_layout.addLayout(row1)

        # Row 2: sliders / editboxes
        row2 = QHBoxLayout()

        # ShowW radio button (rad/s)
        self.rb_w = QRadioButton("Rad/s")
        self.rb_w.setChecked(False)
        self.rb_w.toggled.connect(self._on_show_w)

        # Fo slider + editbox
        self.sl_fo = QSlider(Qt.Orientation.Horizontal)
        self.sl_fo.setMinimum(0)
        self.sl_fo.setMaximum(int(1.49 * self.Fs * 10))
        self.sl_fo.setValue(int(self.Fo * 10))
        self.sl_fo.valueChanged.connect(self._sl_fo_changed)

        self.ed_fo = QLineEdit(f"{self.Fo:.1f}")
        self.ed_fo.setFixedWidth(55)
        self.ed_fo.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.ed_fo.returnPressed.connect(self._ed_fo_changed)

        # Phase editbox
        lbl_phase = QLabel("Phase:")
        lbl_phase.setAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
        self.ed_ph = QLineEdit("0")
        self.ed_ph.setFixedWidth(55)
        self.ed_ph.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.ed_ph.returnPressed.connect(self._ed_ph_changed)

        # ShowW_hat radio button (ω̂)
        self.rb_what = QRadioButton("Radian")
        self.rb_what.setChecked(True)
        self.rb_what.toggled.connect(self._on_show_what)

        # Fs slider + editbox
        self.sl_fs = QSlider(Qt.Orientation.Horizontal)
        self.sl_fs.setMinimum(int(self.FS_MIN * 10))
        self.sl_fs.setMaximum(int(self.FS_MAX * 10))
        self.sl_fs.setValue(int(self.Fs * 10))
        self.sl_fs.valueChanged.connect(self._sl_fs_changed)

        self.ed_fs = QLineEdit(f"{self.Fs:.1f}")
        self.ed_fs.setFixedWidth(55)
        self.ed_fs.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.ed_fs.returnPressed.connect(self._ed_fs_changed)

        row2.addWidget(self.rb_w)
        row2.addWidget(QLabel("fo:"))
        row2.addWidget(self.sl_fo, 3)
        row2.addWidget(self.ed_fo)
        row2.addSpacing(8)
        row2.addWidget(lbl_phase)
        row2.addWidget(self.ed_ph)
        row2.addSpacing(8)
        row2.addWidget(self.rb_what)
        row2.addWidget(QLabel("fs:"))
        row2.addWidget(self.sl_fs, 3)
        row2.addWidget(self.ed_fs)
        ctrl_layout.addLayout(row2)

        # Connect canvas for drag on ax4
        self.canvas.mpl_connect('button_press_event', self._on_press)
        self.canvas.mpl_connect('motion_notify_event', self._on_motion)
        self.canvas.mpl_connect('button_release_event', self._on_release)
        self._dragging = False

        self.resize(1200, 680)

    def _build_menu(self):
        mb = self.menuBar()

        # File
        file_menu = mb.addMenu("&File")
        act_exit = QAction("&Exit", self)
        act_exit.triggered.connect(self.close)
        file_menu.addAction(act_exit)

        # Plot Options
        opt_menu = mb.addMenu("&Plot Options")

        self.act_all = QAction("Show All Plots", self, checkable=True, checked=True)
        self.act_all.triggered.connect(self._toggle_all_plots)
        opt_menu.addAction(self.act_all)

        self.act_lf = QAction("Show Lower Frequency Signal", self, checkable=True, checked=False)
        self.act_lf.triggered.connect(self._toggle_lf)
        opt_menu.addAction(self.act_lf)

        self.act_w = QAction("Show Radian Frequency", self, checkable=True, checked=False)
        self.act_w.triggered.connect(self._menu_show_w)
        opt_menu.addAction(self.act_w)

        self.act_what = QAction("Show Discrete Radian Frequency", self, checkable=True, checked=True)
        self.act_what.triggered.connect(self._menu_show_what)
        opt_menu.addAction(self.act_what)

    def _setup_axes(self):
        Fo, Fs = self.Fo, self.Fs

        signal_limit = 1.2
        # ax1 – x(t)
        self.ax1.set_xlim(0, TIME_END)
        self.ax1.set_ylim(-signal_limit, signal_limit)
        self.ax1.set_xlabel("Time (sec)")
        self.ax1.set_title("Continuous Signal", fontweight='bold')
        self.ax1.tick_params(labelsize=8)

        # ax2 – x[n]
        self.ax2.set_xlim(0, TIME_END)
        self.ax2.set_ylim(-signal_limit, signal_limit)
        self.ax2.set_xlabel("Time (samples)")
        self.ax2.set_title("Sampled Signal", fontweight='bold')
        self.ax2.tick_params(labelsize=8)

        # ax5 – y(t)
        self.ax5.set_xlim(0, TIME_END)
        self.ax5.set_ylim(-signal_limit, signal_limit)
        self.ax5.set_xlabel("Time (sec)")
        self.ax5.set_title("Output Signal", fontweight='bold')
        self.ax5.tick_params(labelsize=8)

        # ax4 – CT spectrum
        self.ax4.set_xlim(-1.5 * Fs, 1.5 * Fs)
        self.ax4.set_ylim(0, YSPMAX)
        self.ax4.set_xlabel("$f$ (Hz)", fontweight='bold')
        self.ax4.set_title("Continuous Time Spectrum", fontweight='bold')
        self.ax4.tick_params(labelsize=8)

        # ax3 – DT spectrum
        self.ax3.set_xlim(-1.5, 1.5)
        self.ax3.set_ylim(0, YSPMAX)
        self.ax3.tick_params(labelsize=8)
        self.ax3.set_title("Discrete Time Spectrum", fontweight='bold')

        # ax6 – output CT spectrum
        self.ax6.set_xlim(-1.5 * Fs, 1.5 * Fs)
        self.ax6.set_ylim(0, YSPMAX)
        self.ax6.set_xlabel("$f$ (Hz)", fontweight='bold')
        self.ax6.set_title("Output CT Spectrum", fontweight='bold')
        self.ax6.tick_params(labelsize=8)

    def _create_artists(self):
        Fo, Fs = self.Fo, self.Fs
        R = Fo / Fs
        Xsp = 0.5
        pi2 = 2 * np.pi

        c1 = np.cos(pi2 * Fo * TIME1)
        time2 = np.arange(0, TIME_END + 1 / Fs, 1 / Fs)

        # ── ax1 ──────────────────────────────────────────────────────────
        self.line1, = self.ax1.plot(TIME1, c1, 'b-', linewidth=self.LW)
        self.text_in = self.ax1.text(0.5, 0.99, '', transform=self.ax1.transAxes,
                                     ha='center', va='top', fontweight='bold',
                                     color='b', fontsize=8)

        # ── ax2 ──────────────────────────────────────────────────────────
        self.line11, = self.ax2.plot(TIME1, c1, '-', color=[0.77, 0.77, 1],
                                     linewidth=self.LW)
        self.line52, = self.ax2.plot(TIME1, c1, '-', color=[0.77, 0.77, 1],
                                     linewidth=self.LW, visible=False)
        c2 = np.cos(pi2 * Fo * time2)
        self.ln2_dot, self.ln2_stem = _make_stem_artists(self.ax2, time2, c2,
                                                          color='k', marker='o',
                                                          lw=self.LW)
        self.text_middle = self.ax2.text(0.5, 0.99, '', transform=self.ax2.transAxes,
                                         ha='center', va='top', fontweight='bold',
                                         color='k', fontsize=8)

        # ── ax5 ──────────────────────────────────────────────────────────
        self.line5, = self.ax5.plot(TIME1, c1, 'b-', linewidth=self.LW)
        self.text_out = self.ax5.text(0.5, 0.99, '', transform=self.ax5.transAxes,
                                      ha='center', va='top', fontweight='bold',
                                      color='b', fontsize=8)
        self.text_alias = self.ax5.text(0.5, 0.85, 'A L I A S I N G !',
                                        transform=self.ax5.transAxes,
                                        ha='center', fontsize=12,
                                        fontweight='bold', color='r', visible=False)

        # ── ax4 ──────────────────────────────────────────────────────────
        from matplotlib.patches import Rectangle
        self.patch4 = Rectangle((-Fs / 2, 0), Fs, YSPMAX, color='yellow', alpha=0.5, zorder=0)
        self.ax4.add_patch(self.patch4)
        self.ln4d, = self.ax4.plot([-Fs, -Fs, np.nan, 0, 0, np.nan, Fs, Fs],
                                   [0, YSPMAX, np.nan, 0, YSPMAX, np.nan, 0, YSPMAX],
                                   'k:', linewidth=1)
        self.ln4_dot, self.ln4_stem = _make_stem_artists(self.ax4, [Fo], [Xsp],
                                                          color='b', marker='o')
        self.ln4c_dot, self.ln4c_stem = _make_stem_artists(self.ax4, [-Fo], [Xsp],
                                                            color='b', marker='x')
        self.ln4c_dot.set_markersize(12)

        # ── ax3 ──────────────────────────────────────────────────────────
        from matplotlib.patches import Rectangle as Rect3
        self.patch3 = Rect3((-0.5, 0), 1.0, YSPMAX, color='yellow', alpha=0.5, zorder=0)
        self.ax3.add_patch(self.patch3)
        # in-band blue
        self.ln3in_dot, self.ln3in_stem = _make_stem_artists(self.ax3, [R], [Xsp],
                                                              color='b', marker='o')
        self.ln3inc_dot, self.ln3inc_stem = _make_stem_artists(self.ax3, [-R], [Xsp],
                                                                color='b', marker='x')
        self.ln3inc_dot.set_markersize(12)
        # out-of-band red
        xs_out = np.array([-2 + R, -1 + R, 1 + R, 2 + R])
        self.ln3out_dot, self.ln3out_stem = _make_stem_artists(self.ax3, xs_out,
                                                                Xsp * np.ones(4),
                                                                color='r', marker='o')
        xs_outc = np.array([-2 - R, -1 - R, 1 - R, 2 - R])
        self.ln3outc_dot, self.ln3outc_stem = _make_stem_artists(self.ax3, xs_outc,
                                                                  Xsp * np.ones(4),
                                                                  color='r', marker='x')
        self.ln3outc_dot.set_markersize(12)

        # ── ax6 ──────────────────────────────────────────────────────────
        from matplotlib.patches import Rectangle as Rect6
        self.patch6 = Rect6((-Fs / 2, 0), Fs, YSPMAX, color='yellow', alpha=0.5, zorder=0)
        self.ax6.add_patch(self.patch6)
        self.ln6_dot, self.ln6_stem = _make_stem_artists(self.ax6, [Fo], [Xsp],
                                                          color='b', marker='o')
        self.ln6c_dot, self.ln6c_stem = _make_stem_artists(self.ax6, [-Fo], [Xsp],
                                                            color='b', marker='x')
        self.ln6c_dot.set_markersize(12)

        # headline labels (positioned outside axes using fig coords)
        self.text_fo_lbl = self.fig.text(0.20, 0.04, '', ha='center',
                                         fontweight='bold', fontsize=10)
        self.text_ph_lbl = self.fig.text(0.50, 0.04, '', ha='center',
                                         fontweight='bold', fontsize=10)
        self.text_fs_lbl = self.fig.text(0.78, 0.04, '', ha='center',
                                         fontweight='bold', fontsize=10)

    # ── update logic ──────────────────────────────────────────────────────────

    def _update_all(self):
        Fo, Fs, phase = self.Fo, self.Fs, self.phase
        R = Fo / Fs
        pi2 = 2 * np.pi

        # ── compute aliased freq & amplitude ──────────────────────────────
        FoNm, Aout, PhOut = _phase_info(Fo, Fs, phase)
        FoNout = abs(FoNm)
        Xsp = _Xsp(Fo, Fs, phase)

        # spectrum height at ±Fo (CT)
        XCsp = abs(np.cos(phase)) if abs(Fo) < 1e-3 else 0.5

        # aliasing state
        aliasing = Fo > Fs / 2
        nyquist = abs(Fo - Fs / 2) < 1e-3

        # ── ax1: x(t) ─────────────────────────────────────────────────────
        c1 = np.cos(pi2 * Fo * TIME1 + phase)
        self.line1.set_ydata(c1)

        # ── ax2: x[n] ────────────────────────────────────────────────────
        self.line11.set_ydata(c1)
        self.line52.set_ydata(c1)
        time2 = np.arange(0, TIME_END + 0.5 / Fs, 1 / Fs)
        # Apply alias folding for the sampled stems
        FoNc2 = Fo if Fo <= Fs / 2 else Fo - Fs
        c2 = np.cos(pi2 * FoNc2 * time2 + phase)
        _update_stem(self.ln2_dot, self.ln2_stem, time2, c2)

        # x-axis ticks for ax2 (sample index labels)
        if len(time2) > 12:
            ticks2 = np.arange(0, 1.0, 2.0 / Fs)
            self.ax2.set_xticks(ticks2)
            self.ax2.set_xticklabels([str(int(round(v * Fs))) for v in ticks2], fontsize=7)
        else:
            self.ax2.set_xticks(time2)
            self.ax2.set_xticklabels([str(i) for i in range(len(time2))], fontsize=7)

        # ── ax5: y(t) ────────────────────────────────────────────────────
        if aliasing or nyquist:
            y_out = Aout * np.cos(pi2 * FoNm * TIME1 + PhOut)
        else:
            y_out = np.cos(pi2 * FoNm * TIME1 + phase)
        self.line5.set_ydata(y_out)

        # color / alias text
        if aliasing:
            color6 = 'r'
            self.ax6.set_facecolor([0.9, 0.85, 0.85])
            self.text_alias.set_visible(True)
            self.line5.set_color([0.7, 0, 0])
            self.text_out.set_color('r')
        elif nyquist:
            color6 = 'm'
            self.ax6.set_facecolor([0.95, 0.95, 0.95])
            self.text_alias.set_visible(False)
            self.line5.set_color('r')
            self.text_out.set_color('m')
        else:
            color6 = 'b'
            self.ax6.set_facecolor('w')
            self.text_alias.set_visible(False)
            self.line5.set_color('b')
            self.text_out.set_color('b')

        # ── ax4: CT spectrum ─────────────────────────────────────────────
        _update_stem(self.ln4_dot, self.ln4_stem, [Fo], [XCsp])
        _update_stem(self.ln4c_dot, self.ln4c_stem, [-Fo], [XCsp])
        # update dotted lines and yellow patch
        self._update_ct_spectrum_axes(Fs, self.ax4, self.patch4, self.ln4d)

        # ── ax3: DT spectrum ─────────────────────────────────────────────
        _update_stem(self.ln3in_dot, self.ln3in_stem, [R], [Xsp])
        _update_stem(self.ln3inc_dot, self.ln3inc_stem, [-R], [Xsp])
        _update_stem(self.ln3out_dot, self.ln3out_stem,
                     [-2 + R, -1 + R, 1 + R, 2 + R], Xsp * np.ones(4))
        _update_stem(self.ln3outc_dot, self.ln3outc_stem,
                     [-2 - R, -1 - R, 1 - R, 2 - R], Xsp * np.ones(4))
        self._update_dt_spectrum_axes()

        # ── ax6: output CT spectrum ───────────────────────────────────────
        _update_stem(self.ln6_dot, self.ln6_stem, [FoNm], [Xsp])
        _update_stem(self.ln6c_dot, self.ln6c_stem, [-FoNm], [Xsp])
        for artist in (self.ln6_dot, self.ln6_stem, self.ln6c_dot, self.ln6c_stem):
            artist.set_color(color6)
        self._update_ct_spectrum_axes(Fs, self.ax6, self.patch6, None)

        # ── text labels ───────────────────────────────────────────────────
        in_str, mid_str = _input_label(Fo, Fs, phase, self.wflag)
        self.text_in.set_text("Input: " + in_str)
        self.text_middle.set_text(mid_str)
        out_str = _output_label(FoNout, Aout, PhOut, self.wflag)
        self.text_out.set_text("Output: " + out_str)

        if self.wflag:
            pi2 = 2 * np.pi
            self.lbl_fo.setText(f"ωo = {pi2*Fo:.1f} (rad/s)")
            self.lbl_fs.setText(f"ωs = {pi2*Fs:.1f} (rad/s)")
        else:
            self.lbl_fo.setText(f"fo = {Fo:.1f} (Hz)")
            self.lbl_fs.setText(f"fs = {Fs:.1f} (Hz)")
        self.lbl_ph.setText(f"Phase = {phase:.2f}")

        self.canvas.draw_idle()

    def _update_ct_spectrum_axes(self, Fs, ax, patch, line4d):
        ax.set_xlim(-1.5 * Fs, 1.5 * Fs)
        ax.set_ylim(0, YSPMAX)
        ticks = np.array([-Fs, -Fs / 2, 0, Fs / 2, Fs])
        ax.set_xticks(ticks)
        if self.wflag:
            pi2 = 2 * np.pi
            labels = [f"{pi2*v:.1f}" for v in ticks]
            ax.set_xlabel(r"$\omega$ (rad/s)", fontweight='bold')
        else:
            labels = [f"{v:.1f}" for v in ticks]
            ax.set_xlabel("$f$ (Hz)", fontweight='bold')
        ax.set_xticklabels(labels, fontsize=7)

        # update yellow passband patch (Rectangle)
        patch.set_x(-Fs / 2)
        patch.set_width(Fs)

        if line4d is not None:
            line4d.set_xdata([-Fs, -Fs, np.nan, 0, 0, np.nan, Fs, Fs])
            line4d.set_ydata([0, YSPMAX, np.nan, 0, YSPMAX, np.nan, 0, YSPMAX])

    def _update_dt_spectrum_axes(self):
        ax = self.ax3
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(0, YSPMAX)
        if self.what_flag:
            ax.set_xticks([-1, -0.5, 0, 0.5, 1])
            ax.set_xticklabels([r'$-2\pi$', r'$-\pi$', '0', r'$\pi$', r'$2\pi$'],
                               fontsize=8, color='b')
            ax.set_xlabel(r"$\hat\omega = 2\pi(f_o/f_s)$", color='b', fontweight='bold')
        else:
            ax.set_xticks([-1, -0.5, 0, 0.5, 1])
            ax.set_xticklabels(['-1', '-0.5', '0', '0.5', '1'], fontsize=8)
            ax.set_xlabel(r"$f = f_o/f_s$", fontweight='bold')

    # ── slider / editbox callbacks ────────────────────────────────────────────

    def _sl_fo_changed(self, val):
        Fo = val / 10.0
        if self.wflag:
            Fo = Fo / (2 * np.pi)
        Fo = max(0.0, min(Fo, 1.49 * self.Fs))
        self.Fo = Fo
        self._sync_fo_controls(from_slider=True)
        self._update_all()

    def _ed_fo_changed(self):
        try:
            val = float(self.ed_fo.text())
        except ValueError:
            return
        if self.wflag:
            val = val / (2 * np.pi)
        val = max(0.0, min(val, 1.49 * self.Fs))
        self.Fo = val
        self._sync_fo_controls(from_slider=False)
        self._update_all()

    def _sl_fs_changed(self, val):
        Fs = val / 10.0
        Fs = max(self.FS_MIN, min(Fs, self.FS_MAX))
        self.Fs = Fs
        if self.Fo > 1.49 * Fs:
            self.Fo = 1.49 * Fs
        self._sync_fs_controls(from_slider=True)
        self._sync_fo_controls(from_slider=False)
        self._update_all()

    def _ed_fs_changed(self):
        try:
            val = float(self.ed_fs.text())
        except ValueError:
            return
        if self.wflag:
            val = val / (2 * np.pi)
        val = max(self.FS_MIN, min(val, self.FS_MAX))
        self.Fs = val
        if self.Fo > 1.49 * val:
            self.Fo = 1.49 * val
        self._sync_fs_controls(from_slider=False)
        self._sync_fo_controls(from_slider=False)
        self._update_all()

    def _ed_ph_changed(self):
        txt = self.ed_ph.text().strip()
        if not txt:
            self.phase = 0.0
        else:
            try:
                self.phase = float(eval(txt, {"pi": np.pi, "__builtins__": {}}))
            except Exception:
                return
        self._update_all()

    def _sync_fo_controls(self, from_slider):
        Fo = self.Fo
        pi2 = 2 * np.pi
        display = pi2 * Fo if self.wflag else Fo
        if not from_slider:
            self.sl_fo.blockSignals(True)
            slider_val = int(round((pi2 * Fo if self.wflag else Fo) * 10))
            self.sl_fo.setValue(max(0, slider_val))
            self.sl_fo.blockSignals(False)
        self.ed_fo.setText(f"{display:.1f}")
        # update slider max
        max_val = int(round(1.49 * (pi2 * self.Fs if self.wflag else self.Fs) * 10))
        self.sl_fo.blockSignals(True)
        self.sl_fo.setMaximum(max_val)
        self.sl_fo.blockSignals(False)

    def _sync_fs_controls(self, from_slider):
        Fs = self.Fs
        pi2 = 2 * np.pi
        display = pi2 * Fs if self.wflag else Fs
        if not from_slider:
            self.sl_fs.blockSignals(True)
            self.sl_fs.setValue(int(round(Fs * 10)))
            self.sl_fs.blockSignals(False)
        self.ed_fs.setText(f"{display:.1f}")

    # ── radio buttons / menu ─────────────────────────────────────────────────

    def _on_show_w(self, checked):
        if checked:
            self._set_wflag(True)
        else:
            self._set_wflag(False)

    def _menu_show_w(self, checked):
        self.rb_w.setChecked(checked)

    def _set_wflag(self, val):
        self.wflag = val
        self.act_w.setChecked(val)
        self.rb_w.blockSignals(True)
        self.rb_w.setChecked(val)
        self.rb_w.blockSignals(False)
        self._sync_fo_controls(from_slider=False)
        self._sync_fs_controls(from_slider=False)
        self._update_all()

    def _on_show_what(self, checked):
        self._set_what_flag(checked)

    def _menu_show_what(self, checked):
        self.rb_what.setChecked(checked)

    def _set_what_flag(self, val):
        self.what_flag = val
        self.act_what.setChecked(val)
        self.rb_what.blockSignals(True)
        self.rb_what.setChecked(val)
        self.rb_what.blockSignals(False)
        self._update_all()

    def _toggle_all_plots(self, checked):
        self.show_all = checked
        for w in (self.ax5, self.ax6):
            for artist in w.get_children():
                try:
                    artist.set_visible(checked)
                except Exception:
                    pass
            w.set_visible(checked)
        self.canvas.draw_idle()

    def _toggle_lf(self, checked):
        self.show_lf = checked
        self.line11.set_visible(not checked)
        self.line52.set_visible(checked)
        self.canvas.draw_idle()

    # ── drag on ax4 to move fo stem ──────────────────────────────────────────

    def _on_press(self, event):
        if event.inaxes is not self.ax4:
            return
        Fo = self.Fo
        tol = self.ax4.get_xlim()[1] * 0.1
        if abs(event.xdata - Fo) < tol or abs(event.xdata + Fo) < tol:
            self._dragging = True

    def _on_motion(self, event):
        if not self._dragging or event.inaxes is not self.ax4:
            return
        x = event.xdata
        Fo = abs(x)
        Fo = round(Fo * 10) / 10
        Fo = max(0.0, min(Fo, 1.49 * self.Fs))
        self.Fo = Fo
        self._sync_fo_controls(from_slider=False)
        self._update_all()

    def _on_release(self, event):
        self._dragging = False


# ──────────────────────────────────────────────────────────────────────────────

def main():
    app = QApplication(sys.argv)
    win = Con2Dis()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
