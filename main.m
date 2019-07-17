% -------------------------------------------
% Theoretical upper bound kernel w.r.t <<P>> 
% -------------------------------------------
h = 1288; w = 1936;

s = 1:50;
P = (fix((h-1)./s)+1).*(fix((w-1)./s)+1);

beta = -0.0026;
assert(beta < 0)

Knl_up = s;
for i = 1:length(s)
    knl_up = 1 - exp(beta*(h-1+s(i))); % define the kernel of upper bound
    knl_up = s(i)*knl_up/(1-exp(beta*s(i)))/(h-1);
    Knl_up(s(i)) = knl_up;
end
lim = (exp(beta*(h-1))-1)/beta/(h-1);

% visualization and save
figure;
p = plot(P,Knl_up,'-o');
hold on
plot(P, repelem(lim,length(P)),'--');
hold off
xlabel('P', 'Interpreter','latex')
ylabel('Theoretical upper bound kernel', 'Interpreter','latex')
 
%p = ancestor(p, 'figure');
%set(p, 'Units', 'Inches', 'Position', [0, 0, 9.125*1.5, 6.25*1.5], 'PaperUnits', 'Inches', 'PaperSize', [9.125*1.5, 6.25*1.5])
%saveas(p,'fig.pdf')



% ---------------------------------------
% Validations of estimators’ properties 
% ---------------------------------------
abs_path = '~';  % absolute path of the database folder
s = 1:50;
n0 = 2;

C_hat = zeros(floor(701/n0),length(s),9,'single');
for i = 1:floor(701/n0) 
    sprintf("This is the %dth realization", i)
    for j = 1:length(s)
    C_hat(i,j,:) = estimator(strcat(abs_path,dtList_filtered_perm((i-1)*n0+1:i*n0)), s(j), 0);
    end   
end

% visualization and save
plot_save(1:length(C_hat(:,2,1)),C_hat(:,2,1),'-','Realizations','$\hat{\mathbf{c}}^0_{RR}$',1)
plot_save(P,var(C_hat(:,:,1)),'-','P','Sample Variances of $\hat{\mathbf{c}}^0_{RR}$',1)



% ------------
% Regression
% ------------
s=2;
dm=0; dM=280;
load('dtList_filtered_permuted.mat') % cell: names of image files

C_hat = zeros(dM-dm+1,9,'single');
tic
count=1;
for d = dm:dM
    C_hat(count,:) = estimator(strcat(abs_path,dtList_filtered_perm), s, d);
    count=count+1;
end   
%save('C_hat_raw.mat','C_hat')
toc

% visualization and save
plot_save(dm:dM,log(C_hat),'-','pixel distance','log(cov) estimates',0)


% fit the model with OLS estimation
dm=80; dM=240;

block = cell(1); block{1} = [repelem(1,dM-dm+1);dm:dM]';

X = repmat(block,1,9); X = blkdiag(X{:});
C_hat = C_hat(dm+1:dM+1,:); y=log(C_hat(:));
    
est_ols = (X'*X)\(X'*y);
sprintf('%.5f, ', est_ols(2:2:end)) % they are the slopes for RR, RG, RB, GR, GG, GB, BR, BG, BB respectively



% ------------------
% MM transformation
% ------------------
% parameter setting
s=2; n0=2;
dm=0; dM=280;

gammaList=0.1:0.1:1;


% get the average intensities for R,G,B channels
mu_RGB = [0 0 0];
for i = 1:length(dtList_filtered_perm)
    im = im2single(imread(strcat(abs_path,dtList_filtered_perm{i})));  
    mu_RGB = mu_RGB + mean(reshape(im,[h*w,3]));
end
mu_RGB = mu_RGB./length(dtList_filtered_perm);
clear im


C_hat = zeros(dM-dm+1,9,'single');
for gamma = gammaList
    sprintf('The current gamma is: %.1f \n', gamma)
    tic
    count=1;
    for d = dm:dM
        C_hat(count,:) = estimator(strcat(abs_path,dtList_filtered_perm), s, d, 'mu', mu_RGB, 'gamma', gamma);
        count=count+1;
    end   
    save(strcat('C_hat_',num2str(gamma),'.mat'),'C_hat')
    toc
end

% visualization and save
plot_save(dm:dM,log(C_hat),'-','pixel distance','log(cov) estimates',0)

