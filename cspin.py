#!/usr/bin/env python3
"""
CSpinDemo — Spinning Phasors Visualisation

Visualises one or more complex phasors z_k(t) = A_k·e^{jφ_k}·e^{j2πf_k t}
spinning in the complex plane, with real and imaginary parts traced over time
and corresponding spectral lines.

Five preset cases plus User Defined mode.

Original MATLAB version by Arie Yeredor (Georgia Tech, 2016).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QCheckBox, QComboBox, QSlider,
    QSizePolicy,
)
from PyQt6.QtCore import Qt, QTimer
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec

VERSION = '1.49'

SKY_BG = '#ccd9e8'
UC_BG  = '#f2f2b2'
IM_BG  = '#f2e6e6'
RE_BG  = '#e6f2e6'
_BROWN = (0.7, 0.3, 0.0)
_BLUE  = (0.0, 0.2, 0.8)

CASES = [
    'Phasor',
    'Phasors: same frequency',
    'Spectral lines: different frequencies',
    'Beat',
    'Harmonics of a periodic signal',
    'User Defined',
]


# ---------------------------------------------------------------------------
# Preset data
# ---------------------------------------------------------------------------

def _preset_xf(name):
    """Return (X, F) complex/float arrays for a preset case (no conjugate)."""
    if name == 'Phasor':
        return (np.array([np.exp(1j * 0.4 * np.pi)]),
                np.array([0.8]))
    if name == 'Phasors: same frequency':
        return (np.array([0.5 * np.exp(1j * 0.6 * np.pi),
                          1.1 * np.exp(1j * 0.2 * np.pi),
                          0.7 * np.exp(-1j * 0.2 * np.pi)]),
                np.array([0.6, 0.6, 0.6]))
    if name == 'Spectral lines: different frequencies':
        return (np.array([1.5 + 0j, 0.5j]),
                np.array([0.2, 1.8]))
    if name == 'Beat':
        return (np.array([0.8 + 0j, 0.8 * np.exp(1j * 0.4 * np.pi)]),
                np.array([1.9, 2.1]))
    if name == 'Harmonics of a periodic signal':
        k = np.arange(1, 8, dtype=float)
        X = np.sin(k * 0.5 * np.pi) / (k * 0.5 * np.pi)
        return X.astype(complex), 0.4 * k
    # User Defined — start same as Phasor
    return (np.array([np.exp(1j * 0.4 * np.pi)]), np.array([0.8]))


def _phasor_color(fn, maxf):
    mured = float(np.clip((fn / maxf + 1.0) / 2.0, 0.0, 1.0)) if maxf > 1e-9 else 0.5
    return (mured, 1.0 - mured, 0.0)


def _eq_text(N0, conjugate):
    N = str(N0)
    if N0 == 1 and not conjugate:
        return r'$\mathbf{z}(t) = z_1(t)$'
    if conjugate:
        return (r'$\mathbf{z}(t)=\sum_{k=1}^{' + N +
                r'}\!\bigl(z_k(t)+z_k^*(t)\bigr)$')
    return r'$\mathbf{z}(t) = \sum_{k=1}^{' + N + r'} z_k(t)$'


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class CSpinWindow(QMainWindow):

    _IDLE    = 0
    _PLAYING = 1
    _PAUSED  = 2
    _DONE    = 3

    def __init__(self):
        super().__init__()
        self.setWindowTitle(f'Spinning Phasors (cspin)  v{VERSION}')

        self._case      = CASES[0]
        self._conjugate = False
        self._T         = 10.0
        self._speed     = 3
        self._state     = self._IDLE
        self._nt        = 0

        self._X         = None
        self._F         = None
        self._tt        = None
        self._xr        = None
        self._xi        = None
        self._phasors_t = None
        self._scl       = 1.5
        self._ph_artists = []

        self._timer = QTimer(self)
        self._timer.setInterval(20)
        self._timer.timeout.connect(self._tick)

        self._build_ui()
        self._setup_case()

    # ------------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------------

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        root = QVBoxLayout(central)
        root.setContentsMargins(4, 4, 4, 4)
        root.setSpacing(4)

        self.fig = Figure(figsize=(12, 7))
        self.fig.patch.set_facecolor(SKY_BG)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        root.addWidget(self.canvas, stretch=1)

        self._build_axes()

        ctrl = QHBoxLayout()
        ctrl.setSpacing(8)

        ctrl.addWidget(QLabel('Case:'))
        self.combo = QComboBox()
        self.combo.addItems(CASES)
        self.combo.currentTextChanged.connect(self._on_case)
        ctrl.addWidget(self.combo)

        ctrl.addSpacing(8)
        ctrl.addWidget(QLabel('T:'))
        self.edit_T = QLineEdit(f'{self._T:.3g}')
        self.edit_T.setFixedWidth(50)
        self.edit_T.editingFinished.connect(self._on_T)
        ctrl.addWidget(self.edit_T)

        self.chk_conj = QCheckBox('Conjugate')
        self.chk_conj.toggled.connect(self._on_conj)
        ctrl.addWidget(self.chk_conj)

        ctrl.addSpacing(8)
        ctrl.addWidget(QLabel('Speed:'))
        self.sld_speed = QSlider(Qt.Orientation.Horizontal)
        self.sld_speed.setRange(1, 20)
        self.sld_speed.setValue(self._speed)
        self.sld_speed.setFixedWidth(120)
        self.sld_speed.valueChanged.connect(lambda v: setattr(self, '_speed', v))
        ctrl.addWidget(self.sld_speed)

        ctrl.addSpacing(12)
        self.btn_play = QPushButton('▶  Play')
        self.btn_play.setFixedWidth(100)
        self.btn_play.clicked.connect(self._on_play)
        ctrl.addWidget(self.btn_play)

        ctrl.addStretch()
        root.addLayout(ctrl)

        self.setMinimumSize(900, 600)

    def _build_axes(self):
        # Layout (3 rows × 3 cols):
        #   row/col     0 (uc)   1 (real)   2 (spec/eq)
        #   0 (tall)    uc       imag       imag
        #   1 (thin)    real     -       spec
        #   2 (strip)   real     -       eq
        gs = gridspec.GridSpec(
            3, 3,
            figure=self.fig,
            width_ratios=[1, 1, 1],
            height_ratios=[1, 1, 1],
            left=0.05, right=0.97,
            top=0.97, bottom=0.06,
            hspace=0.06, wspace=0.08,
        )

        self.ax_uc = self.fig.add_subplot(gs[0, 0])
        self.ax_uc.set_facecolor(UC_BG)
        self.ax_uc.set_aspect('equal', adjustable='box')
        self.ax_uc.set_xticks([]); self.ax_uc.set_yticks([])

        self.ax_imag = self.fig.add_subplot(gs[0, 1:3])
        self.ax_imag.set_facecolor(IM_BG)
        self.ax_imag.set_yticks([])
        self.ax_imag.set_title(r'$\mathrm{Im}\{z(t)\}$', fontsize=8, pad=2)

        self.ax_spec = self.fig.add_subplot(gs[1, 1])
        self.ax_spec.set_facecolor('white')
        self.ax_spec.set_xticks([]); self.ax_spec.set_yticks([])

        self.ax_eq = self.fig.add_subplot(gs[2, 1])
        self.ax_eq.axis('off')

        self.ax_real = self.fig.add_subplot(gs[1:3, 0])
        self.ax_real.set_facecolor(RE_BG)
        self.ax_real.set_xticks([])
        self.ax_real.set_title(r'$\mathrm{Re}\{z(t)\}$', fontsize=8, pad=2)

        # Unit circle (static radius-1 ring)
        th = np.linspace(0, 2 * np.pi, 300)
        self._uc_circle, = self.ax_uc.plot(np.cos(th), np.sin(th), 'k', lw=1)
        self._uc_xline,  = self.ax_uc.plot([], [], 'k:', lw=0.8)
        self._uc_yline,  = self.ax_uc.plot([], [], 'k:', lw=0.8)
        # Projection lines in uc: horizontal (brown) and vertical (blue)
        self._ph1, = self.ax_uc.plot([], [], color=_BROWN, lw=1.5)
        self._pv1, = self.ax_uc.plot([], [], color=_BLUE,  lw=1.5)

        # Imag axis artists
        self._imag_base, = self.ax_imag.plot([], [], 'k:', lw=0.8)
        self._ph2,       = self.ax_imag.plot([], [], color=_BROWN, lw=1.5)
        self._pim,       = self.ax_imag.plot([], [], color=_BROWN, lw=2)

        # Real axis artists (x = time, y = Re value)
        self._real_base, = self.ax_real.plot([], [], 'k:', lw=0.8)
        self._pv2,       = self.ax_real.plot([], [], color=_BLUE,  lw=1.5)
        self._pre,       = self.ax_real.plot([], [], color=_BLUE,  lw=2)

    # ------------------------------------------------------------------
    # Case setup — rebuilds data and all dynamic artists
    # ------------------------------------------------------------------

    def _setup_case(self):
        self._timer.stop()
        self._state = self._IDLE
        self.btn_play.setText('▶  Play')
        self._nt = 0

        X0, F0 = _preset_xf(self._case)
        N0 = len(X0)

        if self._conjugate:
            X = np.concatenate([X0, np.conj(X0)])
            F = np.concatenate([F0, -F0])
        else:
            X = X0.copy()
            F = F0.copy()

        self._X = X
        self._F = F
        N = len(X)

        maxf = float(np.max(np.abs(F))) if N else 1.0
        maxx = float(np.max(np.abs(X))) if N else 1.0

        # Scale (mirror MATLAB logic)
        scl = 1.1 * float(np.sum(np.abs(X)))
        if self._case == 'Phasors: same frequency':
            scl *= 0.7
        elif self._case == 'Harmonics of a periodic signal' and self._conjugate:
            scl *= 0.6
        self._scl = max(scl, 0.1)
        scl = self._scl

        # Time vector
        T  = self._T
        dt = max(0.001, min(T / 4000.0, 1.0 / (4.0 * maxf + 1e-9)))
        self._tt = np.arange(0.0, T + dt * 0.5, dt)
        NT = len(self._tt)

        # Precompute all phasor positions: shape (N, NT)
        t_row = self._tt[np.newaxis, :]
        self._phasors_t = X[:, np.newaxis] * np.exp(
            1j * 2 * np.pi * F[:, np.newaxis] * t_row)
        z_tot    = np.sum(self._phasors_t, axis=0)
        self._xr = np.real(z_tot)
        self._xi = np.imag(z_tot)

        # ── Static axis content ───────────────────────────────────────

        # uc limits and crosshairs
        self._uc_xline.set_data([-scl, scl], [0, 0])
        self._uc_yline.set_data([0, 0], [-scl, scl])
        self.ax_uc.set_xlim(-scl, scl)
        self.ax_uc.set_ylim(-scl, scl)

        # ax_imag: x = time, y = Im{z} (vertical strip right, horizontal direction)
        self._imag_base.set_data([0, T], [0, 0])
        self.ax_imag.set_xlim(0, T)
        self.ax_imag.set_ylim(-scl, scl)
        self.ax_imag.set_xticks([0, T])
        self.ax_imag.set_xticklabels(['0', f'{T:.3g}'], fontsize=7)

        # ax_real: x = Re{z}, y = time with 0 at top (horizontal strip bottom, vertical direction)
        self._real_base.set_data([0, 0], [0, T])
        self.ax_real.set_xlim(-scl, scl)
        self.ax_real.set_ylim(T, 0)          # reversed: 0 at top, T at bottom
        self.ax_real.set_yticks([0, T])
        self.ax_real.set_yticklabels(['0', f'{T:.3g}'], fontsize=7)

        # ── Spectrum ──────────────────────────────────────────────────
        self.ax_spec.cla()
        self.ax_spec.set_facecolor('white')
        self.ax_spec.set_xticks([]); self.ax_spec.set_yticks([])
        self.ax_spec.set_xlim(-1.5 * maxf, 1.5 * maxf)
        self.ax_spec.set_ylim(-0.13 * maxx, 1.18 * maxx)

        aspec = self.ax_spec
        aspec.annotate('', xy=(1.45 * maxf, 0), xytext=(-1.45 * maxf, 0),
                       arrowprops=dict(arrowstyle='->', color='k', lw=0.8))
        aspec.annotate('', xy=(0, 1.12 * maxx), xytext=(0, 0),
                       arrowprops=dict(arrowstyle='->', color='k', lw=0.8))
        aspec.text(1.32 * maxf, -0.09 * maxx, 'f', fontsize=9)

        for n in range(N):
            fn  = float(F[n])
            xn  = X[n]
            clr = _phasor_color(fn, maxf)
            axn = abs(xn)
            pn_pi = float(np.angle(xn) / np.pi)

            aspec.plot([fn, fn], [0, axn], color=clr, lw=2)
            aspec.plot(fn, axn, '^', color=clr, ms=6, markerfacecolor=clr)
            aspec.text(fn, -0.10 * maxx, f'{fn:.3g}',
                       ha='center', fontsize=7)
            if axn > 1e-4:
                if abs(pn_pi) < 1e-3:
                    lbl = f'${axn:.3g}$'
                elif pn_pi > 0:
                    lbl = f'${axn:.3g}e^{{j{pn_pi:.2g}\\pi}}$'
                else:
                    lbl = f'${axn:.3g}e^{{-j{-pn_pi:.2g}\\pi}}$'
                aspec.text(fn + 0.07 * maxf, axn + 0.05 * maxx,
                           lbl, ha='center', fontsize=7, color=clr)

        # ── Phasor vector artists (one Line2D per phasor) ─────────────
        for a in self._ph_artists:
            try:
                a.remove()
            except Exception:
                pass
        self._ph_artists = []
        for n in range(N):
            clr = _phasor_color(float(F[n]), maxf)
            ln, = self.ax_uc.plot([], [], color=clr, lw=2.5)
            self._ph_artists.append(ln)

        # ── Equation + parameter table ────────────────────────────────
        self.ax_eq.cla()
        self.ax_eq.axis('off')
        self.ax_eq.text(0.5, 0.92, _eq_text(N0, self._conjugate),
                        ha='center', va='top',
                        transform=self.ax_eq.transAxes, fontsize=9)

        # Column headers
        cx = [0.05, 0.30, 0.55, 0.78]
        hdrs = [r'$f_k$', r'$A_k$', r'$\phi_k/\pi$', r'$z_k(0)$']
        for hx, ht in zip(cx, hdrs):
            self.ax_eq.text(hx, 0.62, ht, ha='left', va='center',
                            transform=self.ax_eq.transAxes,
                            fontsize=7, fontweight='bold')

        for row_i in range(N):
            y = 0.48 - row_i * 0.14
            if y < -0.05:
                break
            xn  = X[row_i]
            fn  = float(F[row_i])
            clr = _phasor_color(fn, maxf)
            pn_pi = float(np.angle(xn) / np.pi)
            vals = [f'{fn:.3g}', f'{abs(xn):.3g}', f'{pn_pi:.2g}',
                    f'{xn.real:.2g}+j{xn.imag:.2g}' if xn.imag != 0 else f'{xn.real:.2g}']
            for hx, vt in zip(cx, vals):
                self.ax_eq.text(hx, y, vt, ha='left', va='center',
                                transform=self.ax_eq.transAxes,
                                fontsize=7, color=clr)

        # ── Draw t = 0 ────────────────────────────────────────────────
        self._update_frame(0)
        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Per-frame update (called by timer and at t=0)
    # ------------------------------------------------------------------

    def _update_frame(self, nt):
        tt  = self._tt
        t   = float(tt[nt])
        T   = self._T
        scl = self._scl

        xe = self._phasors_t[:, nt]   # shape (N,) — precomputed
        sx = 0.0 + 0j
        for n, xn in enumerate(xe):
            x0, y0 = sx.real, sx.imag
            sx += xn
            self._ph_artists[n].set_data([x0, sx.real], [y0, sx.imag])

        rx, iy = sx.real, sx.imag

        # Projection lines in uc
        self._ph1.set_data([rx, scl], [iy, iy])
        self._pv1.set_data([rx, rx], [iy, -scl])

        # Im trace and level marker (ax_imag: x = time, y = Im)
        self._pim.set_data(tt[:nt + 1], self._xi[:nt + 1])
        self._ph2.set_data([0, t], [iy, iy])

        # Re trace and level marker (ax_real: x = Re, y = time going down)
        self._pre.set_data(self._xr[:nt + 1], tt[:nt + 1])
        self._pv2.set_data([rx, rx], [0, t])

    # ------------------------------------------------------------------
    # Timer
    # ------------------------------------------------------------------

    def _tick(self):
        nt = min(self._nt + self._speed, len(self._tt) - 1)
        self._nt = nt
        self._update_frame(nt)
        self.canvas.draw_idle()
        if nt >= len(self._tt) - 1:
            self._timer.stop()
            self._state = self._DONE
            self.btn_play.setText('↩  Replay')

    # ------------------------------------------------------------------
    # Control handlers
    # ------------------------------------------------------------------

    def _on_play(self):
        if self._state in (self._IDLE, self._PAUSED):
            self._state = self._PLAYING
            self.btn_play.setText('⏸  Pause')
            self._timer.start()
        elif self._state == self._PLAYING:
            self._state = self._PAUSED
            self._timer.stop()
            self.btn_play.setText('▶  Play')
        else:  # DONE → Replay
            self._setup_case()
            self._state = self._PLAYING
            self.btn_play.setText('⏸  Pause')
            self._timer.start()

    def _on_case(self, txt):
        self._case = txt
        self._setup_case()

    def _on_conj(self, on):
        self._conjugate = on
        self._setup_case()

    def _on_T(self):
        try:
            T = float(self.edit_T.text())
            if T > 0:
                self._T = T
        except ValueError:
            self.edit_T.setText(f'{self._T:.3g}')
        self._setup_case()


# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    app.setApplicationName('CSpinDemo')
    win = CSpinWindow()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
