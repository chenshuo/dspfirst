#!/usr/bin/env python3
"""
ZDrill — Complex Number Operations Drill

Tests knowledge of:
  1. Addition         z1 + z2
  2. Subtraction      z1 - z2
  3. Multiplication   z1 * z2
  4. Division         z1 / z2
  5. Inverse          1/z1
  6. Conjugate        z1*

Original MATLAB version by Dr. James H. McClellan, Jordan Rosenthal,
et al. (Georgia Tech, 1994–2017).
Python / PyQt6 port, 2026.
"""

import sys
import cmath
import math
import numpy as np
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QCheckBox, QComboBox,
    QSizePolicy, QInputDialog, QMessageBox, QFrame, QGroupBox,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
import matplotlib
matplotlib.use('QtAgg')
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.patches as mpatches

VERSION = '2.14'

# ---------------------------------------------------------------------------
# Colors — match MATLAB setcolors.m
# ---------------------------------------------------------------------------
COLOR_Z1     = '#cc0000'   # red      (Input 1)
COLOR_Z2     = '#cc00cc'   # magenta  (Input 2)
COLOR_GUESS  = '#0000cc'   # blue     (Your Guess)
COLOR_ANSWER = '#111111'   # black    (Answer)

# ---------------------------------------------------------------------------
# Level parameter sets — match MATLAB NewQuiz case
# ---------------------------------------------------------------------------
LEVELS = {
    'Novice': {
        'r':     [1.0, 1.5],
        'theta': list(np.pi * np.array([-0.5, -0.25, 0.0, 0.25, 0.5, 1.0])),
    },
    'Pro': {
        'r':     [0.5, 0.6, 0.8, 1.0, 1.5, 2.0],
        'theta': list(np.pi / 8 * np.arange(-10, 11, dtype=float)),
    },
}

OPERATIONS = ['Add', 'Subtract', 'Multiply', 'Divide', 'Inverse', 'Conjugate']
OP_LABELS = [
    'z1 + z2  (Add)',
    'z1 − z2  (Subtract)',
    'z1 × z2  (Multiply)',
    'z1 / z2  (Divide)',
    '1/z1  (Inverse)',
    'z1*  (Conjugate)',
]
OP_FORMULA = {
    'Add':       'z₁ + z₂',
    'Subtract':  'z₁ − z₂',
    'Multiply':  'z₁ × z₂',
    'Divide':    'z₁ / z₂',
    'Inverse':   '1/z₁',
    'Conjugate': 'z₁*',
}

# ---------------------------------------------------------------------------
# Pure-Python helpers
# ---------------------------------------------------------------------------

def pickone(lst):
    return lst[np.random.randint(len(lst))]


def safe_eval(expr: str):
    """Evaluate an expression like 'pi/2' or '1.5'. Returns float or None."""
    try:
        val = eval(
            expr.strip(),
            {"__builtins__": {}},
            {"pi": math.pi, "e": math.e,
             "sin": math.sin, "cos": math.cos,
             "sqrt": math.sqrt, "abs": abs},
        )
        return float(val)
    except Exception:
        return None


def polar_form_str(z, nd=3):
    """Return (r_str, theta_str), mirroring MATLAB polarformstring.m."""
    TOL = 1e-7
    r   = abs(z)
    phi = cmath.phase(z)

    if abs(r)             < TOL: r   = 0.0
    if abs(phi)           < TOL: phi = 0.0
    if abs(phi - math.pi) < TOL: phi =  math.pi
    if abs(phi + math.pi) < TOL: phi = -math.pi

    r_str = '0' if r == 0.0 else f'{r:.{nd}g}'

    if phi == 0.0:          theta_str = '0'
    elif phi ==  math.pi:   theta_str = 'pi'
    elif phi == -math.pi:   theta_str = '-pi'
    else:                   theta_str = f'{phi/math.pi:.{nd}g}*pi'

    return r_str, theta_str


