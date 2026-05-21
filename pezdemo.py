#!/usr/bin/env python3
"""
PezDemo — Pole-Zero Demo (z-domain / Discrete-Time)

Interactive placement and dragging of poles (×) and zeros (○) in the
z-plane.  Magnitude/phase frequency response and impulse response update
in real time.

  • Default mode: click and drag existing poles or zeros.
  • Switch to Add Pole / Add Zero mode via the Edit menu or mode buttons.
  • Enter exact coordinates in the text fields and press Add or Edit.
  • "Add Conjugate" keeps conjugate-symmetric pairs together.

Original MATLAB version by J. McClellan / J. Rosenthal et al.
(Georgia Tech, 1994-2016).  Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
import scipy.signal
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QListWidget, QCheckBox,
    QGroupBox, QSizePolicy, QMessageBox,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec

VERSION   = '2.9'
N_FFT     = 512     # frequency-response sample count
N_IMP     = 25      # impulse-response length
DRAG_TOL  = 0.08    # z-plane pick tolerance (data units)
ZOOM_INIT = 1.5
ZOOM_STEP = 0.225

_SUP = str.maketrans('0123456789', '⁰¹²³⁴⁵⁶⁷⁸⁹')


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------

class PezModel:
    """Holds poles/zeros/gain; computes H(z) frequency and impulse response."""

    def __init__(self):
        self.poles: list = []
        self.zeros: list = []
        self.k     = 1.0
        self.a     = np.array([1.0])
        self.b     = np.array([1.0])
        self.hz    = np.ones(N_FFT, dtype=complex)
        self.hn    = np.zeros(N_IMP)
        self.hn[0] = 1.0

    def recalculate(self):
        self.a = np.poly(self.poles) if self.poles else np.array([1.0])
        self.b = np.poly(self.zeros) if self.zeros else np.array([1.0])
        Bf = np.fft.fft(self.k * self.b, N_FFT)
        Af = np.fft.fft(self.a, N_FFT)
        with np.errstate(divide='ignore', invalid='ignore'):
            self.hz = np.fft.fftshift(Bf / Af)
        delta = np.zeros(N_IMP)
        delta[0] = 1.0
        try:
            self.hn = scipy.signal.lfilter(
                np.real(self.k * self.b), np.real(self.a), delta)
        except Exception:
            self.hn = np.zeros(N_IMP)

    def is_stable(self) -> bool:
        return all(abs(p) < 1.0 for p in self.poles) if self.poles else True

    def is_real_valued(self) -> bool:
        h = self.hn
        return bool(np.all(np.abs(np.imag(h)) < 1e-4)) if np.iscomplexobj(h) else True


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class PezMainWindow(QMainWindow):

    def __init__(self):
        super().__init__()
        self.model          = PezModel()
        self._zoom          = ZOOM_INIT
        self._add_mode      = 'drag'
        self._add_conjugate = True
        self._drag_target   = None   # (kind, idx) | ('ray', 0) | None
        self._drag_conj_idx = None
        self._mode_btns: dict = {}
        self._mult_texts: list = []

        self._init_ui()
        self._init_plots()
        self._refresh_all()

    # ------------------------------------------------------------------
    # UI
    # ------------------------------------------------------------------

    def _init_ui(self):
        self.setWindowTitle(f'Pole-Zero Demo  v{VERSION}')
        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setSpacing(4)

        # Canvas
        self.fig    = Figure(figsize=(8, 7))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        root.addWidget(self.canvas, stretch=3)

        # Controls panel
        ctrl = QWidget()
        ctrl.setFixedWidth(265)
        vbox = QVBoxLayout(ctrl)
        vbox.setSpacing(5)
        root.addWidget(ctrl)

        # Gain
        row = QHBoxLayout()
        row.addWidget(QLabel('Gain  k :'))
        self.edit_gain = QLineEdit('1')
        self.edit_gain.setFixedWidth(58)
        self.edit_gain.returnPressed.connect(self._gain_changed)
        row.addWidget(self.edit_gain)
        row.addStretch()
        vbox.addLayout(row)

        # Poles
        pg = QGroupBox('Poles  ×')
        pgl = QVBoxLayout(pg)
        self.list_poles = QListWidget()
        self.list_poles.setFixedHeight(88)
        self.list_poles.currentRowChanged.connect(self._pole_sel)
        pgl.addWidget(self.list_poles)
        self.edit_pole = QLineEdit()
        self.edit_pole.setPlaceholderText('real , imag   e.g.  0.5 , 0.3')
        pgl.addWidget(self.edit_pole)
        pb = QHBoxLayout()
        for lbl, slot in (('Add',  self._add_pole_btn),
                           ('Edit', self._edit_pole),
                           ('Del',  self._del_pole)):
            b = QPushButton(lbl); b.clicked.connect(slot); pb.addWidget(b)
        pgl.addLayout(pb)
        vbox.addWidget(pg)

        # Zeros
        zg = QGroupBox('Zeros  ○')
        zgl = QVBoxLayout(zg)
        self.list_zeros = QListWidget()
        self.list_zeros.setFixedHeight(88)
        self.list_zeros.currentRowChanged.connect(self._zero_sel)
        zgl.addWidget(self.list_zeros)
        self.edit_zero = QLineEdit()
        self.edit_zero.setPlaceholderText('real , imag   e.g.  0.5 , 0.3')
        zgl.addWidget(self.edit_zero)
        zb = QHBoxLayout()
        for lbl, slot in (('Add',  self._add_zero_btn),
                           ('Edit', self._edit_zero),
                           ('Del',  self._del_zero)):
            b = QPushButton(lbl); b.clicked.connect(slot); zb.addWidget(b)
        zgl.addLayout(zb)
        vbox.addWidget(zg)

        # Options
        self.cb_conj = QCheckBox('Add Conjugate')
        self.cb_conj.setChecked(True)
        self.cb_conj.toggled.connect(lambda v: setattr(self, '_add_conjugate', v))
        vbox.addWidget(self.cb_conj)

        self.cb_grid = QCheckBox('Grid')
        self.cb_grid.toggled.connect(self._toggle_grid)
        vbox.addWidget(self.cb_grid)

        # Status
        self.lbl_stable = QLabel('stable')
        self.lbl_real   = QLabel('real')
        vbox.addWidget(self.lbl_stable)
        vbox.addWidget(self.lbl_real)

        # Click mode
        mg = QGroupBox('Click mode (z-plane)')
        mgl = QVBoxLayout(mg)
        for key, label in (('drag',     'Drag  (default)'),
                            ('add_pole', 'Click → Add Pole'),
                            ('add_zero', 'Click → Add Zero')):
            b = QPushButton(label)
            b.setCheckable(True)
            b.clicked.connect(lambda _, k=key: self._set_mode(k))
            mgl.addWidget(b)
            self._mode_btns[key] = b
        self._mode_btns['drag'].setChecked(True)
        vbox.addWidget(mg)

        # Utility buttons
        btn_clear = QPushButton('Clear All')
        btn_clear.clicked.connect(self._del_all)
        vbox.addWidget(btn_clear)

        # Zoom
        zrow = QHBoxLayout()
        zrow.addWidget(QLabel('Zoom:'))
        for sym, d in (('+', -ZOOM_STEP), ('-', +ZOOM_STEP)):
            b = QPushButton(sym)
            b.setFixedWidth(28)
            b.clicked.connect(lambda _, delta=d: self._do_zoom(delta))
            zrow.addWidget(b)
        zrow.addStretch()
        vbox.addLayout(zrow)

        # H(z) formula
        vbox.addWidget(QLabel('H(z) :'))
        self.lbl_formula = QLabel()
        self.lbl_formula.setWordWrap(True)
        self.lbl_formula.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.lbl_formula.setStyleSheet('font-family: monospace; font-size: 10pt;')
        vbox.addWidget(self.lbl_formula)

        vbox.addStretch()

        self._build_menu()

    def _build_menu(self):
        mb = self.menuBar()

        fm = mb.addMenu('&File')
        a = QAction('E&xit', self)
        a.triggered.connect(self.close)
        fm.addAction(a)

        em = mb.addMenu('&Edit')
        for label, slot in (
            ('Add Pole mode',  lambda: self._set_mode('add_pole')),
            ('Add Zero mode',  lambda: self._set_mode('add_zero')),
            ('Drag mode',      lambda: self._set_mode('drag')),
            (None, None),
            ('Delete All Poles', self._del_all_poles),
            ('Delete All Zeros', self._del_all_zeros),
            ('Clear All',        self._del_all),
        ):
            if label is None:
                em.addSeparator()
            else:
                a = QAction(label, self)
                a.triggered.connect(slot)
                em.addAction(a)

    # ------------------------------------------------------------------
    # Plots
    # ------------------------------------------------------------------

    def _init_plots(self):
        gs = gridspec.GridSpec(
            3, 2, figure=self.fig,
            width_ratios=[1, 1], height_ratios=[2, 1, 1],
            hspace=0.50, wspace=0.42,
            left=0.08, right=0.97, top=0.95, bottom=0.07,
        )
        self.ax_pz    = self.fig.add_subplot(gs[0:2, 0])
        self.ax_mag   = self.fig.add_subplot(gs[0, 1])
        self.ax_phase = self.fig.add_subplot(gs[1, 1])
        self.ax_imp   = self.fig.add_subplot(gs[2, :])

        # --- Z-plane background ---
        th = np.linspace(0, 2 * np.pi, 300)
        self.ax_pz.plot(np.cos(th), np.sin(th), 'k:', lw=1, zorder=1)
        self.ax_pz.axhline(0, color='k', lw=0.5, ls=':', zorder=1)
        self.ax_pz.axvline(0, color='k', lw=0.5, ls=':', zorder=1)
        self.ax_pz.set_aspect('equal', adjustable='datalim')
        L = self._zoom
        self.ax_pz.set_xlim(-L, L)
        self.ax_pz.set_ylim(-L, L)
        self.ax_pz.set_xlabel('Re(z)')
        self.ax_pz.set_ylabel('Im(z)')
        self.ax_pz.set_title('Pole-Zero Plot  (z-plane)')

        self.ln_poles,    = self.ax_pz.plot([], [], 'bx',  ms=12, mew=2.5, ls='none', zorder=3)
        self.ln_zeros,    = self.ax_pz.plot([], [], 'bo',  ms=9,  mew=2.0, ls='none',
                                             fillstyle='none', zorder=3)
        self.ln_sel_pole, = self.ax_pz.plot([], [], 'mx',  ms=12, mew=2.5, ls='none', zorder=4)
        self.ln_sel_zero, = self.ax_pz.plot([], [], 'mo',  ms=9,  mew=2.0, ls='none',
                                             fillstyle='none', zorder=4)

        # --- Magnitude response ---
        omega = np.linspace(-np.pi, np.pi, N_FFT)
        self.ln_mag, = self.ax_mag.plot(omega, np.ones(N_FFT), 'b', lw=2)
        self.ax_mag.set_xlim(-np.pi, np.pi)
        self.ax_mag.set_ylim(0, 2.5)
        self.ax_mag.set_xlabel('ω  (rad/sample)')
        self.ax_mag.set_ylabel('|H(eʲω)|')
        self.ax_mag.set_title('Magnitude Response')
        self.ax_mag.set_xticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
        self.ax_mag.set_xticklabels(['-π', '-π/2', '0', 'π/2', 'π'])
        self.ln_ray_mag = self.ax_mag.axvline(np.pi / 4, color='r', lw=1.5)

        # --- Phase response ---
        self.ln_phase, = self.ax_phase.plot(omega, np.zeros(N_FFT), 'b', lw=2)
        self.ax_phase.set_xlim(-np.pi, np.pi)
        self.ax_phase.set_ylim(-np.pi - 0.3, np.pi + 0.3)
        self.ax_phase.set_xlabel('ω  (rad/sample)')
        self.ax_phase.set_ylabel('∠H(eʲω)')
        self.ax_phase.set_title('Phase Response')
        self.ax_phase.set_xticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
        self.ax_phase.set_xticklabels(['-π', '-π/2', '0', 'π/2', 'π'])
        self.ln_ray_phase = self.ax_phase.axvline(np.pi / 4, color='r', lw=1.5)

        # --- Impulse response ---
        self.ln_imp_stems, = self.ax_imp.plot([], [], 'b-',  lw=1.5)
        self.ln_imp_dots,  = self.ax_imp.plot([], [], 'bo',  ms=5)
        self.ax_imp.axhline(0, color='k', lw=0.5)
        self.ax_imp.set_xlabel('n')
        self.ax_imp.set_ylabel('h[n]')
        self.ax_imp.set_title('Impulse Response')
        self.ax_imp.set_xlim(-1, N_IMP)

        self.canvas.mpl_connect('button_press_event',   self._on_press)
        self.canvas.mpl_connect('motion_notify_event',  self._on_motion)
        self.canvas.mpl_connect('button_release_event', self._on_release)

    # ------------------------------------------------------------------
    # Mouse events
    # ------------------------------------------------------------------

    def _on_press(self, event):
        if event.xdata is None:
            return

        # Dragging the frequency cursor (ray) on mag or phase axes
        if event.inaxes in (self.ax_mag, self.ax_phase):
            self._drag_target = ('ray', 0)
            return

        if event.inaxes != self.ax_pz:
            return

        x, y = event.xdata, event.ydata
        z    = complex(x, y)

        if self._add_mode == 'add_pole':
            self._add_pole_at(z)
            return
        if self._add_mode == 'add_zero':
            self._add_zero_at(z)
            return

        # drag mode — pick nearest pole/zero within tolerance
        best_d, best = DRAG_TOL, None
        for i, p in enumerate(self.model.poles):
            d = abs(z - p)
            if d < best_d:
                best_d, best = d, ('pole', i)
        for i, zz in enumerate(self.model.zeros):
            d = abs(z - zz)
            if d < best_d:
                best_d, best = d, ('zero', i)
        if best is None:
            return

        self._drag_target   = best
        kind, idx           = best
        lst                 = self.model.poles if kind == 'pole' else self.model.zeros
        z0                  = lst[idx]
        self._drag_conj_idx = None
        for j, other in enumerate(lst):
            if j != idx and abs(other - z0.conjugate()) < 1e-6:
                self._drag_conj_idx = j
                break

        sel = self.ln_sel_pole if kind == 'pole' else self.ln_sel_zero
        sel.set_data([z0.real], [z0.imag])
        self.canvas.setCursor(Qt.CursorShape.ClosedHandCursor)
        self.canvas.draw_idle()

    def _on_motion(self, event):
        if self._drag_target is None:
            # Hover hint
            if event.inaxes == self.ax_pz and event.xdata is not None \
                    and self._add_mode == 'drag':
                z    = complex(event.xdata, event.ydata)
                near = (any(abs(z - p) < DRAG_TOL for p in self.model.poles) or
                        any(abs(z - zz) < DRAG_TOL for zz in self.model.zeros))
                self.canvas.setCursor(Qt.CursorShape.OpenHandCursor if near
                                      else Qt.CursorShape.ArrowCursor)
            return

        kind, idx = self._drag_target

        if kind == 'ray':
            if event.inaxes in (self.ax_mag, self.ax_phase) and event.xdata is not None:
                w = float(np.clip(event.xdata, -np.pi, np.pi))
                self.ln_ray_mag.set_xdata([w, w])
                self.ln_ray_phase.set_xdata([w, w])
                self.canvas.draw_idle()
            return

        if event.inaxes != self.ax_pz or event.xdata is None:
            return

        x  = float(np.clip(event.xdata,  -5.0, 5.0))
        y  = float(np.clip(event.ydata,  -5.0, 5.0))
        z  = complex(x, y)
        lst = self.model.poles if kind == 'pole' else self.model.zeros
        lst[idx] = z
        if self._drag_conj_idx is not None:
            lst[self._drag_conj_idx] = z.conjugate()

        xs = [z.real, z.conjugate().real] if self._drag_conj_idx is not None else [z.real]
        ys = [z.imag, z.conjugate().imag] if self._drag_conj_idx is not None else [z.imag]
        sel = self.ln_sel_pole if kind == 'pole' else self.ln_sel_zero
        sel.set_data(xs, ys)

        self.model.recalculate()
        self._update_list_display()
        self._refresh_plots()
        self.canvas.draw_idle()

    def _on_release(self, event):
        if self._drag_target is None:
            return
        if self._drag_target[0] != 'ray':
            self.ln_sel_pole.set_data([], [])
            self.ln_sel_zero.set_data([], [])
            self._update_status()
            self._update_formula()
        self._drag_target   = None
        self._drag_conj_idx = None
        self._restore_cursor()
        self.canvas.draw_idle()

    def _restore_cursor(self):
        cur = (Qt.CursorShape.CrossCursor
               if self._add_mode in ('add_pole', 'add_zero')
               else Qt.CursorShape.ArrowCursor)
        self.canvas.setCursor(cur)

    # ------------------------------------------------------------------
    # Pole / zero operations
    # ------------------------------------------------------------------

    def _parse_coord(self, text: str):
        text = text.strip()
        if not text:
            return None
        parts = [p.strip() for p in text.replace(';', ',').split(',') if p.strip()]
        if len(parts) == 2:
            try:
                return complex(float(parts[0]), float(parts[1]))
            except ValueError:
                pass
        try:
            return complex(text.replace('i', 'j'))
        except ValueError:
            pass
        try:
            ns = {'__builtins__': {}, 'pi': np.pi, 'j': 1j, 'i': 1j,
                  'sqrt': np.sqrt, 'exp': np.exp}
            return complex(eval(text, ns))  # noqa: S307
        except Exception:
            return None

    def _add_pole_at(self, z: complex):
        self.model.poles.append(z)
        if self._add_conjugate and abs(z.imag) > 1e-8:
            self.model.poles.append(z.conjugate())
        self._finalize()

    def _add_zero_at(self, z: complex):
        self.model.zeros.append(z)
        if self._add_conjugate and abs(z.imag) > 1e-8:
            self.model.zeros.append(z.conjugate())
        self._finalize()

    def _add_pole_btn(self):
        z = self._parse_coord(self.edit_pole.text())
        if z is None:
            QMessageBox.warning(self, 'Input error',
                                'Enter coordinates as:  real , imag')
            return
        self._add_pole_at(z)

    def _add_zero_btn(self):
        z = self._parse_coord(self.edit_zero.text())
        if z is None:
            QMessageBox.warning(self, 'Input error',
                                'Enter coordinates as:  real , imag')
            return
        self._add_zero_at(z)

    def _edit_pole(self):
        row = self.list_poles.currentRow()
        if not (0 <= row < len(self.model.poles)):
            return
        z = self._parse_coord(self.edit_pole.text())
        if z is None:
            return
        self.model.poles[row] = z
        self._finalize()

    def _edit_zero(self):
        row = self.list_zeros.currentRow()
        if not (0 <= row < len(self.model.zeros)):
            return
        z = self._parse_coord(self.edit_zero.text())
        if z is None:
            return
        self.model.zeros[row] = z
        self._finalize()

    def _del_pole(self):
        row = self.list_poles.currentRow()
        if 0 <= row < len(self.model.poles):
            del self.model.poles[row]
            self._finalize()

    def _del_zero(self):
        row = self.list_zeros.currentRow()
        if 0 <= row < len(self.model.zeros):
            del self.model.zeros[row]
            self._finalize()

    def _del_all_poles(self):
        self.model.poles.clear()
        self._finalize()

    def _del_all_zeros(self):
        self.model.zeros.clear()
        self._finalize()

    def _del_all(self):
        self.model.poles.clear()
        self.model.zeros.clear()
        self._finalize()

    def _gain_changed(self):
        try:
            self.model.k = float(self.edit_gain.text())
        except ValueError:
            return
        self.model.recalculate()
        self._refresh_plots()
        self._update_status()
        self._update_formula()
        self.canvas.draw_idle()

    def _pole_sel(self, row: int):
        if 0 <= row < len(self.model.poles):
            p = self.model.poles[row]
            self.edit_pole.setText(f'{p.real:.6g} , {p.imag:.6g}')

    def _zero_sel(self, row: int):
        if 0 <= row < len(self.model.zeros):
            z = self.model.zeros[row]
            self.edit_zero.setText(f'{z.real:.6g} , {z.imag:.6g}')

    def _finalize(self):
        self.model.recalculate()
        self._refresh_all()
        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # View options
    # ------------------------------------------------------------------

    def _set_mode(self, mode: str):
        self._add_mode = mode
        for key, btn in self._mode_btns.items():
            btn.setChecked(key == mode)
        self._restore_cursor()

    def _toggle_grid(self, on: bool):
        for ax in (self.ax_mag, self.ax_phase, self.ax_imp):
            ax.grid(on)
        self.canvas.draw_idle()

    def _do_zoom(self, delta: float):
        self._zoom = float(np.clip(self._zoom + delta, 0.5, 5.0))
        L = self._zoom
        self.ax_pz.set_xlim(-L, L)
        self.ax_pz.set_ylim(-L, L)
        ms = int(np.clip(-(8 / 9) * L + 94 / 9, 5, 15))
        self.ln_poles.set_markersize(ms)
        self.ln_zeros.set_markersize(ms)
        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Refresh
    # ------------------------------------------------------------------

    def _update_list_display(self):
        for lw, items in ((self.list_poles, self.model.poles),
                           (self.list_zeros, self.model.zeros)):
            lw.blockSignals(True)
            cur = lw.currentRow()
            lw.clear()
            for v in items:
                lw.addItem(f'( {v.real:+.4g} ,  {v.imag:+.4g} )')
            if 0 <= cur < lw.count():
                lw.setCurrentRow(cur)
            lw.blockSignals(False)

    def _refresh_all(self):
        self._update_list_display()
        self._refresh_plots()
        self._update_status()
        self._update_formula()

    def _refresh_plots(self):
        m = self.model

        # Pole-zero markers
        self.ln_poles.set_data(
            [p.real for p in m.poles], [p.imag for p in m.poles])
        self.ln_zeros.set_data(
            [z.real for z in m.zeros], [z.imag for z in m.zeros])

        # Multiplicity labels
        for t in self._mult_texts:
            t.remove()
        self._mult_texts.clear()
        tol = 1e-3
        sh  = 0.07
        for lst in (m.poles, m.zeros):
            seen: set = set()
            for i, v in enumerate(lst):
                if i in seen:
                    continue
                grp = [j for j, u in enumerate(lst) if abs(v - u) < tol]
                seen.update(grp)
                if len(grp) > 1:
                    t = self.ax_pz.text(v.real + sh, v.imag + sh,
                                        str(len(grp)), fontsize=8, zorder=5)
                    self._mult_texts.append(t)

        # Stability background
        self.ax_pz.set_facecolor(
            '#ffe8e8' if (not m.is_stable() and m.poles) else 'white')

        # Magnitude
        mag = np.abs(m.hz)
        self.ln_mag.set_ydata(mag)
        finite_max = float(np.nanmax(mag[np.isfinite(mag)])) if np.any(np.isfinite(mag)) else 1.0
        yhi = max(2.0, finite_max * 1.2)
        self.ax_mag.set_ylim(0, yhi)

        # Phase
        ph = np.angle(m.hz)
        self.ln_phase.set_ydata(ph)
        phi = max(np.pi + 0.3, float(np.nanmax(np.abs(ph))) * 1.2) if ph.size else np.pi + 0.3
        self.ax_phase.set_ylim(-phi, phi)

        # Impulse response (stem via NaN interleave)
        n  = np.arange(N_IMP, dtype=float)
        hn = np.real(m.hn)
        xx = np.empty(3 * N_IMP)
        yy = np.empty(3 * N_IMP)
        xx[0::3] = n;        yy[0::3] = 0.0
        xx[1::3] = n;        yy[1::3] = hn
        xx[2::3] = np.nan;   yy[2::3] = np.nan
        self.ln_imp_stems.set_data(xx, yy)
        self.ln_imp_dots.set_data(n, hn)
        amp = max(1.0, float(np.nanmax(np.abs(hn))) * 1.2)
        self.ax_imp.set_ylim(-amp, amp)

    def _update_status(self):
        stable = self.model.is_stable()
        self.lbl_stable.setText('stable' if stable else 'UNSTABLE')
        self.lbl_stable.setStyleSheet(
            'color: red; font-weight: bold;' if not stable else '')
        real_v = self.model.is_real_valued()
        self.lbl_real.setText('real' if real_v else 'complex  (imaginary part)')
        self.lbl_real.setStyleSheet('' if real_v else 'color: darkred;')

    def _update_formula(self):
        bb = self.model.k * self.model.b
        aa = self.model.a
        if max(len(bb), len(aa)) > 7:
            self.lbl_formula.setText('[formula hidden — too many terms]')
            return

        def poly_str(c):
            terms = []
            for i, v in enumerate(np.real(c)):
                if abs(v) < 1e-10:
                    continue
                av = abs(v)
                if i == 0:
                    terms.append(f'{v:.4g}')
                else:
                    sup = 'z⁻' + str(i).translate(_SUP)
                    cs  = '' if av == 1.0 else f'{av:.4g}'
                    sgn = '+' if v > 0 else '−'
                    terms.append(f'{sgn}{cs}{sup}')
            return ''.join(terms) if terms else '0'

        b_s = poly_str(bb)
        a_s = poly_str(aa)
        sep = '─' * max(len(b_s), len(a_s), 8)
        self.lbl_formula.setText(f'{b_s}\n{sep}\n{a_s}')


# ---------------------------------------------------------------------------

if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = PezMainWindow()
    win.resize(1150, 740)
    win.show()
    sys.exit(app.exec())
