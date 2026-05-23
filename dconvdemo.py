#!/usr/bin/env python3
"""
dconvdemo.py — Discrete Convolution Demo
PyQt6 port of the MATLAB dconvdemo by Jordan Rosenthal.

Layout: three stacked axes on the left (Signal, Multiply, Linear Output),
plus an optional Circular Output axis. Controls on the right.
Drag the ↑ arrow in the plot or use ← → (or 4/6) keys to shift n.
"""

import sys
import numpy as np
import matplotlib
matplotlib.use('QtAgg')
import matplotlib.gridspec as gridspec
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
    QPushButton, QLabel, QButtonGroup, QRadioButton, QDialog,
    QComboBox, QFormLayout, QDoubleSpinBox, QSpinBox,
    QStackedWidget, QDialogButtonBox, QCheckBox, QSizePolicy,
)
from PyQt6.QtCore import Qt


# ── Signal classes ─────────────────────────────────────────────────────────────

class UnitSample:
    name = "Unit Sample"

    def __init__(self, amplitude=1.0, delay=0):
        self.amplitude = float(amplitude)
        self.delay = int(delay)
        self._compute()

    def _compute(self):
        self.xdata = np.array([self.delay], dtype=float)
        self.ydata = np.array([self.amplitude])

    def formula_str(self):
        d = self.delay
        n_arg = "n" if d == 0 else (f"n−{d}" if d > 0 else f"n+{-d}")
        s = f"δ[{n_arg}]"
        if self.amplitude == 1:
            return s
        if self.amplitude == -1:
            return f"−{s}"
        return f"{self.amplitude:g}·{s}"


class Pulse:
    name = "Pulse"

    def __init__(self, amplitude=1.0, length=10, delay=0):
        self.amplitude = float(amplitude)
        self.length = max(1, int(length))
        self.delay = int(delay)
        self._compute()

    def _compute(self):
        self.xdata = np.arange(self.delay, self.delay + self.length, dtype=float)
        self.ydata = self.amplitude * np.ones(self.length)

    def formula_str(self):
        d, L, A = self.delay, self.length, self.amplitude

        def u(k):
            if k == 0:
                return "u[n]"
            return f"u[n−{k}]" if k > 0 else f"u[n+{-k}]"

        expr = f"{u(d)} − {u(d + L)}"
        if A == 1:
            return expr
        if A == -1:
            return f"−({expr})"
        return f"{A:g}({expr})"


class Exponential:
    name = "Exponential"
    CAUSALITIES = ["Causal", "Noncausal"]

    def __init__(self, scaling=1.0, exp_const=0.9, length=10, delay=0,
                 causality="Causal"):
        self.scaling = float(scaling)
        self.exp_const = float(exp_const)
        self.length = max(1, int(length))
        self.delay = int(delay)
        self.causality = causality
        self._compute()

    def _compute(self):
        if self.causality == "Causal":
            self.xdata = np.arange(self.delay, self.delay + self.length, dtype=float)
            self.ydata = self.scaling * self.exp_const ** np.arange(self.length)
        else:
            self.xdata = np.arange(self.delay - self.length + 1,
                                   self.delay + 1, dtype=float)
            self.ydata = self.scaling * self.exp_const ** np.arange(
                self.length - 1, -1, -1)

    def formula_str(self):
        A = ("" if self.scaling == 1 else
             "−" if self.scaling == -1 else f"{self.scaling:g}·")
        a = f"({self.exp_const:g})"
        d = self.delay
        if self.causality == "Causal":
            if d == 0:
                exp = f"{a}^n"
                uw = "u[n]"
            elif d > 0:
                exp = f"{a}^(n−{d})"
                uw = f"u[n−{d}]"
            else:
                exp = f"{a}^(n+{-d})"
                uw = f"u[n+{-d}]"
        else:
            exp = f"{a}^(−n)"
            uw = "u[−n]"
        return f"{A}{exp}·{uw}"


