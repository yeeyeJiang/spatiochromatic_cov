function c_hat = estimator(dir, s, d, varargin)
    % Compute 9 estimates of spatio-chromatic covariances at distance d
    %----------------------------
    % INPUT
    %----------------------------
    % dir: cell, whose components are the absolute paths of image files
    % s: scalar, step size in location sampling
    % d: scalar, neighbour's distance
    % gamma(optional): scalar, the gamma parameter for Michaelis-Menten
    % transformation. If gamma is not provided, the function will not perform transformation on images. 
    % mu(optional): vector of length 3, whose components are the average
    % intensities for Red, Blue, Green channels, respectively.
    % seed(optional): seed, for repreating the results. The locations of
    % neighbours are sampled randomly each time calling this function.
    %----------------------------
    % OUTPUT
    %----------------------------
    % c_hat: vector, estimates of spatio-chromatic covariances, in the
    % order: RR, RG,RB,GR,GG,GB,BR,BG,BB 
    %----------------------------
    
    % input setting
    p = inputParser;
     
    addParameter(p,'mu', nan) 
    addParameter(p,'gamma', nan)
    addParameter(p,'seed', nan)
        
    parse(p,varargin{:})
    

    % get parameters
    assert(~mod(s,1)) 
    N = length(dir);
    
    im = im2single(imread(dir{1}));
    [h,w,~] = size(im);  
        
    assert(d < min(h/s,w/s)) % for simplicity, to assure that every pixel has 
                                   % at least two valid neighbours                        
    % sample centering and neighbouring positions
    % centers
    ctr_x = 1:s:h; %row index
    ctr_y = 1:s:w; %col index
    [ctr_y,ctr_x] = meshgrid(ctr_y,ctr_x);  
    ctr_y = ctr_y(:); ctr_x = ctr_x(:);
    
    K = length(ctr_x);
    
    % neighbours
    if ~isnan(p.Results.seed)
        [nb_x,nb_y] = nb_generator(ctr_x,ctr_y,h,w,d,p.Results.seed);
    else
        [nb_x,nb_y] = nb_generator(ctr_x,ctr_y,h,w,d);
    end   
    
    % calculate c_hat(u,v,d)
    Ix = zeros(length(ctr_x),9, 'single'); 
    Ic = zeros(length(ctr_x),3, 'single'); In = Ic;
    for i = 1:N
        
        im = im2single(imread(dir{i}));
        if ~isnan(p.Results.gamma)
            mm_eq = @(x,gamma,mu) 1./(1+(mu./x).^gamma);
            im(:,:,1) = mm_eq(im(:,:,1),p.Results.gamma,p.Results.mu(1)); 
            im(:,:,2) = mm_eq(im(:,:,2),p.Results.gamma,p.Results.mu(2)); 
            im(:,:,3) = mm_eq(im(:,:,3),p.Results.gamma,p.Results.mu(3)); 
        end
        
        for u = 1:3
            im_u = im(:,:,u);
            Ic(:,u) = Ic(:,u) + im_u((ctr_x-1).*h+ctr_y); % mean for all centering postions
            In(:,u) = In(:,u) + im_u((nb_x-1).*h+nb_y); % mean for all neighbouring postions
            for v = 1:3  
                im_v = im(:,:,v);
                Ix(:,(u-1)*3+v) = Ix(:,(u-1)*3+v) + im_u((ctr_x-1).*h+ctr_y).*im_v((nb_x-1).*h+nb_y); % cross term
            end
        end
    end
          
    c_hat = 1:9;
    for u = 1:3
        for v = 1:3
             tmp = Ix(:,(u-1)*3+v) - (Ic(:,u).*In(:,v))./N;
             c_hat((u-1)*3+v) = sum(tmp)/(N-1)/K;                
        end
    end

end