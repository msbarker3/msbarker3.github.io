% RATING_TO_PIXEL - Based on CREATE_SCENE_PATCH_GRID to reconstruct 
%       pixel grid from patch rating data
%
% See also patch_cut_write, get_files
% 
% (c) Visual Cognition Laboratory at the University of California, Davis
%
% 2.2.0 2020-08-18 GLR: Revised from CREATE_SCENE_PATCH_GRID to produce pixel-patch map
% 2.1.0 2020-01-17 TRHayes: OSF release updated
% 2.0.0 2019-09-25 TRHayes: Streamlined for OSF release
% 1.0.0 2016-10-15 TRHayes: Wrote it

%% 010: Define parameter structure

% The img_sz, patch_scale, patch_diameter, and patch_density  parameters  
%    must match the patch generation parameters exactly for the pixel-patch 
%    correspondence to be correct

%--Directory management

% Define task string
task = 'meaning' ;

% Define file path prefix 
prefix = fullfile('C:\Users','gwenz') ;

% Define full input and output paths
P.path = fullfile(prefix,'Documents','GitHub','SceneMapping','MeaningMap_Generation_Code') ;   
P.scene_in = fullfile(P.path,'data','scene_images','SDesc01') ; 
P.patch_in = {fullfile(P.path,'data','patch_data','sdescOA01',task,'fine')
              fullfile(P.path,'data','patch_data','sdescOA01',task,'coarse')} ;
P.pixel_out = {fullfile(P.path,'data','pixel_data','sdescOA01',task,'fine')
               fullfile(P.path,'data','pixel_data','sdescOA01',task,'coarse')} ;
P.pixel_out_combined = fullfile(P.path,'data','pixel_data','sdescOA01',task,'combined');
         
%--Scene parameters
P.img_sz = [768 1024] ;   % Default [768 1024], scene image dimensions (px)
% * Note if you are using a different scene size you will have to adjust
%   the patch diameter and patch density accordingly.

%--Patch parameter definition

P.patch_scale = {'fine','coarse'} ;  % Patch scale string IDs
P.patch_diameter = [87 205] ;        % Patch diameter (px) [fine coarse]
P.patch_density = [300 108] ;        % Patch density (number) [fine coarse]

%% 020: Get all scene names and verify each scene image matches P.img_sz

%--Get all scene file names
s_filenames = get_files(P.scene_in) ;

disp(' Stored scene file names list as s_filenames');

%--Verify all scenes match P.img_sz
for k=1:length(s_filenames)
    curr_img = imread([P.scene_in filesep s_filenames{k}]) ;
    if isequal([size(curr_img,1) size(curr_img,2)],P.img_sz)==0
        fprintf('%s did not match P.P.img_sz, resizing\n',s_filenames{k}) ;
        new_img = imresize(curr_img,P.img_sz) ;
        imwrite(new_img,[P.scene_in filesep s_filenames{k}]) ;
    end
end

disp(' Verified scene files match P.img_sz');

%% 030: Define the fine and coarse grid
%     See CREATE_SCENE_PATCH_GRID for grid visualization code, removed 
%         here to avoid unnecessary redundancy

%--For each patch grid
x_patch = cell(1,2) ;
y_patch = cell(1,2) ;
for k=1:length(P.patch_diameter)
    
    %-- Determine grid pixel frequency to achieve desired density
    px_freq = round(sqrt(P.img_sz(1)*P.img_sz(2))/sqrt(P.patch_density(k))) ;

    %-- Use meshgrid to grid image space to define fixation center points
    [y,x] = meshgrid(px_freq:px_freq:P.img_sz(1),px_freq:px_freq:P.img_sz(2)) ;
    x = x(:) ;
    y = y(:) ;

    %-- Center grid on image
    y_offset = px_freq - ((P.img_sz(1)-max(y))+px_freq)/2 ;
    x_offset = px_freq - ((P.img_sz(2)-max(x))+px_freq)/2 ;
    x_patch{k} = x - x_offset ;
    y_patch{k} = y - y_offset ;

end

%% 040: Cut patches from each scene and store pixel data in output directory

%-- For each spatial scale
for p=1:length(P.patch_scale)
    fprintf('\nGenerating %s scale scene patches...\n',P.patch_scale{p}) ;
    
    %-- For each scene
    for k=1:length(s_filenames)

        %-- Define patch cut parameter structure
        patch.xy = [y_patch{p} x_patch{p}] ; % [y x] = image format
        
        patch.img_name = s_filenames{k} ;
        patch.img_sz = P.img_sz ;
        patch.diameter = P.patch_diameter(p) ;
        patch.in_dir = P.patch_in{p};
        patch.out_dir = P.pixel_out{p};
        
        %-- Call patch_cut_write to cut patches from each scene
        patch_pixel_match(strrep(s_filenames{k},'.jpg',''),patch) ;
        fprintf('  %s complete\n',s_filenames{k}) ;       
                
    end
end

%--Cleanup
clearvars patch

%% 050: Combine fine and coarse scale patch arrays into a 768x1024x2 cell array

for k=1:length(s_filenames)
    
    scene = strrep(s_filenames{k},'.jpg','');
    
    scene_array = cell(768,1024,2) ;
    
    fine = load(fullfile(P.pixel_out{1},[scene '.mat']));
    coarse = load(fullfile(P.pixel_out{2},[scene '.mat']));
    
    %--- Change dimensions for resolutions other than 768x1024
    for y = 1:768 % 1:image height 
        for x = 1:1024 % 1:image width
            scene_array{y,x,1} = fine.pixel_array{y,x};
            scene_array{y,x,2} = coarse.pixel_array{y,x};
        end
    end  
    
    combined_file = fullfile(P.pixel_out_combined,[scene '.mat']);
    save(combined_file, 'scene_array') ;
    
    clearvars scene_array scene
end

%--- Return scene patches
%%%%% END OF FUNCTION CREATE_SCENE_PATCHES.M