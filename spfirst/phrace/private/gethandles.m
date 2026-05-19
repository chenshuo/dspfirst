function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Jim McClellan, 20-Jan-2001
%    Adapted from Jordan's LTIDEMO-V111/GETHANDLES (14-Jun-1999)


h.Text.Area           = findobj(gcf, 'Tag', 'TextArea');
h.Zplane.Area           = findobj(gcf,'Tag','zplaneArea');
h.Timer.Start             = findobj(gcf, 'Tag', 'StartTimer');
h.Timer.Stop              = findobj(gcf, 'Tag', 'StopTimer');

h.Show.Problem            = findobj(gcf, 'Tag', 'NewQuestion');
h.Show.Answer             = findobj(gcf, 'Tag', 'ShowAnswer');

h.Popup.TestType          = findobj(gcf, 'Tag', 'TypeOfTest');

h.Checkbox.ShowRectForm   = findobj(gcf, 'Tag', 'ShowRectForm');
%h.Checkbox.ShowVectorSum  = findobj(gcf, 'Tag', 'ShowVectorSum');
%h.Checkbox.ShowAnswer     = findobj(gcf, 'Tag', 'ShowAnswer');

h.Text.Title              = findobj(gcf,'Tag', 'TextTitle');
h.Text.Timer              = findobj(gcf,'Tag', 'TextTimer');

h.Text.Question           = findobj(gcf,'Tag', 'TextQuestion');
h.Text.Questionline       = findobj(gcf,'Tag', 'TextQuestionline');
h.Text.Questionden        = findobj(gcf,'Tag', 'TextQuestionden');

h.Text.Answer             = findobj(gcf,'Tag', 'TextAnswer');

h.phasecounter = 1;
