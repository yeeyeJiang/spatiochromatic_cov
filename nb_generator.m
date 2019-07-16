function [nb_x,nb_y] = nb_generator(ctr_x,ctr_y,h,w,d,sd)    
    % Generate the coordinates of neighbours, given the ones of centers
    % Rule: randomly choose one valid neighbour from TOP, BOTTOM, LEFT and
    % RIGHT with identical probabilities
    %----------------------------
    % INPUT
    %----------------------------
    % ctr_x: vector, row index of centering pixel
    % ctr_y: vector, column index of centering pixel
    % h: height of image domain
    % w: weight of image domain
    % d: neighbour's distance
    % sd(optional): seed, for repreating the results. The locations of
    % neighbours are sampled randomly each time calling this function.
    %----------------------------
    % OUTPUT
    %----------------------------
    % nb_x: vector(same dimension as ctr_x), row index of neighbour
    % nb_y: vector(same dimension as ctr_x), column index of neighbour
    %----------------------------
    
    assert(length(ctr_x) == length(ctr_y))

    nb_x = ctr_x; nb_y = ctr_y;
    
    % generate displacements
    displ_x = randi(2,length(ctr_x),1,'single') - 1; 
    ind = displ_x == 1;  % row displacement
    if nargin == 6, rng(sd), end
    displ_x(ind) = (randi(2,sum(ind),1,'single')-1.5).*2.*d; 
    
    displ_y = zeros(length(ctr_x),1,'single'); 
    ind = displ_x == 0;  % column displacement
    if nargin == 6, rng(sd), end
    displ_y(ind) = (randi(2,sum(ind),1,'single')-1.5).*2.*d; 
    
    % generate random neighbours
    nb_x = nb_x + displ_x; nb_y = nb_y + displ_y;    
    
    % deal with invalid neighbours
    ind = or(nb_x < 1 , nb_x > h);
    nb_x(ind) = nb_x(ind) - 2.*displ_x(ind);
        
    ind = or(nb_y < 1 , nb_y > w);
    nb_y(ind) = nb_y(ind) - 2.*displ_y(ind);                                                                           
    
end