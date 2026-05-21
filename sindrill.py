#!/usr/bin/env python3
"""
SinDrill — Reading Sinusoids Drill

Tests the user's ability to identify the amplitude, frequency, and phase
of a displayed cosine wave:  x(t) = A·cos(2π·f₀·t + φ)

Original MATLAB version by Dr. James H. McClellan, Jordan Rosenthal,
et al. (Georgia Tech, 1994–2021).
Python / PyQt6 port, 2026.
"""

import sys
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QCheckBox, QGroupBox,
    QSizePolicy, QInputDialog, QMessageBox,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

VERSION = '1.0'

# ---------------------------------------------------------------------------
# Difficulty-level parameter sets
# ---------------------------------------------------------------------------
LEVELS = {
    'Novice': {
        'amplitude': [1.0, 2.0],
        'frequency': [500.0, 1000.0],
        'phase':     [-np.pi / 2, 0.0, np.pi / 2],
    },
    'Pro': {
        'amplitude': [1.0, 5.0, 10.0, 25.0, 100.0],
        'frequency': [60.0, 100.0, 250.0, 500.0, 1000.0],
        'phase':     list(np.pi / 24 * np.arange(-30, 31, dtype=float)),
    },
}

# Start / end time expressed as multiples of one period (1/f₀)
START_CHOICES = [-2, -1, 0]
END_CHOICES   = [1, 2]

DEFAULT_AMPLITUDE = '0'
DEFAULT_FREQUENCY = '0'
DEFAULT_PHASE     = 'pi/4'

# ---------------------------------------------------------------------------
# Utility functions
# ---------------------------------------------------------------------------

def pickone(lst):
    return lst[np.random.randint(len(lst))]


def safe_eval(expr: str):
    """
    Evaluate a mathematical expression string such as 'pi/4' or '-2.5'.
    Returns float on success, None on any error.
    """
    try:
        val = eval(
            expr,
            {"__builtins__": {}},
            {"pi": np.pi, "e": np.e,
             "sin": np.sin, "cos": np.cos,
             "sqrt": np.sqrt, "abs": abs},
        )
        return float(val)
    except Exception:
        return None


def phase_str(phi: float) -> str:
    """Format a phase in radians using π notation."""
    TOL = 1e-7
    if abs(phi) <= TOL:
        return '0'
    if abs(phi - np.pi) < TOL:
        return 'π'
    if abs(phi + np.pi) < TOL:
        return '-π'
    return f'{phi / np.pi:.3g}π'


