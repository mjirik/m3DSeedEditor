% Editor for seed selection in 3D data
% seeds = m3DSeedEditor(im3d)
% [seeds, sliceindex] = m3DSeedEditor(im3d, windowCenter, windowWidth)
% 
% Params
% 'wcenter': 0
% 'wwidth': 0
% 'seeds': zeros
% 'labels': zeros
% 'colorbar':  true
% 'wait': true
% 'text': ''
% 'initsliceindex':  1
function varargout = m3DSeedEditor(varargin)

%m3DSeedEditor M-file for m3DSeedEditor.fig
%      m3DSeedEditor, by itself, creates a new m3DSeedEditor or raises the existing
%      singleton*.
%
%      H = m3DSeedEditor returns the handle to a new m3DSeedEditor or the handle to
%      the existing singleton*.
%
%      m3DSeedEditor('Property','Value',...) creates a new m3DSeedEditor using
%      the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to m3DSeedEditor_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      m3DSeedEditor('CALLBACK') and m3DSeedEditor('CALLBACK',hObject,...) call the
%      local function named CALLBACK in m3DSeedEditor.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m3DSeedEditor

% Last Modified by GUIDE v2.5 13-Sep-2012 10:49:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m3DSeedEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @m3DSeedEditor_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before m3DSeedEditor is made visible.
function m3DSeedEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for m3DSeedEditor
handles.output = hObject;
%hObject

if nargin >= 4
    d = varargin{1};
else
    load ('mri.mat','D');
    varargin{1} = squeeze(D);
    d = varargin{1};
%     error('Musi byt zadana alespon vstupni data');
%     handles.closeFigure = true;
end

p = inputParser;


%p.addRequired('data')
p.addOptional('wcenter',0);
p.addOptional('wwidth',0);
p.addParamValue('seeds',int8(zeros(size(d))));
p.addParamValue('labels',int8(zeros(size(d))));
p.addParamValue('colorbar', true);
p.addParamValue('wait', true);
p.addParamValue('text', '');
p.addParamValue('initsliceindex', 1);
p.parse(varargin{2:end});

minw=0;
maxw=0;

% vypocet minima a maxima
if p.Results.wwidth==0
    minw = min(d(:));
    maxw = max(d(:));
else
    wcenter = p.Results.wcenter;
    wwidth  = p.Results.wwidth;
    minw = wcenter-round(wwidth/2);
    maxw = wcenter+round(wwidth/2);
end
% aplikace okna na obrazek
% d = d-minw;
% d = uint8(single(d).*single(255)./single(maxw-minw));
    
handles.maxw = maxw;
handles.minw = minw;
handles.data = d;
handles.seeds = p.Results.seeds;
handles.labels = p.Results.labels;
handles.colorbar = p.Results.colorbar;
handles.wait = p.Results.wait;
handles.text = p.Results.text;
handles.imageIndex = p.Results.initsliceindex;


% if(nargin == 4)
%     d = varargin{1};
%     %okno pres cely rozsah
%     minw = min(d(:));
%     maxw = max(d(:));
%     d = d-minw;
%     d = uint8(single(d).*single(255)./single(maxw-minw));
%     handles.data = d;
%     handles.seeds = zeros(size(handles.data));
%     handles.imageIndex = 1;
%     
% elseif (nargin == 6)
%     d = varargin{1};
%     %okno pres cely rozsah
%     wcenter = varargin{2};
%     wwidth = varargin{3};
%     minw = wcenter-round(wwidth/2);
%     maxw = wcenter+round(wwidth/2);
%     d = d-minw;
%     d = uint8(single(d).*single(255)./single(maxw-minw));
%     handles.data = d;
%     handles.seeds = zeros(size(handles.data));
%     handles.imageIndex = 1;
%     
% 
% else
%     disp 'Nezadana zadna data, ukoncuji prohlizec.'
% %         close(hObject)
%     handles.closeFigure = true;
% end

handles.seedList = [];
handles.scrollBlock = false; % blokace otaceni koleckem, behem vyberu seedu

if(isfield(handles, 'data'))
    nSlices = size(handles.data,3);
    set(handles.depthSlider, 'Min', 1, 'Max', nSlices);
    minStep = 1 / nSlices;
    maxStep = 10 / nSlices;
    set(handles.depthSlider, 'SliderStep', [minStep maxStep]);

    img = handles.data(:,:,handles.imageIndex);
    imshow(img, [handles.minw, handles.maxw]);
    if handles.colorbar
        colorbar
    end
    

%     set(handles.statusBarLabel, 'String', sprintf('Data uspesne nactena, celkem %i obrazku.', nSlices));
    set(handles.statusBarLabel, 'String', p.Results.text);
else
    set(handles.statusBarLabel, 'String', 'Promenna _data3D_ nenalezena.');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m3DSeedEditor wait for user response (see UIRESUME)
