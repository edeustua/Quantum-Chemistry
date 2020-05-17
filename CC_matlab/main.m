clear all
clc
close all

format long

addpath(genpath('/Users/karthik/Dropbox/Hartree Fock/hartree_fock/v4/CC_matlab'));
addpath(genpath('/Users/karthik/Dropbox/Davidson_methods/davidson_cheb_test/Davidson_matlab_test'));
addpath(genpath('/Users/karthik/Dropbox/Davidson_methods/davidson_cheb_test/GDav'));
addpath(genpath('/Users/karthik/Dropbox/Davidson_methods/davidson_cheb_test/Bchdav'));

%addpath(genpath('/Users/karthik/Desktop/CC_matlab_tests/h2o-pvdz/'));
%load h2o-pvdz-integrals.mat

addpath(genpath('/Users/karthik/Desktop/CC_matlab_tests/h2/'));
%load h2-pvdz-integrals.mat
load h2o-631g-eom-ccpy


sys_ucc = build_system_ucc(e1int,e2int,Nocc_a,Nocc_b);
sys_cc = build_system_cc(e1int,e2int,Nocc_a+Nocc_b);


% load h2o-pvdz-ccpy.mat
%sys_cc = build_system(VM,FM,occ,unocc,2);

%% UCCSD

% update: 4/6/20 - 
% there is still something wrong with UCC - errors on order of 10^-6... but accurate for the most part...
% problem seems to lie primarily in T2B with some errors in T2A and T2C

ccopts.diis_size = 3;
ccopts.maxit = 100;
ccopts.tol = 1e-8;
[t1a,t1b,t2a,t2b,t2c,Ecorr_ucc] = uccsd(sys_ucc,ccopts);

%%

E1A_exact = 9.944089519854425E-011;
E1B_exact = 9.944091634197451E-011;
E2A_exact =    -1.118149855483151E-002;
E2C_exact =    -1.118149857437544E-002;
E2B_exact =    -0.193074895116479;
E1A1A_exact =   -7.721105018602925E-005;
E1A1B_exact =   5.956425520525440E-004;
E1B1B_exact =   -7.721105255510347E-005;
Ecorr_exact = E1A_exact + E1B_exact + E2A_exact + E2B_exact + E2C_exact + E1A1A_exact + E1B1B_exact + E1A1B_exact;

E1A = einsum(sys.fa_ov,t1a,'me,em->');
E1B = einsum(sys.fb_ov,t1b,'me,em->');
E2A = 0.25*einsum(sys.vA_oovv,t2a,'mnef,efmn->');
E2C = 0.25*einsum(sys.vC_oovv,t2c,'mnef,efmn->');
E2B = einsum(sys.vB_oovv,t2b,'mnef,efmn->');
E1A1A = 0.5*einsum(einsum(sys.vA_oovv,t1a,'mnef,fn->me'),t1a,'me,em->');
E1B1B = 0.5*einsum(einsum(sys.vC_oovv,t1b,'mnef,fn->me'),t1b,'me,em->');
E1A1B = einsum(einsum(sys.vB_oovv,t1a,'mnef,em->nf'),t1b,'nf,fn->');

Ecorr = E1A + E1B + E2A + E2B + E2C + E1A1A + E1B1B+ E1A1B;

Ecorr-Ecorr_exact

        
%% CCSD

ccopts.diis_size = 3;
ccopts.maxit = 100;
ccopts.tol = 1e-9;

[t1,t2,Ecorr_cc] = ccsd(sys_cc,ccopts);


%% Build HBar

[HBar] = build_HBar(t1,t2,sys_cc); 
[D, Dia, Dijab] = HBar_CCSD_diagonal(HBar, t1, t2, sys_cc);
[Nocc,Nunocc] = size(HBar{1}{1,2}); Nov = Nocc*Nunocc; Hbar_dim = Nov + Nov^2;

%% Left-CCSD ground state

ccopts.diis_size = 5;
ccopts.maxit = 200;
ccopts.tol = 1e-9;

[lambda1,lambda2,lcc_resid] = lccsd(0.0,[],t1,t2,HBar,Dia,Dijab,sys_cc,ccopts);


%% EOMCCSD

eomopts.nroot = 20;
eomopts.maxit = 1000;
eomopts.tol = 1e-6;
eomopts.nvec_per_root = 1;
eomopts.max_nvec_per_root = 10;
eomopts.flag_verbose = 1;
eomopts.init_guess = 'cis';
eomopts.thresh_vec = 1e-5;

[Rvec, omega, r0, eom_residual] = eomccsd(HBar,t1,t2,sys_cc,eomopts);

% Using iterative diagonalization solvers of Yunkai Zhou

% eomopts.tol = 1e-4;
% eomopts.Matsymm = 1;
% eomopts.vmax = max(2*nroot, 20);
% eomopts.itmax = 100;
% eomopts.nkeep = nroot;
% eomopts.v0 = rand(Nocc*Nunocc+Nocc^2*Nunocc^2,1);
% eomopts.displ = 2;
% eomopts.les_solver = 31; % 71 jacobi-davidson minres does not work!

% HRvec = @(x) HR_matvec(x,HBar);
% [eval, V, nconv, history] = gdav(HRvec, Nocc*Nunocc+Nocc^2*Nunocc^2, nroot, 'SM',eomopts);
% [eval, V, nconv, history] = bchdav('HR_matvec', HBar_dim, nroot);

%% Left EOMCCSD
 

ccopts.maxit = 80;
ccopts.diis_size = 5;
ccopts.tol = 1e-9;

L = zeros(size(Rvec));
for i = 1:size(Rvec,2)
    
    [lambda_e1,lambda_e2,lcc_resid] = lccsd(omega(i),Rvec(:,i),t1,t2,HBar,Dia,Dijab,sys_cc,ccopts);
    
    L(:,i) = cat(1,lambda_e1(:),lambda_e2(:));
    
end



%%
for i = 1:length(e)
    [x1, x2] = build_L_HBar(reshape(L(1:Nov,i),Nocc,Nunocc), reshape(L(Nov+1:end,i),Nocc,Nocc,Nunocc,Nunocc),...
                        HBar, FM, VM, 0, 0);
                    
    xchk = cat(1,x1(:),x2(:));
    
    res = norm(xchk - e(i)*L(:,i));
    
    fprintf('\nRoot-%d      |LH-EL| = %4.8f\n',i,res)
end
%%


L = L/(L'*R);