class Cosine:
    name = "Cosine"

    def __init__(self, amplitude=1.0, period=10.0, phase=0.0, length=20, delay=0):
        self.amplitude = float(amplitude)
        self.period = max(1.0, float(period))
        self.phase = float(phase)
        self.length = max(1, int(length))
        self.delay = int(delay)
        self._compute()

    def _compute(self):
        self.xdata = np.arange(self.delay, self.delay + self.length, dtype=float)
        k = np.arange(self.length)
        self.ydata = self.amplitude * np.cos(2 * np.pi / self.period * k + self.phase)

    def formula_str(self):
        A = f"{self.amplitude:g}·" if self.amplitude != 1 else ""
        ph = f" + {self.phase:g}" if self.phase else ""
        return f"{A}cos(2π/{self.period:g}·n{ph})"


class Sine:
    name = "Sine"

    def __init__(self, amplitude=1.0, period=10.0, phase=0.0, length=20, delay=0):
        self.amplitude = float(amplitude)
        self.period = max(1.0, float(period))
        self.phase = float(phase)
        self.length = max(1, int(length))
        self.delay = int(delay)
        self._compute()

    def _compute(self):
        self.xdata = np.arange(self.delay, self.delay + self.length, dtype=float)
        k = np.arange(self.length)
        self.ydata = self.amplitude * np.sin(2 * np.pi / self.period * k + self.phase)

    def formula_str(self):
        A = f"{self.amplitude:g}·" if self.amplitude != 1 else ""
        ph = f" + {self.phase:g}" if self.phase else ""
        return f"{A}sin(2π/{self.period:g}·n{ph})"


SIGNAL_TYPES = [Pulse, UnitSample, Exponential, Cosine, Sine]


# ── Math helpers ───────────────────────────────────────────────────────────────

def alias(x, L, nStart=0):
    """Alias vector x with period L, first sample at integer index nStart.

    Implements y[n] = Σ_r x[n + rL] for n = 0 … L-1.
    """
    x = np.asarray(x, dtype=float).ravel()
    nend = nStart + len(x) - 1
    nFillLow = int(nStart % L)          # Python % matches MATLAB mod for L > 0
    nFillHigh = int(L - nend % L - 1)
    if nFillHigh < 0:
        nFillHigh += L
    y = np.concatenate([np.zeros(nFillLow), x, np.zeros(nFillHigh)])
    n_sec = len(y) // L
    return y[: n_sec * L].reshape(n_sec, L).sum(axis=0)


def _stem_artists(ax, x, y, color='b', lw=1.5, marker='o', ms=5):
    """Draw a stem plot; return (dot_line, stem_line) artists."""
    x = np.asarray(x).ravel()
    y = np.asarray(y).ravel()
    N = len(x)
    xx = np.empty(3 * N)
    yy = np.zeros(3 * N)
    xx[0::3] = x
    xx[1::3] = x
    xx[2::3] = np.nan
    yy[1::3] = y
    yy[2::3] = np.nan
    (stem_line,) = ax.plot(xx, yy, '-', color=color, lw=lw)
    (dot_line,)  = ax.plot(x, y, marker, color=color,
                           markerfacecolor=color, ms=ms, lw=lw)
    return dot_line, stem_line


def _safe_ylim(y, margin=1.1):
    """Symmetric y-limits from data, with margin; never zero-range."""
    mn = min(0.0, float(np.min(y)))
    mx = max(0.0, float(np.max(y)))
    if mn == mx:
        mn -= 1.0
        mx += 1.0
    return margin * mn, margin * mx


# ── Signal Dialog ──────────────────────────────────────────────────────────────

