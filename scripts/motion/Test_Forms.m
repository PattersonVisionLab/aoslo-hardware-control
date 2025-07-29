
NET.addAssembly('System.Windows.Forms');
import System.Windows.Forms.*;
import System.Drawing.*;

rgb2net = @(x) int32(x * 255);

f = Form;
f.Text = 'TableLayoutPanel';

tlp = TableLayoutPanel;
tlp.Dock = DockStyle.Fill;
tlp.ColumnCount = 1;
tlp.RowCount = 4;

tlp.RowStyles.Add(RowStyle(SizeType.Percent, 10));
for i = 1:3
    tlp.RowStyles.Add(RowStyle(SizeType.Percent, 30));
    %tlp.RowStyles.Add(RowStyle(SizeType.Percent, 30));
    %tlp.RowStyles.Add(RowStyle(SizeType.Percent, 30));
end
tlp.ColumnStyles.Add(ColumnStyle(SizeType.Percent, 100));

lbl = Label();
lbl.Text = 'Reflectance';
lbl.Dock = DockStyle.Fill;
lbl.TextAlign = ContentAlignment.MiddleCenter;
rgb = int32([0.7, 0.85, 1]*255);
lbl.BackColor = Color.FromArgb(rgb(1), rgb(2), rgb(3));
lbl.Font = Font('Arial', 10, FontStyle.Bold);
tlp.Controls.Add(lbl, 0, 0);

%function adjustLabelFont(label, container)
%    totalHeight = double(container.Height);
%    rowHeight = totalHeight * 0.1;
%    newFontSize = max(8, floor(rowHeight * 0.4));
%    label.Font = Font(label.FontFamily, newFontSize, FontStyle.Bold);
%end
%resizeFcn = @(~,~) adjustLabelFont(lbl, panel);
%panel.SizeChanged = resizeFcn;

buttonText = ["Ref X", "Ref Y", "Ref Z"];
f.Controls.Add(tlp);
for i = 1:3
    btn = Button();
    btn.Text = sprintf('%s - Button %d', buttonText(i), i);
    btn.Dock = DockStyle.Fill;
    tlp.Controls.Add(btn, 0, i);
end

% Display the form
f.Show;

% Close the form
f.IsDisposed;
