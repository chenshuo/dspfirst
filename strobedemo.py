#!/usr/bin/env python3
"""
StrobeDemo — Rotating Disc / Aliasing Demo

Simulates a rotating disc with an arrow being flashed by a strobe light.
Vary the flash rate to observe aliasing concepts.

Original MATLAB version by Akshai Parthasarathy and Dr. Mark Smith (Georgia Tech).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout, QGridLayout,
    QLabel, QLineEdit, QSlider, QGroupBox, QSizePolicy,
)
from PyQt6.QtCore import Qt
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.gridspec as gridspec
import matplotlib.patches as mpatches

VERSION = '1.43'

MOTOR_RPM_INIT = 750.0
FLASH_FPM_INIT = 1500.0
MOTOR_RPM_MIN  = 60.0
MOTOR_RPM_MAX  = 1500.0
FLASH_FPM_MIN  = 60.0
FLASH_FPM_MAX  = 4500.0

PHI_INIT  = np.pi / 4  # initial disk arrow angle (reference)
LW        = 1.75
YELLOW    = (1.0, 1.0, 0.5)
XMAX4     = 3 * np.pi
YMAX      = 1.5


# ---------------------------------------------------------------------------
# Arrow helpers (port of arrow.m)
# ---------------------------------------------------------------------------

def _arrow_pts(theta, arrow_length, arrow_span, tail_x, tail_y, fraction):
    tipx = fraction * np.cos(theta) + tail_x
    tipy = fraction * np.sin(theta) + tail_y
    a    = np.sqrt((1 - arrow_length) ** 2 + arrow_span ** 2)
    sig  = np.arctan2(arrow_span, (1 - arrow_length))
    x1   = fraction * a * np.cos(theta - sig) + tail_x
    y1   = fraction * a * np.sin(theta - sig) + tail_y
    x2   = fraction * a * np.cos(theta + sig) + tail_x
    y2   = fraction * a * np.sin(theta + sig) + tail_y
    return tipx, tipy, x1, y1, x2, y2


def draw_arrow_line(ax, theta, al=0.25, asp=0.1,
                    tx=0.0, ty=0.0, frac=1.0, color='b', lw=LW):
    """Draw a line-style arrow; return (stem, wing1, wing2) Line2D tuple."""
    tipx, tipy, x1, y1, x2, y2 = _arrow_pts(theta, al, asp, tx, ty, frac)
    stem, = ax.plot([tx, tipx], [ty, tipy], color=color, lw=lw)
    w1,   = ax.plot([x1, tipx], [y1, tipy], color=color, lw=lw)
    w2,   = ax.plot([x2, tipx], [y2, tipy], color=color, lw=lw)
    return stem, w1, w2


def update_arrow_line(arts, theta, al=0.25, asp=0.1,
                      tx=0.0, ty=0.0, frac=1.0):
    """Update (stem, wing1, wing2) in place."""
    tipx, tipy, x1, y1, x2, y2 = _arrow_pts(theta, al, asp, tx, ty, frac)
    arts[0].set_data([tx, tipx], [ty, tipy])
    arts[1].set_data([x1, tipx], [y1, tipy])
    arts[2].set_data([x2, tipx], [y2, tipy])


def draw_arrow_patch(ax, theta, al, asp, tx, ty, frac, color='b', lw=LW):
    """Draw a patch-style (filled head) arrow; return (stem Line2D, Polygon)."""
    tipx, tipy, x1, y1, x2, y2 = _arrow_pts(theta, al, asp, tx, ty, frac)
    stem, = ax.plot([tx, tipx], [ty, tipy], color=color, lw=lw)
    poly  = mpatches.Polygon(
        [[x1, y1], [x2, y2], [tipx, tipy]],
        closed=True, facecolor=color, edgecolor=color, zorder=3,
    )
    ax.add_patch(poly)
    return stem, poly


def set_arrow_color(arts, color):
    arts[0].set_color(color)
    arts[1].set_facecolor(color)
    arts[1].set_edgecolor(color)


def set_arrow_visible(arts, visible):
    for a in arts:
        a.set_visible(visible)


# ---------------------------------------------------------------------------
# Strobe window
# ---------------------------------------------------------------------------

class StrobeWindow(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle(f'StrobeDemo v{VERSION}')
        self.fm = MOTOR_RPM_INIT / 60.0
        self.fs = FLASH_FPM_INIT / 60.0
        self._build_ui()
        self._build_figure()
        self._init_plots()
        self._update()

    # ------------------------------------------------------------------
    # UI
    # ------------------------------------------------------------------

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        vbox = QVBoxLayout(central)
        vbox.setContentsMargins(4, 4, 4, 4)
        vbox.setSpacing(4)

        self.fig    = Figure(figsize=(11, 6.5))
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                  QSizePolicy.Policy.Expanding)
        vbox.addWidget(self.canvas, stretch=1)

        ctrl = QWidget()
        hbox = QHBoxLayout(ctrl)
        hbox.setContentsMargins(4, 2, 4, 2)
        hbox.setSpacing(14)
        vbox.addWidget(ctrl)

        # Motor group
        mg = QGroupBox('Motor')
        gl = QGridLayout(mg)
        gl.setSpacing(3)
        gl.addWidget(QLabel('RPM:'),     0, 0)
        self.edit_rpm = QLineEdit(f'{MOTOR_RPM_INIT:.1f}')
        self.edit_rpm.setMaximumWidth(72)
        gl.addWidget(self.edit_rpm,      0, 1)
        gl.addWidget(QLabel('Hz:'),      1, 0)
        self.edit_fm  = QLineEdit(f'{self.fm:.2f}')
        self.edit_fm.setMaximumWidth(72)
        gl.addWidget(self.edit_fm,       1, 1)
        self.sl_motor = QSlider(Qt.Orientation.Horizontal)
        self.sl_motor.setRange(int(MOTOR_RPM_MIN), int(MOTOR_RPM_MAX))
        self.sl_motor.setValue(int(MOTOR_RPM_INIT))
        self.sl_motor.setMinimumWidth(220)
        gl.addWidget(self.sl_motor,      2, 0, 1, 2)
        hbox.addWidget(mg)

        # Flash group
        fg = QGroupBox('Strobe Flash')
        fl = QGridLayout(fg)
        fl.setSpacing(3)
        fl.addWidget(QLabel('Flash/min:'), 0, 0)
        self.edit_fpm = QLineEdit(f'{FLASH_FPM_INIT:.1f}')
        self.edit_fpm.setMaximumWidth(72)
        fl.addWidget(self.edit_fpm,        0, 1)
        fl.addWidget(QLabel('Hz:'),        1, 0)
        self.edit_fs  = QLineEdit(f'{self.fs:.2f}')
        self.edit_fs.setMaximumWidth(72)
        fl.addWidget(self.edit_fs,         1, 1)
        self.sl_flash = QSlider(Qt.Orientation.Horizontal)
        self.sl_flash.setRange(int(FLASH_FPM_MIN), int(FLASH_FPM_MAX))
        self.sl_flash.setValue(int(FLASH_FPM_INIT))
        self.sl_flash.setMinimumWidth(220)
        fl.addWidget(self.sl_flash,        2, 0, 1, 2)
        hbox.addWidget(fg)

        # Info labels
        ig = QGroupBox('Status')
        il = QVBoxLayout(ig)
        self.lbl_motor = QLabel()
        self.lbl_flash = QLabel()
        self.lbl_delta = QLabel()
        il.addWidget(self.lbl_motor)
        il.addWidget(self.lbl_flash)
        il.addWidget(self.lbl_delta)
        hbox.addWidget(ig)
        hbox.addStretch()

        # Signals
        self.sl_motor.valueChanged.connect(self._motor_slider)
        self.sl_flash.valueChanged.connect(self._flash_slider)
        self.edit_rpm.returnPressed.connect(self._edit_rpm)
        self.edit_fm.returnPressed.connect(self._edit_fm)
        self.edit_fpm.returnPressed.connect(self._edit_fpm)
        self.edit_fs.returnPressed.connect(self._edit_fs)

    # ------------------------------------------------------------------
    # Figure / axes
    # ------------------------------------------------------------------

    def _build_figure(self):
        self.fig.set_facecolor('#e8e8e8')
        gs = gridspec.GridSpec(
            2, 3, figure=self.fig,
            left=0.06, right=0.97, top=0.94, bottom=0.06,
            hspace=0.45, wspace=0.35,
        )
        self.ax1 = self.fig.add_subplot(gs[0, 0])  # Motor disk
        self.ax2 = self.fig.add_subplot(gs[1, 0])  # CT spectrum
        self.ax3 = self.fig.add_subplot(gs[0, 2])  # Samples disk
        self.ax4 = self.fig.add_subplot(gs[1, 1])  # DT spectrum
        self.ax5 = self.fig.add_subplot(gs[1, 2])  # Sampled spectrum

        for ax, title in [
            (self.ax1, 'MOTOR'),
            (self.ax3, 'SAMPLES'),
            (self.ax2, 'Continuous-Time Spectrum'),
            (self.ax4, 'Discrete-Time Spectrum'),
            (self.ax5, 'Sampled Spectrum'),
        ]:
            ax.set_title(title, fontsize=9, fontweight='bold')

    # ------------------------------------------------------------------
    # Initial plots
    # ------------------------------------------------------------------

    def _draw_disk(self, ax):
        """Draw unit circle + semicircle. Return (semi_line,)."""
        th = np.linspace(0, 2 * np.pi, 500)
        ax.plot(np.cos(th), np.sin(th), 'k', lw=1)
        ax.set_aspect('equal')
        ax.set_xlim(-1.25, 1.25)
        ax.set_ylim(-1.25, 1.25)
        ax.set_xticks([])
        ax.set_yticks([])
        r  = 1 / 3
        th2 = np.linspace(0, np.pi / 2, 100)
        semi, = ax.plot(r * np.cos(th2), r * np.sin(th2), 'b', lw=1)
        return semi

    def _init_plots(self):
        fm = self.fm
        fs = self.fs

        # ---- Axes 1: Motor disk (static) ----
        self._draw_disk(self.ax1)
        # Rotation-direction indicator (patch arrow at pi, below center)
        draw_arrow_patch(self.ax1, np.pi, 1.2, 0.3, 0.1, -0.32, 0.2, color='b')
        # Reference position arrow at phi
        draw_arrow_line(self.ax1, PHI_INIT, color='b', lw=LW)

        # ---- Axes 2: CT spectrum ----
        ax = self.ax2
        ax.set_ylim(0, YMAX)
        ax.axvline(0, color='k', ls=':', lw=1, zorder=2)
        self.patch2 = mpatches.Polygon(
            [[-fs/2, 0], [-fs/2, YMAX], [fs/2, YMAX], [fs/2, 0]],
            closed=True, facecolor=YELLOW, edgecolor='none', zorder=0)
        ax.add_patch(self.patch2)
        self.stem2v, = ax.plot([-fm, -fm], [0, 1], 'b', lw=LW, zorder=3)
        self.stem2d, = ax.plot([-fm], [1], 'bo', ms=6, mfc='b', zorder=3)
        ax.set_xlabel('frequency (Hz)', fontsize=9)
        self._set_ax2_lim()

        # ---- Axes 3: Samples disk ----
        self.semi3 = self._draw_disk(self.ax3)
        # Rotation indicator (blue by default)
        self.arr3d = draw_arrow_patch(
            self.ax3, np.pi, 1.2, 0.3, 0.1, -0.32, 0.2, color='b')
        # Alias rotation indicator (red, at +0.32, initially hidden)
        self.arr3da = draw_arrow_patch(
            self.ax3, np.pi, 1.2, 0.3, 0.1,  0.32, 0.2, color='r')
        set_arrow_visible(self.arr3da, False)

        # Reference position arrow (blue/red depending on aliasing)
        self.arr3v = draw_arrow_line(self.ax3, PHI_INIT, color='b', lw=1)

        # 3 sample-position arrows
        phin  = PHI_INIT - 2 * np.pi * fm / fs
        delt  = self._wrap_delt(2 * np.pi * (-fm / fs) * 180 / np.pi)
        phin2 = phin + delt * np.pi / 180
        phin3 = phin2 + delt * np.pi / 180
        self.arr3n  = draw_arrow_line(self.ax3, phin,  color='k', lw=LW)
        self.arr3n2 = draw_arrow_line(self.ax3, phin2, color='g', lw=LW)
        self.arr3n3 = draw_arrow_line(self.ax3, phin3, color='m', lw=LW)

        # Delta-angle text inside axes3
        self.txt_delt = self.ax3.text(
            0.5, 0.03, '', transform=self.ax3.transAxes,
            ha='center', va='bottom', fontsize=8, color='k')

        # ---- Axes 4: DT frequency spectrum ----
        ax = self.ax4
        ax.set_xlim(-XMAX4, XMAX4)
        ax.set_ylim(0, YMAX)
        ax.set_xticks(np.arange(-2, 3) * np.pi)
        ax.set_xticklabels(
            [r'$-2\pi$', r'$-\pi$', r'$0$', r'$\pi$', r'$2\pi$'],
            fontsize=8)
        ax.set_xlabel(r'$\omega = 2\pi (f_0/f_s)$', fontsize=9)
        ax.axvline(0, color='k', ls=':', lw=1, zorder=2)
        self.patch4 = ax.axvspan(-np.pi, np.pi, facecolor=YELLOW, zorder=0)

        what = 2 * np.pi * (-fm / fs)
        # Main (blue) stem
        self.s4v,  = ax.plot([what, what], [0, 1], 'b', lw=LW, zorder=3)
        self.s4d,  = ax.plot([what], [1], 'bo', ms=6, mfc='b', zorder=3)
        # Alias copies (red) at ±2π offsets
        self.s4a1, = ax.plot([what + 2*np.pi, what + 2*np.pi],
                             [0, 1], 'r', lw=LW, zorder=3)
        self.s4a2, = ax.plot([what - 2*np.pi, what - 2*np.pi],
                             [0, 1], 'r', lw=LW, zorder=3)
        # Extra alias stem (used when c > 1)
        self.s4al, = ax.plot([what, what], [0, 1],
                             'r', lw=LW, zorder=3, visible=False)
        self.s4ald,= ax.plot([what], [1],
                             'ro', ms=6, mfc='r', zorder=3, visible=False)
        # "ALIASING!" label
        self.txt_alias = ax.text(
            0, 1.35, 'A L I A S I N G!',
            ha='center', color='r', fontsize=11,
            fontweight='bold', visible=False)

        # ---- Axes 5: Sampled spectrum ----
        ax = self.ax5
        ax.set_ylim(0, YMAX)
        ax.axvline(0, color='k', ls=':', lw=1, zorder=2)
        self.patch5 = mpatches.Polygon(
            [[-fs/2, 0], [-fs/2, YMAX], [fs/2, YMAX], [fs/2, 0]],
            closed=True, facecolor=YELLOW, edgecolor='none', zorder=0)
        ax.add_patch(self.patch5)
        self.stem5v, = ax.plot([-fm, -fm], [0, 1], 'b', lw=LW, zorder=3)
        self.stem5d, = ax.plot([-fm], [1], 'bo', ms=6, mfc='b', zorder=3)
        ax.set_xlabel('frequency (Hz)', fontsize=9)
        self._set_ax5_lim()

        self.canvas.draw()

    # ------------------------------------------------------------------
    # Core update (called whenever fm or fs changes)
    # ------------------------------------------------------------------

    @staticmethod
    def _wrap_delt(delt):
        while delt > 360:
            delt -= 360
        while delt < -360:
            delt += 360
        if delt < -180:
            delt = 360 + delt
        if delt > 180:
            delt = 360 - delt
        return delt

    @staticmethod
    def _set_patch_x(patch, xmin, xmax):
        patch.set_xy(np.array([[xmin, 0], [xmin, YMAX],
                               [xmax, YMAX], [xmax, 0]]))

    def _set_ax2_lim(self):
        fs = self.fs
        tks = [-fs, 0, fs]
        self.ax2.set_xlim(-1.5 * fs, 1.5 * fs)
        self.ax2.set_xticks(tks)
        self.ax2.set_xticklabels([f'{t:.1f}' for t in tks], fontsize=8)
        self.ax2.set_ylim(0, YMAX)

    def _set_ax5_lim(self):
        fs = self.fs
        tks = [-fs, 0, fs]
        self.ax5.set_xlim(-1.5 * fs, 1.5 * fs)
        self.ax5.set_xticks(tks)
        self.ax5.set_xticklabels([f'{t:.1f}' for t in tks], fontsize=8)
        self.ax5.set_ylim(0, YMAX)

    def _update(self):
        fm   = self.fm
        fs   = self.fs
        what = 2 * np.pi * (-fm / fs)

        # Compute aliasing state
        aliasing = what < -np.pi
        walias, c = what, 0
        while walias < -np.pi:
            walias += 2 * np.pi
            c += 1

        delt = self._wrap_delt(what * 180 / np.pi)

        # ---- Axes 2 ----
        self._set_patch_x(self.patch2, -fs / 2, fs / 2)
        self.stem2v.set_xdata([-fm, -fm])
        self.stem2d.set_xdata([-fm])
        self._set_ax2_lim()

        # ---- Axes 4: DT spectrum ----
        self.txt_alias.set_visible(aliasing)
        if not aliasing:
            self.s4v.set_xdata([what, what]);  self.s4v.set_visible(True)
            self.s4d.set_xdata([what]);         self.s4d.set_visible(True)
            self.s4al.set_visible(False);       self.s4ald.set_visible(False)
            self.s4a1.set_xdata([what + 2*np.pi, what + 2*np.pi])
            self.s4a2.set_xdata([what - 2*np.pi, what - 2*np.pi])
        elif c == 1:
            self.s4v.set_xdata([what, what]);   self.s4v.set_visible(True)
            self.s4d.set_xdata([what]);          self.s4d.set_visible(True)
            self.s4al.set_visible(False);        self.s4ald.set_visible(False)
            self.s4a1.set_xdata([walias, walias])
            self.s4a2.set_xdata([walias + 2*np.pi, walias + 2*np.pi])
        else:
            self.s4v.set_visible(False);         self.s4d.set_visible(False)
            self.s4al.set_xdata([walias - 2*np.pi, walias - 2*np.pi])
            self.s4al.set_visible(True)
            self.s4ald.set_xdata([walias - 2*np.pi])
            self.s4ald.set_visible(True)
            self.s4a1.set_xdata([walias, walias])
            self.s4a2.set_xdata([walias + 2*np.pi, walias + 2*np.pi])

        # ---- Axes 3: Samples disk ----
        # Direction indicator color
        if not aliasing or walias <= 0:
            col_dir = 'b' if not aliasing else 'r'
            set_arrow_color(self.arr3d, col_dir)
            set_arrow_visible(self.arr3d,  True)
            set_arrow_visible(self.arr3da, False)
            self.semi3.set_color(col_dir)
            for a in self.arr3v:
                a.set_color(col_dir)
        else:  # walias > 0: apparent reverse rotation
            set_arrow_visible(self.arr3d,  False)
            set_arrow_visible(self.arr3da, True)
            self.semi3.set_color('r')
            for a in self.arr3v:
                a.set_color('r')

        # Sample-position arrows
        phin  = PHI_INIT - 2 * np.pi * fm / fs
        phin2 = phin  + delt * np.pi / 180
        phin3 = phin2 + delt * np.pi / 180
        update_arrow_line(self.arr3n,  phin)
        update_arrow_line(self.arr3n2, phin2)
        update_arrow_line(self.arr3n3, phin3)

        # Show/hide arrows based on apparent step size
        adelt = abs(delt)
        v3 = adelt <= 120
        v2 = True  # always visible after wrapping into (-180, 180]
        for a in self.arr3n:  a.set_visible(True)
        for a in self.arr3n2: a.set_visible(v2)
        for a in self.arr3n3: a.set_visible(v3)

        col_delt = 'b' if not aliasing else 'r'
        self.txt_delt.set_text(f'Δθ = {delt:.1f}°')
        self.txt_delt.set_color(col_delt)

        # ---- Axes 5: Sampled spectrum ----
        if not aliasing:
            f5, col5 = -fm, 'b'
        else:
            f5, col5 = walias * fs / (2 * np.pi), 'r'
        self.stem5v.set_xdata([f5, f5]);   self.stem5v.set_color(col5)
        self.stem5d.set_xdata([f5]);       self.stem5d.set_color(col5)
        self.stem5d.set_markerfacecolor(col5)
        self._set_patch_x(self.patch5, -fs / 2, fs / 2)
        self._set_ax5_lim()

        # ---- Status labels ----
        rpm = fm * 60
        fpm = fs * 60
        self.lbl_motor.setText(f'f = {fm:.2f} Hz  ({rpm:.1f} rpm)')
        self.lbl_flash.setText(f'f = {fs:.2f} Hz  ({fpm:.1f} flash/min)')
        self.lbl_delta.setText(f'Δθ = {delt:.1f}°  '
                               f'{"(ALIASING)" if aliasing else ""}')

        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Slider / edit-box callbacks
    # ------------------------------------------------------------------

    def _set_edit(self, w, txt):
        w.blockSignals(True)
        w.setText(txt)
        w.blockSignals(False)

    def _set_motor(self, rpm):
        rpm = max(MOTOR_RPM_MIN, min(MOTOR_RPM_MAX, rpm))
        self.fm = rpm / 60.0
        self._set_edit(self.edit_rpm, f'{rpm:.1f}')
        self._set_edit(self.edit_fm,  f'{self.fm:.2f}')
        self.sl_motor.blockSignals(True)
        self.sl_motor.setValue(int(rpm))
        self.sl_motor.blockSignals(False)
        self._update()

    def _set_flash(self, fpm):
        fpm = max(FLASH_FPM_MIN, min(FLASH_FPM_MAX, fpm))
        self.fs = fpm / 60.0
        self._set_edit(self.edit_fpm, f'{fpm:.1f}')
        self._set_edit(self.edit_fs,  f'{self.fs:.2f}')
        self.sl_flash.blockSignals(True)
        self.sl_flash.setValue(int(fpm))
        self.sl_flash.blockSignals(False)
        self._update()

    def _motor_slider(self, v):  self._set_motor(float(v))
    def _flash_slider(self, v):  self._set_flash(float(v))

    def _edit_rpm(self):
        try: self._set_motor(float(self.edit_rpm.text()))
        except ValueError: pass

    def _edit_fm(self):
        try: self._set_motor(float(self.edit_fm.text()) * 60)
        except ValueError: pass

    def _edit_fpm(self):
        try: self._set_flash(float(self.edit_fpm.text()))
        except ValueError: pass

    def _edit_fs(self):
        try: self._set_flash(float(self.edit_fs.text()) * 60)
        except ValueError: pass


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    win = StrobeWindow()
    win.resize(960, 660)
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