def cosine_title(A: float, f0: float, phi: float) -> str:
    """
    Return a matplotlib math-text string representing A·cos(2π·f₀·t + φ).
    φ is in radians; displayed normalised by π.
    """
    TOL = 1e-7
    g = 4   # significant digits

    if abs(A) <= TOL:
        return r'$x(t) = 0$'

    # --- amplitude ---
    if abs(A - 1) <= TOL:
        a_str = ''
    elif abs(A + 1) <= TOL:
        a_str = '-'
    else:
        a_str = f'{A:.{g}g}\\,'

    # --- frequency ---
    if abs(f0) <= TOL:
        w_str = '0'
    elif abs(f0 - 1) < TOL:
        w_str = r'2\pi'
    elif abs(f0 + 1) < TOL:
        w_str = r'-2\pi'
    elif f0 > 0:
        w_str = rf'2\pi({f0:.{g}g})'
    else:
        w_str = rf'-2\pi({-f0:.{g}g})'

    # --- phase (normalised by π) ---
    pn = phi / np.pi
    if abs(phi) <= TOL:
        ph_str = ''
    elif abs(pn - 1) < TOL:
        ph_str = r' + \pi'
    elif abs(pn + 1) < TOL:
        ph_str = r' - \pi'
    elif pn > 0:
        ph_str = rf' + {pn:.{g}g}\pi'
    else:
        ph_str = rf' - {-pn:.{g}g}\pi'

    return rf'$x(t) = {a_str}\cos\!({w_str}\,t{ph_str})$'


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class SinDrillWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(f'Reading Sinusoids Drill  v{VERSION}')
        self.level      = 'Novice'
        self.line_width = 2.0
        self.A_true     = 1.0
        self.f0_true    = 500.0
        self.phi_true   = 0.0
        self.t          = np.array([0.0, 0.002])

        self._build_menu()
        self._build_ui()
        self.new_quiz()

    # ------------------------------------------------------------------
    # Menu bar
    # ------------------------------------------------------------------

    def _build_menu(self):
        mb = self.menuBar()

        # Quiz
        quiz_menu = mb.addMenu('Quiz')
        act_new = QAction('New Quiz', self)
        act_new.setShortcut('Ctrl+N')
        act_new.triggered.connect(self.new_quiz)
        quiz_menu.addAction(act_new)

        # Answers (labels refreshed each quiz; disabled so they act as read-only info)
        ans_menu = mb.addMenu('Answers')
        self.act_amp   = QAction('A  = ???', self)
        self.act_freq  = QAction('f₀ = ???', self)
        self.act_phase = QAction('φ  = ???', self)
        for a in (self.act_amp, self.act_freq, self.act_phase):
            a.setEnabled(False)
            ans_menu.addAction(a)

        # Level
        lv_menu = mb.addMenu('Level')
        self.act_novice = QAction('Novice', self, checkable=True, checked=True)
        self.act_pro    = QAction('Pro',    self, checkable=True, checked=False)
        self.act_novice.triggered.connect(lambda: self._set_level('Novice'))
        self.act_pro.triggered.connect(   lambda: self._set_level('Pro'))
        lv_menu.addAction(self.act_novice)
        lv_menu.addAction(self.act_pro)

        # Options
        opt_menu = mb.addMenu('Options')
        act_lw = QAction('Line Width…', self)
        act_lw.triggered.connect(self._change_line_width)
        opt_menu.addAction(act_lw)

        # Help
        help_menu = mb.addMenu('Help')
        act_about = QAction('About', self)
        act_about.triggered.connect(self._show_about)
        help_menu.addAction(act_about)

    # ------------------------------------------------------------------
    # Central widget / layout
    # ------------------------------------------------------------------

    def _build_ui(self):
        root = QWidget()
        self.setCentralWidget(root)
        vbox = QVBoxLayout(root)
        vbox.setContentsMargins(8, 4, 8, 8)
        vbox.setSpacing(6)

        # ── Plot ────────────────────────────────────────────────────────
        self.figure = Figure(figsize=(7, 4))
        self.figure.subplots_adjust(left=0.10, right=0.97, top=0.88, bottom=0.13)
        self.canvas = FigureCanvas(self.figure)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                   QSizePolicy.Policy.Expanding)

        self.ax = self.figure.add_subplot(111)
        self.ax.set_xlabel('Time (s)')
        self.ax.set_ylabel('Amplitude')
        self.ax.grid(True)

        self.line_true,  = self.ax.plot([], [], color='red',  lw=self.line_width,
                                         label='True signal')
        self.line_guess, = self.ax.plot([], [], color='blue', lw=self.line_width + 1,
                                         ls='--', label='Your guess', visible=False)
        self.title_artist = self.ax.set_title('', color='blue', fontsize=10,
                                               visible=False)
        vbox.addWidget(self.canvas, stretch=1)

        # ── Controls row ────────────────────────────────────────────────
        hbox = QHBoxLayout()
        hbox.setSpacing(12)

        # "Your Guess" group
        guess_box = QGroupBox('Your Guess')
        guess_box.setStyleSheet(
            'QGroupBox {'
            '  font-weight: bold;'
            '  background-color: #3a6ea5;'
            '  color: white;'
            '  border: 1px solid #888;'
            '  border-radius: 4px;'
            '  margin-top: 8px;'
            '}'
            'QGroupBox::title {'
            '  subcontrol-origin: margin;'
            '  left: 8px;'
            '}'
        )
        gb_hbox = QHBoxLayout(guess_box)
        gb_hbox.setSpacing(10)

        def make_field(label_text, default):
            col = QVBoxLayout()
            lbl = QLabel(label_text)
            lbl.setAlignment(Qt.AlignmentFlag.AlignCenter)
            lbl.setStyleSheet('color: white;')
            ed = QLineEdit(default)
            ed.setFixedWidth(90)
            ed.setAlignment(Qt.AlignmentFlag.AlignCenter)
            col.addWidget(lbl)
            col.addWidget(ed)
            return col, ed

        col_a, self.edit_amp   = make_field('Amplitude',  DEFAULT_AMPLITUDE)
        col_f, self.edit_freq  = make_field('Freq (Hz)',   DEFAULT_FREQUENCY)
        col_p, self.edit_phase = make_field('Phase (rad)', DEFAULT_PHASE)
        for col in (col_a, col_f, col_p):
            gb_hbox.addLayout(col)

        for ed in (self.edit_amp, self.edit_freq, self.edit_phase):
            ed.editingFinished.connect(self._on_change_value)

        hbox.addWidget(guess_box)

        # Right-side info + buttons
        right_vbox = QVBoxLayout()
        right_vbox.setSpacing(6)

        self.lbl_period = QLabel('Period = ∞')
        self.lbl_period.setAlignment(Qt.AlignmentFlag.AlignCenter)
        right_vbox.addWidget(self.lbl_period)

        self.chk_show = QCheckBox('Show Guess')
        self.chk_show.toggled.connect(self._on_show_guess)
        right_vbox.addWidget(self.chk_show)

        btn_new = QPushButton('New Quiz')
        btn_new.clicked.connect(self.new_quiz)
        right_vbox.addWidget(btn_new)

        right_vbox.addStretch()
        hbox.addLayout(right_vbox)
        vbox.addLayout(hbox)

        self.setMinimumSize(720, 530)

    # ------------------------------------------------------------------
    # Quiz logic
    # ------------------------------------------------------------------

    def new_quiz(self):
        choices = LEVELS[self.level]
        self.A_true   = float(pickone(choices['amplitude']))
        self.f0_true  = float(pickone(choices['frequency']))
        self.phi_true = float(pickone(choices['phase']))

        t_start = pickone(START_CHOICES) / self.f0_true
        t_stop  = pickone(END_CHOICES)   / self.f0_true
        n_pts   = int((t_stop - t_start) * 100 * self.f0_true) + 1
        self.t  = np.linspace(t_start, t_stop, max(n_pts, 10))

        # Reset inputs
        self.edit_amp.setText(DEFAULT_AMPLITUDE)
        self.edit_freq.setText(DEFAULT_FREQUENCY)
        self.edit_phase.setText(DEFAULT_PHASE)

        # Suppress signals while resetting checkbox
        self.chk_show.blockSignals(True)
        self.chk_show.setChecked(False)
        self.chk_show.blockSignals(False)

        self.line_guess.set_visible(False)
        self.title_artist.set_visible(False)
        self._update_period(0.0)

        # Draw true signal
        y = self.A_true * np.cos(2 * np.pi * self.f0_true * self.t + self.phi_true)
        self.line_true.set_data(self.t, y)
        self._apply_axis_limits(show_guess=False, A_guess=0.0, f0_guess=0.0)

        # Populate Answers menu
        self.act_amp.setText(f'A  = {self.A_true}')
        self.act_freq.setText(f'f₀ = {self.f0_true} Hz')
        self.act_phase.setText(f'φ  = {phase_str(self.phi_true)}')

        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Signal handlers
    # ------------------------------------------------------------------

    def _on_change_value(self):
        A   = safe_eval(self.edit_amp.text())
        f0  = safe_eval(self.edit_freq.text())
        phi = safe_eval(self.edit_phase.text())
        if None in (A, f0, phi):
            return

        y = A * np.cos(2 * np.pi * f0 * self.t + phi)
        self.line_guess.set_data(self.t, y)
        self.title_artist.set_text(cosine_title(A, f0, phi))

        self._update_period(f0)

        show = self.chk_show.isChecked()
        self._apply_axis_limits(show_guess=show, A_guess=A, f0_guess=f0)
        self.canvas.draw_idle()

    def _on_show_guess(self, checked: bool):
        self.line_guess.set_visible(checked)
        self.title_artist.set_visible(checked)

        A   = safe_eval(self.edit_amp.text())  or 0.0
        f0  = safe_eval(self.edit_freq.text()) or 0.0
        self._apply_axis_limits(show_guess=checked, A_guess=A, f0_guess=f0)
        self.canvas.draw_idle()

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _update_period(self, f0: float):
        if f0 == 0.0:
            self.lbl_period.setText('Period = ∞')
        else:
            ms = abs(1000.0 / f0)
            self.lbl_period.setText(f'Period = {ms:.3g} ms')

    def _apply_axis_limits(self, show_guess: bool, A_guess: float, f0_guess: float):
        if len(self.t) < 2:
            return
        self.ax.set_xlim(self.t[0], self.t[-1])
        if not show_guess:
            ylim = self.A_true
        elif abs(A_guess) > self.A_true:
            ylim = 1.1 * abs(A_guess)
        elif abs(A_guess) == self.A_true and f0_guess < self.f0_true / 10:
            ylim = 1.1 * self.A_true
        else:
            ylim = self.A_true
        self.ax.set_ylim(-ylim, ylim)

    def _set_level(self, level: str):
        self.level = level
        self.act_novice.setChecked(level == 'Novice')
        self.act_pro.setChecked(level == 'Pro')

    def _change_line_width(self):
        lw, ok = QInputDialog.getDouble(
            self, 'Line Width', 'Enter line width:',
            self.line_width, 0.5, 10.0, 1)
        if ok:
            self.line_width = lw
            self.line_true.set_linewidth(lw)
            self.line_guess.set_linewidth(lw + 1)
            self.canvas.draw_idle()

    def _show_about(self):
        QMessageBox.about(
            self, 'About SinDrill',
            f'<b>Reading Sinusoids Drill &nbsp; v{VERSION}</b><br><br>'
            'Tests the ability to identify the amplitude, frequency, and phase '
            'of a cosine wave.<br><br>'
            '<b>Signal model:</b> &nbsp; x(t) = A · cos(2π f₀ t + φ)<br><br>'
            'Original MATLAB version by Dr. James H. McClellan,<br>'
            'Jordan Rosenthal, et al. (Georgia Tech, 1994–2021).<br><br>'
            'Python / PyQt6 port, 2026.')


# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    app.setApplicationName('SinDrill')
    win = SinDrillWindow()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