def rect_form_str(z, nd=3):
    """Return 'x + j*y' string, mirroring MATLAB rectformstring.m."""
    TOL = 1e-7
    x = z.real
    y = z.imag

    if abs(x)     < TOL: x = 0.0
    if abs(y)     < TOL: y = 0.0
    if abs(x - 1) < TOL: x = 1.0
    if abs(y - 1) < TOL: y = 1.0

    def fmt(v): return f'{v:.{nd}g}'

    if x == 0.0:
        if   y == -1: return '-j'
        elif y ==  0: return '0'
        elif y ==  1: return 'j'
        elif y  >  0: return f'j*{fmt(y)}'
        else:         return f'-j*{fmt(-y)}'
    else:
        sx = fmt(x)
        if   y == -1: return f'{sx} - j'
        elif y ==  0: return sx
        elif y ==  1: return f'{sx} + j'
        elif y  >  0: return f'{sx} + j*{fmt(y)}'
        else:         return f'{sx} - j*{fmt(-y)}'


# ---------------------------------------------------------------------------
# Axis / drawing helpers
# ---------------------------------------------------------------------------

def set_axis_lims(ax, zs):
    """Set symmetric axis limits to fit all complex numbers, mirroring setaxislims.m."""
    zs = [z for z in zs if z is not None]
    if not zs:
        ax.set_xlim(-1.2, 1.2)
        ax.set_ylim(-1.2, 1.2)
        return [-1.2, 1.2, -1.2, 1.2]

    xs = [z.real for z in zs]
    ys = [z.imag for z in zs]
    mx = 1.2 * min(min(xs), -1)
    Mx = 1.2 * max(max(xs),  1)
    my = 1.2 * min(min(ys), -1)
    My = 1.2 * max(max(ys),  1)
    ax.set_xlim(mx, Mx)
    ax.set_ylim(my, My)
    return [mx, Mx, my, My]


def draw_background(ax):
    """Draw unit circle and Real/Imag crosshairs (dotted, behind data)."""
    theta = np.linspace(0, 2 * math.pi, 300)
    ax.plot(np.cos(theta), np.sin(theta), 'k:', lw=0.8, zorder=1)
    ax.axhline(0, color='k', linestyle=':', lw=0.8, zorder=1)
    ax.axvline(0, color='k', linestyle=':', lw=0.8, zorder=1)


def draw_arrow(ax, z_end, color, z_start=None, arrow_scale=1.0):
    """
    Draw a filled arrow from z_start (default 0+0j) to z_end.

    Arrow proportions are scaled relative to the current axis extent,
    mirroring MATLAB plotvect.m / makeplots.m sizing logic.
    """
    if z_start is None:
        z_start = 0 + 0j

    ox, oy = z_start.real, z_start.imag
    tx, ty = z_end.real,   z_end.imag
    dx, dy = tx - ox, ty - oy

    xl = ax.get_xlim()
    yl = ax.get_ylim()
    M = max(xl[1] - xl[0], yl[1] - yl[0])

    # Sizes mirror MATLAB: basewidth=0.035*M, headwidth=2.5x, headlength=3.5x
    bw = 0.035 * M * arrow_scale

    if math.hypot(dx, dy) < 1e-10:
        ax.add_patch(mpatches.Circle((ox, oy), bw, color=color, zorder=4))
        return

    arrow = mpatches.FancyArrow(
        ox, oy, dx, dy,
        width=2.0 * bw,
        head_width=2.0 * 2.5 * bw,
        head_length=3.5 * bw,
        length_includes_head=True,
        color=color,
        zorder=4,
    )
    ax.add_patch(arrow)


# ---------------------------------------------------------------------------
# Main window
# ---------------------------------------------------------------------------

