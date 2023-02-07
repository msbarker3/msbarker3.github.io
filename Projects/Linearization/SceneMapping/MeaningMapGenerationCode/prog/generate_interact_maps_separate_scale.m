% GENERATE_grasp_maps - Loads patch rating structure and image to
%      generate rating map
%
% See also rating_to_pixel, patch_pixel_match, build_meaning_map
% 
% (c) Visual Cognition Laboratory at the University of California, Davis
%
% 1.1.0 2020-08-25 GLR: Wrote it

%% 010: Define input directories

task = 'grasp' ;
exp = 'gdesc0102' ;
scale = {'coarse','fine'} ;

prefix = fullfile('C:\Users','gwenz') ;
I.path = fullfile(prefix,'Documents','GitHub','SceneMapping','MeaningMap_Generation_Code') ;   
I.scene_in = fullfile(I.path,'data','scene_images',exp) ; 
I.rating_in = {fullfile(I.path,'data','pixel_data',exp,task,'fine') 
               fullfile(I.path,'data','pixel_data',exp,task,'coarse')} ;
I.map_out = {fullfile(I.path,'data',exp,'grasp_maps','coarse','raw') 
             fullfile(I.path,'data',exp,'grasp_maps','fine','raw')} ;
I.map_visuals = {fullfile(I.path,'data',exp,'grasp_maps','coarse','img')
             fullfile(I.path,'data',exp,'grasp_maps','fine','img')} ;
I.map_scaled_out = {fullfile(I.path,'data',exp,'grasp_maps','coarse','scaled')
                    fullfile(I.path,'data',exp,'grasp_maps','fine','scaled')} ;

%% 020: Import scene files and generate maps

s_filenames = getFiles(I.rating_in{1}) ;

for k=1:length(s_filenames)
    for s=1:length(scale)

        %-- Read scene image
        scene_image = imread([I.scene_in filesep strrep(s_filenames{k},'.mat','.jpg')]) ;

        %-- Load rating structure
        load(fullfile(I.path,'data','pixel_data',exp,task,scale{s},s_filenames{k})) ;
    
        %-- Duplicate array to work with build_meaning_map
        scene_array = cell(768,1024,2) ;

        %--- Change dimensions for resolutions other than 768x1024
        for y = 1:768 % 1:image height 
            for x = 1:1024 % 1:image width
                scene_array{y,x,1} = pixel_array{y,x};
                scene_array{y,x,2} = pixel_array{y,x};
            end
        end  
    
        %-- Call build_meaning_map to generate map
        grasp_map = build_meaning_map(scene_array,scene_image) ;

        %-- Save raw map to file
        map_file = fullfile(I.path,'data',exp,'grasp_maps',scale{s},'raw',strrep(s_filenames{k},'.jpg','.mat')) ;
        save(map_file,'grasp_map') ;
    end
end

%% 030: Save map visuals and generate grayscale version

s_filenames = getFiles(I.map_out{1}) ;

for k=1:length(s_filenames)
    for s=1:length(scale)
        %-- Load interact map 
        
        map = load(fullfile(I.path,'data',exp,'grasp_maps',scale{s},'raw',s_filenames{k})) ;

        %-- Convert to grayscale (0-1)
        map_gray = mat2gray(map.grasp_map) ;

        %-- Save .mat file of grayscale image
        save(fullfile(I.path,'data',exp,'grasp_maps',scale{s},'scaled',s_filenames{k}), 'map_gray') ;

        %-- Save image to file
        imwrite(map_gray,fullfile(I.path,'data',exp,'grasp_maps',scale{s},'img',strrep(s_filenames{k},'.mat','.png'))) ;
    end
end

%%%%% END 

