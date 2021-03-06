function z = Process(varargin)
% Process() is a function designed to make consistent image processing
% easy and nice. It should be used by calling it after plotting an image.
% Required additions as labels, legenda etc should be added before calling
% this function. When ready Process can be called. The function creates
% two images. A .fig file as backup when the layout of images is not
% fullfilling and a .pdf file which can be used in reports. A folder
% "figures" is created in which the pdf-files are stored. It contains a
% subfolder fig which contains the fig-files.
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%                             Usage                                %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Process needs no input arguments although it is probably neccesary to add
% some. There are various chaging parameters which can be changed using the
% flags:
% title     -   The filename under which the images are stored
% height    -   The image height
% width     -   The image width
% fontsize  -   The fontsize of labels, legenda entries etc.
% autocut   -   Autocutting the image leaving 10% margin on all sides.
% fontsize  -   Select the font size of the axis
% fontsizelegend - Select the legend font size
% fontsizetitle - Select the title font size
% grid - Turn a grid on or off
% units - Select units for height and width measure
% fontsizeaxes - Select font size of axis lables
% samefoldersave - If enabled, the script saves the image not in a
%                   subfolder, but in the active directory (true/false)
% ghostscript - Rerun ghostscript (if available) after saving as a PDF.
% graphlinewidth - Set Width of the plotted lines
% markersize - Set the size of the markers in the plot
% fontname - Select the font used in the plot
% fontweigth - Select the weight of the font in the plot
% extraspace - Add extra space (in set units) to each side of the plot
% filetype - Select File Type (currently pdf or png)
% resolution - Set resolutiom of PNG file
% Example:
% Process('title', 'Excellent plot', 'height', 100, 'width', 161)

p = inputParser;
p.CaseSensitive = false;        % Fuck capitals
defaultHeight = 10;            % Default image height
defaultWidth = 16.1;             % Default image width (based on phi)
defaultFontSize = 15;           % Used fontsize (labels)
defaultFontSizeLegend=13;
defaultFontSizeTitle=18;
defaultFontSizeAxes=13;
defaultAutoCut = false;
defaultUnits = 'centimeters';
defaultFileName = 'Awesome plot by Nico';
defaultTitle = '';
defaultGrid = 'off';
defaultSameFolderSave = false;
defaultGhostscript = false;
defaultGraphLineWidth = 1;
defaultMarkerSize = 10;
defaultFontName = 'Helvetica';
defaultFontWeight = 'bold';
defaultFileType = 'pdf';
defaultResolution = 300;
defaultAutoCutMargin = 0.1;
addOptional(p, 'width',  defaultWidth, @isnumeric);
addOptional(p, 'height', defaultHeight, @isnumeric);
addOptional(p, 'fontsize', defaultFontSize, @isnumeric);
addOptional(p, 'fontsizelegend', defaultFontSizeLegend, @isnumeric);
addOptional(p, 'fontsizetitle', defaultFontSizeTitle, @isnumeric);
addOptional(p, 'filename', defaultFileName,@ischar);
addOptional(p, 'autoCut', defaultAutoCut,@islogical);
addOptional(p, 'title', defaultTitle,@ischar);
addOptional(p, 'grid', defaultGrid,@isvalidgrid);
addOptional(p, 'units',  defaultUnits,@isvalidunit);
addOptional(p, 'fontsizeaxes',  defaultFontSizeAxes, @isnumeric);
addOptional(p, 'samefoldersave', defaultSameFolderSave, @islogical);
addOptional(p, 'ghostscript', defaultGhostscript, @islogical);
addOptional(p, 'graphlinewidth', defaultGraphLineWidth, @isnumeric);
addOptional(p, 'markersize', defaultMarkerSize, @isnumeric);
addOptional(p, 'fontname', defaultFontName, @ischar);
addOptional(p, 'fontweight', defaultFontWeight, @isvalidfontweight);
addOptional(p, 'extraspace', [0 0 0 0]);
addOptional(p, 'filetype', defaultFileType, @isvalidfiletype);
addOptional(p, 'resolution', defaultResolution, @isnumeric);
addOptional(p, 'autocutmargin', defaultAutoCutMargin, @isnumeric);
parse(p, varargin{:})

%% creating save structure and backup file
if exist([pwd, '/figures/fig'], 'dir') ~= 7   %checks if apropriate folder exists
    mkdir(strcat('figures', filesep, 'fig'));
end
saveas(gcf, fullfile('figures', filesep,...
    'fig',filesep, p.Results.filename), 'fig'); %saving backup fig


%% Initializing defaults
AxisLineWidth = 1;          % Thickness of the axis and grid.
fontColor = 0.0*ones(1,3);  % 0 is black 1 is white
axisColor = 0.0*ones(1,3);  % 0 is black 1 is white

%% Adjusting canvas
set(gcf,...
    'PaperUnits', p.Results.units,...
    'PaperPosition', [p.Results.width*p.Results.extraspace(1),p.Results.width*p.Results.extraspace(4), p.Results.width*(1-p.Results.extraspace(2)), p.Results.height*(1-p.Results.extraspace(3))]',...
    'PaperSize', [p.Results.width, p.Results.height],...
    'KeyPressFcn', 'close');