class SignalDialog(QDialog):
    """Modal dialog: choose a signal type, set parameters, see a live preview."""

    def __init__(self, current_signal=None, title="Get Signal", parent=None):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setModal(True)
        self.resize(460, 430)
        self.result_signal = None

        outer = QVBoxLayout(self)

        # ── Signal type combo ──
        row = QHBoxLayout()
        row.addWidget(QLabel("Signal type:"))
        self.combo = QComboBox()
        for cls in SIGNAL_TYPES:
            self.combo.addItem(cls.name)
        row.addWidget(self.combo)
        outer.addLayout(row)

        # ── Stacked parameter pages ──
        self.stack = QStackedWidget()
        self._pages = [self._make_page(cls) for cls in SIGNAL_TYPES]
        for p in self._pages:
            self.stack.addWidget(p)
        outer.addWidget(self.stack)

        # ── Preview figure ──
        self.fig_prev = Figure(figsize=(4, 2), facecolor='white')
        self.canvas_prev = FigureCanvas(self.fig_prev)
        self.canvas_prev.setMinimumHeight(140)
        self.ax_prev = self.fig_prev.add_subplot(111)
        outer.addWidget(self.canvas_prev)

        # ── OK / Cancel ──
        btns = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok |
            QDialogButtonBox.StandardButton.Cancel)
        btns.accepted.connect(self._on_ok)
        btns.rejected.connect(self.reject)
        outer.addWidget(btns)

        # Pre-fill from existing signal
        if current_signal is not None:
            for i, cls in enumerate(SIGNAL_TYPES):
                if isinstance(current_signal, cls):
                    self.combo.setCurrentIndex(i)
                    self._fill_page(i, current_signal)
                    break

        self.combo.currentIndexChanged.connect(self._on_type_changed)
        self._on_type_changed(self.combo.currentIndex())

    # ── page builders ──

    def _make_page(self, cls):
        w = QWidget()
        form = QFormLayout(w)
        w._fields = {}

        def dbl(lo=-1e6, hi=1e6, val=1.0, step=0.5, dec=3):
            sb = QDoubleSpinBox()
            sb.setRange(lo, hi)
            sb.setValue(val)
            sb.setSingleStep(step)
            sb.setDecimals(dec)
            return sb

        def spin(lo=-500, hi=500, val=0):
            sb = QSpinBox()
            sb.setRange(lo, hi)
            sb.setValue(val)
            return sb

        if cls is UnitSample:
            w._fields = dict(amplitude=dbl(val=1.0), delay=spin())
            form.addRow("Amplitude:", w._fields['amplitude'])
            form.addRow("Delay n₀:", w._fields['delay'])

        elif cls is Pulse:
            w._fields = dict(amplitude=dbl(val=1.0),
                             length=spin(lo=1, hi=200, val=10),
                             delay=spin())
            form.addRow("Amplitude:", w._fields['amplitude'])
            form.addRow("Length:", w._fields['length'])
            form.addRow("Delay n₀:", w._fields['delay'])

        elif cls is Exponential:
            w._fields = dict(scaling=dbl(val=1.0),
                             exp_const=dbl(lo=-10, hi=10, val=0.9, step=0.05),
                             length=spin(lo=1, hi=200, val=10),
                             delay=spin(),
                             causality=QComboBox())
            w._fields['causality'].addItems(Exponential.CAUSALITIES)
            form.addRow("Scaling factor:", w._fields['scaling'])
            form.addRow("Exp. constant a:", w._fields['exp_const'])
            form.addRow("Length:", w._fields['length'])
            form.addRow("Delay n₀:", w._fields['delay'])
            form.addRow("Causality:", w._fields['causality'])

        elif cls in (Cosine, Sine):
            w._fields = dict(amplitude=dbl(val=1.0),
                             period=dbl(lo=0.1, hi=1000, val=10.0, step=1.0),
                             phase=dbl(lo=-100, hi=100, val=0.0, step=0.1),
                             length=spin(lo=1, hi=400, val=20),
                             delay=spin(lo=-400, hi=400))
            form.addRow("Amplitude:", w._fields['amplitude'])
            form.addRow("Period T₀:", w._fields['period'])
            form.addRow("Phase (rad):", w._fields['phase'])
            form.addRow("Length:", w._fields['length'])
            form.addRow("Delay n₀:", w._fields['delay'])

        for f in w._fields.values():
            if isinstance(f, (QDoubleSpinBox, QSpinBox)):
                f.valueChanged.connect(self._update_preview)
            elif isinstance(f, QComboBox):
                f.currentIndexChanged.connect(self._update_preview)
        return w

    def _fill_page(self, idx, sig):
        page = self._pages[idx]
        cls = SIGNAL_TYPES[idx]
        F = page._fields

        def sv(key, val):
            if key not in F:
                return
            f = F[key]
            f.blockSignals(True)
            if isinstance(f, (QDoubleSpinBox, QSpinBox)):
                f.setValue(val)
            elif isinstance(f, QComboBox):
                f.setCurrentText(str(val))
            f.blockSignals(False)

        if cls is UnitSample:
            sv('amplitude', sig.amplitude); sv('delay', sig.delay)
        elif cls is Pulse:
            sv('amplitude', sig.amplitude); sv('length', sig.length)
            sv('delay', sig.delay)
        elif cls is Exponential:
            sv('scaling', sig.scaling); sv('exp_const', sig.exp_const)
            sv('length', sig.length); sv('delay', sig.delay)
            sv('causality', sig.causality)
        elif cls in (Cosine, Sine):
            sv('amplitude', sig.amplitude); sv('period', sig.period)
            sv('phase', sig.phase); sv('length', sig.length)
            sv('delay', sig.delay)

    def _on_type_changed(self, idx):
        self.stack.setCurrentIndex(idx)
        self._update_preview()

    def _build_signal(self):
        idx = self.combo.currentIndex()
        cls = SIGNAL_TYPES[idx]
        F = self._pages[idx]._fields
        try:
            if cls is UnitSample:
                return UnitSample(F['amplitude'].value(), F['delay'].value())
            if cls is Pulse:
                return Pulse(F['amplitude'].value(), F['length'].value(),
                             F['delay'].value())
            if cls is Exponential:
                return Exponential(F['scaling'].value(), F['exp_const'].value(),
                                   F['length'].value(), F['delay'].value(),
                                   F['causality'].currentText())
            if cls is Cosine:
                return Cosine(F['amplitude'].value(), F['period'].value(),
                              F['phase'].value(), F['length'].value(),
                              F['delay'].value())
            if cls is Sine:
                return Sine(F['amplitude'].value(), F['period'].value(),
                            F['phase'].value(), F['length'].value(),
                            F['delay'].value())
        except Exception:
            return None

    def _update_preview(self):
        sig = self._build_signal()
        self.ax_prev.cla()
        if sig is not None and len(sig.xdata):
            _stem_artists(self.ax_prev, sig.xdata, sig.ydata)
            self.ax_prev.axhline(0, color='k', lw=0.5)
            pad = max(1, len(sig.xdata) * 0.1)
            self.ax_prev.set_xlim(sig.xdata[0] - pad, sig.xdata[-1] + pad)
            self.ax_prev.set_ylim(_safe_ylim(sig.ydata))
        self.fig_prev.tight_layout(pad=0.4)
        self.canvas_prev.draw_idle()

    def _on_ok(self):
        self.result_signal = self._build_signal()
        self.accept()

    @classmethod
    def get_signal(cls, current_signal=None, title="Get Signal", parent=None):
        dlg = cls(current_signal=current_signal, title=title, parent=parent)
        if dlg.exec() == QDialog.DialogCode.Accepted:
            return dlg.result_signal
        return None


