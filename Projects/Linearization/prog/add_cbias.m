function center_image = add_cbias(target)

%-- Use GBVS filter to apply exact same bias to other maps
GBVS_CB = load('GBVS_CenterBias') ;
center_image = mat2gray((target.*GBVS_CB.CenterBias)) ;

% m = 100 ;
% cm_inferno=magma(m) ;
% imagesc(mat2gray(GBVS_CB.CenterBias)) ;  colormap(cm_inferno) ;
% set(gca,'xtick',[],'ytick',[],'xticklabels',[],'yticklabels',[]) ;
% set(gca,'units','normalized','position',[0 0 1 1]) ;
% save2pdf('GBVS_centerBias.pdf',gcf,600)

% %-- Original version GBVS (does not preserve scale)
% invCB = load('invCenterBias');
% invCB = invCB.invCenterBias;
% centerNewWeight = 400;
% invCB = centerNewWeight + (1-centerNewWeight) * invCB;
% invCB = imresize(invCB,size(target));
% output2 = target .* invCB;
% center_image = mat2gray(output2) ;

% %-- Method 2 preserves scale
% mask_size = size(target)+1 ;        % must be an odd number
% R = make_grid(mask_size(1),1) ;     % distance from image center px
% C = make_grid(mask_size(2),1) ;     % distance from image center px
% 
% [X,Y] = meshgrid(C,R) ;  
% RC = sqrt(X.^2 + Y.^2) ;    
% RC = mat2gray(RC) ;
% RC = imresize(RC,[768 1024]) ;
% center_bias = imcomplement(RC) ;
% 
% % then apply center bias
% bias_weight = .1 ;
% center_image = bias_weight*center_bias + (1-bias_weight)*norm_map;
% imshow(center_image)

% %-- Debug and try to equate methods
% imshowpair(output1,output2) ;
% diff_val = abs(output1-output2) ;
% diff_val = sum(diff_val(:)) ;
% fprintf('%.2f\n',diff_val) ;
