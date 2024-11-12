% BNST Affect Task paradigm
% 
% 
% Saurabh Sonkusare, March 2021
% University of Cambridge
% Dept of Psychiatry

sca; close all; clearvars;
clc;
Screen('Preference', 'SkipSyncTests', 1);
%% definitions %%

PsychDefaultSetup(2); % load default settings

p = mfilename('fullpath'); i = strfind(p,'\');
workdir = p(1:i(end));
clear p i
%% Screen Conditions
screens = Screen('Screens'); % get the screen numbers
screenNumber = max(screens); % select the maximum (possibly external)
HideCursor;

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

pointspos = .9;

lineWidthPix = 10; % line width for fixation cross
fixCrossDimPix = 40; % size of fixation cross arms
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords]; % set coordinates for fixation cross

heightScalers = .75; % set image height to fraction of screen height

wrapatLong = 60; % set max. width for text
vSpacing = 1.7; % set line spacing for text

Screen('Preference', 'DefaultFontSize', 40); % default font size = 40 pt

rect          = Screen('Rect',screenNumber);
screenRatio   = rect(3)/rect(4);
pixelSizes    = Screen('PixelSizes', 0);
startPosition = round([rect(3)/2, rect(4)/2]);

%% Enter the details of the subject and retrieve the image
subj_num =  input('Enter the subject number\n');
name = input('Subjects initials: ','s');
% stimfreq= input('enter stimulation frequency');
%% Blocks, jitters and trials
totaltrials= 135;
flag=0;

% Generating ITI between 1-1.5s
iti=linspace(1,1.5,totaltrials);
iti=iti(randperm(totaltrials));

% Variable initialization for ratings
pos_Valence = 1;% Variable that keep track of valence in each condition
pos_Arousal=1; % Variable that keep track of arousal in each condition

neg_Valence=1;
neg_Arousal=1;

neu_Valence=1;
neu_Arousal=1;

% Variables for storing data of ratings and RT
neg_ns_response_valence=[];neu_ns_response_valence=[];neg_s1_response_valence=[];neu_s1_response_valence=[];
neg_ns_RT_all_valence=[];neu_ns_RT_all_valence=[];neg_s1_RT_all_valence=[];neu_s1_RT_all_valence=[];

neg_ns_response_Arousal=[];neu_ns_response_Arousal=[];neg_s1_response_Arousal=[];neu_s1_response_Arousal=[];
neg_ns_RT_all_Arousal=[];neu_ns_RT_all_Arousal=[];neg_s1_RT_all_Arousal=[];neu_s1_RT_all_Arousal=[];

% Trigger numbers per condition
%1= negative nostim
%2= neutral no stim
%3 = negative stim1
%5=  ITI normal
%64= valence
%65= arousal
%33= stim on image
%0 = stim off

%% finding the dimensions of the image
stim1 = imread('1.jpg'); % stimulus
[s1, s2, s3] = size(stim1); % get size of one stimulus (all stimuli have same size in this experiment)

aspectRatio = s2/s1; % get aspect ratio for stimuli so it doesn't appear warped / stretched

[window, windowRect] = Screen('OpenWindow', screenNumber, black); % black background window
[screenXpixels, screenYpixels] = Screen('WindowSize', window); % get size of on screen window
[xCenter, yCenter] = RectCenter(windowRect); % get centre of screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % set up alpha-blending for smooth (anti-aliased) lines

imageHeights = screenYpixels .* heightScalers;
imageWidths = imageHeights .* aspectRatio;

centralRect1 = CenterRectOnPointd([0 0 imageWidths imageHeights], xCenter, yCenter); % for fruit


%% start instructions %%
% line1 = '\n you will be shown a series of Images. Sometimes, you will be asked to rate the valence and sometimes arousal level.';
% line2 = '\n\n Please use the mouse to rate it on the slider.';
% line3 = '\n Press any key to start the session';
% DrawFormattedText(window, [line1 line2 line3], 'center', 'center', [255 255 255], wrapatLong, [], [], vSpacing);

%  line1 = '\n If High frequency = 160 Hz.';
%  line2 = '\n\n If alpha burst mode settings = 100Hz with 25ms ON and 75ms OFF.';
% % line3 = '\n Press any key to start the session';
%  DrawFormattedText(window, [line1 line2], 'center', 'center', [255 255 255], wrapatLong, [], [], vSpacing);
% Screen('Flip', window);
% KbStrokeWait;

instruct= imread('INSTRUCTION.jpg');
i1=Screen('MakeTexture',window,instruct);
Screen('DrawTexture',window,i1,[],[],0);
Screen('Flip', window);
KbStrokeWait;

% %% Trigger
object=io64;           %  put this at the start of the script.
status=io64(object);
address=hex2dec('3FF8');


% ---------------------Randomizing the images--------------------%
image_num = randperm(totaltrials);

%-------- Rating trials for valence and arousal ---------%
valence_trials=[];
arousal_trials=[];

% Defining valence and arousal trial numbers randomly
neg_temp_trials=91:135;
neg_temp_trials= Shuffle(neg_temp_trials);

neu_temp_trials=46:90;
neu_temp_trials= Shuffle(neu_temp_trials);