if handles.wait
    % v nekterych pripadech uzivatel nechce cekat na odezvu
    uiwait();
end
end

% --- Outputs from this function are returned to the command line.
function varargout = m3DSeedEditor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
%handles.seeds
disp('outputFcn');
if (exist('handles') && isfield(handles, 'wait') && handles.wait)
    uiresume();
    varargout{1} = handles.seeds;
    varargout{2} = handles.imageIndex;
    
    delete(hObject);
else
    varargout={};
end


% if exist('handles.seeds', 'var')
%     varargout{1} = handles.seeds;
% end
% % if (isfield(handles,'closeFigure') && handles.closeFigure)
% % 	figure1_CloseRequestFcn(hObject, eventdata, handles)
% % end
% 
% % objekt se odstranuje  jen pokud se ceka na vystupy
% % misto toho jsem pridal delete object na klavesu q
% if handles.wait
%     delete(hObject);
% end

end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
if ~handles.scrollBlock
    if eventdata.VerticalScrollCount > 0 
    %          disp 'DOWN'
        if( handles.imageIndex > get(handles.depthSlider,'Min'))
            handles.imageIndex  = handles.imageIndex - 1;
            set(handles.depthSlider, 'Value', handles.imageIndex);
        end
    elseif eventdata.VerticalScrollCount < 0 
    %          disp 'UP'
        if( handles.imageIndex < get(handles.depthSlider,'Max'))
            handles.imageIndex = handles.imageIndex + 1;
            set(handles.depthSlider, 'Value', handles.imageIndex);
        end
    end
    showSlice(handles);

    set(handles.indexLabel,'String', sprintf('%i / %i', handles.imageIndex, get(handles.depthSlider, 'Max')));

    guidata(hObject, handles);
end


end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% seeds = handles.seeds;
% Hint: delete(hObject) closes the figure

% uiresume neuzavre figuru
% nekdy vsak nebylo mozne ukoncit prohlizec, proto pokus o opravu
% uiresume();

disp('closereqFcn');
% % 
if (exist('handles') && isfield(handles, 'wait') && handles.wait)
    disp('clreq uir');
    uiresume();
    
else
    disp('clreq del');
    delete(hObject);
end

end

% --- Executes on slider movement.
function depthSlider_Callback(hObject, eventdata, handles)
% hObject    handle to depthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject, 'Value', round(get(hObject, 'Value')));

handles.imageIndex = get(handles.depthSlider, 'Value');

set(handles.indexLabel,'String', sprintf('%i / %i', handles.imageIndex, get(handles.depthSlider, 'Max')));

showSlice(handles);

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function depthSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% handles.imageIndex = get(hObject, 'Value');

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes
axis off;

guidata(hObject, handles);
end

% --- Executes on mouse press over axes background.
% function axes_ButtonDownFcn(hObject, eventdata, handles)
% % hObject    handle to axes (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% disp('clicked')
% disp(get(hObject, 'CurrentPoint'))
% end

%display slice
function showSlice(handles)
    img = handles.data(:,:,handles.imageIndex);
    seeds2 = handles.seeds(:,:,handles.imageIndex);
    labels2 = handles.labels(:,:,handles.imageIndex);
    
    %imrgb = putTogether(double(img),seeds2, labels2, handles.maxw);
    %imshow(imrgb, [handles.minw, handles.maxw]);
    imshow(img, [handles.minw, handles.maxw]);
    if handles.colorbar
        colorbar
    end
        
    if ~isempty( find(seeds2,1) )
%       showSeeds2(seeds2); % na lunuxu trochu pada
%       showSeeds(seeds2); % na windows neozkousene, 

      %  showSeedsAndLabels(handles.seeds(:,:,handles.imageIndex), labels2); % na win pada


        imrgb = putTogether(double(img),seeds2, handles.minw, handles.maxw);
         % tohle nejde, protoze pro barvy neumi imshow pouzivat meze         
         % imshow(imrgb, [handles.minw, handles.maxw]);
         % takze prevod, ale pak nefunguje colorbar
        imrgbd = double((double(imrgb)- double(handles.minw))./(double(handles.maxw) - double(handles.minw)) );
        imshow(imrgbd,[0 1])
        if handles.colorbar
            colorbar('YTickLabel',{num2str(handles.maxw), num2str(handles.minw)});
        end
         
    end
    if(max(labels2(:)) ~= 0 || min(labels2(:)) ~= 0)
    %         showSeedsAndLabels(handles.seeds(:,:,handles.imageIndex),
    %         labels2); % na win pada
        showSegmentation(labels2, 'g' );
    end


end


%display seeds
function showSeedsAndLabels(seeds, labels2)
%     blue = cat(3, zeros(size(seeds)), zeros(size(seeds)), ones(size(seeds)));
%     red = cat(3, ones(size(seeds)), zeros(size(seeds)), zeros(size(seeds)));
%     hold on
%     hb = imshow(blue);
%     hr = imshow(red);
%     hold off
%     set(hb, 'AlphaData', seeds == -1);
%     set(hr, 'AlphaData', seeds == 1);

edg = edge(uint8(labels2));
bluered = (cat(3, seeds==1, edg>0,  seeds==-1));
hold on;
h = imshow(single(bluered));
hold off
%set(h, 'AlphaData', (seeds ~= 0) );%& (edg ~= 0));
set(h, 'AlphaData', (seeds ~= 0) | (edg ~= 0));
end