class ZDrillWindow(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle(f'Complex Number Operations Drill  v{VERSION}')

        self.level       = 'Novice'
        self.operation   = 'Add'
        self.arrow_scale = 1.0

        self.z1    = 1 + 0j
        self.z2    = 1 + 0j
        self.z3    = {}      # pre-computed answers for all ops
        self.guess = 1j

        self._build_menu()
        self._build_ui()
        self.new_question()

    # ------------------------------------------------------------------
    # Menu
    # ------------------------------------------------------------------

    def _build_menu(self):
        mb = self.menuBar()

        # Answer — read-only labels showing the current answer
        ans_menu = mb.addMenu('&Answer')
        self.act_ans_r     = QAction('r = ???',     self)
        self.act_ans_theta = QAction('theta = ???', self)
        self.act_ans_rect  = QAction('z = ???',     self)
        for a in (self.act_ans_r, self.act_ans_theta, self.act_ans_rect):
            a.setEnabled(False)
        ans_menu.addAction(self.act_ans_r)
        ans_menu.addAction(self.act_ans_theta)
        ans_menu.addSeparator()
        ans_menu.addAction(self.act_ans_rect)

        # Options
        opt_menu = mb.addMenu('&Options')

        lvl_menu = opt_menu.addMenu('&Level')
        self.act_novice = QAction('&Novice', self, checkable=True, checked=True)
        self.act_pro    = QAction('&Pro',    self, checkable=True, checked=False)
        self.act_novice.triggered.connect(lambda: self._set_level('Novice'))
        self.act_pro.triggered.connect(   lambda: self._set_level('Pro'))
        lvl_menu.addAction(self.act_novice)
        lvl_menu.addAction(self.act_pro)

        opt_menu.addSeparator()
        act_aw = QAction('&Set Arrow Width…', self)
        act_aw.triggered.connect(self._set_arrow_width)
        opt_menu.addAction(act_aw)

        # Help
        help_menu = mb.addMenu('&Help')
        act_about = QAction('About', self)
        act_about.triggered.connect(self._show_about)
        help_menu.addAction(act_about)

    # ------------------------------------------------------------------
    # UI layout
    # ------------------------------------------------------------------

    def _build_ui(self):
        root = QWidget()
        self.setCentralWidget(root)
        main_vbox = QVBoxLayout(root)
        main_vbox.setContentsMargins(6, 4, 6, 6)
        main_vbox.setSpacing(4)

        # ── Top controls row ─────────────────────────────────────────
        ctrl_hbox = QHBoxLayout()
        ctrl_hbox.setSpacing(6)

        self.z1_panel  = self._make_input_panel('INPUT #1 : z₁', COLOR_Z1)
        self.z2_panel  = self._make_input_panel('INPUT #2 : z₂', COLOR_Z2)
        self.z2_widget = self.z2_panel['widget']
        ctrl_hbox.addWidget(self.z1_panel['widget'])
        ctrl_hbox.addWidget(self.z2_widget)
        ctrl_hbox.addWidget(self._build_center_panel(), stretch=1)
        ctrl_hbox.addWidget(self._build_right_panel())
        main_vbox.addLayout(ctrl_hbox)

        # ── Legend ───────────────────────────────────────────────────
        main_vbox.addLayout(self._build_legend())

        # ── Two axes (bottom, fills remaining space) ──────────────────
        self.figure = Figure(figsize=(8, 3.8))
        self.figure.subplots_adjust(
            left=0.07, right=0.97, top=0.90, bottom=0.12, wspace=0.32
        )
        self.canvas = FigureCanvas(self.figure)
        self.canvas.setSizePolicy(QSizePolicy.Policy.Expanding,
                                   QSizePolicy.Policy.Expanding)

        self.ax_in  = self.figure.add_subplot(1, 2, 1, aspect='equal')
        self.ax_ans = self.figure.add_subplot(1, 2, 2, aspect='equal')
        for ax, lbl in [(self.ax_in, 'Inputs'), (self.ax_ans, 'Your Guess')]:
            ax.set_xlabel('Real', fontsize=9)
            ax.set_ylabel('Imag', fontsize=9)
            ax.tick_params(labelsize=8)

        main_vbox.addWidget(self.canvas, stretch=1)
        self.setMinimumSize(820, 620)

    def _make_input_panel(self, title, color):
        w = QGroupBox()
        w.setStyleSheet(
            f'QGroupBox {{ border: 2px solid {color}; border-radius: 4px;'
            f'  margin-top: 2px; padding: 4px; background-color: #f5f5f5; }}'
        )
        vb = QVBoxLayout(w)
        vb.setSpacing(2)
        vb.setContentsMargins(4, 4, 4, 4)

        hdr = QLabel(title)
        hdr.setAlignment(Qt.AlignmentFlag.AlignCenter)
        hdr.setStyleSheet(
            f'background: {color}; color: white; font-weight: bold;'
            ' padding: 2px; border-radius: 2px;'
        )
        vb.addWidget(hdr)

        lbl_r = QLabel('    r = 1')
        lbl_r.setStyleSheet('background: white; padding: 2px;')
        vb.addWidget(lbl_r)

        lbl_theta = QLabel('    θ = pi/4')
        lbl_theta.setStyleSheet('background: white; padding: 2px;')
        vb.addWidget(lbl_theta)

        lbl_rect = QLabel('z = …')
        lbl_rect.setStyleSheet('padding: 2px;')
        lbl_rect.setVisible(False)
        vb.addWidget(lbl_rect)

        vb.addStretch()
        return {'widget': w, 'labels': (lbl_r, lbl_theta, lbl_rect)}

    def _build_center_panel(self):
        w = QFrame()
        w.setFrameShape(QFrame.Shape.StyledPanel)
        w.setStyleSheet(
            'QFrame { background: #d0d8e0; border: 1px solid #aaa;'
            ' border-radius: 4px; }'
        )
        vb = QVBoxLayout(w)
        vb.setSpacing(4)
        vb.setContentsMargins(8, 6, 8, 6)

        op_hdr = QLabel('OPERATION')
        op_hdr.setAlignment(Qt.AlignmentFlag.AlignCenter)
        op_hdr.setStyleSheet('font-weight: bold; font-size: 10pt; background: transparent;')
        vb.addWidget(op_hdr)

        self.combo_op = QComboBox()
        self.combo_op.addItems(OP_LABELS)
        self.combo_op.currentIndexChanged.connect(self._on_operation_changed)
        vb.addWidget(self.combo_op)

        guess_hdr = QLabel('YOUR GUESS')
        guess_hdr.setAlignment(Qt.AlignmentFlag.AlignCenter)
        guess_hdr.setStyleSheet(
            f'background: {COLOR_GUESS}; color: white; font-weight: bold;'
            ' padding: 2px; border-radius: 2px;'
        )
        vb.addWidget(guess_hdr)

        def field_row(label_text, default):
            row = QHBoxLayout()
            lbl = QLabel(label_text)
            lbl.setFixedWidth(44)
            lbl.setAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
            lbl.setStyleSheet('background: transparent;')
            ed = QLineEdit(default)
            ed.setFixedWidth(88)
            row.addWidget(lbl)
            row.addWidget(ed)
            row.addStretch()
            return row, ed

        row_r, self.edit_r         = field_row('r =', '1')
        row_th, self.edit_theta    = field_row('θ =', 'pi/2')
        self.edit_r.editingFinished.connect(self._on_change_value)
        self.edit_theta.editingFinished.connect(self._on_change_value)
        vb.addLayout(row_r)
        vb.addLayout(row_th)

        self.lbl_guess_rect = QLabel('z = j')
        self.lbl_guess_rect.setStyleSheet('padding: 2px; background: transparent;')
        self.lbl_guess_rect.setVisible(False)
        vb.addWidget(self.lbl_guess_rect)

        vb.addStretch()
        return w

    def _build_right_panel(self):
        w = QFrame()
        vb = QVBoxLayout(w)
        vb.setSpacing(6)
        vb.setContentsMargins(4, 4, 4, 4)

        btn_new = QPushButton('New Quiz')
        btn_new.setMinimumWidth(110)
        btn_new.clicked.connect(self.new_question)
        vb.addWidget(btn_new)

        vb.addSpacing(4)

        self.chk_rect   = QCheckBox('Show Rect Form')
        self.chk_vecsum = QCheckBox('Show Vector Sum')
        self.chk_answer = QCheckBox('Show Answer')
        self.chk_rect.toggled.connect(self._on_show_rect_form)
        self.chk_vecsum.toggled.connect(self._on_show_vector_sum)
        self.chk_answer.toggled.connect(self._on_show_answer)
        vb.addWidget(self.chk_rect)
        vb.addWidget(self.chk_vecsum)
        vb.addWidget(self.chk_answer)

        vb.addStretch()
        return w

    def _build_legend(self):
        hbox = QHBoxLayout()
        hbox.setSpacing(20)
        hbox.addStretch()

        for color, label in [
            (COLOR_Z1,     'z₁'),
            (COLOR_Z2,     'z₂'),
            (COLOR_GUESS,  'Guess'),
            (COLOR_ANSWER, 'Answer'),
        ]:
            row = QHBoxLayout()
            swatch = QLabel()
            swatch.setFixedSize(18, 14)
            swatch.setStyleSheet(
                f'background: {color}; border: 1px solid #555;'
            )
            lbl = QLabel(label)
            row.addWidget(swatch)
            row.addWidget(lbl)
            hbox.addLayout(row)

        hbox.addStretch()
        return hbox

    # ------------------------------------------------------------------
    # Question generation
    # ------------------------------------------------------------------

    def new_question(self):
        """Generate new z1, z2; compute all answers; reset UI."""
        params = LEVELS[self.level]

        self.z1 = pickone(params['r']) * cmath.exp(1j * pickone(params['theta']))

        if self.operation in ('Add', 'Subtract', 'Multiply', 'Divide'):
            self.z2 = pickone(params['r']) * cmath.exp(1j * pickone(params['theta']))

        self.z3 = {
            'Add':       self.z1 + self.z2,
            'Subtract':  self.z1 - self.z2,
            'Multiply':  self.z1 * self.z2,
            'Divide':    self.z1 / self.z2,
            'Inverse':   1.0 / self.z1,
            'Conjugate': self.z1.conjugate(),
        }

        self.guess = 1j
        self.edit_r.setText('1')
        self.edit_theta.setText('pi/2')

        self._set_checkboxes_off()
        self._update_strings()
        self._make_plots()

    def _set_checkboxes_off(self):
        for w in (self.chk_rect, self.chk_vecsum, self.chk_answer):
            w.blockSignals(True)
            w.setChecked(False)
            w.blockSignals(False)

    # ------------------------------------------------------------------
    # String update
    # ------------------------------------------------------------------

    def _update_strings(self):
        """Refresh all text labels from current state."""
        nd = 3
        r_s, th_s = polar_form_str(self.z1, nd)
        self.z1_panel['labels'][0].setText(f'    r = {r_s}')
        self.z1_panel['labels'][1].setText(f'    θ = {th_s}')
        self.z1_panel['labels'][2].setText(f'z1 = {rect_form_str(self.z1, nd)}')

        if self.operation in ('Add', 'Subtract', 'Multiply', 'Divide'):
            r_s, th_s = polar_form_str(self.z2, nd)
            self.z2_panel['labels'][0].setText(f'    r = {r_s}')
            self.z2_panel['labels'][1].setText(f'    θ = {th_s}')
            self.z2_panel['labels'][2].setText(f'z2 = {rect_form_str(self.z2, nd)}')

        # Answer menu labels
        z_ans = self.z3[self.operation]
        r_s, th_s = polar_form_str(z_ans, nd)
        self.act_ans_r.setText(f'r = {r_s}')
        self.act_ans_theta.setText(f'theta = {th_s}')
        self.act_ans_rect.setText(f'z = {rect_form_str(z_ans, nd)}')

        # Guess rect form
        self.lbl_guess_rect.setText(f'z = {rect_form_str(self.guess, nd)}')

        # Show/hide rect-form labels based on checkbox and operation
        show = self.chk_rect.isChecked()
        self.lbl_guess_rect.setVisible(show)
        self.z1_panel['labels'][2].setVisible(show)
        self.z2_panel['labels'][2].setVisible(
            show and self.operation not in ('Inverse', 'Conjugate')
        )

    # ------------------------------------------------------------------
    # Plot update
    # ------------------------------------------------------------------

    def _make_plots(self):
        self._draw_input_axis()
        self._draw_answer_axis()
        self.canvas.draw_idle()

    def _draw_input_axis(self):
        ax = self.ax_in
        ax.cla()
        ax.set_aspect('equal')
        ax.set_xlabel('Real', fontsize=9)
        ax.set_ylabel('Imag', fontsize=9)
        ax.tick_params(labelsize=8)

        if self.operation in ('Inverse', 'Conjugate'):
            lim_zs = [self.z1]
        else:
            lim_zs = [self.z1, self.z2]

        set_axis_lims(ax, lim_zs)
        draw_background(ax)

        draw_arrow(ax, self.z1, COLOR_Z1, arrow_scale=self.arrow_scale)
        if self.operation not in ('Inverse', 'Conjugate'):
            draw_arrow(ax, self.z2, COLOR_Z2, arrow_scale=self.arrow_scale)

        ax.set_title(f'Inputs  ( {OP_FORMULA[self.operation]} )', fontsize=10)

    def _draw_answer_axis(self):
        ax = self.ax_ans
        ax.cla()
        ax.set_aspect('equal')
        ax.set_xlabel('Real', fontsize=9)
        ax.set_ylabel('Imag', fontsize=9)
        ax.tick_params(labelsize=8)
        ax.set_title('Your Guess', fontsize=10)

        z_ans      = self.z3[self.operation]
        show_ans   = self.chk_answer.isChecked()
        show_vsum  = self.chk_vecsum.isChecked()

        # Axis limits: match MATLAB ShowAnswer / ShowVectorSum logic
        lim_zs = [self.guess]
        if show_ans:
            lim_zs.append(z_ans)
        if show_vsum and self.operation in ('Add', 'Subtract'):
            lim_zs += [self.z1, self.z2]

        set_axis_lims(ax, lim_zs)
        draw_background(ax)

        # Vector-sum arrows (tip-to-tail), only for Add / Subtract
        if show_vsum and self.operation in ('Add', 'Subtract'):
            v2 = self.z2 if self.operation == 'Add' else -self.z2
            draw_arrow(ax, self.z1,          COLOR_Z1, arrow_scale=self.arrow_scale)
            draw_arrow(ax, self.z1 + v2, COLOR_Z2,
                       z_start=self.z1, arrow_scale=self.arrow_scale)

        # Guess arrow
        draw_arrow(ax, self.guess, COLOR_GUESS, arrow_scale=self.arrow_scale)

        # Answer arrow (hidden until checkbox is checked)
        if show_ans:
            draw_arrow(ax, z_ans, COLOR_ANSWER, arrow_scale=self.arrow_scale)

    # ------------------------------------------------------------------
    # Callbacks
    # ------------------------------------------------------------------

    def _on_change_value(self):
        r     = safe_eval(self.edit_r.text())
        theta = safe_eval(self.edit_theta.text())
        if r is not None and theta is not None and r >= 0:
            self.guess = r * cmath.exp(1j * theta)
            self._update_strings()
            self._make_plots()
        else:
            self.lbl_guess_rect.setText('z = NaN')

    def _on_operation_changed(self, idx):
        self.operation = OPERATIONS[idx]

        # Show / hide vector-sum checkbox and update its label
        if self.operation in ('Add', 'Subtract'):
            self.chk_vecsum.setVisible(True)
            self.chk_vecsum.setText(
                'Show Vector Sum' if self.operation == 'Add' else 'Show Vector Diff'
            )
        else:
            self.chk_vecsum.setVisible(False)

        # Hide z2 panel for unary operations
        self.z2_widget.setVisible(self.operation not in ('Inverse', 'Conjugate'))

        # Reset checkboxes
        self._set_checkboxes_off()
        self._update_strings()
        self._make_plots()

    def _on_show_rect_form(self, _checked):
        self._update_strings()

    def _on_show_vector_sum(self, _checked):
        self._make_plots()

    def _on_show_answer(self, _checked):
        self._make_plots()

    def _set_level(self, level):
        self.level = level
        self.act_novice.setChecked(level == 'Novice')
        self.act_pro.setChecked(level == 'Pro')

    def _set_arrow_width(self):
        val, ok = QInputDialog.getDouble(
            self, 'Arrow Width',
            'Enter arrow width (positive number):',
            value=self.arrow_scale, min=0.1, max=10.0, decimals=2,
        )
        if ok and val > 0:
            self.arrow_scale = val
            self._make_plots()

    def _show_about(self):
        QMessageBox.about(
            self, 'About ZDrill',
            f'<b>Complex Number Operations Drill</b><br>'
            f'Version {VERSION}<br><br>'
            'Original MATLAB by Dr. James H. McClellan,<br>'
            'Jordan Rosenthal, et al. (Georgia Tech, 1994–2017).<br>'
            'Python / PyQt6 port, 2026.',
        )


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    app = QApplication(sys.argv)
    win = ZDrillWindow()
    win.show()
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
