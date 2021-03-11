function varargout = minipro(varargin)
% MINIPRO MATLAB code for minipro.fig
%      MINIPRO, by itself, creates a new MINIPRO or raises the existing
%      singleton*.
%
%      H = MINIPRO returns the handle to a new MINIPRO or the handle to
%      the existing singleton*.
%
%      MINIPRO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINIPRO.M with the given input arguments.
%
%      MINIPRO('Property','Value',...) creates a new MINIPRO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before minipro_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to minipro_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help minipro

% Last Modified by GUIDE v2.5 30-Nov-2020 10:53:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @minipro_OpeningFcn, ...
                   'gui_OutputFcn',  @minipro_OutputFcn, ...
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

% --- Executes just before minipro is made visible.
function minipro_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to minipro (see VARARGIN)

% Choose default command line output for minipro
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes minipro wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = minipro_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function my_callback_fcn(handles)
global Type;
switch(Type)
    case(1)
        F1 = 1209;F2 = 697;%对应按钮“1”发声的频率值
    case(2)
        F1 = 1336;F2 = 697;%对应按钮“2”发声的频率值
    case(3)
        F1 = 1477;F2 = 697;%对应按钮“3”发声的频率值
    case(4)
        F1 = 1633;F2 = 697;%对应按钮“+”发声的频率值
    case(5)
        F1 = 1209;F2 = 770;%对应按钮“4”发声的频率值
    case(6)
        F1 = 1336;F2 = 770;%对应按钮“5”发声的频率值
    case(7)
        F1 = 1477;F2 = 770;%对应按钮“6”发声的频率值
    case(8)
        F1 = 1633;F2 = 770;%对应按钮“-”发声的频率值
    case(9)
        F1 = 1209;F2 = 852;%对应按钮”7“发声的频率值
    case(10)
        F1 = 1336;F2 = 852;%对应按钮”8发声的频率值
    case(11)
        F1 = 1477;F2 = 852;%对应按钮“9发声的频率值
    case(12)
        F1 = 1633;F2 = 852;%对应按钮”*“发声的频率值
    case(13)
        F1 = 1209;F2 = 941;%对应按钮”#“发声的频率值
    case(14)
        F1 = 1336;F2 = 941;%对应按钮”0“发声的频率值
    case(15)
        F1 = 1477;F2 = 941;%对应按钮”.“发声的频率值
    case(16)
        F1 = 1633;F2 = 941;%对应按钮”/“发声的频率值
end

Fs = 44100;                  %采样频率
T = 0.2;                     %采样时间
dt = 1/Fs;                %采样时间间隔
N = T*Fs;                    %采样点数
t = linspace(0,T,N);       %采样时间序列
t1 = linspace(0,0.02,N);
A11 = 1500*sin(2*pi*F1*t1); %F1频率对应信号
A22 = 1500*sin(2*pi*F2*t1); %F2频率对应信号
A1 = 1500*sin(2*pi*F1*t); %F1频率对应信号
A2 = 1500*sin(2*pi*F2*t); %F2频率对应信号
x = A1 + A2;                 %F1、F2叠加频率信号，即按键声音信号
N1 = 1024*2;              %快速傅里叶变换采样点数
y = fft(x,N1);            %快速傅里叶变换，第一个参数为时域函数，第二个参数为FFT的点数。N1的值应为2的n次幂
y = abs(y)/(N1/2);        %取实数并进行幅值修正
f = linspace(0,Fs,N1);    %频率序列
filename = 'actual.wav';
audiowrite(filename,x/3000,Fs);
sound(x/3000,Fs);%第一个参数为声音函数，第二个参数为采样点数
axes(handles.axes1);
plot(t1,A11);
title('A1');
axes(handles.axes2);
plot(t1,A22);
title('A2');
axes(handles.axes3);
plot(t,x);
title('按键音时域信号');
axes(handles.axes4);
plot(f,y);
title('按键音频域信号');

d=1000*randn(size(x)); %产生等长度的随机噪声信号(这里的噪声的大小取决于随机函数的幅度倍数）
x_mix=x+d;
y_mix = fft(x_mix,N1);            %快速傅里叶变换，第一个参数为时域函数，第二个参数为FFT的点数。N1的值应为2的n次幂
y_mix = abs(y_mix)/(N1/2);        %取实数并进行幅值修正
axes(handles.axes5);
plot(f,y_mix);
title('加噪后频谱图');
wp=3400*pi/Fs;
ws=3600*pi/Fs;
wd=abs(wp-ws);
N=ceil(4*pi/wd);
wc=(wp+ws)/2;
b=fir1(N,wc/pi,hamming(N+1));
%freqz(b,1);
x_final=filter(b,1,x_mix);
%xfinal = fftfilt(b,x_mix);
y_final = fft(x_final,N1);            %快速傅里叶变换，第一个参数为时域函数，第二个参数为FFT的点数。N1的值应为2的n次幂
y_final = abs(y_final)/(N1/2);        %取实数并进行幅值修正
axes(handles.axes6);
plot(f,y_final);
title('滤波后频谱图');

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 1;%第一个按钮设置编号1，以此类推
my_callback_fcn(handles);%设置编号后同意进行之后的操作


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 2;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 3;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 4;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 5;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 6;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 7;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 8;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 9;
my_callback_fcn(handles);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 10;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 11;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 12;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 13;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 14;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 15;
my_callback_fcn(handles);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Type;
Type = 16;
my_callback_fcn(handles);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