function showSeeds(seeds)
%     blue = cat(3, zeros(size(seeds)), zeros(size(seeds)), ones(size(seeds)));
%     red = cat(3, ones(size(seeds)), zeros(size(seeds)), zeros(size(seeds)));
%     hold on
%     hb = imshow(blue);
%     hr = imshow(red);
%     hold off
%     set(hb, 'AlphaData', seeds == -1);
%     set(hr, 'AlphaData', seeds == 1);
% bluered = (cat(3, seeds==1, zeros(size(seeds,1), size(seeds,2)),  seeds==-1));
bluered = (cat(3, seeds==1, seeds==-1,  seeds==-1));
hold on;
h = imshow(single(bluered));
hold off
%set(h, 'AlphaData', (seeds ~= 0) );%& (edg ~= 0));
set(h, 'AlphaData', double(seeds ~= 0));
end

function showSeeds2(seeds)
    red = cat(3, ones(size(seeds)), zeros(size(seeds)), zeros(size(seeds)));
%     green = cat(3, zeros(size(seeds)), ones(size(seeds)), zeros(size(seeds)));
    blue = cat(3, zeros(size(seeds)), zeros(size(seeds)), ones(size(seeds)));
    hold on
    hb = imshow(blue);
    hr = imshow(red);
   % hg = imshow(green);
    hold off
    set(hb, 'AlphaData', seeds == -1);
    %set(hg, 'AlphaData', seeds == 3);
    set(hr, 'AlphaData', seeds == 1);
end

function showSegmentation(segmentation, color)
    bound = bwboundaries(segmentation);%, 'noholes');
    hold on
    for(wb = 1:length(bound))
        blobBound = bound{wb};
        plot(blobBound(:,2), blobBound(:,1), color, 'LineWidth', 2);
    end
    hold off
end

% funkce dava dohromady obraz dat a obraz seedu. Labely jsou prozatim
% ignorovany
function imrgb = putTogether(img, seeds, minIntensity, maxIntensity)
% imrgb = zeros(size(img1,1), size(img1,2), 3);
% maxIntensity = 255;%max(img(:));


if size(img,3) == 1
    imgr = img;
    imgg = img;
    imgb = img;
    
else
    imgr = img(:,:,1);
    imgg = img(:,:,2);
    imgb = img(:,:,3);
end

imgr(seeds ~= 0) = minIntensity; 
imgg(seeds ~= 0) = minIntensity; 
imgb(seeds ~= 0) = minIntensity; 

imgr(seeds == 1) = maxIntensity; 

imgb(seeds == - 1) = maxIntensity;
%okrajSeg = edge(uint8(labels2));

imrgb = cat(3, imgr, imgg, imgb);


end

function seedMode(hObject, eventdata, handles)
%         fcn = get(gcf, 'WindowKeyPressFcn');
%         set(gcf, 'WindowKeyPressFcn', '');
 
        % blokovani kolecka
        handles.scrollBlock = true;
        guidata(hObject, handles);
        
        
        nghb = 5;
    	[oSeeds, bSeeds, oSeedsIm, bSeedsIm] = markSeeds(gcf, nghb, handles.data(:,:,handles.imageIndex));
        %objekt ma +1, pozadi ma -1
        handles.seeds(:,:,handles.imageIndex) = oSeedsIm - bSeedsIm;

        % odblokovani kolecka
        handles.scrollBlock = false;
        guidata(hObject, handles);
end


function quitFcn(hObject, eventdata, handles)
set(handles.statusBarLabel, 'String', 'Exiting');
        figure1_CloseRequestFcn(hObject, eventdata, handles);
end

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


    if(strcmp(eventdata.Key, 'm'))
        seedMode(hObject, eventdata, handles)
%         set(gcf, 'WindowKeyPressFcn', {@figure1_WindowKeyPressFcn,guidata(hObject)}); 
%         set(gcf, 'WindowKeyPressFcn', fcn);
    end
    
    if (strcmp(eventdata.Key, 'q'))
        quitFcn(hObject, eventdata, handles)
        
    

       
        %m3DSeedEditor_OutputFcn(hObject, eventdata, handles);
    end
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
seedMode(hObject, eventdata, handles)

end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
quitFcn(hObject, eventdata, handles)
end
