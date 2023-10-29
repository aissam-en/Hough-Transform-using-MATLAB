function varargout = guis(varargin)
    % GUIS MATLAB code for guis.fig
    %      GUIS, by itself, creates a new GUIS or raises the existing
    %      singleton*.
    %
    %      H = GUIS returns the handle to a new GUIS or the handle to
    %      the existing singleton*.
    %
    %      GUIS('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUIS.M with the given input arguments.
    %
    %      GUIS('Property','Value',...) creates a new GUIS or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before guis_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to guis_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help guis

    % Last Modified by GUIDE v2.5 07-Jan-2023 23:21:51

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @guis_OpeningFcn, ...
                       'gui_OutputFcn',  @guis_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
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


    
% --- Executes just before guis is made visible.
function guis_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to guis (see VARARGIN)

    %/% difinir le "Threshold" et "Radius" par défaut %/%
    handles.threshold = 0.5;
    handles.radius = 100;  %/% Le minimum "radius"=20 et le maximum "radius" par défaut=100

    % Choose default command line output for guis
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes guis wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


    
% --- Outputs from this function are returned to the command line.
function varargout = guis_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % Get default command line output from handles structure
    varargout{1} = handles.output;



% --- Executes on button press in LoadImageBtn.
function LoadImageBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to LoadImageBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %/% Charger l'image depuis l'ordinateur :
    [file,path] = uigetfile('*.jpg;*.png','Choisis une image');
    fullname = [path file];
    img = imread(fullname);
    %/% convertir l'image en gris :
    imgGray = rgb2gray(img); 
    
    %/% Rendre les variables "img" et "imgGray" globaux, pour transférer ces variables entre toutes les fonctions :
    handles.img = img;
    handles.imgGray = imgGray;
    guidata(hObject, handles);

    %/% afficher l'image originale sur "axes_1" :
    axes(handles.axes_1);
    imshow(img);


    
% --- Executes on button press in DetectEdgzsBtn.
function DetectEdgzsBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to DetectEdgzsBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %/% charger la variable globale "handles.Algo" dans le variable "Algo", et aussi les variables imgGray et threshold : 
    Algo = handles.Algo;
    imgGray = handles.imgGray;
    threshold = handles.threshold;

    %/% faire "Edge detection" selon "Algo" choisi :
    if Algo == 2
        EdgeImg = edge(imgGray,'canny', threshold);
    end
    if Algo == 3
        EdgeImg = edge(imgGray,'sobel', threshold);
    end

    %/% afficher l'edge image sur "axes_2" :
    axes(handles.axes_2);
    imshow(EdgeImg);

    %/% Rendre la variable "EdgeImg" global, pour la transférer entre toutes les fonctions :
    handles.EdgeImg = EdgeImg;
    guidata(hObject, handles);

    %/% charger le global variable "handles.radius" dans le variable "radius": 
    radius = handles.radius;
    %/% convertir en "int" :
    radius = cast(radius,'int8');
    %/% déterminer le min=20 et max rayon=radius:
    rd=[20 radius];
    
    %/% Trouver des cercles en utilisant la "Hough Transforme",en appliquant la fonction prédéfinie "imfindcircles" sur "EdgeImg" :
    %/% on choisit "dark" car l'objet est dans une bright background, avec une 'Sensitivity' de 0.91
    %/% cette fonction "imfindcircles" retourne le centre de tout le cercle détecté et le rayon correspond
    [centers, radii] = imfindcircles(EdgeImg,rd,'ObjectPolarity','dark','Sensitivity',0.91);

    %/% Rendre les variables "centers" et "radii" globaux, pour transférer ces variables entre toutes les fonctions :
    handles.centers = centers;
    handles.radii = radii;
    guidata(hObject, handles);

    %/% tracer les cercles dans Axes_1 de l'image originale :
    DrawCircleAxes_1(hObject, eventdata, handles);
    %/% tracer les cercles dans Axes_2 de l'image après Edge Detector :
    DrawCircleAxes_2(hObject, eventdata, handles);
    
    
    
%/% cette fonction trace les cercles dans Axes_1 de l'image originale :
function DrawCircleAxes_1(hObject, eventdata, handles)    
    centers = handles.centers;
    radii = handles.radii;
        
    img = handles.img;
    
    axes(handles.axes_1);
    imshow(img);
    viscircles(centers,radii);
    
%/% cette fonction trace les cercles dans Axes_2 de l'image après Edge Detector :
function DrawCircleAxes_2(hObject, eventdata, handles)
    centers = handles.centers;
    radii = handles.radii;
        
    axes(handles.axes_2);
    viscircles(centers,radii);
    

 
% --- Executes on selection change in DetectEdgesMenu.
function DetectEdgesMenu_Callback(hObject, eventdata, handles)
    % hObject    handle to DetectEdgesMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns DetectEdgesMenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from DetectEdgesMenu

    %/% Enregistrer algorithme qui sera choisi après le popup menu dans Algo :
    Algo = get(hObject,'Value');

    %/% Choisir l'algorithme "Canny" par defaut :
    if ~Algo 
        Algo = 2;
    end
    
    %/% Rendre la variable "Algo" global, pour transférer cette variable entre toutes les fonctions :
    handles.Algo = Algo;
    guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function DetectEdgesMenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to DetectEdgesMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


    
% --- Executes on slider movement.
function sliderThreshold_Callback(hObject, eventdata, handles)
    % hObject    handle to sliderThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    %/% Enregistrer le "threshold" qui sera choisi après le slider :
    threshold = get(hObject,'Value');

    %/% Afficher le threshold sous le slider: 
    set(handles.ThresholdAffiche, 'String', threshold);

    %/% les images sont automatiquement mise à jour lorsque la barre se déplace :
    DetectEdgesMenu_Callback(hObject, eventdata, handles);
    DetectEdgzsBtn_Callback(hObject, eventdata, handles);

    %/% Rendre la variable "threshold" global, pour transférer cette variable entre toutes les fonctions :
    handles.threshold = threshold;
    guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function sliderThreshold_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to sliderThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


    
% --- Executes on slider movement.
function sliderRadius_Callback(hObject, eventdata, handles)
    % hObject    handle to sliderRadius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    %/% Enregistrer le "radius" qui sera choisi après le slider :
    radius = get(hObject,'Value');
    
    %/% Afficher le threshold sous le slider: 
    set(handles.RadiusAffiche, 'String', radius);

    %/% les images sont automatiquement mise à jour lorsque la barre se déplace :
    DetectEdgesMenu_Callback(hObject, eventdata, handles);
    DetectEdgzsBtn_Callback(hObject, eventdata, handles);

    %/% Rendre la variable "threshold" global, pour transférer cette variable entre toutes les fonctions :
    handles.radius = radius;
    guidata(hObject, handles);
    
    

% --- Executes during object creation, after setting all properties.
function sliderRadius_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to sliderRadius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


    
% --- Executes on key press with focus on LoadImageBtn and none of its controls.
function LoadImageBtn_KeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to LoadImageBtn (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)


    
% --- Executes during object creation, after setting all properties.
function axes_2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: place code in OpeningFcn to populate axes_2
