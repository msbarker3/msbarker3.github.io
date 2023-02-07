function patch_pixel_match(scene,patch)
    
% PATCH_PIXEL_MATCH - Takes patch ratings as input and translates patches to
%       pixels in an image (parameters must match patch generation parameters).
%
% See also create_scene_patches

% (c) Visual Cognition Laboratory at the University of California, Davis
%
% 1.0.0 2020-08-25 GLR: Wrote it

%% 010: Define empty cell array for current scene and scale

%-- Change if your image dimensions are not 768x1024 (y,x)
pixel_array = cell(768,1024) ; 

%% 020: Unpack patch input structure

xy = patch.xy ;              % center points of patches
img_sz = patch.img_sz ;      % input image dimensions
img_name = patch.img_name ;  % input image name
cut_sz = patch.diameter ;    % patch diameter
output_dir = patch.out_dir ; % patch output directory
in_dir = patch.in_dir ;      % patch input directory

%% 030: Load patch data structure

load(fullfile(in_dir,[scene '.mat'])) ;

%% 040: Size up input image, define cut size, define output directory

%--Define cut size in pixels
circle_px = cut_sz ;

%--Destination directory for output images
dest = output_dir ;

%% 050: For each centroid (x,y) cut circular piece out from image

%--For each xy centroid in the image
for k = 1:size(xy,1)
    
    %--Define cut mask
    cut = [round(xy(k,1)) round(xy(k,2)) circle_px/2] ;
    [xx,yy] = ndgrid((1:img_sz(1))-cut(1),(1:img_sz(2))-cut(2));    
    mask = (xx.^2 + yy.^2)<cut(3)^2;

    [patch_y,patch_x] = find(mask) ; % Get pixels in mask
    for j = 1:length(patch_y) % For each x,y pixel pair
        if isempty(pixel_array{patch_y(j), patch_x(j)}) 
            %-- If cell is empty, store data
            %pixel_array{patch_y(j), patch_x(j)} = eval(['data.' scene '_' num2str(k)]) ;
            %!! grasp and meaning maps for gdesc0102 were made with different patch naming convention
            pixel_array{patch_y(j), patch_x(j)} = eval(['data.' scene num2str(k)]) ;
        else 
            %-- If data exists from overlapping patch, concatenate array
            %pixel_array{patch_y(j), patch_x(j)} = [pixel_array{patch_y(j), patch_x(j)} eval(['data.' scene '_' num2str(k)])];
            %!! grasp and meaning maps for gdesc0102 were made with different patch naming convention
            pixel_array{patch_y(j), patch_x(j)} = [pixel_array{patch_y(j), patch_x(j)} eval(['data.' scene num2str(k)])];
        end
    end  
    disp(['   -- Done with patch ' num2str(k) ' of ' num2str(size(xy,1))]) ;
end

%% 060: Save cell array containing patch data

rating_fname = [dest filesep [scene '.mat']] ;
save(rating_fname, 'pixel_array') ;
disp([' Rating pixel matrix saved to ' rating_fname]) ;

%%%%% END OF FUNCTION PATCH_PIXEL_MATCH.m