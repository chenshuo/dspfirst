#!/usr/bin/env python3
"""
CConvDemo — Continuous Convolution Demo

Visualises continuous-time convolution interactively:
    y(t) = ∫ x(τ) h(t−τ) dτ

Six panels:
  Top row   : x(t)  |  h(t)  |  formula key
  Bottom row: τ-domain signals  |  τ-domain product  |  output y(t)

A slider controls the current t value; signals can be dragged by clicking
on the signal or output axes.

Original MATLAB version by Jordan Rosenthal / J. McClellan (Georgia Tech, 1999–2017).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QDialog,
    QVBoxLayout, QHBoxLayout, QFormLayout,
    QLabel, QLineEdit, QPushButton, QComboBox, QRadioButton,
    QButtonGroup, QSizePolicy, QSlider, QInputDialog, QMessageBox,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec

VERSION   = '1.0'
XLIM      = (-10.0, 10.0)      # default axis x-limits
T_RESET   = -2.0                # initial t value
FS_MIN    = 1.0                 # minimum sample rate

# ---------------------------------------------------------------------------
# Signal classes
# ---------------------------------------------------------------------------

class Signal:
    """Abstract base for all continuous-time signal types."""
    is_impulse = False
    display_name = ''

    def eval(self, t: np.ndarray) -> np.ndarray:
        raise NotImplementedError

    def support(self) -> tuple:
        """Return (t_start, t_end) bounding interval."""
        raise NotImplementedError

    def suggest_rate(self, t_range=None) -> float:
        if t_range is None:
            t_range = self.support()
        span = abs(t_range[1] - t_range[0])
        return max(FS_MIN, 511.0 / span) if span > 0 else 512.0

    def sample(self, t_range=None, fs=None):
        if t_range is None:
            t_range = self.support()
        if fs is None:
            fs = self.suggest_rate(t_range)
        t = np.arange(t_range[0], t_range[1] + 0.5 / fs, 1.0 / fs)
        return t, self.eval(t)

    def formula_str(self) -> str:
        return self.display_name


class CPulse(Signal):
    display_name = 'Pulse'

    def __init__(self, amplitude=1.0, width=2.0, delay=0.0):
        self.amplitude = float(amplitude)
        self.width     = max(float(width), 1e-9)
        self.delay     = float(delay)

    def eval(self, t):
        t = np.asarray(t, float)
        return self.amplitude * ((self.delay <= t) & (t < self.delay + self.width)).astype(float)

    def support(self):
        return (self.delay, self.delay + self.width)

    def suggest_rate(self, t_range=None):
        return max(FS_MIN, 511.0 / self.width)

    def formula_str(self):
        A, W, d = self.amplitude, self.width, self.delay
        a = '' if abs(A - 1) < 1e-6 else ('-' if abs(A + 1) < 1e-6 else f'{A:.3g} ')
        def us(shift):
            return 'u(t)' if abs(shift) < 1e-6 else (
                f'u(t − {abs(shift):.3g})' if shift >= 0 else f'u(t + {abs(shift):.3g})')
        return f'{a}[{us(-d)} − {us(-(d+W))}]'


class CExponential(Signal):
    display_name = 'Exponential'

    def __init__(self, scaling_factor=1.0, exp_constant=0.5, length=10.0, delay=0.0, causal=True):
        self.scaling_factor = float(scaling_factor)
        self.exp_constant   = float(exp_constant)
        self.length         = max(float(length), 0.0)
        self.delay          = float(delay)
        self.causal         = bool(causal)

    def eval(self, t):
        t = np.asarray(t, float)
        A, a, d, L = self.scaling_factor, self.exp_constant, self.delay, self.length
        if self.causal:
            return A * np.exp(-a * (t - d)) * ((d <= t) & (t <= d + L))
        else:
            return A * np.exp(a * (t - d)) * ((d - L <= t) & (t <= d))

    def support(self):
        d, L = self.delay, self.length
        return (d, d + L) if self.causal else (d - L, d)

    def suggest_rate(self, t_range=None):
        return max(FS_MIN, 511.0 / max(self.length, 1e-9))

    def formula_str(self):
        A, a, d = self.scaling_factor, self.exp_constant, self.delay
        a_str = '' if abs(A - 1) < 1e-6 else ('-' if abs(A + 1) < 1e-6 else f'{A:.3g}')
        sgn = '−' if a >= 0 else '+'
        d_str = f' − {d:.3g}' if d > 1e-6 else (f' + {abs(d):.3g}' if d < -1e-6 else '')
        return f'{a_str}e^({sgn}{abs(a):.3g}(t{d_str})) · u({"" if self.causal else "−"}(t{d_str}))'


class CCosine(Signal):
    display_name = 'Cosine'

    def __init__(self, amplitude=1.0, period=10.0, phase=0.0, length=10.0, delay=0.0):
        self.amplitude = float(amplitude)
        self.period    = max(float(period), 1e-9)
        self.phase     = float(phase)
        self.length    = max(float(length), 1e-9)
        self.delay     = float(delay)

    def eval(self, t):
        t = np.asarray(t, float)
        A, T, phi, d, L = self.amplitude, self.period, self.phase, self.delay, self.length
        return A * np.cos(2 * np.pi / T * (t - d) + phi) * ((d <= t) & (t <= d + L))

    def support(self):
        return (self.delay, self.delay + self.length)

    def suggest_rate(self, t_range=None):
        return max(511.0 / max(self.length, 1e-9), 40.0 / self.period)

    def formula_str(self):
        A, T, phi = self.amplitude, self.period, self.phase
        a = '' if abs(A - 1) < 1e-6 else ('-' if abs(A + 1) < 1e-6 else f'{A:.3g}')
        w = 2.0 / T
        w_str = (f'{w:.3g}π' if abs(abs(w) - 1) > 1e-6 else ('π' if w > 0 else '-π'))
        ph = (f' + {phi/np.pi:.3g}π' if phi > 1e-6 else
              (f' − {-phi/np.pi:.3g}π' if phi < -1e-6 else ''))
        return f'{a}cos({w_str}t{ph}) · rect'


class CSine(Signal):
    display_name = 'Sine'

    def __init__(self, amplitude=1.0, period=10.0, phase=0.0, length=10.0, delay=0.0):
        self.amplitude = float(amplitude)
        self.period    = max(float(period), 1e-9)
        self.phase     = float(phase)
        self.length    = max(float(length), 1e-9)
        self.delay     = float(delay)

    def eval(self, t):
        t = np.asarray(t, float)
        A, T, phi, d, L = self.amplitude, self.period, self.phase, self.delay, self.length
        return A * np.sin(2 * np.pi / T * (t - d) + phi) * ((d <= t) & (t <= d + L))

    def support(self):
        return (self.delay, self.delay + self.length)

    def suggest_rate(self, t_range=None):
        return max(511.0 / max(self.length, 1e-9), 40.0 / self.period)

    def formula_str(self):
        A, T, phi = self.amplitude, self.period, self.phase
        a = '' if abs(A - 1) < 1e-6 else ('-' if abs(A + 1) < 1e-6 else f'{A:.3g}')
        w = 2.0 / T
        w_str = (f'{w:.3g}π' if abs(abs(w) - 1) > 1e-6 else ('π' if w > 0 else '-π'))
        ph = (f' + {phi/np.pi:.3g}π' if phi > 1e-6 else
              (f' − {-phi/np.pi:.3g}π' if phi < -1e-6 else ''))
        return f'{a}sin({w_str}t{ph}) · rect'


class CGaussian(Signal):
    display_name = 'Gaussian'

    def __init__(self, scaling_factor=1.0, exp_constant=0.5, length=10.0, delay=0.0):
        self.scaling_factor = float(scaling_factor)
        self.exp_constant   = max(float(exp_constant), 1e-9)
        self.length         = max(float(length), 1e-9)
        self.delay          = float(delay)

    def eval(self, t):
        t = np.asarray(t, float)
        A, a, d, L = self.scaling_factor, self.exp_constant, self.delay, self.length
        return A * np.exp(-a * (t - d) ** 2) * ((d - L/2 <= t) & (t <= d + L/2))

    def support(self):
        return (self.delay - self.length / 2, self.delay + self.length / 2)

    def suggest_rate(self, t_range=None):
        return max(FS_MIN, 511.0 / max(self.length, 1e-9))

    def formula_str(self):
        A, a, d = self.scaling_factor, self.exp_constant, self.delay
        a_str = '' if abs(A - 1) < 1e-6 else f'{A:.3g}'
        d_str = f' − {d:.3g}' if d > 1e-6 else (f' + {abs(d):.3g}' if d < -1e-6 else '')
        return f'{a_str}e^(−{a:.3g}(t{d_str})²)'


class CImpulse(Signal):
    display_name = 'Impulse'
    is_impulse   = True

    def __init__(self, area=1.0, delay=0.0):
        self.area  = float(area)
        self.delay = float(delay)

    def eval(self, t):
        return np.zeros_like(np.asarray(t, float))

    def support(self):
        return (self.delay, self.delay)

    def formula_str(self):
        a = ('' if abs(self.area - 1) < 1e-6
             else ('-' if abs(self.area + 1) < 1e-6 else f'{self.area:.3g}'))
        d = self.delay
        d_str = (f'(t − {d:.3g})' if d > 1e-6
                 else (f'(t + {abs(d):.3g})' if d < -1e-6 else '(t)'))
        return f'{a}δ{d_str}'


# Signal type registry: (display_name, class, default_params_dict)
SIGNAL_TYPES = [
    ('Pulse',       CPulse,       {'amplitude': 1.0, 'width': 2.0,  'delay': 0.0}),
    ('Exponential', CExponential, {'scaling_factor': 1.0, 'exp_constant': 0.5,
                                   'length': 10.0, 'delay': 0.0, 'causal': True}),
    ('Cosine',      CCosine,      {'amplitude': 1.0, 'period': 10.0, 'phase': 0.0,
                                   'length': 10.0, 'delay': 0.0}),
    ('Sine',        CSine,        {'amplitude': 1.0, 'period': 10.0, 'phase': 0.0,
                                   'length': 10.0, 'delay': 0.0}),
    ('Gaussian',    CGaussian,    {'scaling_factor': 1.0, 'exp_constant': 0.5,
                                   'length': 10.0, 'delay': 0.0}),
    ('Impulse',     CImpulse,     {'area': 1.0, 'delay': 0.0}),
]

# ---------------------------------------------------------------------------
# Convolution utilities
# ---------------------------------------------------------------------------

def overlap(supp1, supp2):
    """Return (max(a,c), min(b,d)) or None if supports do not intersect."""
    lo = max(supp1[0], supp2[0])
    hi = min(supp1[1], supp2[1])
    return (lo, hi) if lo < hi else None


def numerical_convolve(sig1: Signal, sig2: Signal):
    """
    Compute y(t) = sig1 * sig2 via FFT.
    Returns (t, y) arrays, or a special dict for impulse pairs.
    """
    imp1, imp2 = sig1.is_impulse, sig2.is_impulse

    if imp1 and imp2:
        return {'type': 'impulse', 'delay': sig1.delay + sig2.delay,
                'area': sig1.area * sig2.area}

    s1, s2 = sig1.support(), sig2.support()

    if imp1:
        # y(t) = area * sig2(t − delay)
        t_out = np.linspace(s2[0] + sig1.delay, s2[1] + sig1.delay, 600)
        return t_out, sig1.area * sig2.eval(t_out - sig1.delay)

    if imp2:
        t_out = np.linspace(s1[0] + sig2.delay, s1[1] + sig2.delay, 600)
        return t_out, sig2.area * sig1.eval(t_out - sig2.delay)

    # Both finite-support signals: FFT convolution
    fs = max(sig1.suggest_rate(s1), sig2.suggest_rate(s2)) * 2.0
    T  = 1.0 / fs
    t1 = np.arange(s1[0], s1[1] + T * 0.5, T)
    t2 = np.arange(s2[0], s2[1] + T * 0.5, T)
    y1, y2 = sig1.eval(t1), sig2.eval(t2)
    n_conv = len(y1) + len(y2) - 1
    n_fft  = int(2 ** np.ceil(np.log2(max(n_conv, 1))))
    y_full = np.real(np.fft.ifft(np.fft.fft(y1, n_fft) * np.fft.fft(y2, n_fft)))[:n_conv] * T

    out_lo = s1[0] + s2[0]
    out_hi = s1[1] + s2[1]
    pad    = (out_hi - out_lo) / 2.0
    t_core = np.linspace(out_lo, out_hi, len(y_full))
    t_out  = np.r_[out_lo - pad, out_lo, t_core, out_hi, out_hi + pad]
    y_out  = np.r_[0.0, 0.0, y_full, 0.0, 0.0]
    return t_out, y_out


# ---------------------------------------------------------------------------
# Signal generator dialog
# ---------------------------------------------------------------------------

_PARAM_DEFS = {
    CPulse:       [('Amplitude', 'amplitude'), ('Width',    'width'),
                   ('Delay',     'delay')],
    CExponential: [('Scaling Factor',    'scaling_factor'),
                   ('Exp Constant (a)',  'exp_constant'),
                   ('Length',            'length'),
                   ('Delay',             'delay'),
                   ('Causal (1) / Noncausal (0)', 'causal_int')],
    CCosine:      [('Amplitude', 'amplitude'), ('Period', 'period'),
                   ('Phase',     'phase'),     ('Length', 'length'),
                   ('Delay',     'delay')],
    CSine:        [('Amplitude', 'amplitude'), ('Period', 'period'),
                   ('Phase',     'phase'),     ('Length', 'length'),
                   ('Delay',     'delay')],
    CGaussian:    [('Scaling Factor',  'scaling_factor'),
                   ('Exp Constant (a)', 'exp_constant'),
                   ('Length',          'length'),
                   ('Delay',           'delay')],
    CImpulse:     [('Area', 'area'), ('Delay', 'delay')],
}


def _sig_to_dict(sig: Signal) -> dict:
    """Extract current parameter values from a signal object."""
    d = {}
    for _, attr in _PARAM_DEFS[type(sig)]:
        if attr == 'causal_int':
            d[attr] = 1.0 if sig.causal else 0.0
        elif hasattr(sig, attr):
            d[attr] = float(getattr(sig, attr))
    return d


def _dict_to_sig(cls, vals: dict) -> Signal:
    """Construct a signal from a parameter dict."""
    if cls is CPulse:
        return CPulse(vals['amplitude'], vals['width'], vals['delay'])
    if cls is CExponential:
        return CExponential(vals['scaling_factor'], vals['exp_constant'],
                            vals['length'], vals['delay'],
                            causal=bool(vals.get('causal_int', 1) > 0.5))
    if cls is CCosine:
        return CCosine(vals['amplitude'], vals['period'], vals['phase'],
                       vals['length'], vals['delay'])
    if cls is CSine:
        return CSine(vals['amplitude'], vals['period'], vals['phase'],
                     vals['length'], vals['delay'])
    if cls is CGaussian:
        return CGaussian(vals['scaling_factor'], vals['exp_constant'],
                         vals['length'], vals['delay'])
    if cls is CImpulse:
        return CImpulse(vals['area'], vals['delay'])
    return cls()


class SignalDialog(QDialog):
    def __init__(self, title='Get Signal', initial: Signal = None, parent=None):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setMinimumSize(620, 420)
        self.result: Signal = None

        # Determine initial type index
        self._cls_idx = 0
        if initial is not None:
            for i, (_, cls, _) in enumerate(SIGNAL_TYPES):
                if isinstance(initial, cls):
                    self._cls_idx = i
                    break
            self._sig = initial
        else:
            self._sig = SIGNAL_TYPES[0][1]()

        self._build()
        self._populate_params()
        self._refresh_preview()

    def _build(self):
        root = QVBoxLayout(self)

        # Type selector row
        top = QHBoxLayout()
        top.addWidget(QLabel('Signal:'))
        self.combo = QComboBox()
        for name, _, _ in SIGNAL_TYPES:
            self.combo.addItem(name)
        self.combo.setCurrentIndex(self._cls_idx)
        self.combo.currentIndexChanged.connect(self._on_type)
        top.addWidget(self.combo)
        top.addStretch()
        root.addLayout(top)

        # Middle: params | preview
        mid = QHBoxLayout()

        self._param_widget = QWidget()
        self._param_form   = QFormLayout(self._param_widget)
        self._param_form.setRowWrapPolicy(QFormLayout.RowWrapPolicy.WrapAllRows)
        self._edits: dict[str, QLineEdit] = {}
        mid.addWidget(self._param_widget, stretch=1)

        fig = Figure(figsize=(3.2, 2.8), tight_layout=True)
        self._preview_canvas = FigureCanvas(fig)
        self._preview_canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                            QSizePolicy.Policy.Expanding)
        self._preview_ax = fig.add_subplot(111)
        mid.addWidget(self._preview_canvas, stretch=2)
        root.addLayout(mid)

        # Buttons
        btns = QHBoxLayout()
        btns.addStretch()
        ok = QPushButton('OK')
        ok.setDefault(True)
        ok.clicked.connect(self._on_ok)
        btns.addWidget(ok)
        ca = QPushButton('Cancel')
        ca.clicked.connect(self.reject)
        btns.addWidget(ca)
        root.addLayout(btns)

    def _on_type(self, idx):
        self._cls_idx = idx
        self._sig = SIGNAL_TYPES[idx][1]()
        self._populate_params()
        self._refresh_preview()

    def _populate_params(self):
        while self._param_form.rowCount():
            self._param_form.removeRow(0)
        self._edits.clear()

        vals = _sig_to_dict(self._sig)
        for label, attr in _PARAM_DEFS[type(self._sig)]:
            ed = QLineEdit(f'{vals.get(attr, 0):.4g}')
            ed.editingFinished.connect(self._on_param_edit)
            self._edits[attr] = ed
            self._param_form.addRow(label + ':', ed)

    def _on_param_edit(self):
        vals = {}
        for attr, ed in self._edits.items():
            try:
                vals[attr] = float(ed.text())
            except ValueError:
                return
        try:
            self._sig = _dict_to_sig(type(self._sig), vals)
        except Exception:
            return
        self._refresh_preview()

    def _refresh_preview(self):
        ax = self._preview_ax
        ax.clear()
        sig = self._sig
        if sig.is_impulse:
            d, A = sig.delay, sig.area
            ax.annotate('', xy=(d, A), xytext=(d, 0),
                        arrowprops=dict(arrowstyle='->', color='blue', lw=2))
            ax.set_xlim(d - 5, d + 5)
            ax.set_ylim(-0.1, max(1.1, abs(A) * 1.2))
        else:
            supp = sig.support()
            pad  = max(0.5, (supp[1] - supp[0]) * 0.25)
            t    = np.linspace(supp[0] - pad, supp[1] + pad, 512)
            y    = sig.eval(t)
            ax.plot(t, y, 'b-', lw=1.5)
            ax.set_xlim(t[0], t[-1])
            ys = max(float(np.abs(y).max()), 1e-3)
            ax.set_ylim(-ys * 0.15, ys * 1.2)
        ax.axhline(0, color='k', lw=0.5)
        ax.set_title(sig.formula_str(), color='blue', fontsize=8)
        ax.set_xlabel('t', fontsize=9)
        ax.grid(True, alpha=0.3)
        self._preview_canvas.draw_idle()

    def _on_ok(self):
        self.result = self._sig
        self.accept()

    @classmethod
    def get_signal(cls, title='Get Signal', initial: Signal = None, parent=None):
        dlg = cls(title=title, initial=initial, parent=parent)
        return dlg.result if dlg.exec() == QDialog.DialogCode.Accepted else None


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class CConvDemoWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(f'Continuous Convolution Demo  v{VERSION}')

        self.x_sig: Signal = None
        self.h_sig: Signal = None
        self.flip_h        = True    # True = flip h(t); False = flip x(t)
        self.t_val         = T_RESET
        self.line_width    = 1.5
        self.grid_on       = True
        self.tutorial      = False

        # Cached precomputed data
        self._x_t = self._x_y = None   # x(t) sampled
        self._h_t = self._h_y = None   # h(t) sampled
        self._conv  = None              # result of numerical_convolve (t,y) or dict

        self._build_menu()
        self._build_ui()
        self._show_placeholder()

    # ------------------------------------------------------------------
    # Menu
    # ------------------------------------------------------------------
    def _build_menu(self):
        mb = self.menuBar()

        sig_m = mb.addMenu('Signal')
        for txt, which, sc in [('Get x(t)…', 'x', 'Ctrl+X'),
                                ('Get h(t)…', 'h', 'Ctrl+H')]:
            a = QAction(txt, self)
            a.setShortcut(sc)
            a.triggered.connect(lambda _, w=which: self._get_signal(w))
            sig_m.addAction(a)
        sig_m.addSeparator()
        a = QAction('Reset t', self)
        a.triggered.connect(self._reset_t)
        sig_m.addAction(a)

        view_m = mb.addMenu('View')
        self.act_grid = QAction('Grid', self, checkable=True, checked=True)
        self.act_grid.triggered.connect(self._toggle_grid)
        view_m.addAction(self.act_grid)
        self.act_tut = QAction('Tutorial Mode', self, checkable=True, checked=False)
        self.act_tut.triggered.connect(self._toggle_tutorial)
        view_m.addAction(self.act_tut)

        opt_m = mb.addMenu('Options')
        a = QAction('Line Width…', self)
        a.triggered.connect(self._change_lw)
        opt_m.addAction(a)
        a = QAction('Set t…', self)
        a.triggered.connect(self._set_t_dlg)
        opt_m.addAction(a)

        help_m = mb.addMenu('Help')
        a = QAction('About', self)
        a.triggered.connect(self._about)
        help_m.addAction(a)

    # ------------------------------------------------------------------
    # Central widget
    # ------------------------------------------------------------------
    def _build_ui(self):
        root = QWidget()
        self.setCentralWidget(root)
        vbox = QVBoxLayout(root)
        vbox.setContentsMargins(4, 4, 4, 4)
        vbox.setSpacing(4)

        # ── Figure ───────────────────────────────────────────────────
        self.fig    = Figure(figsize=(12, 6))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        vbox.addWidget(self.canvas, stretch=1)

        gs = gridspec.GridSpec(2, 3, figure=self.fig,
                               left=0.06, right=0.98, top=0.93, bottom=0.08,
                               hspace=0.50, wspace=0.38)
        self.ax_x    = self.fig.add_subplot(gs[0, 0])
        self.ax_h    = self.fig.add_subplot(gs[0, 1])
        self.ax_txt  = self.fig.add_subplot(gs[0, 2])
        self.ax_sig  = self.fig.add_subplot(gs[1, 0])
        self.ax_mul  = self.fig.add_subplot(gs[1, 1])
        self.ax_out  = self.fig.add_subplot(gs[1, 2])

        for ax, lbl in [(self.ax_x,   'Input  x(t)'),
                        (self.ax_h,   'Impulse Response  h(t)'),
                        (self.ax_sig, 'τ-domain  (Signals)'),
                        (self.ax_mul, 'τ-domain  (Product)'),
                        (self.ax_out, 'Output  y(t)')]:
            ax.set_title(lbl, fontsize=8, fontweight='bold')
            ax.axhline(0, color='k', lw=0.5)
            ax.grid(self.grid_on)
            ax.set_xlim(*XLIM)

        self.ax_txt.axis('off')
        self._ftexts = []
        self._redraw_formula_key()

        self.canvas.mpl_connect('button_press_event', self._canvas_click)

        # ── Controls ─────────────────────────────────────────────────
        ctrl = QHBoxLayout()
        ctrl.setSpacing(8)

        btn_x = QPushButton('Get x(t)…')
        btn_x.clicked.connect(lambda: self._get_signal('x'))
        btn_h = QPushButton('Get h(t)…')
        btn_h.clicked.connect(lambda: self._get_signal('h'))
        ctrl.addWidget(btn_x)
        ctrl.addWidget(btn_h)
        ctrl.addSpacing(10)

        ctrl.addWidget(QLabel('Flip:'))
        self.rb_flip_h = QRadioButton('h(t)')
        self.rb_flip_x = QRadioButton('x(t)')
        self.rb_flip_h.setChecked(True)
        grp = QButtonGroup(self)
        grp.addButton(self.rb_flip_h)
        grp.addButton(self.rb_flip_x)
        self.rb_flip_h.toggled.connect(self._flip_changed)
        self.rb_flip_x.toggled.connect(self._flip_changed)
        ctrl.addWidget(self.rb_flip_h)
        ctrl.addWidget(self.rb_flip_x)
        ctrl.addSpacing(10)

        ctrl.addWidget(QLabel('t ='))
        self.lbl_t = QLabel(f'{self.t_val:.2f}')
        self.lbl_t.setFixedWidth(40)
        self.slider = QSlider(Qt.Orientation.Horizontal)
        self.slider.setMinimum(int(XLIM[0] * 100))
        self.slider.setMaximum(int(XLIM[1] * 100))
        self.slider.setValue(int(self.t_val * 100))
        self.slider.setSingleStep(10)
        self.slider.setPageStep(100)
        self.slider.valueChanged.connect(self._on_slider)
        ctrl.addWidget(self.slider, stretch=1)
        ctrl.addWidget(self.lbl_t)
        ctrl.addSpacing(8)

        btn_reset = QPushButton('Reset t')
        btn_reset.clicked.connect(self._reset_t)
        ctrl.addWidget(btn_reset)

        vbox.addLayout(ctrl)
        self.setMinimumSize(950, 620)

    # ------------------------------------------------------------------
    # Formula key (top-right panel)
    # ------------------------------------------------------------------
    def _redraw_formula_key(self):
        for txt in self._ftexts:
            txt.remove()
        self._ftexts.clear()
        ax = self.ax_txt
        ax.clear()
        ax.axis('off')

        if self.flip_h:
            blue, red = 'x(τ)', 'h(t−τ)'
            mul_str   = 'x(τ) · h(t−τ)'
            conv_str  = 'y(t) = ∫ x(τ)h(t−τ)dτ'
        else:
            blue, red = 'h(τ)', 'x(t−τ)'
            mul_str   = 'h(τ) · x(t−τ)'
            conv_str  = 'y(t) = ∫ h(τ)x(t−τ)dτ'

        rows = [
            (0.05, 0.94, 'Signal Axis:',           'k', 'left',   9, 'bold'),
            (0.50, 0.82, f'{blue} = blue',          'b', 'center', 8, 'normal'),
            (0.50, 0.70, f'{red} = red',            'r', 'center', 8, 'normal'),
            (0.05, 0.58, 'Multiplication Axis:',    'k', 'left',   9, 'bold'),
            (0.50, 0.46, mul_str,                   'b', 'center', 8, 'normal'),
            (0.05, 0.34, 'Convolution Axis:',       'k', 'left',   9, 'bold'),
            (0.50, 0.22, conv_str,                  'b', 'center', 8, 'normal'),
        ]
        for x, y, s, c, ha, fs, fw in rows:
            t = ax.text(x, y, s, transform=ax.transAxes, color=c, ha=ha,
                        va='top', fontsize=fs, fontweight=fw)
            self._ftexts.append(t)

    # ------------------------------------------------------------------
    # Signal selection / resampling
    # ------------------------------------------------------------------
    def _get_signal(self, which):
        title = 'Get x(t)' if which == 'x' else 'Get h(t)'
        init  = self.x_sig if which == 'x' else self.h_sig
        sig   = SignalDialog.get_signal(title=title, initial=init, parent=self)
        if sig is None:
            return
        if which == 'x':
            self.x_sig = sig
        else:
            self.h_sig = sig
        self._resample()
        self._draw_individual()
        if self.x_sig is not None and self.h_sig is not None:
            self._recompute_conv()
            self._update_dynamic()

    def _resample(self):
        self._x_t = self._x_y = None
        self._h_t = self._h_y = None
        for sig, attr_t, attr_y in [(self.x_sig, '_x_t', '_x_y'),
                                     (self.h_sig, '_h_t', '_h_y')]:
            if sig is not None and not sig.is_impulse:
                supp = sig.support()
                fs   = sig.suggest_rate()
                T    = 1.0 / fs
                t    = np.arange(supp[0], supp[1] + T * 0.5, T)
                setattr(self, attr_t, t)
                setattr(self, attr_y, sig.eval(t))

    def _recompute_conv(self):
        self._conv = None
        if self.x_sig is not None and self.h_sig is not None:
            self._conv = numerical_convolve(self.x_sig, self.h_sig)

    # ------------------------------------------------------------------
    # Static plots: x(t) and h(t) panels
    # ------------------------------------------------------------------
    def _draw_individual(self):
        for sig, ax, lbl in [(self.x_sig, self.ax_x, 'Input  x(t)'),
                              (self.h_sig, self.ax_h, 'Impulse Response  h(t)')]:
            ax.clear()
            ax.axhline(0, color='k', lw=0.5)
            ax.grid(self.grid_on)
            ax.set_xlim(*XLIM)
            if sig is None:
                ax.set_title(lbl, fontsize=8, fontweight='bold')
                ax.text(0.5, 0.5, '(not set)', transform=ax.transAxes,
                        ha='center', va='center', color='gray', fontsize=9)
                continue
            if sig.is_impulse:
                self._arrow(ax, sig.delay, sig.area, 'blue')
                ax.set_xlim(sig.delay - 5, sig.delay + 5)
                ax.set_ylim(-0.1, max(1.1, abs(sig.area) * 1.2))
            else:
                supp = sig.support()
                pad  = max(0.5, (supp[1] - supp[0]) * 0.25)
                t    = np.linspace(supp[0] - pad, supp[1] + pad, 600)
                y    = sig.eval(t)
                ax.plot(t, y, 'b-', lw=self.line_width)
                _yscale(ax, y)
            ax.set_title(f'{lbl}\n{sig.formula_str()}', fontsize=7, fontweight='bold')
        self.canvas.draw_idle()

    def _show_placeholder(self):
        for ax, msg in [(self.ax_sig, 'Pick x(t) and h(t)\nthen slide t'),
                        (self.ax_mul, ''),
                        (self.ax_out, '')]:
            ax.text(0.5, 0.5, msg, transform=ax.transAxes,
                    ha='center', va='center', color='gray', fontsize=9)
        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Dynamic update (called when t changes or signals change)
    # ------------------------------------------------------------------
    def _update_dynamic(self):
        if self.x_sig is None or self.h_sig is None:
            return
        t = self.t_val

        # Identify blue (non-flipped) and red (flipped) signals
        if self.flip_h:
            blue_sig, bt, by = self.x_sig, self._x_t, self._x_y
            red_sig = self.h_sig
        else:
            blue_sig, bt, by = self.h_sig, self._h_t, self._h_y
            red_sig = self.x_sig

        # ── τ-domain Signal axis ──────────────────────────────────────
        ax = self.ax_sig
        ax.clear()
        ax.set_title('τ-domain  (Signals)', fontsize=8, fontweight='bold')
        ax.axhline(0, color='k', lw=0.5)
        ax.grid(self.grid_on)
        ax.set_xlim(*XLIM)

        if blue_sig.is_impulse:
            self._arrow(ax, blue_sig.delay, blue_sig.area, 'blue')
        else:
            ax.plot(bt, by, 'b-', lw=self.line_width)

        if red_sig.is_impulse:
            tau_imp = t - red_sig.delay   # impulse appears at τ = t − delay
            self._arrow(ax, tau_imp, red_sig.area, 'red')
        else:
            supp_r = red_sig.support()
            n_pts  = max(300, int((supp_r[1] - supp_r[0]) * red_sig.suggest_rate() * 0.5))
            tau_r  = np.linspace(t - supp_r[1], t - supp_r[0], n_pts)
            y_r    = red_sig.eval(t - tau_r)
            ax.plot(tau_r, y_r, 'r-', lw=self.line_width)

        blue_lbl = 'x(τ)' if self.flip_h else 'h(τ)'
        red_lbl  = 'h(t−τ)' if self.flip_h else 'x(t−τ)'
        ax.text(0.01, 0.98, blue_lbl, transform=ax.transAxes,
                color='blue', va='top', fontsize=8, fontstyle='italic')
        ax.text(0.01, 0.86, red_lbl,  transform=ax.transAxes,
                color='red',  va='top', fontsize=8, fontstyle='italic')
        ylim = ax.get_ylim()
        ax.text(t, ylim[0], f'↑ t={t:.2f}', ha='center', va='bottom',
                fontsize=7, color='blue')

        # ── τ-domain Multiply axis ────────────────────────────────────
        ax = self.ax_mul
        ax.clear()
        ax.set_title('τ-domain  (Product)', fontsize=8, fontweight='bold')
        ax.axhline(0, color='k', lw=0.5)
        ax.grid(self.grid_on)
        ax.set_xlim(*XLIM)
        self._draw_product(blue_sig, red_sig, t, ax)

        # ── Output axis ───────────────────────────────────────────────
        self._draw_output(t)

        self.canvas.draw_idle()

    def _draw_product(self, blue: Signal, red: Signal, t: float, ax):
        """Fill the product blue(τ)·red(t−τ) in the multiply axis."""
        if blue.is_impulse and red.is_impulse:
            if abs(blue.delay - (t - red.delay)) < 0.5:
                A = blue.area * red.area
                self._arrow(ax, blue.delay, A, 'green')
            ax.set_ylim(-1, 2)
            return

        if blue.is_impulse:
            tau0 = blue.delay
            supp_r_flipped = (t - red.support()[1], t - red.support()[0])
            if supp_r_flipped[0] < tau0 < supp_r_flipped[1]:
                val = blue.area * red.eval(np.array([t - tau0]))[0]
                self._arrow(ax, tau0, val, 'green')
            ax.set_ylim(-1, 2)
            return

        if red.is_impulse:
            tau0   = t - red.delay
            supp_b = blue.support()
            if supp_b[0] <= tau0 <= supp_b[1]:
                val = red.area * blue.eval(np.array([tau0]))[0]
                self._arrow(ax, tau0, val, 'green')
            ax.set_ylim(-1, 2)
            return

        supp_b         = blue.support()
        supp_r_flipped = (t - red.support()[1], t - red.support()[0])
        ov             = overlap(supp_b, supp_r_flipped)
        if ov is None:
            ax.set_ylim(-1, 1)
            return

        fs  = max(blue.suggest_rate(ov), red.suggest_rate(ov))
        tau = np.arange(ov[0], ov[1] + 0.5 / fs, 1.0 / fs)
        if len(tau) < 2:
            ax.set_ylim(-1, 1)
            return
        y   = blue.eval(tau) * red.eval(t - tau)
        tau_p = np.r_[tau[0], tau, tau[-1]]
        y_p   = np.r_[0.0, y, 0.0]
        ax.fill(tau_p, y_p, color='lightgreen', edgecolor='blue', lw=0.8)
        ax.plot(tau_p, y_p, 'b-', lw=self.line_width * 0.6)
        _yscale(ax, y)

    def _draw_output(self, t: float):
        ax = self.ax_out
        ax.clear()
        ax.set_title('Output  y(t)', fontsize=8, fontweight='bold')
        ax.axhline(0, color='k', lw=0.5)
        ax.grid(self.grid_on)
        ax.set_xlim(*XLIM)

        if self.tutorial:
            ax.text(0.5, 0.5, 'Tutorial Mode\n(result hidden)', transform=ax.transAxes,
                    ha='center', va='center', fontsize=10, color='gray')
            return

        if self._conv is None:
            return

        # Impulse × impulse result
        if isinstance(self._conv, dict):
            d, A = self._conv['delay'], self._conv['area']
            self._arrow(ax, d, A, 'blue')
            ax.set_ylim(-0.1, max(1.1, abs(A) * 1.2))
            ax.text(0.01, 0.98, 'Convolution', transform=ax.transAxes,
                    color='blue', va='top', fontsize=8, fontstyle='italic')
            return

        ct, cy = self._conv
        ax.plot(ct, cy, 'b-', lw=self.line_width, label='y(t)')

        # Highlight y at current t
        idx   = int(np.argmin(np.abs(ct - t)))
        y_now = cy[idx]
        ax.plot([t, t], [0, y_now], 'g-', lw=2)
        ax.plot(t, y_now, 'go', ms=6)

        _yscale(ax, cy)
        ylim = ax.get_ylim()
        ax.text(t, ylim[1], f'↓ t={t:.2f}', ha='center', va='top',
                fontsize=7, color='blue')
        ax.text(0.01, 0.98, 'Convolution', transform=ax.transAxes,
                color='blue', va='top', fontsize=8, fontstyle='italic')

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def _arrow(self, ax, delay, area, color):
        ax.annotate('', xy=(delay, area), xytext=(delay, 0),
                    arrowprops=dict(arrowstyle='->', color=color,
                                    lw=self.line_width))
        ax.text(delay + 0.15, area / 2, f'{area:.3g}δ',
                color=color, fontsize=7, va='center')

    # ------------------------------------------------------------------
    # Event handlers
    # ------------------------------------------------------------------
    def _on_slider(self, val):
        self.t_val = val / 100.0
        self.lbl_t.setText(f'{self.t_val:.2f}')
        if self.x_sig is not None and self.h_sig is not None:
            self._update_dynamic()

    def _canvas_click(self, event):
        """Click in signal or output axis jumps t to that x position."""
        if event.inaxes in (self.ax_sig, self.ax_out) and event.xdata is not None:
            new_t = float(np.clip(event.xdata, XLIM[0], XLIM[1]))
            self.slider.setValue(int(new_t * 100))

    def _flip_changed(self, checked):
        if checked:
            self.flip_h = self.rb_flip_h.isChecked()
            self._redraw_formula_key()
            if self.x_sig is not None and self.h_sig is not None:
                self._update_dynamic()

    def _reset_t(self):
        self.slider.setValue(int(T_RESET * 100))

    def _toggle_grid(self, on):
        self.grid_on = on
        for ax in (self.ax_x, self.ax_h, self.ax_sig, self.ax_mul, self.ax_out):
            ax.grid(on)
        self.canvas.draw_idle()

    def _toggle_tutorial(self, on):
        self.tutorial = on
        if self.x_sig is not None and self.h_sig is not None:
            self._draw_output(self.t_val)
            self.canvas.draw_idle()

    def _change_lw(self):
        lw, ok = QInputDialog.getDouble(self, 'Line Width', 'Enter line width:',
                                         self.line_width, 0.5, 10.0, 1)
        if ok:
            self.line_width = lw
            self._draw_individual()
            if self.x_sig is not None and self.h_sig is not None:
                self._update_dynamic()

    def _set_t_dlg(self):
        val, ok = QInputDialog.getDouble(self, 'Set t', 'Value for t:',
                                          self.t_val, XLIM[0], XLIM[1], 2)
        if ok:
            self.slider.setValue(int(val * 100))

    def _about(self):
        QMessageBox.about(
            self, 'About CConvDemo',
            f'<b>Continuous Convolution Demo  v{VERSION}</b><br><br>'
            'Interactively visualises continuous-time convolution:<br>'
            '&nbsp;&nbsp;&nbsp;y(t) = ∫ x(τ) h(t−τ) dτ<br><br>'
            '<b>Usage:</b><br>'
            '• Click <i>Get x(t)…</i> and <i>Get h(t)…</i> to pick signals.<br>'
            '• Drag the t-slider (or click any plot) to change t.<br>'
            '• Choose which signal to flip with the radio buttons.<br>'
            '• Enable Tutorial Mode to hide y(t) as a student exercise.<br><br>'
            'Original MATLAB version by Jordan Rosenthal &amp; J. McClellan<br>'
            '(Georgia Tech, 1999–2017).<br><br>'
            'Python / PyQt6 port, 2026.')


# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

def _yscale(ax, y):
    if len(y) == 0:
        ax.set_ylim(-1, 1)
        return
    lo, hi = float(np.min(y)), float(np.max(y))
    span   = max(abs(hi - lo), 1e-6)
    ax.set_ylim(min(0.0, lo) - span * 0.12, max(0.0, hi) + span * 0.12)


# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    app.setApplicationName('CConvDemo')
    win = CConvDemoWindow()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