pos_temp_trials=1:45;
pos_temp_trials= Shuffle(pos_temp_trials);



if rem(subj_num,2)== 0
valence_trials= [neg_temp_trials(1:5) neu_temp_trials(1:5) pos_temp_trials(1:5)]; 
arousal_trials = [neg_temp_trials(6:10) neu_temp_trials(6:10) pos_temp_trials(6:10)];
else
arousal_trials= [neg_temp_trials(1:5) neu_temp_trials(1:5) pos_temp_trials(1:5)]; 
valence_trials = [neg_temp_trials(6:10) neu_temp_trials(6:10) pos_temp_trials(6:10)];
end

trig_array=[];
iti_condt_all=[];
%% load images and define default screen %%
% Images type and stimulation specification
% No stim neg images= 1:30
% No stim neu images= 31:60
% Stim1 neg images= 61:75
% Stim1 neu images= 76:90

for condt= 1:totaltrials
    
    %-------------------------- Image presentation-----------%
    image = image_num(condt);
    
    %------------ Determing the condition,trigger value based on image type------------------------%
    if image>=1 && image<=45
        condt_temp=1;
        trig = 1; % Trigger for pos image nostim condition
        
    elseif image>=46 && image<=90
        condt_temp=2;
        trig = 2; % Trigger for neutral image nostim condition
        
    else
        condt_temp=3;
        trig = 3; % Trigger for negative nostim condition
        
    end
    
 
    %----------------------Display the ITI with fixation-----------%

    Screen('DrawLines', window, allCoords, lineWidthPix, [255 255 255], [xCenter yCenter], 2); % draw fixation cross
    Screen('Flip', window);
    
    % Trigger
    io64(object,address,5);
    WaitSecs(iti(condt)); % for 1-1.5 s
    io64(object,address,0); % Triggers stimulation off


    
    %-----------------------------Presenting the image-----------------------------%
    temp= sprintf('%d.jpg',image);
    [stim1,map1] = imread(temp); % stimulus
    temp2 = imresize(stim1,0.3);
    
    stim1Texture = Screen('MakeTexture', window, stim1);
    Screen('DrawTexture', window, stim1Texture,[], centralRect1); %show 1st stim
    StimulusOnsetTime = Screen('Flip', window);
    
% %         Trigger
        io64(object,address,trig);
        WaitSecs(2); % for 2s
        io64(object,address,0); % Triggers stimulation off


    
    
    
    %% -------- Define when to rate based on valence and arousal-----%
    
    if ismember(image,valence_trials)
        
        %-------Valence Question-------%
        question  = 'How Positive or Negative is this image';
        endPoints = {'Very Negative','Very Positive'};
        
        [position, RT, answer] = slideScale(window, question, rect, endPoints, 'device', 'mouse', 'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'range', 2,'linelength',50,'scalaposition',0.5,'scalacolor',[255 0 255],'width',10,'aborttime',60,'image',temp2);
        
        %%Trigger
        io64(object,address,64);
         WaitSecs(0.001); % 
        io64(object,address,0);
%         
        % Segrating valence raings and RT based on the condition
        if image>=1 && image<=45
            pos_response_valence(pos_Valence)= position;
            pos_RT_all_valence(pos_Valence)=RT;
            pos_Valence=pos_Valence+1;
        elseif image>=46 && image<=90
            neu_response_valence(neu_Valence)= position;
            neu_RT_all_valence(neu_Valence)=RT;
            neu_Valence=neu_Valence+1;
        else
            neg_response_valence(neg_Valence)= position;
            neg_RT_all_valence(neg_Valence)=RT;
            neg_Valence=neg_Valence+1;
        end
        
        position=[]; RT=[];
        
    elseif ismember(image,arousal_trials)
        %-------Arousal Question-------%
        
        question  = 'How exciting is this image';
        endPoints = {'Not Exciting','Very Exciting'};
        
        [position, RT, answer] = slideScale(window, question, rect, endPoints, 'device', 'mouse', 'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'range', 2,'linelength',50,'scalaposition',0.5,'scalacolor',[0 0 255],'width',10,'aborttime',60,'image',temp2);
        
        %%Trigger
        io64(object,address,65);
         WaitSecs(0.001); 
        io64(object,address,0);
        
        % Segrating arousal raings and RT based on the condition
        if image>=1 && image<=45
            pos_response_Arousal(pos_Arousal)= position;
            pos_RT_all_Arousal(pos_Arousal)=RT;
            pos_Arousal=pos_Arousal+1;
            
        elseif image>=46 && image<=90
            neu_response_Arousal(neu_Arousal)= position;
            neu_RT_all_Arousal(neu_Arousal)=RT;
            neu_Arousal=neu_Arousal+1;
            
        else
            neg_response_Arousal(neg_Arousal)= position;
            neg_RT_all_Arousal(neg_Arousal)=RT;
            neg_Arousal=neg_Arousal+1;
        end
         position=[]; RT=[];
        
        
    end
    
    
    
end

%% save data %%
mkdir(sprintf(name));
cd(name);
save(sprintf('Affect_Ratings_subj_%s_number_%d.mat',name,subj_num)); %

sca; % clear the screen