# ── Main Window ────────────────────────────────────────────────────────────────

class DConvDemo(QMainWindow):
    _XLIM_DEFAULT = [-25, 25]
    _N_RESET = -5
    _CIRC_LEN_RESET = 10
    _COLOR_M = (0.10, 0.60, 0.20)   # green for product / highlighted output

    def __init__(self):
        super().__init__()
        # State
        self.sig_x: object = None
        self.sig_h: object = None
        self.n = self._N_RESET
        self.flip_which = 'h'           # 'x' → flip x; 'h' → flip h (default)
        self.circ_mode = False
        self.circ_len = self._CIRC_LEN_RESET
        self.xlim = list(self._XLIM_DEFAULT)
        self.initialized = False
        self._out_x: np.ndarray = None
        self._out_y: np.ndarray = None
        # Drag state
        self._dragging = False
        self._drag_x0 = 0.0
        self._drag_n0 = 0

        self._build_ui()

    # ── UI construction ────────────────────────────────────────────────────────

    def _build_ui(self):
        self.setWindowTitle("Discrete Convolution Demo")
        self.resize(1100, 680)

        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setContentsMargins(4, 4, 4, 4)
        root.setSpacing(4)

        # ── Left: main matplotlib canvas ──
        self.fig = Figure(facecolor='#bbbbbb')
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        root.addWidget(self.canvas, stretch=3)
        self._build_axes()

        # ── Right: control panel ──
        panel = QWidget()
        panel.setFixedWidth(295)
        col = QVBoxLayout(panel)
        col.setContentsMargins(4, 4, 4, 4)
        col.setSpacing(5)
        root.addWidget(panel)

        # Small preview figures (x[n] and h[n])
        prev_row = QHBoxLayout()
        col.addLayout(prev_row)

        self.fig_x, self.canvas_x, self.ax_x = self._make_mini_fig()
        self.ax_x.set_title("Input", fontweight='bold', fontsize=8)
        prev_row.addWidget(self.canvas_x)

        self.fig_h, self.canvas_h, self.ax_h = self._make_mini_fig()
        self.ax_h.set_title("Impulse Response", fontweight='bold', fontsize=8)
        prev_row.addWidget(self.canvas_h)

        # Get buttons
        get_row = QHBoxLayout()
        self.btn_get_x = QPushButton("Get x[n]")
        self.btn_get_h = QPushButton("Get h[n]")
        for b in (self.btn_get_x, self.btn_get_h):
            b.setStyleSheet("font-weight:bold;")
        get_row.addWidget(self.btn_get_x)
        get_row.addWidget(self.btn_get_h)
        col.addLayout(get_row)

        # Flip radio buttons
        flip_row = QHBoxLayout()
        self._flip_grp = QButtonGroup(self)
        self.rad_flip_x = QRadioButton("Flip x[n]")
        self.rad_flip_h = QRadioButton("Flip h[n]")
        self.rad_flip_h.setChecked(True)
        self._flip_grp.addButton(self.rad_flip_x, 0)
        self._flip_grp.addButton(self.rad_flip_h, 1)
        flip_row.addWidget(self.rad_flip_x)
        flip_row.addWidget(self.rad_flip_h)
        col.addLayout(flip_row)

        # Circular convolution toggle
        self.chk_circ = QCheckBox("Show Circular Convolution")
        col.addWidget(self.chk_circ)

        # Formula key
        self.lbl_key = QLabel()
        self.lbl_key.setTextFormat(Qt.TextFormat.RichText)
        self.lbl_key.setAlignment(Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft)
        self.lbl_key.setStyleSheet(
            "background:#f4f4f4; border:1px solid #aaa; padding:6px; font-size:12px;")
        self.lbl_key.setWordWrap(True)
        self.lbl_key.setMinimumHeight(110)
        col.addWidget(self.lbl_key, stretch=1)
        self._refresh_key()

        # Instructions (shown until signals chosen)
        self.lbl_hint = QLabel(
            "<b>To start:</b> click <b>Get x[n]</b> and <b>Get h[n]</b>.<br>"
            "Then drag the ↑ marker or press ← → to shift n.")
        self.lbl_hint.setWordWrap(True)
        self.lbl_hint.setStyleSheet("color:#555; font-size:11px;")
        col.addWidget(self.lbl_hint)

        # Close button
        self.btn_close = QPushButton("Close")
        self.btn_close.setStyleSheet("font-weight:bold;")
        col.addWidget(self.btn_close)

        # Wiring
        self.btn_get_x.clicked.connect(lambda: self._get_signal('x'))
        self.btn_get_h.clicked.connect(lambda: self._get_signal('h'))
        self._flip_grp.idClicked.connect(self._on_flip)
        self.chk_circ.toggled.connect(self._on_circ_toggled)
        self.btn_close.clicked.connect(self.close)

        self.canvas.mpl_connect('button_press_event',   self._on_press)
        self.canvas.mpl_connect('motion_notify_event',  self._on_motion)
        self.canvas.mpl_connect('button_release_event', self._on_release)

        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    def _make_mini_fig(self):
        fig = Figure(figsize=(2.2, 1.7), facecolor='white')
        canvas = FigureCanvas(fig)
        canvas.setFixedHeight(125)
        ax = fig.add_subplot(111)
        ax.axhline(0, color='k', lw=0.5)
        ax.tick_params(labelsize=7)
        fig.tight_layout(pad=0.35)
        return fig, canvas, ax

    # ── Axes layout ────────────────────────────────────────────────────────────

    def _build_axes(self):
        """(Re)create main axes.  Called at startup and on circ-mode toggle."""
        self.fig.clear()
        n_rows = 4 if self.circ_mode else 3
        gs = gridspec.GridSpec(n_rows, 1, figure=self.fig,
                               left=0.09, right=0.97,
                               top=0.97, bottom=0.07,
                               hspace=0.10)
        self.ax_sig = self.fig.add_subplot(gs[0])
        self.ax_mul = self.fig.add_subplot(gs[1], sharex=self.ax_sig)
        if self.circ_mode:
            self.ax_out  = self.fig.add_subplot(gs[3], sharex=self.ax_sig)
            self.ax_circ = self.fig.add_subplot(gs[2], sharex=self.ax_sig)
        else:
            self.ax_out  = self.fig.add_subplot(gs[2], sharex=self.ax_sig)
            self.ax_circ = None

        self.ax_sig.set_xlim(self.xlim)
        for ax in self._all_axes():
            ax.set_facecolor('white')
            ax.tick_params(labelsize=8)
        self.canvas.draw_idle()

    def _all_axes(self):
        axes = [self.ax_sig, self.ax_mul]
        if self.circ_mode and self.ax_circ:
            axes.append(self.ax_circ)
        axes.append(self.ax_out)
        return axes

    # ── Signal acquisition ─────────────────────────────────────────────────────

    def _get_signal(self, which):
        title = f"Get {'x[n]' if which == 'x' else 'h[n]'}"
        current = self.sig_x if which == 'x' else self.sig_h
        sig = SignalDialog.get_signal(current_signal=current, title=title, parent=self)
        if sig is None:
            return
        if which == 'x':
            self.sig_x = sig
            self._draw_mini(self.ax_x, self.canvas_x, self.fig_x, sig, "Input")
        else:
            self.sig_h = sig
            self._draw_mini(self.ax_h, self.canvas_h, self.fig_h, sig,
                            "Impulse Response")
        if self.sig_x is not None and self.sig_h is not None:
            self._initialize()

    def _draw_mini(self, ax, canvas, fig, sig, title):
        ax.cla()
        ax.set_title(title, fontweight='bold', fontsize=8)
        ax.tick_params(labelsize=7)
        ax.axhline(0, color='k', lw=0.5)
        _stem_artists(ax, sig.xdata, sig.ydata)
        ax.set_ylim(_safe_ylim(sig.ydata))
        ax.set_xlim(sig.xdata[0] - 1, sig.xdata[-1] + 1)
        fig.tight_layout(pad=0.35)
        canvas.draw_idle()

    # ── Convolution engine ─────────────────────────────────────────────────────

    def _initialize(self):
        """Compute convolution and redraw everything.  Called after any state change."""
        self.initialized = False
        self.n = self._N_RESET

        # Decide which signal is fixed (blue) and which is the one that gets flipped
        if self.flip_which == 'h':
            sig, flip = self.sig_x, self.sig_h
        else:
            sig, flip = self.sig_h, self.sig_x

        # Full linear convolution  y = sig * flip
        self._out_y = np.convolve(sig.ydata, flip.ydata)
        x_start = int(sig.xdata[0]) + int(flip.xdata[0])
        self._out_x = np.arange(x_start, x_start + len(self._out_y), dtype=float)

        # Default circular length = min(len_x, len_h)
        self.circ_len = max(self._CIRC_LEN_RESET,
                            min(len(self.sig_x.xdata), len(self.sig_h.xdata)))

        self._build_axes()
        self.initialized = True
        self.lbl_hint.setVisible(False)
        self._draw()

    def _flipped(self, flip, n):
        """Return (xdata, ydata) of flip reversed and centred at n."""
        return n - flip.xdata[::-1], flip.ydata[::-1]

    # ── Drawing ────────────────────────────────────────────────────────────────

    def _draw(self):
        """Redraw all main axes from current state."""
        if not self.initialized:
            return

        sig = self.sig_x if self.flip_which == 'h' else self.sig_h
        flip = self.sig_h if self.flip_which == 'h' else self.sig_x
        flip_x, flip_y = self._flipped(flip, self.n)

        self._draw_signal_axis(sig, flip_x, flip_y)
        self._draw_multiply_axis(sig, flip_x, flip_y)
        self._draw_output_axis()
        if self.circ_mode and self.ax_circ is not None:
            self._draw_circ_axis()
        self.canvas.draw_idle()

    def _draw_signal_axis(self, sig, flip_x, flip_y):
        ax = self.ax_sig
        ax.cla()
        ax.set_xlim(self.xlim)
        ax.set_facecolor('white')
        ax.axhline(0, color='k', lw=0.5)
        ax.tick_params(labelsize=8)
        ax.set_xticklabels([])

        _stem_artists(ax, sig.xdata, sig.ydata, color='b')
        _stem_artists(ax, flip_x, flip_y, color='r')

        all_y = np.concatenate([sig.ydata, flip_y, [0.0]])
        ax.set_ylim(_safe_ylim(all_y))

        ylo = ax.get_ylim()[0]
        ax.annotate(f'↑ n = {self.n}', xy=(self.n, ylo),
                    fontsize=9, color='b', fontweight='bold',
                    ha='center', va='top')

        ax.text(0.01, 0.99, 'Signal', color='b', transform=ax.transAxes,
                va='top', fontsize=8, fontstyle='italic')
        ax.text(0.01, 0.88, 'Flipped Signal', color='r',
                transform=ax.transAxes, va='top', fontsize=8, fontstyle='italic')

    def _draw_multiply_axis(self, sig, flip_x, flip_y):
        ax = self.ax_mul
        ax.cla()
        ax.set_xlim(self.xlim)
        ax.set_facecolor('white')
        ax.axhline(0, color='k', lw=0.5)
        ax.tick_params(labelsize=8)
        ax.set_xticklabels([])

        sig_map  = {int(k): v for k, v in zip(sig.xdata,  sig.ydata)}
        flip_map = {int(k): v for k, v in zip(flip_x, flip_y)}
        common = sorted(set(sig_map) & set(flip_map))
        if common:
            x_c = np.array(common, dtype=float)
            y_c = np.array([sig_map[k] * flip_map[k] for k in common])
            _stem_artists(ax, x_c, y_c, color=self._COLOR_M)
            ax.set_ylim(_safe_ylim(np.concatenate([y_c, [0.0]])))
        else:
            ax.set_ylim(-1.0, 1.0)

        ax.text(0.01, 0.99, 'Multiplication', color=self._COLOR_M,
                transform=ax.transAxes, va='top', fontsize=8, fontstyle='italic')

    def _draw_output_axis(self):
        ax = self.ax_out
        ax.cla()
        ax.set_xlim(self.xlim)
        ax.set_facecolor('white')
        ax.axhline(0, color='k', lw=0.5)
        ax.tick_params(labelsize=8)

        out_x, out_y = self._out_x, self._out_y
        ylim = _safe_ylim(np.concatenate([out_y, [0.0]]))
        ax.set_ylim(ylim)

        if self.circ_mode:
            colors, markers = self._alias_colors(out_x)
        else:
            colors  = ['b'] * len(out_x)
            markers = ['o'] * len(out_x)

        n = self.n
        for xi, yi, c, mk in zip(out_x, out_y, colors, markers):
            xi_int = int(xi)
            is_n = (xi_int == n)
            col = self._COLOR_M if is_n else c
            lw  = 2.2  if is_n else 1.5
            ms  = 7    if is_n else 5
            ax.plot([xi, xi], [0, yi], color=col, lw=lw)
            ax.plot(xi, yi, mk, color=col, markerfacecolor=col, ms=ms)

        ax.annotate(f'↓ n = {n}', xy=(n, ylim[1]),
                    fontsize=9, color='b', fontweight='bold',
                    ha='center', va='bottom')

        ax.text(0.01, 0.99, 'Linear Convolution', color='b',
                transform=ax.transAxes, va='top', fontsize=8, fontstyle='italic')
        ax.set_xlabel('n', fontsize=8)

    def _draw_circ_axis(self):
        ax = self.ax_circ
        ax.cla()
        ax.set_xlim(self.xlim)
        ax.set_facecolor('white')
        ax.axhline(0, color='k', lw=0.5)
        ax.tick_params(labelsize=8)
        ax.set_xticklabels([])

        N = self.circ_len
        circ_y = alias(self._out_y, N, int(self._out_x[0]))
        circ_x = np.arange(N, dtype=float)
        _stem_artists(ax, circ_x, circ_y)
        ax.set_ylim(_safe_ylim(np.concatenate([circ_y, [0.0]])))

        # Period divider lines on output axis
        self._draw_period_lines()

        ax.text(0.01, 0.99, 'Circular Convolution', color='b',
                transform=ax.transAxes, va='top', fontsize=8, fontstyle='italic')
        ax.set_xlabel('n', fontsize=8)

    def _draw_period_lines(self):
        """Grey vertical lines on the output axis marking period boundaries."""
        N = self.circ_len
        ax = self.ax_out
        ylim = ax.get_ylim()
        xlo, xhi = self.xlim
        xs = np.arange(int(xlo / N) * N, int(xhi / N + 1) * N + 1, N, dtype=float)
        for xv in xs:
            ax.axvline(xv, color='#bbbbbb', lw=1.0, zorder=0)

    def _alias_colors(self, out_x):
        """Colour-code output stems to reveal aliasing in circular mode."""
        N = self.circ_len
        x_int = np.array([int(xi) for xi in out_x])
        n_tot = len(x_int)

        in_rng = (x_int >= 0) & (x_int < N)
        I = np.where(in_rng)[0]
        extra = np.where(~in_rng)[0]

        overlapped = set()
        if len(extra):
            wrapped = set(x_int[extra] % N)
            for i in I:
                if x_int[i] in wrapped:
                    overlapped.add(i)

        colors  = ['b'] * n_tot
        markers = ['o'] * n_tot
        for i in overlapped:
            colors[i]  = 'r'
            markers[i] = 's'          # square = aliased in-range sample
        for i in extra:
            colors[i]  = 'r'
            markers[i] = 'o'
        return colors, markers

    # ── Formula key ────────────────────────────────────────────────────────────

    def _refresh_key(self):
        if self.flip_which == 'h':
            blue, red = "x[k]", "h[n−k]"
            mul = "x[k]·h[n−k]"
        else:
            blue, red = "h[k]", "x[n−k]"
            mul = "h[k]·x[n−k]"
        conv = f"y[n] = Σ {mul}"

        lines = [
            "<b>Signal Axis:</b>",
            f"&nbsp;&nbsp;<font color='blue'>● = {blue}</font>",
            f"&nbsp;&nbsp;<font color='red'>● = {red}</font>",
            "<b>Multiplication Axis:</b>",
            f"&nbsp;&nbsp;<font color='#1a9933'>● = {mul}</font>",
            "<b>Convolution Axis:</b>",
            f"&nbsp;&nbsp;<font color='blue'>{conv}</font>",
        ]
        if self.circ_mode:
            lines += [
                "<b>Circular Conv. Axis:</b>",
                "&nbsp;&nbsp;<font color='blue'>y<sub>c</sub>[n] = Σ y[n−Nr]</font>",
            ]
        self.lbl_key.setText("<br>".join(lines))

    # ── Interaction ────────────────────────────────────────────────────────────

    def _on_flip(self, btn_id):
        self.flip_which = 'x' if btn_id == 0 else 'h'
        self._refresh_key()
        if self.initialized:
            self._initialize()

    def _on_circ_toggled(self, checked):
        self.circ_mode = checked
        self._refresh_key()
        if self.initialized:
            self._initialize()
        else:
            self._build_axes()

    def _on_press(self, event):
        if not self.initialized:
            return
        if event.inaxes in (self.ax_sig, self.ax_out) and event.button == 1:
            self._dragging  = True
            self._drag_x0   = event.xdata
            self._drag_n0   = self.n

    def _on_motion(self, event):
        if not self._dragging or event.xdata is None:
            return
        delta = int(round(event.xdata - self._drag_x0))
        new_n = self._drag_n0 + delta
        if new_n != self.n:
            self.n = new_n
            self._pan_if_needed()
            self._draw()

    def _on_release(self, _event):
        self._dragging = False

    def _pan_if_needed(self):
        lo, hi = self.xlim
        if self.n < lo:
            d = lo - self.n
            self.xlim = [lo - d, hi - d]
        elif self.n > hi:
            d = self.n - hi
            self.xlim = [lo + d, hi + d]

    def keyPressEvent(self, event):
        if self.initialized:
            key = event.key()
            if key in (Qt.Key.Key_Left,  Qt.Key.Key_4):
                self.n -= 1
                self._pan_if_needed()
                self._draw()
                return
            if key in (Qt.Key.Key_Right, Qt.Key.Key_6):
                self.n += 1
                self._pan_if_needed()
                self._draw()
                return
        super().keyPressEvent(event)


# ── Entry point ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = DConvDemo()
    win.show()
    sys.exit(app.exec())