%% Changing figure borders and grid
set(gca,'Xgrid',p.Results.grid,'Ygrid',p.Results.grid)     % Turns the grid off (prefered by most editors)
box on                  % Turns box on
GridLineStyle = '--';   % [-, --, :, -., none] not in use when grid is off

%% Handle collection
h_line = findobj(gcf, 'type', 'line');
h_ax = findobj(gcf,'type','axes');
h_cb = findobj(gcf,'type','colorbar');
h_legend = findobj(gcf, 'Type', 'Legend');

%% autocutting image
if p.Results.autoCut && ~isempty(h_line)
    xmin = min([h_line.XData]);
    ymin = min([h_line.YData]);
    zmin = min([h_line.ZData]);
    xmax = max([h_line.XData]);
    ymax = max([h_line.YData]);
    zmax = max([h_line.ZData]);
    cutoffX = [xmin-p.Results.autocutmargin*(xmax-xmin), xmax + p.Results.autocutmargin*(xmax-xmin)];
    cutoffY = [ymin-p.Results.autocutmargin*(ymax-ymin), ymax + p.Results.autocutmargin*(ymax-ymin)];
    cutoffZ = [zmin-p.Results.autocutmargin*(zmax-zmin), zmax + p.Results.autocutmargin*(zmax-zmin)];
    
    axis([cutoffX, cutoffY cutoffZ]);
end

%% Lines and Marker makeup
set(h_line,...
    'LineWidth', p.Results.graphlinewidth,...
    'MarkerSize', p.Results.markersize)

%% Axes makeup
set(h_ax,...
    'LineWidth', AxisLineWidth,...
    'GridLineStyle', GridLineStyle,...
    'FontWeight', p.Results.fontweight,...
    'FontName', p.Results.fontname,...
    'XColor', axisColor,...
    'YColor', axisColor,...
    'FontSize',p.Results.fontsizeaxes);
set(h_cb,...
    'Color', axisColor,...
    'FontSize',p.Results.fontsizeaxes,...
    'LineWidth', AxisLineWidth,...
    'FontWeight', p.Results.fontweight,...
    'FontName', p.Results.fontname)


%% Label makeup
labels = {'XLabel', 'YLabel', 'ZLabel', 'Title'};
h_labels = get(h_ax, labels);
set([h_labels{:}],...
    'FontSize', p.Results.fontsize,...
    'FontWeight', p.Results.fontweight,...
    'FontName', p.Results.fontname,...
    'Color', fontColor);

%% Legend tuning
if ~isempty(h_legend)
    set(legend,'FontSize',p.Results.fontsizelegend)
end

%% Save in current folder
if ~p.Results.samefoldersave
    pdfsavepath = fullfile('figures', p.Results.filename);
else
    pdfsavepath = p.Results.filename;
end

%% Setting title
if length(h_ax) == 1
    if ~isempty(p.Results.title)
        if ~strcmp(h_ax.Title.String,'')
            warning('Overwriting existing title!')
        end
        title(p.Results.title);
    end
    h_ax.Title.FontSize = p.Results.fontsizetitle;
elseif ~isempty(p.Results.title)
    warning('Subplots detected, title ignored.')
end

%% Saving
ftcell = cellstr(p.Results.filetype);
for j = 1:length(ftcell)
    switch ftcell{j}
        case 'pdf'
            print(gcf, pdfsavepath, '-dpdf','-painters') %Saves the image as pdf in the figures folder
            
            %% Ghostscript rerun
            if p.Results.ghostscript
                if ~(exist('ghostscript')==2)
                    error('This function uses part of the export_fig function, please download this from: https://github.com/altmany/export_fig');
                end
                str = [' -dSAFER -dNOPLATFONTS -dNOPAUSE -dBATCH -sDEVICE=pdfwrite ', ...
                    '-dPDFSETTINGS=/printer -dCompatibilityLevel=1.4 ', ...
                    '-dMaxSubsetPct=100 -dSubsetFonts=true -sFONTPATH=/Applications/MATLAB_R2016a.app/sys/fonts/ttf/ -dEmbedAllFonts=true -sOutputFile=', p.Results.filename, '_temp.pdf -f ', p.Results.filename, '.pdf'];
                ghostscript(str);
                delete([p.Results.filename,'.pdf']);
                movefile([p.Results.filename,'_temp.pdf'],[p.Results.filename,'.pdf']);
            end
        case 'png'
            resflag = ['-r' num2str(p.Results.resolution)];
            print(gcf, pdfsavepath, '-dpng' ,resflag) %Saves the image as pdf in the figures folder
    end
end
end
function out = isvalidgrid(in)
out = any(strcmp(in,{'in','off'}));
end

function out = isvalidunit(in)
out = any(strcmp(in,{'pixels','points','centimeters','inches','characters','normalized'}));
end

function out = isvalidfontweight(in)
out = any(strcmp(in,{'normal','bold'}));
end

function out = isvalidfiletype(in)
out = any(strcmp(in,{'pdf','png'}));
end