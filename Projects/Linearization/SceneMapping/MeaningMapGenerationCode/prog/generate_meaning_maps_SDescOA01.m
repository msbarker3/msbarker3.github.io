% GENERATE_meaning_maps_SDescOA01 - Loads patch rating structure and image to
%      generate rating map
%
% See also rating_to_pixel, patch_pixel_match, build_meaning_map
% 
% (c) Visual Cognition Laboratory at the University of California, Davis
%
% 1.1.0 2020-08-25 GLR: Wrote it

%% 010: Define input directories

task = 'meaning' ;

prefix = fullfile('C:\Users','gwenz') ;
I.path = fullfile(prefix,'Documents','GitHub','SceneMapping','MeaningMap_Generation_Code') ;   
I.scene_in = fullfile(I.path,'data','scene_images','SDesc01') ; 
I.rating_in = fullfile(I.path,'data','pixel_data','sdescOA01',task,'combined') ;
I.map_out = fullfile(I.path,'data','sdescOA01','meaning_maps','raw') ;
I.map_visuals = fullfile(I.path,'data','sdescOA01','meaning_maps','img') ;
I.map_scaled_out = fullfile(I.path,'data','sdescOA01','meaning_maps','scaled') ;

%% 020: Import scene files and generate maps

s_filenames = getFiles(I.scene_in) ;

for k=1:length(s_filenames)
    
    %-- Read scene image
    scene_image = imread([I.scene_in filesep s_filenames{k}]) ;

    %-- Load rating structure
    load([I.rating_in filesep strrep(s_filenames{k},'.jpg','.mat')]) ;

    %-- Call build_meaning_map to generate map
    meaning_map = build_meaning_map(scene_array,scene_image) ;
    
    %-- Save raw map to file
    map_file = [I.map_out filesep strrep(s_filenames{k},'.jpg','.mat')] ;
    save(map_file,'meaning_map') ;
end

%% 030: Save map visuals and generate grayscale version

s_filenames = getFiles(I.map_out) ;

for k=1:length(s_filenames)

    %-- Load interact map 
    map = load([I.map_out filesep s_filenames{k}]) ;
    
    %-- Convert to grayscale (0-1)
    map_gray = mat2gray(map.meaning_map) ;
    
    %-- Save .mat file of grayscale image
    save([I.map_scaled_out filesep s_filenames{k}], 'map_gray') ;
    
    %-- Save image to file
    imwrite(map_gray,[I.map_visuals filesep strrep(s_filenames{k},'.mat','.png')]) ;

end

%%%%% END 

